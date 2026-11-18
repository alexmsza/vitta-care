from sqlalchemy import Column, Integer, String, Boolean, Float, ForeignKey, DateTime, JSON, Text
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.core.database import Base


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, index=True)
    email = Column(String, unique=True, index=True)
    hashed_password = Column(String)
    # Valid roles: 'professional', 'family', 'admin'
    role = Column(String, nullable=False)
    # False = pending admin approval (default for new registrations)
    is_active = Column(Boolean, default=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    # Common profile fields
    phone = Column(String, nullable=True)

    # Professional-only fields
    specialty = Column(String, nullable=True)
    crm_coren = Column(String, nullable=True)
    rating = Column(Float, default=0.0, nullable=True)
    balance = Column(Float, default=0.0, nullable=True)

    # Family/patient-only fields
    clinical_summary = Column(Text, nullable=True)

    # Affinity matching — list of hobby strings, e.g. ["música", "futebol"]
    hobbies = Column(JSON, default=list, nullable=True)

    # Password reset
    reset_code = Column(String, nullable=True)
    reset_code_expires = Column(DateTime, nullable=True)

    shifts = relationship("Shift", back_populates="professional")


class Shift(Base):
    __tablename__ = "shifts"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, index=True)
    description = Column(String)
    hospital_name = Column(String)
    address = Column(String)
    date_start = Column(DateTime)
    date_end = Column(DateTime)
    value = Column(Float)
    # Single shift object: urgent shifts are distinguished only by this flag.
    is_urgent = Column(Boolean, default=False, nullable=False)
    patient = Column(JSON, nullable=True)
    # open | assigned | in_progress | completed | cancelled
    status = Column(String, default="open")

    professional_id = Column(Integer, ForeignKey("users.id"), nullable=True)
    professional = relationship("User", back_populates="shifts")

    created_at = Column(DateTime(timezone=True), server_default=func.now())


class ServiceRequest(Base):
    __tablename__ = "service_requests"

    id = Column(Integer, primary_key=True, index=True)
    family_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    patient_name = Column(String, nullable=False)
    address = Column(String, nullable=False)
    lat = Column(Float, nullable=True)
    lng = Column(Float, nullable=True)
    notes = Column(Text, nullable=True)
    status = Column(String, default="searching", nullable=False)
    professional_id = Column(Integer, ForeignKey("users.id"), nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    matched_at = Column(DateTime(timezone=True), nullable=True)

    family = relationship("User", foreign_keys=[family_id])
    professional = relationship("User", foreign_keys=[professional_id])


class Conversation(Base):
    __tablename__ = "conversations"

    id = Column(Integer, primary_key=True, index=True)
    # request_id points to ServiceRequest.id or Shift.id depending on request_type.
    request_id = Column(Integer, nullable=False)
    request_type = Column(String, default="service_request", nullable=False)
    family_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    professional_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    is_closed = Column(Boolean, default=False, nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    family = relationship("User", foreign_keys=[family_id])
    professional = relationship("User", foreign_keys=[professional_id])
    messages = relationship(
        "Message",
        back_populates="conversation",
        order_by="Message.sent_at",
    )


class Message(Base):
    __tablename__ = "messages"

    id = Column(Integer, primary_key=True, index=True)
    conversation_id = Column(Integer, ForeignKey("conversations.id"), nullable=False)
    sender_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    content = Column(Text, nullable=False)
    sent_at = Column(DateTime(timezone=True), server_default=func.now())
    read = Column(Boolean, default=False, nullable=False)

    conversation = relationship("Conversation", back_populates="messages")
    sender = relationship("User", foreign_keys=[sender_id])
