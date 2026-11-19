# Contrato HTTP v1 — proposta para implementação

Base: `/api/v1`. Todas as rotas de medicamentos exigem sessão válida, HTTPS e autorização pelo usuário autenticado. A API nunca aceita `userId` como autoridade.

## Sessão

- `POST /auth/register`: cadastro de conta; validação e tratamento de e-mail duplicado.
- `POST /auth/login`: autenticação; rate limiting e respostas sem vazamento de existência de conta.
- `POST /auth/logout`: invalida sessão.
- `GET /auth/me`: retorna `{id, email}` da sessão atual.
- `POST /auth/password-reset/request`: resposta genérica, sem enumerar e-mails.
- Cookies `HttpOnly`, `Secure`, `SameSite` para clientes web; clientes Flutter precisam de transporte seguro e armazenamento protegido de credenciais de sessão. Definir estratégia concreta na implementação.

## Medicamentos

| Método | Rota | Corpo | Resposta |
| --- | --- | --- | --- |
| GET | `/medications` | — | `{items: Medication[], nextCursor: string?}` |
| POST | `/medications` | `{name: string}` | `201 Medication` |
| PATCH | `/medications/:id` | `{name?: string, active?: boolean}` | `200 Medication` |
| DELETE | `/medications/:id` | — | `204` após política de retenção definida |
| GET | `/medications/:id/doses` | — | `{items: DoseLog[]}` |
| POST | `/medications/:id/doses` | `{scheduledFor: ISO8601, status: 'taken'}` | `201 DoseLog` ou `409` para ocorrência duplicada |

`Medication`: `{id: uuid, name: string, active: boolean, createdAt: ISO8601, updatedAt: ISO8601}`.

`DoseLog`: `{id: uuid, medicationId: uuid, scheduledFor: ISO8601, recordedAt: ISO8601, status: 'taken'}`.

- Nome: trim, 1 a 160 caracteres; validar no servidor.
- IDs: UUIDs gerados pelo servidor; para migração Firestore criar tabela de correspondência antes de copiar dados.
- Paginação: cursor estável por `createdAt` + `id`, ordem decrescente.
- Erros: `{error: {code, message}}`; usar `401` sem sessão, `404` para recurso inexistente **ou de outro usuário**, `422` para validação, `409` para duplicidade.
- Isolamento: RLS + filtro explícito por identidade da sessão; não usar `userId` do corpo/query.
- Concorrência: restrição única `(medication_id, scheduled_for)` garante que duas confirmações simultâneas não gerem duplicatas.
- Exclusão: **bloqueada** até definir retenção de histórico e implicações de LGPD. Não fazer `CASCADE` silencioso.
- Não alterar tratamentos ou gerar recomendações médicas a partir dos registros.

## Status

Este é um **contrato proposto**, não endpoints implementados. Antes de conectar Flutter, implementar testes de autenticação, autorização cruzada, transações com `app.user_id`, erro 404, concorrência, paginação e logout.
