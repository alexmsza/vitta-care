# API_CONTRACTS.md — Única Fonte da Verdade

> **REGRA:** Nenhum engenheiro (Codex ou Gemini) deve implementar ou consumir um endpoint
> sem que ele esteja documentado aqui. Toda mudança de contrato passa pelo Tech Lead (Claude)
> antes de ser delegada.
>
> Última atualização: 2026-04-13
> Versão da API: 2.7.0

---

## Base URL

```
Produção:  http://localhost:8000
Local:     http://localhost:8000
```

---

## Autenticação

- Tipo: **Bearer JWT** (HS256)
- Header obrigatório em todas as rotas protegidas:
  ```
  Authorization: Bearer <access_token>
  ```
- Expiração do token: **24 horas**
- Rotas públicas (sem token): `/`, `/health`, `/version`, `/auth/login`, `/auth/register`, `/auth/forgot-password`, `/auth/reset-password`

---

## Respostas de Erro (Padrão)

Todos os erros seguem o formato:
```json
{ "detail": "mensagem de erro legível" }
```

| Status | Significado |
|--------|-------------|
| `400` | Dados inválidos (ex: email já cadastrado) |
| `401` | Token ausente, inválido ou expirado |
| `403` | Conta inativa (aguardando aprovação) ou role sem permissão |
| `404` | Recurso não encontrado |
| `409` | Conflito de estado (ex: plantão já atribuído) |

---

## Schemas Canônicos

### `Token` — Retorno de Login e Registro
```json
{
  "access_token": "eyJhbGci...",
  "token_type": "bearer",
  "role": "professional | family | admin",
  "user_id": 1,
  "user_name": "Carlos Mendes"
}
```
> ⚠️ **Frontend:** O token de login NÃO retorna `email`. Guarde o email localmente a partir do formulário.

---

### `UserResponse` — Retorno de GET /profile/me
```json
{
  "id": 1,
  "email": "carlos@vitta.com",
  "name": "Carlos Mendes",
  "role": "professional",
  "is_active": true,
  "phone": "21999990000",
  "specialty": "Enfermeiro",
  "crm_coren": "COREN-RJ 123456",
  "rating": 4.8,
  "balance": 1200.00,
  "hobbies": ["futebol", "música"],
  "clinical_summary": null,
  "created_at": "2026-04-09T10:00:00Z"
}
```
> Campos `null` significam que o usuário não preencheu ou que o campo não se aplica à sua role.

---

### `ShiftResponse` — Retorno de GET /shifts e POST /shifts
```json
{
  "id": 3,
  "title": "Plantão Noturno - Copacabana",
  "description": "Cuidados com paciente idoso, medicamentos e acompanhamento noturno.",
  "hospital_name": "Residência Particular",
  "address": "Av. Atlântica, 1500 - Copacabana, Rio de Janeiro",
  "date_start": "2026-04-10T20:00:00",
  "date_end": "2026-04-11T08:00:00",
  "value": 450.00,
  "status": "open",
  "is_urgent": false,
  "professional_id": null,
  "created_at": "2026-04-09T10:00:00Z",
  "patient": {
    "name": "Sra. Maria Silva",
    "age": 79,
    "rating": 4.9,
    "medical_history": "Hipertensão arterial, diabetes tipo 2, mobilidade reduzida. Usa insulina NPH 10UI às 08h e 22h. Alergia a dipirona."
  }
}
```
> `status` pode ser: `open` | `assigned` | `in_progress` | `completed` | `cancelled`
> `is_urgent`: `true` quando o admin marca o plantão como urgente (substituiu a inferência por texto/data no frontend). Plantões programados e urgentes são o mesmo objeto `Shift`; este booleano altera tag, ordenação e precificação.
> `value`: para `is_urgent: true`, o backend armazena e retorna o valor final com multiplicador de urgência já aplicado. O frontend NÃO deve multiplicar novamente.
> Multiplicadores de urgência em `POST /shifts`: início em até 2h = `1.75x`; até 6h = `1.50x`; até 24h = `1.35x`; acima de 24h = `1.25x`.
> `patient`: objeto presente em todos os plantões. `age` e `rating` podem ser `null` se o familiar não preencheu. `medical_history` é `null` se não há histórico registrado.

---

