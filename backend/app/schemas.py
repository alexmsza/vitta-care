from pydantic import BaseModel, EmailStr, ConfigDict
from typing import List, Optional
from datetime import datetime


# --- USER SCHEMAS ---

class UserRegister(BaseModel):
    email: EmailStr
    name: str
    password: str
    role: str  # 'professional' | 'family'
    phone: Optional[str] = None
    specialty: Optional[str] = None
    crm_coren: Optional[str] = None


class UserLogin(BaseModel):
    email: EmailStr
    password: str


class UserResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    email: str
    name: str
    role: str
    is_active: bool
    phone: Optional[str] = None
    specialty: Optional[str] = None
    crm_coren: Optional[str] = None
    rating: Optional[float] = None
    balance: Optional[float] = None
    hobbies: Optional[List[str]] = None
    clinical_summary: Optional[str] = None
    created_at: datetime


class UserProfileUpdate(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    name: Optional[str] = None
    phone: Optional[str] = None
    specialty: Optional[str] = None
    crm_coren: Optional[str] = None
    hobbies: Optional[List[str]] = None
    clinical_summary: Optional[str] = None


class UserUpdate(UserProfileUpdate):
    pass


class Token(BaseModel):
    access_token: str
    token_type: str = "bearer"
    role: str
    user_id: int
    user_name: str


# --- PASSWORD RESET SCHEMAS ---

class ForgotPasswordRequest(BaseModel):
    email: EmailStr


class PasswordResetRequest(BaseModel):
    email: EmailStr
    reset_code: str
    new_password: str


# --- SHIFT SCHEMAS ---

class PatientInfo(BaseModel):
    name: str
    age: Optional[int] = None
    rating: Optional[float] = None
    medical_history: Optional[str] = None


class ShiftBase(BaseModel):
    title: str
    description: str
    hospital_name: str
    address: str
    date_start: datetime
    date_end: datetime
    value: float
    is_urgent: bool = False
    patient: Optional[PatientInfo] = None


class ShiftCreate(ShiftBase):
    pass


class ShiftResponse(ShiftBase):
    model_config = ConfigDict(from_attributes=True)

    id: int
    status: str
    professional_id: Optional[int] = None
    created_at: datetime


class ServiceRequestCreate(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    patient_name: str
    address: str
    lat: Optional[float] = None
    lng: Optional[float] = None
    notes: Optional[str] = None


class ServiceRequestResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    family_id: int
    patient_name: str
    address: str
    lat: Optional[float] = None
    lng: Optional[float] = None
    notes: Optional[str] = None
    status: str
    professional_id: Optional[int] = None
    professional_name: Optional[str] = None
    created_at: datetime
    matched_at: Optional[datetime] = None

    @classmethod
    def from_orm_with_name(cls, obj: object) -> "ServiceRequestResponse":
        data = cls.model_validate(obj)
        professional = getattr(obj, "professional", None)
        if professional is not None:
            data = data.model_copy(update={"professional_name": professional.name})
        return data


class MessageResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    conversation_id: int
    sender_id: int
    sender_name: str = ""
    sender_role: str = ""
    content: str
    sent_at: datetime
    read: bool


class ConversationResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    request_id: int
    request_type: str
    family_id: int
    professional_id: int
    family_name: str = ""
    professional_name: str = ""
    patient_name: Optional[str] = None
    visit_date: Optional[datetime] = None
    last_message: Optional[str] = None
    last_message_at: Optional[datetime] = None
    unread_count: int = 0


class MessageCreate(BaseModel):
    content: str
