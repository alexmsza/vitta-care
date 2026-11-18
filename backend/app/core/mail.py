import logging
import os

from fastapi_mail import FastMail, MessageSchema, ConnectionConfig, MessageType
from pydantic_settings import BaseSettings
from pydantic import EmailStr

logger = logging.getLogger(__name__)


class Settings(BaseSettings):
    MAIL_USERNAME: str = os.getenv("MAIL_USERNAME", "your_email@gmail.com")
    MAIL_PASSWORD: str = os.getenv("MAIL_PASSWORD", "your_app_password")
    MAIL_FROM: str = os.getenv("MAIL_FROM", "your_email@gmail.com")
    MAIL_PORT: int = int(os.getenv("MAIL_PORT", 587))
    MAIL_SERVER: str = os.getenv("MAIL_SERVER", "smtp.gmail.com")
    MAIL_FROM_NAME: str = os.getenv("MAIL_FROM_NAME", "Vitta App")
    MAIL_STARTTLS: bool = os.getenv("MAIL_STARTTLS", "True").lower() == "true"
    MAIL_SSL_TLS: bool = os.getenv("MAIL_SSL_TLS", "False").lower() == "true"
    USE_CREDENTIALS: bool = True
    VALIDATE_CERTS: bool = True


settings = Settings()

conf = ConnectionConfig(
    MAIL_USERNAME=settings.MAIL_USERNAME,
    MAIL_PASSWORD=settings.MAIL_PASSWORD,
    MAIL_FROM=settings.MAIL_FROM,
    MAIL_PORT=settings.MAIL_PORT,
    MAIL_SERVER=settings.MAIL_SERVER,
    MAIL_FROM_NAME=settings.MAIL_FROM_NAME,
    MAIL_STARTTLS=settings.MAIL_STARTTLS,
    MAIL_SSL_TLS=settings.MAIL_SSL_TLS,
    USE_CREDENTIALS=settings.USE_CREDENTIALS,
    VALIDATE_CERTS=settings.VALIDATE_CERTS,
)


async def send_registration_email(user_email: EmailStr, user_name: str, user_role: str):
    try:
        html_user = f"""
        <h3>Olá {user_name},</h3>
        <p>Recebemos sua solicitação de cadastro como <b>{user_role}</b> no Vitta.</p>
        <p>Seus dados estão em análise. Você receberá um novo email assim que seu acesso for aprovado.</p>
        <br>
        <p>Atenciosamente,<br>Equipe Vitta</p>
        """

        message_user = MessageSchema(
            subject="Vitta - Cadastro Recebido",
            recipients=[user_email],
            body=html_user,
            subtype=MessageType.html,
        )

        html_admin = f"""
        <h3>Nova Solicitação de Cadastro</h3>
        <ul>
            <li><b>Nome:</b> {user_name}</li>
            <li><b>Email:</b> {user_email}</li>
            <li><b>Perfil:</b> {user_role}</li>
        </ul>
        <p>Acesse o painel administrativo para validar este usuário.</p>
        """

        admin_email = os.getenv("ADMIN_EMAIL", settings.MAIL_USERNAME)

        message_admin = MessageSchema(
            subject=f"Novo Cadastro: {user_role}",
            recipients=[admin_email],
            body=html_admin,
            subtype=MessageType.html,
        )

        fm = FastMail(conf)
        await fm.send_message(message_user)
        logger.info("Registration email sent to user: %s", user_email)
        await fm.send_message(message_admin)
        logger.info("Registration notification sent to admin: %s", admin_email)
    except Exception as e:
        logger.error(
            "Email sending failed for %s — %s:%s — %s",
            user_email,
            settings.MAIL_SERVER,
            settings.MAIL_PORT,
            e,
        )
        # Don't raise — let registration continue even if email fails


async def send_approval_email(user_email: EmailStr, user_name: str, approved: bool):
    """Envia email de aprovação ou rejeição de conta"""
    try:
        if approved:
            subject = "Vitta - Conta Aprovada! 🎉"
            html = f"""
            <h3>Olá {user_name},</h3>
            <p>Sua conta no Vitta foi <b>aprovada</b>!</p>
            <p>Agora você pode fazer login no aplicativo e começar a usar nossos serviços.</p>
            <br>
            <p>Bem-vindo(a) à Vitta!<br>Equipe Vitta</p>
            """
        else:
            subject = "Vitta - Cadastro Não Aprovado"
            html = f"""
            <h3>Olá {user_name},</h3>
            <p>Infelizmente, sua solicitação de cadastro não foi aprovada neste momento.</p>
            <p>Se você acredita que isso é um erro, entre em contato conosco.</p>
            <br>
            <p>Atenciosamente,<br>Equipe Vitta</p>
            """

        message = MessageSchema(
            subject=subject,
            recipients=[user_email],
            body=html,
            subtype=MessageType.html,
        )

        fm = FastMail(conf)
        await fm.send_message(message)
        logger.info("Approval email sent to: %s (approved=%s)", user_email, approved)
    except Exception as e:
        logger.error("Error sending approval email to %s: %s", user_email, e)


async def send_password_reset_email(user_email: EmailStr, user_name: str, reset_code: str):
    """Envia email com código de reset de senha"""
    try:
        subject = "Vitta - Código de Recuperação de Senha"
        html = f"""
        <h3>Olá {user_name},</h3>
        <p>Você solicitou a recuperação de senha da sua conta no Vitta.</p>
        <p>Use o código abaixo no aplicativo para redefinir sua senha:</p>
        <h2 style="background-color: #f0f0f0; padding: 15px; text-align: center; letter-spacing: 5px; font-family: monospace;">
            {reset_code}
        </h2>
        <p><b>Este código expira em 15 minutos.</b></p>
        <p>Se você não solicitou esta recuperação, ignore este email.</p>
        <br>
        <p>Atenciosamente,<br>Equipe Vitta</p>
        """

        message = MessageSchema(
            subject=subject,
            recipients=[user_email],
            body=html,
            subtype=MessageType.html,
        )

        fm = FastMail(conf)
        await fm.send_message(message)
        logger.info("Password reset email sent to: %s", user_email)
    except Exception as e:
        logger.error("Error sending password reset email to %s: %s", user_email, e)
