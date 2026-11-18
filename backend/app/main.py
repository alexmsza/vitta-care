from datetime import datetime, timedelta, timezone
from typing import List, Optional, Tuple

from fastapi import BackgroundTasks, Depends, FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from passlib.context import CryptContext
from sqlalchemy import or_, select
from sqlalchemy.orm import Session

from app import models, schemas
from app.core.auth import create_access_token, require_active_user, require_admin
from app.core.database import Base, engine, get_db
from app.core.mail import send_registration_email

Base.metadata.create_all(bind=engine)

app = FastAPI(title="Vitta API", version="2.7.0")

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/")
def read_root():
    return {"message": "Vitta API", "status": "online", "version": "2.7.0"}


@app.get("/health")
def health_check():
    return {"status": "ok"}


@app.get("/version")
def check_version():
    return {
        "latest_version": "1.0.1",
        "force_update": False,
        "download_url": "https://example.com/downloads/vitta.apk",
    }


@app.post("/auth/register", response_model=schemas.Token)
async def register(
    user: schemas.UserRegister,
    background_tasks: BackgroundTasks,
    db: Session = Depends(get_db),
):
    if user.role.lower() == "admin":
        raise HTTPException(status_code=403, detail="Registro de administrador não permitido.")

    existing_user = db.execute(
        select(models.User).where(models.User.email == user.email)
    ).scalar_one_or_none()
    if existing_user:
        raise HTTPException(status_code=400, detail="Email já cadastrado.")

    new_user = models.User(
        email=user.email,
        name=user.name,
        hashed_password=pwd_context.hash(user.password),
        role=user.role,
        phone=user.phone,
        specialty=user.specialty,
        crm_coren=user.crm_coren,
        is_active=False,
    )
    db.add(new_user)
    db.commit()
    db.refresh(new_user)

    background_tasks.add_task(send_registration_email, user.email, user.name, user.role)

    token = create_access_token(data={"sub": str(new_user.id)})
    return schemas.Token(
        access_token=token,
        role=new_user.role,
        user_id=new_user.id,
        user_name=new_user.name,
    )


@app.post("/auth/login", response_model=schemas.Token)
def login(user: schemas.UserLogin, db: Session = Depends(get_db)):
    db_user = db.execute(
        select(models.User).where(models.User.email == user.email)
    ).scalar_one_or_none()
    if not db_user or not pwd_context.verify(user.password, db_user.hashed_password):
        raise HTTPException(status_code=401, detail="Credenciais inválidas.")

    if not db_user.is_active:
        raise HTTPException(
            status_code=403,
            detail="Sua conta está em análise. Você receberá um email quando for aprovada.",
        )

    token = create_access_token(data={"sub": str(db_user.id)})
    return schemas.Token(
        access_token=token,
        role=db_user.role,
        user_id=db_user.id,
        user_name=db_user.name,
    )


@app.get("/profile/me", response_model=schemas.UserResponse)
def get_my_profile(current_user: models.User = Depends(require_active_user)):
    return current_user


@app.put("/profile/me", response_model=schemas.UserResponse)
def update_my_profile(
    updates: schemas.UserUpdate,
    current_user: models.User = Depends(require_active_user),
    db: Session = Depends(get_db),
):
    update_data = updates.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(current_user, field, value)
    db.commit()
    db.refresh(current_user)
    return current_user


@app.get("/shifts", response_model=List[schemas.ShiftResponse])
def get_shifts(
    skip: int = 0,
    limit: int = 100,
    _: models.User = Depends(require_active_user),
    db: Session = Depends(get_db),
):
    stmt = (
        select(models.Shift)
        .where(models.Shift.status == "open")
        .order_by(models.Shift.is_urgent.desc(), models.Shift.date_start.asc())
        .offset(skip)
        .limit(limit)
    )
    return db.execute(stmt).scalars().all()


@app.get("/shifts/my", response_model=List[schemas.ShiftResponse])
def get_my_shifts(
    status: Optional[str] = None,
    skip: int = 0,
    limit: int = 50,
    current_user: models.User = Depends(require_active_user),
    db: Session = Depends(get_db),
):
    stmt = select(models.Shift).where(
        models.Shift.professional_id == current_user.id,
        models.Shift.status != "cancelled",
    )

    if status in {"assigned", "completed"}:
        stmt = stmt.where(models.Shift.status == status)

    stmt = stmt.order_by(models.Shift.date_start.desc()).offset(skip).limit(limit)
    return db.execute(stmt).scalars().all()