### `PatientInfo` — Objeto aninhado em `ShiftResponse`
```json
{
  "name": "Sra. Maria Silva",
  "age": 79,
  "rating": 4.9,
  "medical_history": "Hipertensão arterial, diabetes tipo 2..."
}
```
| Campo | Tipo | Obrigatório | Descrição |
|-------|------|:-----------:|-----------|
| `name` | string | ✅ | Nome completo do paciente |
| `age` | integer | ❌ | Idade em anos |
| `rating` | float | ❌ | Média de avaliações de cuidadores anteriores (0–5) |
| `medical_history` | string | ❌ | Resumo clínico livre fornecido pela família |

---

## Endpoints

### Auth (Público)

#### `POST /auth/register`
Cria uma conta. Usuário começa com `is_active: false` e precisa de aprovação do admin.

**Body:**
```json
{
  "email": "usuario@email.com",
  "name": "Nome Completo",
  "password": "minimo6chars",
  "role": "professional | family",
  "phone": "21999990000",
  "specialty": "Enfermeiro",
  "crm_coren": "COREN-RJ 123456"
}
```
> `phone`, `specialty` e `crm_coren` são opcionais.
> `role: "admin"` é bloqueado — retorna `403`.

**Response `200`:** `Token` (ver schema acima)

---

#### `POST /auth/login`
**Body:**
```json
{
  "email": "usuario@email.com",
  "password": "suasenha"
}
```
**Response `200`:** `Token`
**Erros:**
- `401` — credenciais incorretas
- `403` — conta aguardando aprovação (`detail` explica)

---

#### `POST /auth/forgot-password`
**Body:**
```json
{ "email": "usuario@email.com" }
```
**Response `200`:**
```json
{ "message": "Se o email existir, você receberá um código de recuperação." }
```
> Sempre retorna sucesso para não revelar se o email existe.

---

#### `POST /auth/reset-password`
**Body:**
```json
{
  "email": "usuario@email.com",
  "reset_code": "483920",
  "new_password": "novasenha123"
}
```
**Response `200`:**
```json
{ "message": "Senha alterada com sucesso!" }
```

---

### Perfil (Autenticado)

#### `GET /profile/me`
**Response `200`:** `UserResponse`

---

#### `PUT /profile/me`
Atualiza campos do próprio perfil. Somente campos enviados são alterados (partial update).

**Body (todos opcionais):**
```json
{
  "name": "Novo Nome",
  "phone": "21999990001",
  "specialty": "Fisioterapeuta",
  "crm_coren": "CREFITO-RJ 000001",
  "hobbies": ["yoga", "leitura"],
  "clinical_summary": "Paciente com hipertensão..."
}
```
**Response `200`:** `UserResponse` atualizado

---

### Plantões (Autenticado)

#### `GET /shifts?skip=0&limit=100`
Retorna apenas plantões com `status: "open"`.

**Response `200`:** `Array<ShiftResponse>`

---

#### `POST /shifts`
Cria um novo plantão. **Restrito a admins.**

**Body:**
```json
{
  "title": "Plantão Noturno - Ipanema",
  "description": "Cuidados gerais.",
  "hospital_name": "Residência Particular",
  "address": "Rua Visconde de Pirajá, 100",
  "date_start": "2026-04-12T20:00:00",
  "date_end": "2026-04-13T08:00:00",
  "value": 480.00,
  "is_urgent": false,
  "patient": {
    "name": "Sr. Roberto Faria",
    "age": 72,
    "rating": null,
    "medical_history": "Pós-operatório de quadril. Requer auxílio na mobilização."
  }
}
```
**Response `200`:** `ShiftResponse`
**Erro:** `403` se não for admin.
> Se `is_urgent: true`, o `value` enviado é tratado como valor base e o backend retorna `ShiftResponse.value` com o multiplicador aplicado.

---

#### `GET /shifts/my?status=assigned&skip=0&limit=50`
Retorna plantões do profissional autenticado (onde `professional_id == current_user.id`).
Exclui plantões `cancelled`. Ordenados por `date_start DESC`.

**Query params opcionais:** `status` (aceita `assigned` ou `completed`; valores inválidos são ignorados), `skip`, `limit`

**Response `200`:** `Array<ShiftResponse>` — mesmo schema de `GET /shifts`

---

#### `POST /shifts/{shift_id}/apply`
Profissional aceita um plantão. Muda `status` para `assigned`. Cria `Conversation` automaticamente.

**Response `200`:**
```json
{ "message": "Plantão aceito com sucesso!" }
```
**Erros:**
- `404` — plantão não encontrado
- `409` — plantão não está `open` (já foi atribuído)

---

