"""
Script de mock data para a Vitta.

Uso:
    docker-compose exec api python seed_mock.py
"""

from datetime import datetime, timedelta
import random

from passlib.context import CryptContext

from app import models
from app.core.database import SessionLocal

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


def seed_mock_data():
    db = SessionLocal()

    print("Iniciando seed de dados mockados...")

    print("Limpando dados antigos...")
    db.query(models.Message).delete()
    db.query(models.Conversation).delete()
    db.query(models.ServiceRequest).delete()
    db.query(models.Shift).delete()
    db.query(models.User).filter(models.User.role != "admin").delete()
    db.commit()

    print("\nCriando usuarios de teste...")

    admin = db.query(models.User).filter(models.User.email == "admin@vitta.com").first()
    if not admin:
        admin = models.User(
            name="Admin Vitta",
            email="admin@vitta.com",
            hashed_password=pwd_context.hash("admin123"),
            role="admin",
            is_active=True,
        )
        db.add(admin)
        print("  Admin criado")

    professionals = [
        {
            "name": "Dr. Carlos Mendes",
            "email": "carlos.mendes@vitta.com",
            "password": "prof123",
            "specialty": "Enfermeiro",
            "crm_coren": "COREN-RJ 123456",
            "rating": 4.9,
            "balance": 2100.00,
            "hobbies": ["futebol", "musica", "leitura"],
        },
        {
            "name": "Dra. Ana Paula Silva",
            "email": "ana.silva@vitta.com",
            "password": "prof123",
            "specialty": "Tecnica de Enfermagem",
            "crm_coren": "COREN-RJ 234567",
            "rating": 4.7,
            "balance": 850.00,
            "hobbies": ["yoga", "culinaria", "viagens"],
        },
        {
            "name": "Dr. Roberto Costa",
            "email": "roberto.costa@vitta.com",
            "password": "prof123",
            "specialty": "Fisioterapeuta",
            "crm_coren": "CREFITO-RJ 345678",
            "rating": 4.5,
            "balance": 340.00,
            "hobbies": ["ciclismo", "fotografia", "cinema"],
        },
        {
            "name": "Dra. Juliana Santos",
            "email": "juliana.santos@vitta.com",
            "password": "prof123",
            "specialty": "Enfermeira",
            "crm_coren": "COREN-RJ 456789",
            "rating": 4.8,
            "balance": 1600.00,
            "hobbies": ["danca", "pintura", "jardinagem"],
        },
    ]

    for prof_data in professionals:
        existing = db.query(models.User).filter(models.User.email == prof_data["email"]).first()
        if existing:
            continue
        professional = models.User(
            name=prof_data["name"],
            email=prof_data["email"],
            hashed_password=pwd_context.hash(prof_data["password"]),
            role="professional",
            specialty=prof_data["specialty"],
            crm_coren=prof_data["crm_coren"],
            rating=prof_data["rating"],
            balance=prof_data["balance"],
            hobbies=prof_data["hobbies"],
            is_active=True,
        )
        db.add(professional)
        print(f"  Profissional: {prof_data['name']}")

    families = [
        {
            "name": "Maria Silva",
            "email": "maria.silva@vitta.com",
            "clinical_summary": "Paciente idosa, 78 anos, hipertensa. Usa andador. Acamada 60% do tempo.",
            "hobbies": ["musica", "jardim", "leitura"],
        },
        {
            "name": "Joao Oliveira",
            "email": "joao.oliveira@vitta.com",
            "clinical_summary": "Paciente de 65 anos, pos-AVC. Necessita fisioterapia diaria e apoio na locomocao.",
            "hobbies": ["futebol", "churrasco", "pesca"],
        },
        {
            "name": "Carla Souza",
            "email": "carla.souza@vitta.com",
            "clinical_summary": "Paciente com diabetes tipo 2. Controle glicemico diario necessario.",
            "hobbies": ["culinaria", "novelas", "jardinagem"],
        },
        {
            "name": "Pedro Santos",
            "email": "pedro.santos@vitta.com",
            "clinical_summary": "Paciente em reabilitacao motora com necessidade de suporte leve nas atividades diarias.",
            "hobbies": ["xadrez", "radio", "caminhadas curtas"],
        },
    ]

    for family_data in families:
        existing = db.query(models.User).filter(models.User.email == family_data["email"]).first()
        if existing:
            continue
        family = models.User(
            name=family_data["name"],
            email=family_data["email"],
            hashed_password=pwd_context.hash("familia123"),
            role="family",
            clinical_summary=family_data["clinical_summary"],
            hobbies=family_data["hobbies"],
            is_active=True,
        )
        db.add(family)
        print(f"  Familia: {family_data['name']}")

    db.commit()
    professional_by_email = {
        user.email: user for user in db.query(models.User).filter(models.User.role == "professional").all()
    }

    print("\nCriando plantoes de teste...")

    shifts_data = [
        {
            "title": "Plantao Noturno - Copacabana",
            "description": "Cuidados com paciente idoso, administracao de medicamentos e acompanhamento noturno.",
            "hospital_name": "Residencia Particular",
            "address": "Av. Atlantica, 1500 - Copacabana, Rio de Janeiro",
            "hours": 12,
            "value": 450.00,
            "status": "open",
        },
        {
            "title": "Home Care Diurno - Barra da Tijuca",
            "description": "Acompanhamento de paciente pos-cirurgico, troca de curativos e fisioterapia.",
            "hospital_name": "Residencia Particular",
            "address": "Av. das Americas, 3000 - Barra da Tijuca, Rio de Janeiro",
            "hours": 8,
            "value": 320.00,
            "status": "open",
        },
        {
            "title": "Plantao 24h - Leblon",
            "description": "Cuidados intensivos com paciente acamado, alimentacao por sonda e higiene.",
            "hospital_name": "Residencia Particular",
            "address": "Rua Dias Ferreira, 200 - Leblon, Rio de Janeiro",
            "hours": 24,
            "value": 850.00,
            "status": "open",
        },
        {
            "title": "Fisioterapia Domiciliar - Ipanema",
            "description": "Sessoes de fisioterapia motora e respiratoria para paciente com mobilidade reduzida.",
            "hospital_name": "Residencia Particular",
            "address": "Rua Visconde de Piraja, 500 - Ipanema, Rio de Janeiro",
            "hours": 4,
            "value": 280.00,
            "status": "assigned",
        },
        {
            "title": "Plantao Fim de Semana - Botafogo",
            "description": "Acompanhamento de idoso com Alzheimer, atividades recreativas e administracao de medicamentos.",
            "hospital_name": "Residencia Particular",
            "address": "Rua Sao Clemente, 300 - Botafogo, Rio de Janeiro",
            "hours": 48,
            "value": 1600.00,
            "status": "open",
        },
        {
            "title": "Cuidados Paliativos - Tijuca",
            "description": "Cuidados paliativos com paciente oncologico, controle de dor e suporte emocional.",
            "hospital_name": "Residencia Particular",
            "address": "Rua Conde de Bonfim, 800 - Tijuca, Rio de Janeiro",
            "hours": 12,
            "value": 520.00,
            "status": "completed",
        },
        {
            "title": "Plantao Pediatrico - Flamengo",
            "description": "Cuidados com crianca em recuperacao pos-operatoria, monitoramento de sinais vitais.",
            "hospital_name": "Residencia Particular",
            "address": "Praia do Flamengo, 100 - Flamengo, Rio de Janeiro",
            "hours": 12,
            "value": 480.00,
            "status": "open",
        },
        {
            "title": "Home Care Noturno - Centro",
            "description": "Acompanhamento noturno de paciente diabetico, controle glicemico e administracao de insulina.",
            "hospital_name": "Residencia Particular",
            "address": "Av. Rio Branco, 500 - Centro, Rio de Janeiro",
            "hours": 10,
            "value": 380.00,
            "status": "open",
        },
    ]

    all_professionals = list(professional_by_email.values())

    for index, shift_data in enumerate(shifts_data):
        days_ahead = index % 7
        start_date = datetime.now() + timedelta(days=days_ahead, hours=8)
        end_date = start_date + timedelta(hours=shift_data["hours"])

        professional_id = None
        if shift_data["status"] in {"assigned", "completed"} and all_professionals:
            professional_id = random.choice(all_professionals).id

        shift = models.Shift(
            title=shift_data["title"],
            description=shift_data["description"],
            hospital_name=shift_data["hospital_name"],
            address=shift_data["address"],
            date_start=start_date,
            date_end=end_date,
            value=shift_data["value"],
            status=shift_data["status"],
            professional_id=professional_id,
        )
        db.add(shift)
        print(f"  Plantao: {shift_data['title']} ({shift_data['status']})")

    db.commit()

    family_by_email = {
        user.email: user for user in db.query(models.User).filter(models.User.role == "family").all()
    }
    service_requests = []
    conversations = []
    messages = []

    maria = family_by_email.get("maria.silva@vitta.com")
    carlos = professional_by_email.get("carlos.mendes@vitta.com")
    if maria:
        service_requests.append(
            models.ServiceRequest(
                family_id=maria.id,
                patient_name="Sra. Maria (79 anos)",
                address="Rua Nascimento Silva, 107 - Ipanema, RJ",
                lat=-22.9835,
                lng=-43.1990,
                notes="Paciente acamada. Precisa de cuidados noturnos e administracao de medicacao.",
                status="matched" if carlos else "searching",
                professional_id=carlos.id if carlos else None,
                matched_at=datetime.utcnow() - timedelta(minutes=20) if carlos else None,
            )
        )

    joao = family_by_email.get("joao.oliveira@vitta.com")
    if joao:
        service_requests.append(
            models.ServiceRequest(
                family_id=joao.id,
                patient_name="Sr. Roberto (65 anos)",
                address="Av. Epitacio Pessoa, 2566 - Lagoa, RJ",
                lat=-22.9711,
                lng=-43.2130,
                notes="Pos-operatorio. Curativo, controle de dor e fisioterapia leve.",
                status="searching",
            )
        )

    if service_requests:
        db.add_all(service_requests)
        db.commit()

    matched_request = next(
        (
            request
            for request in service_requests
            if request.status in {"matched", "in_progress"} and request.professional_id is not None
        ),
        None,
    )
    if matched_request is not None:
        conversation = models.Conversation(
            request_id=matched_request.id,
            request_type="service_request",
            family_id=matched_request.family_id,
            professional_id=matched_request.professional_id,
        )
        db.add(conversation)
        db.flush()

        first_message = models.Message(
            conversation_id=conversation.id,
            sender_id=matched_request.professional_id,
            content="Ola! Estarei ai em 20 minutos.",
        )
        second_message = models.Message(
            conversation_id=conversation.id,
            sender_id=matched_request.family_id,
            content="Otimo, obrigada! Portao estara aberto.",
        )
        db.add_all([first_message, second_message])
        db.commit()
        conversations.append(conversation)
        messages.extend([first_message, second_message])

    print("\nCriando solicitacoes on-demand...")
    for service_request in service_requests:
        print(f"  Solicitacao: {service_request.patient_name} ({service_request.status})")

    print("\nCriando conversas de chat...")
    for conversation in conversations:
        print(f"  Conversa: request_id={conversation.request_id}, type={conversation.request_type}")
    if not conversations:
        print("  Nenhuma conversa criada.")

    print("\nSeed de dados mockados concluido!")
    print("\nResumo:")
    print("  - Usuarios Admin: 1")
    print(f"  - Profissionais: {len(professionals)}")
    print(f"  - Familias: {len(families)}")
    print(f"  - Plantoes: {len(shifts_data)}")
    print(f"  - Solicitacoes on-demand: {len(service_requests)}")
    print(f"  - Conversas: {len(conversations)}")
    print(f"  - Mensagens: {len(messages)}")
    print("\nCredenciais de teste:")
    print("  Admin: admin@vitta.com / admin123")
    print("  Profissional: carlos.mendes@vitta.com / prof123")
    print("  Familia: maria.silva@vitta.com / familia123")

    db.close()


if __name__ == "__main__":
    seed_mock_data()