@app.post("/shifts", response_model=schemas.ShiftResponse)
def create_shift(
    shift: schemas.ShiftCreate,
    _: models.User = Depends(require_admin),
    db: Session = Depends(get_db),
):
    shift_data = shift.model_dump()

    # Urgency pricing:
    # `is_urgent` is the single source of truth for urgent shifts. Programmed
    # and urgent shifts share the same Shift object; only this boolean changes
    # tag/display/sorting. When true, we apply a progressive multiplier to the
    # stored `value`: the closer the shift start, the higher the multiplier.
    # Frontend must display `value` as already final and must not multiply again.
    if shift_data.get("is_urgent"):
        hours_until_start = (
            shift.date_start.replace(tzinfo=None) - datetime.utcnow()
        ).total_seconds() / 3600
        if hours_until_start <= 2:
            multiplier = 1.75
        elif hours_until_start <= 6:
            multiplier = 1.50
        elif hours_until_start <= 24:
            multiplier = 1.35
        else:
            multiplier = 1.25
        shift_data["value"] = round(shift.value * multiplier, 2)

    if shift.patient is not None:
        shift_data["patient"] = shift.patient.model_dump()

    new_shift = models.Shift(**shift_data)
    db.add(new_shift)
    db.commit()
    db.refresh(new_shift)
    return new_shift


@app.post("/shifts/{shift_id}/apply")
def apply_for_shift(
    shift_id: int,
    current_user: models.User = Depends(require_active_user),
    db: Session = Depends(get_db),
):
    if current_user.role not in {"professional", "admin"}:
        raise HTTPException(
            status_code=403,
            detail="Apenas profissionais podem aceitar plantoes.",
        )

    shift = db.execute(
        select(models.Shift).where(models.Shift.id == shift_id)
    ).scalar_one_or_none()
    if not shift:
        raise HTTPException(status_code=404, detail="Plantão não encontrado.")
    if shift.status != "open":
        raise HTTPException(status_code=409, detail="Plantão não está disponível.")

    shift.status = "assigned"
    shift.professional_id = current_user.id
    db.commit()

    # TODO: criar Conversation para shifts quando o modelo Shift ganhar family_id.
    # Shifts são criados pelo admin, não por famílias, então não há contraparte
    # natural para o chat. Criar Conversation com admin.id como family_id seria
    # errado (admin veria todas as conversas de turno) e o fallback para
    # current_user.id criaria uma conversa de um usuário consigo mesmo.

    return {"message": "Plantao aceito com sucesso!"}


@app.get("/service-requests/mine", response_model=List[schemas.ServiceRequestResponse])
def get_my_service_requests(
    current_user: models.User = Depends(require_active_user),
    db: Session = Depends(get_db),
):
    stmt = (
        select(models.ServiceRequest)
        .where(models.ServiceRequest.family_id == current_user.id)
        .where(models.ServiceRequest.status != "cancelled")
        .order_by(models.ServiceRequest.created_at.desc())
    )
    requests = db.execute(stmt).scalars().all()
    return [schemas.ServiceRequestResponse.from_orm_with_name(item) for item in requests]


@app.get("/service-requests/nearby", response_model=List[schemas.ServiceRequestResponse])
def get_nearby_service_requests(
    current_user: models.User = Depends(require_active_user),
    db: Session = Depends(get_db),
):
    if current_user.role not in {"professional", "admin"}:
        raise HTTPException(
            status_code=403,
            detail="Apenas profissionais podem ver o pool de solicitações.",
        )

    stmt = (
        select(models.ServiceRequest)
        .where(models.ServiceRequest.status == "searching")
        .order_by(models.ServiceRequest.created_at.desc())
    )
    requests = db.execute(stmt).scalars().all()
    return [schemas.ServiceRequestResponse.from_orm_with_name(item) for item in requests]


@app.get("/service-requests/accepted", response_model=List[schemas.ServiceRequestResponse])
def get_accepted_service_requests(
    current_user: models.User = Depends(require_active_user),
    db: Session = Depends(get_db),
):
    # Retorna lista vazia para family/admin — só profissionais têm solicitações atribuídas
    if current_user.role not in {"professional", "admin"}:
        return []

    stmt = (
        select(models.ServiceRequest)
        .where(models.ServiceRequest.professional_id == current_user.id)
        .where(models.ServiceRequest.status.in_(["matched", "in_progress"]))
        .order_by(models.ServiceRequest.matched_at.desc())
    )
    requests = db.execute(stmt).scalars().all()
    return [schemas.ServiceRequestResponse.from_orm_with_name(item) for item in requests]


