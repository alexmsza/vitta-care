from sqlalchemy.orm import Session
from app.core.database import SessionLocal, engine, Base
from app import models
from passlib.context import CryptContext
from datetime import datetime, timedelta

# Create DB structure
Base.metadata.create_all(bind=engine)

db = SessionLocal()
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def seed_data():
    # 1. Create Admin
    if not db.query(models.User).filter(models.User.email == "admin@vitta.com").first():
        admin = models.User(
            name="Admin Vitta",
            email="admin@vitta.com",
            hashed_password=pwd_context.hash("admin123"),
            role="admin",
            is_active=True
        )
        db.add(admin)
        print("✅ Admin user created.")
    
    # 2. Create Professional Test User
    if not db.query(models.User).filter(models.User.email == "profissional@vitta.com").first():
        professional = models.User(
            name="Dr. Carlos Mendes",
            email="profissional@vitta.com",
            hashed_password=pwd_context.hash("prof123"),
            role="professional",
            is_active=True
        )
        db.add(professional)
        print("✅ Professional test user created.")
    
    # 3. Create Family/Patient Test User
    if not db.query(models.User).filter(models.User.email == "familia@vitta.com").first():
        family = models.User(
            name="Maria Silva",
            email="familia@vitta.com",
            hashed_password=pwd_context.hash("familia123"),
            role="family",
            is_active=True
        )
        db.add(family)
        print("✅ Family test user created.")

    # 2. Create Shifts (Plantões)
    if db.query(models.Shift).count() == 0:
        shifts = [
            models.Shift(
                title="Plantão Noturno - Copacabana",
                description="Plantão de 12h em home care. Paciente idoso, baixa complexidade.",
                hospital_name="Residencial",
                address="Av. Atlântica, 1500 - Rio de Janeiro",
                date_start=datetime.now() + timedelta(days=1),
                date_end=datetime.now() + timedelta(days=1, hours=12),
                value=450.00,
                status="open"
            ),
            models.Shift(
                title="Acompanhamento Hospitalar - Barra",
                description="Acompanhamento em quarto particular. Necessário experiência com sonda.",
                hospital_name="Hospital Barra D'Or",
                address="Av. Ayrton Senna, 3079 - Barra da Tijuca",
                date_start=datetime.now() + timedelta(days=2),
                date_end=datetime.now() + timedelta(days=2, hours=24),
                value=800.00,
                status="open"
            ),
            models.Shift(
                title="Cuidador Diurno - Tijuca",
                description="Plantão 12x36. Apoio em atividades diárias.",
                hospital_name="Residencial",
                address="Rua Conde de Bonfim, 300 - Tijuca",
                date_start=datetime.now() + timedelta(days=3),
                date_end=datetime.now() + timedelta(days=3, hours=12),
                value=250.00,
                status="open"
            ),
        ]
        db.add_all(shifts)
        print("✅ Plantões de exemplo criados.")

    db.commit()
    db.close()

if __name__ == "__main__":
    seed_data()
