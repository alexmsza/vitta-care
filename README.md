# Vitta — Conexão de Confiança

Plataforma de Home Care que conecta famílias a profissionais de saúde através de **Affinity Matching** — pareamento por hobbies e preferências pessoais para um cuidado humanizado.

## Stack

| Camada | Tecnologia |
|--------|-----------|
| Mobile | Flutter (Stable) · Riverpod (codegen) · GoRouter · Material 3 |
| Backend | Python FastAPI · SQLAlchemy · PostgreSQL · Docker |
| Auth | JWT HS256 · aprovação manual de contas pelo admin |

## Pré-requisitos

- Flutter SDK (Stable channel)
- Docker + Docker Compose (para o backend)

## Rodando o projeto

### Frontend

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

### Backend

```bash
cd backend
cp .env.example .env        # preencha as variáveis
docker-compose up -d --build
docker-compose exec api python seed_mock.py  # dados de teste
```

Health check: `curl http://localhost:8000/health`

## Estrutura Flutter

```
lib/
├── main.dart                  # Entrada: ProviderScope + GoRouter
├── app/router.dart            # Rotas e redirecionamento por role
├── core/                      # Modelos, providers globais, tema, config de API
└── features/
    ├── auth/                  # Login, registro
    ├── professional/          # Dashboard do profissional, plantões
    ├── family/                # Dashboard da família
    └── admin/                 # Painel de aprovação de usuários
```

## Roles

| Role | Acesso |
|------|--------|
| `professional` | Feed de plantões abertos, aceitar plantão, ver meus plantões |
| `family` | Visualizar plantões disponíveis, solicitar atendimento |
| `admin` | Aprovar / rejeitar novos cadastros |

## Backend (produção)

Servidor: `http://localhost:8000` (NGINX → uvicorn :8000)

Documentação dos endpoints: [`API_CONTRACTS.md`](./API_CONTRACTS.md)

## Antes de fazer push

```bash
flutter analyze
dart run build_runner build --delete-conflicting-outputs
```

---

## Próximos Passos

### 1. Desligar o bypass de UX

O modo de teste local deve ser desativado antes de qualquer build de produção.

```dart
// lib/features/auth/presentation/screens/login_screen.dart
static const bool _useTemporaryUiBypass = false; // era true
```

Remover também os blocos `_mock*` e os guards `if (token == _devBypassToken)` em:
- `lib/features/professional/data/shift_repository.dart`
- `lib/features/admin/data/admin_repository.dart`

---

### 2. Preparar o backend para deploy

**Infraestrutura atual:** VPS DigitalOcean em `localhost` com Ubuntu + Docker + NGINX.

**Stack do backend:**

| Componente | Tecnologia |
|------------|-----------|
| API | Python 3.11 · FastAPI · Uvicorn (:8000) |
| ORM | SQLAlchemy 2.x |
| Banco | PostgreSQL 15 (container Docker) |
| Auth | JWT HS256 via `python-jose` · `passlib[bcrypt]` |
| Email | `fastapi-mail` · SMTP Lark Suite (porta 465 SSL) |
| Proxy | NGINX (porta 80 → uvicorn :8000) |

**Dependências Python** (`requirements.txt` — recriar se ausente):

```
fastapi
uvicorn[standard]
sqlalchemy
psycopg2-binary
python-jose[cryptography]
passlib[bcrypt]
fastapi-mail
pydantic-settings
python-multipart
```

**Dockerfile** (recriar em `backend/Dockerfile` se ausente):

```dockerfile
FROM python:3.11-slim
WORKDIR /code
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

---

### 3. Variáveis de ambiente

Criar `backend/.env` a partir do `backend/.env.example`:

```env
# Banco de dados
POSTGRES_USER=vitta_user
POSTGRES_PASSWORD=<senha forte>
POSTGRES_DB=vitta_db

# JWT — gerar com: openssl rand -hex 32
SECRET_KEY=<chave gerada>

# Email (Lark Suite)
MAIL_USERNAME=admin@example.com
MAIL_PASSWORD=<senha do app>
MAIL_FROM=admin@example.com
MAIL_SERVER=smtp.larksuite.com
MAIL_PORT=465
MAIL_STARTTLS=False
MAIL_SSL_TLS=True
ADMIN_EMAIL=<email do admin>
```

---

### 4. Deploy do backend

```bash
# No servidor (ssh root@localhost)

# Clonar / atualizar o repositório
git pull origin develop

cd backend

# Criar o .env com as variáveis de produção
cp .env.example .env
nano .env

# Subir os containers
docker-compose up -d --build

# Aguardar o Postgres inicializar (~5s) e popular o banco
docker-compose exec api python seed_mock.py

# Verificar
curl http://localhost:8000/health
```

Para rebuild sem perder dados:
```bash
docker-compose down
docker-compose up -d --build
# NÃO rodar seed_mock.py novamente — apaga dados existentes
```

Para reset completo do banco:
```bash
docker-compose down
docker volume rm backend_postgres_data
docker-compose up -d --build
docker-compose exec api python seed_mock.py
```

---

### 5. NGINX (configuração mínima)

```nginx
server {
    listen 80;
    server_name localhost;

    location / {
        proxy_pass http://localhost:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

```bash
sudo nginx -t && sudo systemctl reload nginx
```

---

### 6. Build do app Flutter

```bash
# Confirmar que ApiConfig.baseUrl aponta para produção
# lib/core/config/api_config.dart → http://localhost:8000

flutter build apk --release
# APK em: build/app/outputs/flutter-apk/app-release.apk
```

---

### 7. Pós-deploy — fluxo de validação

| Passo | Ação |
|-------|------|
| 1 | Logar com `admin@vitta.com` no app |
| 2 | Registrar um profissional e uma família como teste |
| 3 | Aprovar ambos no painel admin |
| 4 | Logar como profissional → ver feed de plantões |
| 5 | Aceitar um plantão → verificar em "Meus Plantões" |
| 6 | Logar como família → visualizar plantões disponíveis |

---

### 8. Funcionalidades pendentes (pós-MVP)

- [ ] Fluxo de solicitação de atendimento pela família (endpoint POST /requests)
- [ ] Matching por afinidade (hobbies) entre família e profissional
- [ ] Sistema de avaliação pós-atendimento (`rating`)
- [ ] Carteira do profissional (`balance`)
- [ ] Notificações push
- [ ] Build iOS (requer conta Apple Developer)