@app.post("/service-requests", response_model=schemas.ServiceRequestResponse, status_code=201)
def create_service_request(
    data: schemas.ServiceRequestCreate,
    current_user: models.User = Depends(require_active_user),
    db: Session = Depends(get_db),
):
    if current_user.role != "family":
        raise HTTPException(
            status_code=403,
            detail="Apenas famílias podem criar solicitações.",
        )

    request = models.ServiceRequest(
        family_id=current_user.id,
        patient_name=data.patient_name,
        address=data.address,
        lat=data.lat,
        lng=data.lng,
        notes=data.notes,
        status="searching",
    )
    db.add(request)
    db.commit()
    db.refresh(request)
    return schemas.ServiceRequestResponse.from_orm_with_name(request)


@app.post("/service-requests/{request_id}/accept", response_model=schemas.ServiceRequestResponse)
def accept_service_request(
    request_id: int,
    current_user: models.User = Depends(require_active_user),
    db: Session = Depends(get_db),
):
    if current_user.role not in {"professional", "admin"}:
        raise HTTPException(
            status_code=403,
            detail="Apenas profissionais podem aceitar solicitações.",
        )

    request = db.get(models.ServiceRequest, request_id)
    if request is None:
        raise HTTPException(status_code=404, detail="Solicitação não encontrada.")
    if request.status != "searching":
        raise HTTPException(status_code=409, detail="Solicitação não está mais disponível.")

    request.status = "matched"
    request.professional_id = current_user.id
    request.matched_at = datetime.now(timezone.utc)
    db.commit()
    db.refresh(request)

    existing_conversation = db.execute(
        select(models.Conversation).where(
            models.Conversation.request_id == request.id,
            models.Conversation.request_type == "service_request",
        )
    ).scalar_one_or_none()
    if existing_conversation is None:
        db.add(
            models.Conversation(
                request_id=request.id,
                request_type="service_request",
                family_id=request.family_id,
                professional_id=current_user.id,
            )
        )
        db.commit()

    return schemas.ServiceRequestResponse.from_orm_with_name(request)


@app.post("/service-requests/{request_id}/cancel")
def cancel_service_request(
    request_id: int,
    current_user: models.User = Depends(require_active_user),
    db: Session = Depends(get_db),
):
    request = db.get(models.ServiceRequest, request_id)
    if request is None:
        raise HTTPException(status_code=404, detail="Solicitação não encontrada.")
    if request.family_id != current_user.id and current_user.role != "admin":
        raise HTTPException(
            status_code=403,
            detail="Sem permissão para cancelar essa solicitação.",
        )
    if request.status not in {"searching", "matched"}:
        raise HTTPException(
            status_code=409,
            detail=f"Não é possível cancelar solicitação com status '{request.status}'.",
        )

    request.status = "cancelled"
    conversation = db.execute(
        select(models.Conversation).where(
            models.Conversation.request_id == request_id,
            models.Conversation.request_type == "service_request",
        )
    ).scalar_one_or_none()
    if conversation is not None:
        conversation.is_closed = True

    db.commit()
    return {"message": "Solicitação cancelada com sucesso.", "id": request_id}


def _resolve_patient_name_and_visit_date(
    conversation: models.Conversation,
    db: Session,
) -> Tuple[Optional[str], Optional[datetime]]:
    patient_name: Optional[str] = None
    visit_date: Optional[datetime] = None

    if conversation.request_type == "service_request":
        service_request = db.get(models.ServiceRequest, conversation.request_id)
        if service_request is not None:
            patient_name = service_request.patient_name
    elif conversation.request_type == "shift":
        shift = db.get(models.Shift, conversation.request_id)
        if shift is not None:
            if isinstance(shift.patient, dict):
                patient_name = shift.patient.get("name") or shift.hospital_name
            else:
                patient_name = shift.hospital_name
            visit_date = shift.date_start

    return patient_name, visit_date