#### `POST /shifts/{shift_id}/cancel`
Profissional cancela um plantão aceito. Reduz `reliability_score` do profissional. Só permitido se `status: "assigned"`.

**Role:** profissional dono do shift ou `admin`

**Response `200`:**
```json
{ "message": "Plantão cancelado.", "reliability_score_delta": -5 }
```

**Erros:**
- `403` — usuário não é dono nem admin
- `409` — status não permite cancelamento (`in_progress`, `completed`)

---

### Admin (Apenas role `admin`)

#### `GET /admin/pending-users`
Lista usuários com `is_active: false`.

**Response `200`:** `Array<UserResponse>`

---

#### `POST /admin/approve-user/{user_id}`
Ativa a conta do usuário. Envia email de aprovação.

**Response `200`:**
```json
{ "message": "Usuário aprovado com sucesso.", "user_id": 5 }
```

---

#### `POST /admin/reject-user/{user_id}`
Remove o usuário do banco. Envia email de rejeição.

**Response `200`:**
```json
{ "message": "Usuário rejeitado e removido.", "user_id": 5 }
```

---

---

## Solicitações On-Demand (ServiceRequest)

> **Modelo Uber-like:** Família solicita cuidado imediato → entra no pool geoespacial → profissional aceita → status muda para matched.
> Distinto dos `Shift` (plantões programados criados pelo admin).

### `ServiceRequestResponse` — Schema canônico
```json
{
  "id": 1,
  "family_id": 3,
  "patient_name": "Sra. Maria (79 anos)",
  "address": "Rua Nascimento Silva, 107 - Ipanema, RJ",
  "lat": -22.9835,
  "lng": -43.1990,
  "notes": "Paciente acamada. Precisa de cuidados noturnos.",
  "status": "searching",
  "professional_id": null,
  "professional_name": null,
  "created_at": "2026-04-12T14:30:00Z",
  "matched_at": null
}
```
> `status` pode ser: `searching` | `matched` | `in_progress` | `completed` | `cancelled`

---

#### `POST /service-requests`
Família cria nova solicitação. Status inicial: `searching`.

**Role:** `family` (profissional e admin recebem `403`)

**Body:**
```json
{
  "patient_name": "Sra. Maria (79 anos)",
  "address": "Rua Nascimento Silva, 107 - Ipanema, RJ",
  "lat": -22.9835,
  "lng": -43.1990,
  "notes": "Paciente acamada."
}
```
> `lat`, `lng`, `notes` são opcionais no MVP.

**Response `201`:** `ServiceRequestResponse`

---

#### `GET /service-requests/mine`
Família vê suas próprias solicitações (exceto `cancelled`), mais recentes primeiro.

**Role:** qualquer usuário ativo (retorna lista vazia para profissional/admin)

**Response `200`:** `Array<ServiceRequestResponse>`

---

#### `GET /service-requests/nearby`
Pool de solicitações com `status: "searching"` visível pelos profissionais.
> Fase 2: filtrar por raio geoespacial com PostGIS. Por ora, retorna todas.

**Role:** `professional` ou `admin`

**Response `200`:** `Array<ServiceRequestResponse>`

---

#### `GET /service-requests/accepted`
Solicitações aceitas pelo profissional autenticado (`status: matched` ou `in_progress`), ordenadas por `matched_at` desc.

> **Bypass:** retorna `_mockAcceptedRequests` filtrados por `status == matched || status == in_progress`.

**Role:** `professional` ou `admin`

**Response `200`:** `Array<ServiceRequestResponse>` onde `professional_id == current_user.id`

---

#### `POST /service-requests/{id}/accept`
Profissional aceita uma solicitação. `status` → `matched`. Remove do pool público.

**Role:** `professional` ou `admin`

**Response `200`:** `ServiceRequestResponse` atualizado com `professional_id`, `professional_name`, `matched_at`

**Erros:**
- `404` — solicitação não encontrada
- `409` — `status != "searching"` (já foi aceita por outro profissional)

---

#### `POST /service-requests/{id}/cancel`
Família cancela uma solicitação. Só permitido se `status` for `searching` ou `matched`.

**Role:** família dona da solicitação ou `admin`

**Response `200`:**
```json
{ "message": "Solicitação cancelada com sucesso.", "id": 1 }
```

**Erros:**
- `403` — usuário não é dono nem admin
- `409` — status não permite cancelamento (`in_progress`, `completed`)

---

## Chat

> **Modelo:** Conversa 1-para-1 vinculada a um `ServiceRequest` (ou `Shift`). Criada automaticamente quando o profissional aceita. Mensagens em tempo real são fase 2 (WebSocket); MVP usa polling.

