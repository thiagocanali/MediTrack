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


## Inventário Neon em 15/11/2026

A organização conectada possui projetos separados para `thiagocanali-hub`, `monsys`, `cleanair-gestao`, `pokemon-tracker`, `pagino`, `conectados-em-cristo`, `taskdesk` e `meaprovae`. **Não foi identificado projeto Neon específico para MediTrack.** Nenhum projeto novo foi criado para evitar consumo não avaliado da cota. Os testes seguem executados em PostgreSQL descartável do GitHub Actions.

## Acompanhamento

| Prioridade | Tarefa | Estado | Evidência / próxima ação |
| --- | --- | --- | --- |
| P0 | Validar schema e RLS em PostgreSQL isolado | Validada | CI #43750752934 aprovada para HEAD 93bfca2; revalidar commits posteriores |
| P0 | Revisar isolamento e duplicidade das doses | Em andamento | Testes RLS e índice único; ampliar casos |
| P1 | Inventariar contratos legados Firebase | Em andamento | FIREBASE_CONTRACT_INVENTORY.md; ampliar para regras e doses |
| P1 | Projetar backend de autenticação independente | Em andamento | API_CONTRACT.md proposto; implementar protótipo e testes |
| P1 | Provisionar Neon dedicado | Bloqueada | Avaliar capacidade do plano e confirmar ausência de duplicidade |
| P1 | Migrar Flutter sem perda de dados | Pendente | Depende de API, autenticação e homologação |

## Lote de integridade — 15/11/2026

- Migration `0002_medication_name_limit.sql`: limite de 160 caracteres no banco.
- Teste `integrity_smoke.sql`: duplicidade de ocorrência, tamanho de nome e exclusão com histórico.
- Teste `dose_write_rls.sql`: tentativa de escrita de dose por outro usuário. **Arquivo criado; integração na CI ainda pendente**.
- A CI existente foi atualizada para executar `0002` e `integrity_smoke.sql`; conferir checks do HEAD antes de validar.
- `flutter analyze`, `flutter test` e builds Android/iOS não foram executados neste lote: não houve alteração Flutter e a execução conectada não disponibilizou SDK Flutter.

### Próximas cinco tarefas

1. P0: conferir CI do HEAD e corrigir falhas SQL.
2. P0: incluir `dose_write_rls.sql` na CI e validar o cenário.
3. P1: implementar camada HTTP autenticada sem expor credenciais.
4. P1: mapear integralmente campos Firestore e regras de exclusão de dados.
5. P1: testar concorrência de registro de doses e idempotência.

## Lote: camada de dados autenticada (15/11/2026)

- `src/medications.cjs`: protótipo de camada de dados, com identidade UUID validada, `BEGIN` / `set_config(..., true)` / `COMMIT`, rollback e liberação da conexão em `finally`.
- Funções: listagem limitada a 100 registros, criação e alteração de nome. **Não é uma API HTTP e não autentica sessões**; o chamador deverá fornecer identidade já verificada.
- `tests/medications.test.cjs`: testes de validação, isolamento do parâmetro de identidade, rollback e queries parametrizadas, integrados à CI.
- `tests/dose_write_rls.sql`: integrado à CI PostgreSQL para verificar rejeição de escrita cruzada.
- Nenhuma integração com Neon, alteração de produção ou migração de dados foi realizada.

### Pendências seguintes

1. Verificar CI do commit atual e corrigir falhas.
2. Integrar testes PostgreSQL com papel real de aplicação e concorrência.
3. Implementar autenticação independente, gestão segura de sessões e endpoints HTTP.
4. Reconciliar contratos de doses e dados legados antes da migração.
5. Avaliar criação de projeto Neon isolado e plano de migração com rollback.