def _conversation_to_response(
    conversation: models.Conversation,
    current_user_id: int,
    db: Session,
) -> schemas.ConversationResponse:
    last_message = conversation.messages[-1] if conversation.messages else None
    unread_count = sum(
        1 for message in conversation.messages if message.sender_id != current_user_id and not message.read
    )
    patient_name, visit_date = _resolve_patient_name_and_visit_date(conversation, db)

    return schemas.ConversationResponse(
        id=conversation.id,
        request_id=conversation.request_id,
        request_type=conversation.request_type,
        family_id=conversation.family_id,
        professional_id=conversation.professional_id,
        family_name=conversation.family.name if conversation.family is not None else "",
        professional_name=conversation.professional.name if conversation.professional is not None else "",
        patient_name=patient_name,
        visit_date=visit_date,
        last_message=last_message.content if last_message is not None else None,
        last_message_at=last_message.sent_at if last_message is not None else None,
        unread_count=unread_count,
    )


def _normalize_sort_datetime(value: Optional[datetime]) -> datetime:
    if value is None:
        return datetime.min
    return value.replace(tzinfo=None)


@app.get("/chat/conversations/by-request/{request_id}", response_model=schemas.ConversationResponse)
def get_conversation_by_request(
    request_id: int,
    request_type: str = "service_request",
    current_user: models.User = Depends(require_active_user),
    db: Session = Depends(get_db),
):
    if request_type not in {"service_request", "shift"}:
        raise HTTPException(status_code=400, detail="request_type invalido.")

    conversation = db.execute(
        select(models.Conversation).where(
            models.Conversation.request_id == request_id,
            models.Conversation.request_type == request_type,
        )
    ).scalar_one_or_none()
    if conversation is None:
        raise HTTPException(status_code=404, detail="Conversa nao encontrada para esta solicitacao.")
    if current_user.id not in {conversation.family_id, conversation.professional_id}:
        raise HTTPException(status_code=403, detail="Acesso negado.")

    return _conversation_to_response(conversation, current_user.id, db)


@app.get("/chat/conversations/{conversation_id}/messages", response_model=List[schemas.MessageResponse])
def get_conversation_messages(
    conversation_id: int,
    skip: int = 0,
    limit: int = 50,
    current_user: models.User = Depends(require_active_user),
    db: Session = Depends(get_db),
):
    conversation = db.get(models.Conversation, conversation_id)
    if conversation is None:
        raise HTTPException(status_code=404, detail="Conversa nao encontrada.")
    if current_user.id not in {conversation.family_id, conversation.professional_id}:
        raise HTTPException(status_code=403, detail="Acesso negado.")

    has_read_updates = False
    for message in conversation.messages:
        if message.sender_id != current_user.id and not message.read:
            message.read = True
            has_read_updates = True
    if has_read_updates:
        db.commit()

    stmt = (
        select(models.Message)
        .where(models.Message.conversation_id == conversation_id)
        .order_by(models.Message.sent_at.asc())
        .offset(skip)
        .limit(limit)
    )
    messages = db.execute(stmt).scalars().all()
    return [
        schemas.MessageResponse(
            id=message.id,
            conversation_id=message.conversation_id,
            sender_id=message.sender_id,
            sender_name=message.sender.name if message.sender is not None else "",
            sender_role=message.sender.role if message.sender is not None else "",
            content=message.content,
            sent_at=message.sent_at,
            read=message.read,
        )
        for message in messages
    ]


@app.post(
    "/chat/conversations/{conversation_id}/messages",
    response_model=schemas.MessageResponse,
    status_code=201,
)
def send_chat_message(
    conversation_id: int,
    body: schemas.MessageCreate,
    current_user: models.User = Depends(require_active_user),
    db: Session = Depends(get_db),
):
    conversation = db.get(models.Conversation, conversation_id)
    if conversation is None:
        raise HTTPException(status_code=404, detail="Conversa nao encontrada.")
    if current_user.id not in {conversation.family_id, conversation.professional_id}:
        raise HTTPException(status_code=403, detail="Acesso negado.")
    if conversation.is_closed:
        raise HTTPException(status_code=409, detail="Esta conversa foi encerrada.")

    content = body.content.strip()
    if not content:
        raise HTTPException(status_code=400, detail="Mensagem nao pode ser vazia.")
    if len(content) > 1000:
        raise HTTPException(status_code=400, detail="Mensagem excede 1000 caracteres.")

    message = models.Message(
        conversation_id=conversation_id,
        sender_id=current_user.id,
        content=content,
    )
    db.add(message)
    db.commit()
    db.refresh(message)

    return schemas.MessageResponse(
        id=message.id,
        conversation_id=message.conversation_id,
        sender_id=message.sender_id,
        sender_name=current_user.name,
        sender_role=current_user.role,
        content=message.content,
        sent_at=message.sent_at,
        read=message.read,
    )