### `ConversationResponse` — Schema canônico
```json
{
  "id": 1,
  "request_id": 7,
  "request_type": "service_request",
  "family_id": 3,
  "professional_id": 12,
  "family_name": "Ana Lima",
  "professional_name": "Carlos Mendes",
  "patient_name": "Sra. Maria Lima",
  "last_message": "Estarei aí em 20 minutos.",
  "last_message_at": "2026-04-13T15:42:00Z",
  "unread_count": 2,
  "visit_date": "2026-04-14T14:00:00Z"
}
```
> `visit_date`: `date_start` do Shift vinculado (null para ServiceRequest — on-demand não tem janela de bloqueio). `patient_name`: nome do paciente da solicitação/plantão, para exibição na lista de conversas.

**Regra de negócio — Chat Gating:**
- `ServiceRequest` (on-demand): chat disponível imediatamente após aceite (`matched`).
- `Shift` (programado): chat disponível apenas 24h antes de `visit_date`. Frontend bloqueia a entrada na conversa antes disso.

### `MessageResponse` — Schema canônico
```json
{
  "id": 55,
  "conversation_id": 1,
  "sender_id": 12,
  "sender_name": "Carlos Mendes",
  "sender_role": "professional",
  "content": "Estarei aí em 20 minutos.",
  "sent_at": "2026-04-13T15:42:00Z",
  "read": false
}
```

---

#### `GET /chat/conversations`
Lista todas as conversas do usuário autenticado (família ou profissional), ordenadas por `last_message_at DESC`.

**Role:** `family` ou `professional`

**Response `200`:** `Array<ConversationResponse>`

---

#### `GET /chat/conversations/{conversation_id}/messages?skip=0&limit=50`
Retorna mensagens de uma conversa. Marca como lidas as mensagens do outro lado.

**Role:** participante da conversa (family_id ou professional_id)

**Response `200`:** `Array<MessageResponse>` — mais antigas primeiro

**Erros:**
- `403` — usuário não é participante
- `404` — conversa não encontrada

---

#### `POST /chat/conversations/{conversation_id}/messages`
Envia uma mensagem.

**Role:** participante da conversa

**Body:**
```json
{ "content": "Texto da mensagem (máx 1000 chars)" }
```

**Response `201`:** `MessageResponse`

**Erros:**
- `403` — usuário não é participante
- `409` — conversa em status `closed` (solicitação concluída/cancelada)

---

#### `GET /chat/conversations/by-request/{request_id}`
Busca a conversa associada a uma solicitação específica. Usado pelo frontend para abrir o chat direto após aceitar.

**Query param:** `request_type=service_request|shift` (default: `service_request`)

**Role:** participante da conversa

**Response `200`:** `ConversationResponse`

**Erro:** `404` — conversa ainda não existe (solicitação ainda em `searching`)

---

> ⚠️ **Criação automática de conversa:** o backend cria a `Conversation` automaticamente em `POST /service-requests/{id}/accept` e em `POST /shifts/{id}/apply`. O frontend não precisa criar conversas manualmente.

---

## FAQ

> FAQ público, gerenciado pelo admin. Leitura disponível para todos os usuários autenticados (family e professional). Escrita restrita ao admin.

### `FAQItemResponse` — Schema canônico
```json
{
  "id": 1,
  "category": "Pagamentos",
  "question": "Como funciona o pagamento dos plantões?",
  "answer": "O pagamento é processado automaticamente após a conclusão do plantão, com repasse em até 2 dias úteis.",
  "order": 1,
  "target_roles": ["professional", "family"],
  "updated_at": "2026-04-13T00:00:00Z"
}
```
> `target_roles`: quais perfis visualizam essa pergunta. `["professional", "family"]` = todos.

---

#### `GET /faq`
Lista todos os itens de FAQ visíveis para o role do usuário autenticado, ordenados por `category` e `order`.

**Role:** qualquer usuário ativo

**Query params opcionais:** `category=Pagamentos` (filtrar por categoria)

**Response `200`:** `Array<FAQItemResponse>`

---

#### `POST /faq` *(Admin only)*
Cria novo item de FAQ.

**Body:**
```json
{
  "category": "Plantões",
  "question": "Como cancelo um plantão aceito?",
  "answer": "Entre em contato com o suporte em até 2h antes do início.",
  "order": 2,
  "target_roles": ["professional"]
}
```

**Response `201`:** `FAQItemResponse`

