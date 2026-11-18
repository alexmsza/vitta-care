# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Vitta** ("Conexão de Confiança") is a Home Care platform connecting patients/families with healthcare professionals. The key differentiator is **Affinity Matching** — pairing based on hobbies and personal preferences for humanized care.

## Tech Stack

- **Frontend**: Flutter (Stable channel) — Clean Architecture + Riverpod (code generation) + GoRouter
- **Backend**: Python FastAPI + SQLAlchemy + PostgreSQL (Docker)
- **UI**: Material 3, custom design system (Petrol, Sage, Cream colors)
- **Backend status**: Live at `http://localhost:8000` (via NGINX on port 80 → uvicorn on :8000)

## Flutter Commands

```bash
flutter pub get
flutter run

# Before every push:
flutter analyze
dart run build_runner build --delete-conflicting-outputs  # Regenerate Riverpod codegen files

# Build release APK:
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

## Backend Commands

```bash
# Run locally with Docker Compose:
cd backend
docker-compose up -d --build

# Health check:
curl http://localhost:8000/health

# Seed mock data (after fresh DB):
docker-compose exec api python seed_mock.py
```

## Architecture — Flutter (Clean Architecture)

Entry point: `lib/main.dart` → `ProviderScope` → `lib/app/router.dart` → features.

Each feature lives under `lib/features/<feature_name>/` with three layers:

```
lib/features/<feature>/
├── data/         # Repositories calling the real API
└── presentation/ # Screens, Widgets, Riverpod providers
```

**Shared core**: `lib/core/` holds models, providers, services, theme, and API config.

**Auth state split**:
- `lib/core/providers/auth_provider.dart` — `authStateProvider` (StateNotifier, global, watched by router)
- `lib/features/auth/presentation/providers/auth_provider.dart` — `authProvider` (AsyncNotifier, used by screens)

**API URL config**: `lib/core/config/api_config.dart` — points to the production server.

## Architecture — Backend (FastAPI)

```
backend/
├── app/
│   ├── main.py       # All routes (auth, shifts, admin, password reset)
│   ├── models.py     # SQLAlchemy ORM models
│   ├── schemas.py    # Pydantic v2 request/response schemas
│   └── core/
│       ├── database.py   # SQLAlchemy engine + session
│       └── mail.py       # Email via Lark Suite SMTP (uses logging, not print)
├── docker-compose.yml    # postgres + api services (all secrets via .env)
├── Dockerfile
├── seed_mock.py          # Populates DB with test users/shifts
└── requirements.txt
```

**Auth**: Real HS256 JWT, 24h expiry. `require_active_user` + `require_admin` dependency chain protects all routes. New users start with `is_active=False` and require admin approval.

## User Roles

Three roles: `family`, `professional`, `admin`.
- **professional**: sees open shift feed, can accept shifts, has specialty/crm_coren/rating/balance fields.
- **family**: read-only shift browser, can request care (MVP: contact via email). Has clinical_summary/hobbies fields.
- **admin**: approves/rejects new user registrations via the admin dashboard.

## Key Data Entities

Full schemas in `API_CONTRACTS.md`:
- `User` — base auth + role, `is_active` flag
- `Shift` (plantão) — status flow: `open → assigned → in_progress → completed`
- Token (login response): `access_token`, `role`, `user_id`, `user_name`
- UserResponse (profile): `id`, `name`, `email`, `role`, plus role-specific fields

## UX Bypass Mode (develop only — NEVER merge to main ligado)

Existe um modo de teste local que permite navegar os três painéis sem servidor. **Deve ser desativado antes de qualquer merge para main.**

**Flag de controle** (única coisa a mudar para ligar/desligar):
```dart
// lib/features/auth/presentation/screens/login_screen.dart — linha 18
static const bool _useTemporaryUiBypass = true;  // ← mudar para false
```

**Como funciona:**
- O token sentinela `'dev-bypass-token'` é injetado no `authStateProvider` ao clicar nos atalhos
- `ShiftRepository` e `AdminRepository` detectam esse token e retornam dados em memória em vez de chamar a API
- O `AuthRepository` (login real) **não é modificado** — o bypass age na camada de apresentação

**Dados mockados presentes:**
| Repositório | Dados |
|-------------|-------|
| `ShiftRepository._mockOpenShifts` | 2 plantões abertos (Copacabana · Barra da Tijuca) |
| `ShiftRepository._mockMyShifts` | 1 plantão aceito (Ipanema, status `assigned`) |
| `AdminRepository._mockPendingUsers` | 2 usuários pendentes (1 professional · 1 family) |

**Ações funcionam em memória:**
- Aceitar plantão → move de `_mockOpenShifts` para `_mockMyShifts` com status `assigned`
- Aprovar/rejeitar usuário → remove de `_mockPendingUsers`

**Para desligar antes do merge:**
1. `login_screen.dart:18` → `_useTemporaryUiBypass = false`
2. Remover os blocos `static const _devBypassToken` e `static final _mock*` dos repositórios
3. Remover os guards `if (token == _devBypassToken)` de cada método

## Pre-Push Checklist

1. `_useTemporaryUiBypass = false` — confirmar que o bypass está desligado
2. `flutter analyze` — fix all warnings
3. `dart run build_runner build --delete-conflicting-outputs` — regenerate `*.g.dart` files
4. Update `API_CONTRACTS.md` if any endpoint or schema changed

## Key Reference Files

- `API_CONTRACTS.md` — single source of truth for all API endpoints and schemas
- `agents/gemini_frontend.md` — active Flutter task queue for Gemini
- `agents/codex_backend.md` — active backend task queue for Codex