@app.get("/chat/conversations", response_model=List[schemas.ConversationResponse])
def list_conversations(
    current_user: models.User = Depends(require_active_user),
    db: Session = Depends(get_db),
):
    stmt = (
        select(models.Conversation)
        .where(
            or_(
                models.Conversation.family_id == current_user.id,
                models.Conversation.professional_id == current_user.id,
            )
        )
        .order_by(models.Conversation.created_at.desc())
    )
    conversations = db.execute(stmt).scalars().all()

    response = [_conversation_to_response(conversation, current_user.id, db) for conversation in conversations]
    response.sort(key=lambda item: _normalize_sort_datetime(item.last_message_at), reverse=True)
    return response


@app.post("/auth/forgot-password")
async def forgot_password(
    body: schemas.ForgotPasswordRequest,
    background_tasks: BackgroundTasks,
    db: Session = Depends(get_db),
):
    import secrets as secrets_module

    user = db.execute(
        select(models.User).where(models.User.email == body.email)
    ).scalar_one_or_none()
    response = {"message": "Se o email existir, você receberá um código de recuperação."}
    if not user:
        return response

    reset_code = str(secrets_module.randbelow(900000) + 100000)
    user.reset_code = reset_code
    user.reset_code_expires = datetime.now(timezone.utc).replace(tzinfo=None) + timedelta(
        minutes=15
    )
    db.commit()

    from app.core.mail import send_password_reset_email

    background_tasks.add_task(send_password_reset_email, user.email, user.name, reset_code)
    return response


@app.post("/auth/reset-password")
def reset_password(body: schemas.PasswordResetRequest, db: Session = Depends(get_db)):
    user = db.execute(
        select(models.User).where(models.User.email == body.email)
    ).scalar_one_or_none()
    if not user or user.reset_code != body.reset_code:
        raise HTTPException(status_code=400, detail="Código inválido ou expirado.")

    now = datetime.now(timezone.utc).replace(tzinfo=None)
    if not user.reset_code_expires or user.reset_code_expires < now:
        raise HTTPException(status_code=400, detail="Código expirado. Solicite um novo.")

    user.hashed_password = pwd_context.hash(body.new_password)
    user.reset_code = None
    user.reset_code_expires = None
    db.commit()
    return {"message": "Senha alterada com sucesso!"}


@app.get("/admin/pending-users", response_model=List[schemas.UserResponse])
def get_pending_users(
    _: models.User = Depends(require_admin),
    db: Session = Depends(get_db),
):
    stmt = select(models.User).where(models.User.is_active == False)
    return db.execute(stmt).scalars().all()


@app.post("/admin/approve-user/{user_id}")
async def approve_user(
    user_id: int,
    background_tasks: BackgroundTasks,
    _: models.User = Depends(require_admin),
    db: Session = Depends(get_db),
):
    user = db.execute(
        select(models.User).where(models.User.id == user_id)
    ).scalar_one_or_none()
    if not user:
        raise HTTPException(status_code=404, detail="Usuário não encontrado.")

    user.is_active = True
    db.commit()

    from app.core.mail import send_approval_email

    background_tasks.add_task(send_approval_email, user.email, user.name, True)
    return {"message": "Usuário aprovado com sucesso.", "user_id": user_id}


@app.post("/admin/reject-user/{user_id}")
async def reject_user(
    user_id: int,
    background_tasks: BackgroundTasks,
    _: models.User = Depends(require_admin),
    db: Session = Depends(get_db),
):
    user = db.execute(
        select(models.User).where(models.User.id == user_id)
    ).scalar_one_or_none()
    if not user:
        raise HTTPException(status_code=404, detail="Usuário não encontrado.")

    from app.core.mail import send_approval_email

    background_tasks.add_task(send_approval_email, user.email, user.name, False)

    db.delete(user)
    db.commit()
    return {"message": "Usuário rejeitado e removido.", "user_id": user_id}
