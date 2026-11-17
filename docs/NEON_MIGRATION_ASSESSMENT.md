# Avaliação de migração: Firebase → Neon PostgreSQL

## Estado confirmado no código (15/11/2026)

- Aplicativo Flutter em `MediTrack/`.
- `firebase_core`, `firebase_auth` e `cloud_firestore` declarados em `MediTrack/pubspec.yaml`.
- `MediTrack/lib/main.dart` inicializa Firebase e usa `FirebaseAuth.instance.authStateChanges()`, cadastro e login por e-mail/senha.
- O acesso a medicamentos usa documentos Firestore sob `users/{uid}/medications`; `firestore.rules` protege o acesso por UID.
- PRs #9, #10 e #11 tratam histórico de doses e ainda não foram integradas.
- Nenhuma dependência Supabase foi identificada nos arquivos acima; isto não é uma auditoria exaustiva de todo o repositório.

## Decisão de arquitetura

Neon fornece PostgreSQL, **não** um endpoint seguro de acesso direto do Flutter nem substituto de Firebase Auth. Nunca colocar `DATABASE_URL` no aplicativo móvel.

Arquitetura-alvo proposta: Flutter → API autenticada HTTPS → PostgreSQL Neon. O backend é responsável por sessões, validação, autorização por usuário, consultas parametrizadas e transações. Avaliar Better Auth em backend TypeScript, com compatibilidade do fluxo de autenticação Flutter; não escolher biblioteca sem protótipo validado.

## Sequência segura de implementação

1. Inventariar integralmente operações Firebase Auth/Firestore, dados e fluxos de notificações; classificar dados reais.
2. Confirmar projeto Neon existente antes de provisionar outro; usar banco e branch de teste isolados, SSL e credenciais somente no backend.
3. Definir contratos versionados de API e migrations SQL para usuários, medicamentos e doses; impor unicidade de ocorrência por medicamento, FK e índices por usuário.
4. Implementar backend com autenticação independente, autorização e testes de acesso cruzado, sem remover Firebase.
5. Implementar cliente Flutter com adaptador alternável em homologação; testar cadastro, login, CRUD, histórico e funcionamento offline.
6. Migrar dados reais com consentimento e verificação de integridade; nunca presumir que dados antigos podem ser apagados.
7. Executar testes de integração, segurança e recuperação, e só então planejar corte de produção com rollback.

## Critérios de segurança

- Senhas nunca em texto puro; hash seguro e sessões revogáveis.
- Identidade de usuário derivada da sessão, nunca confiada de um `uid` recebido do cliente.
- Segredos somente em variáveis do servidor/CI; nenhuma credencial PostgreSQL no bundle Flutter.
- Dados reais não são descartados por padrão.
- Sem deploy de produção, exclusão de Firebase ou migração destrutiva nesta etapa.

## Estado

**Avaliação inicial documentada; migração ainda não iniciada.** A criação de projeto Neon e a implementação do backend dependem de auditoria de código e escolha/validação do ambiente. O plano não representa testes aprovados.