---

#### `PUT /faq/{id}` *(Admin only)*
Atualiza um item. Todos os campos opcionais (partial update).

**Response `200`:** `FAQItemResponse`

---

#### `DELETE /faq/{id}` *(Admin only)*
Remove um item.

**Response `200`:** `{ "message": "Item removido." }`

---

## Roles e Permissões

| Role | Pode fazer |
|------|-----------|
| `family` | Login, ver próprio perfil, criar/cancelar ServiceRequests, ver pool de shifts (leitura), chat, FAQ |
| `professional` | Login, ver próprio perfil, ver plantões abertos, aceitar plantão, ver/aceitar ServiceRequests próximos, chat, FAQ |
| `admin` | Tudo acima + criar/editar/remover FAQ + aprovar/rejeitar usuários + criar plantões |

---

## Campos por Role (no modelo `User`)

| Campo | professional | family | admin |
|-------|:-----------:|:------:|:-----:|
| `specialty` | ✅ | ❌ | ❌ |
| `crm_coren` | ✅ | ❌ | ❌ |
| `rating` | ✅ | ❌ | ❌ |
| `balance` | ✅ | ❌ | ❌ |
| `hobbies` | ✅ | ✅ | ❌ |
| `clinical_summary` | ❌ | ✅ | ❌ |

---

## Changelog

| Data | Versão | Mudança |
|------|--------|---------|
| 2026-04-25 | 2.8.1 | UX (frontend-only): card "IMEDIATO" da home profissional agora abre `OnDemandDetailsDialog` (popup com paciente, endereço, distância, observações, status e atalhos para Mensagens/Ver tudo) — usa `ServiceRequestResponse` existente, sem mudança de endpoint. Removida seção órfã "Informações do Plantão" da home (atalhos clínicos sem contexto); `HealthAssessmentSheet` e `MedicationsSheet` continuam acessíveis a partir de `PatientDetailsDialog`. |
| 2026-04-16 | 2.8.0 | BE-006 e BE-007 implementados e validados pelo Tech Lead. Bug crítico corrigido: `POST /shifts/{id}/apply` não cria mais Conversation (Shift não tem family_id — bloco removido com TODO). `GET /service-requests/accepted` retorna `[]` para family/admin em vez de 403. Shift chat pendente de redesign de modelo. |
| 2026-04-13 | 2.7.0 | GET /service-requests/accepted documentado (profissional busca suas solicitações ativas); garbled strings em `on_demand_repository.dart` corrigidos |
| 2026-04-13 | 2.7.0 | `is_urgent` definido como única fonte de verdade para plantões urgentes; `POST /shifts` aplica multiplicador progressivo no `value` quando `is_urgent=true`; frontend exibe tag/ordena pelo booleano sem criar tipo separado |
| 2026-04-13 | 2.6.0 | ShiftResponse ganha `is_urgent` (boolean) e objeto aninhado `patient` (`name`, `age`, `rating`, `medical_history`); `PatientInfo` schema documentado; POST /shifts body atualizado com novos campos; remove workarounds de inferência de urgência no frontend |
| 2026-04-13 | 2.5.0 | ConversationResponse ganha `patient_name` e `visit_date`; chat gating rule documentada (24h antes da visita); POST /shifts/{id}/cancel adicionado com `reliability_score_delta`; detalhe de Shift e ServiceRequest acessíveis pelo frontend via extras de rota |
| 2026-04-13 | 2.4.0 | Chat (Conversation + Message) e FAQ adicionados; criação automática de Conversation em /accept e /apply; Roles atualizados |
| 2026-04-12 | 2.3.0 | ServiceRequest (modelo Uber-like) adicionado: POST /service-requests, GET /mine, GET /nearby, POST /accept, POST /cancel — delegado ao Codex em TAREFA-BE-005 |
| 2026-04-09 | 2.2.0 | `PUT /profile/me` documentado; JWT real marcado como pendente de implementação (TAREFA-BE-004); `UserUpdate` schema adicionado |
| 2026-04-09 | 2.1.0 | `GET /shifts/my` adicionado (plantões do profissional autenticado, ordenados por data desc, exclui cancelled) |
| 2026-04-09 | 2.0.0 | JWT real especificado como alvo; `/profile/me` adicionado; `reset_password` migrado para body; `hobbies`, `rating`, `balance`, `clinical_summary` adicionados ao modelo |
| — | 1.0.0 | Versão inicial com JWT falso (estado atual em produção — aguardando BE-004) |
