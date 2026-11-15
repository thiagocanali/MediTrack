# Contrato de isolamento PostgreSQL (protótipo)

## Execução local

A CI executa `backend/migrations/0001_initial.sql` em PostgreSQL 16 descartável e roda `backend/tests/rls_smoke.sql` com `ON_ERROR_STOP=1`. Não usa credenciais Neon nem deploys Vercel.

## Segurança de acesso

- **Nunca** conectar Flutter diretamente ao PostgreSQL nem embutir `DATABASE_URL` no APK/IPA.
- A API deverá autenticar cada requisição, derivar o UUID da conta da sessão e usar um papel SQL de aplicação **sem** `BYPASSRLS`, sem superuser e sem propriedade das tabelas.
- Para cada operação, abrir transação e executar `SELECT set_config('app.user_id', $1, true)` com o UUID derivado da sessão, usando conexão reservada à transação. Executar as queries e finalizar a transação antes de devolver a conexão ao pool.
- Não utilizar `SET` de escopo de sessão em conexões compartilhadas. Não confiar no `user_id` enviado pelo cliente.
- As tabelas `medications` e `dose_logs` usam RLS e `FORCE ROW LEVEL SECURITY`. A tabela `app_users` permanece inacessível ao papel da API até que seja definida política de conta e autenticação.
- O teste RLS precisa usar um papel não administrador. Testar como `postgres` sozinho não comprova isolamento.

## Limitações do primeiro schema

- Ainda não existe backend HTTP, autenticação independente, migração de dados ou conexão Neon.
- O schema não cobre todos os campos legados Firestore, horários recorrentes, anexos e configurações de notificação. Não aplicar em produção.
- A autenticação precisa de uma migration própria para contas e sessões após a escolha do provedor.
- `dose_logs` garante unicidade de `(medication_id, scheduled_for)` no banco, mas a API ainda precisará validar se a ocorrência pertence à agenda autorizada.

## Próximos testes

1. Rejeição de leitura, escrita e exclusão entre contas.
2. Isolamento de `dose_logs`, inclusive ausência de identidade e rollback.
3. Testes da API para cadastro, login, logout e acesso não autorizado.
4. Teste de concorrência de confirmações duplicadas.
