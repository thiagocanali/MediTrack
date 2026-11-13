# Consolidação MediTrack / MedCheck / PillPilot

## Decisão
**Repositório canônico:** thiagocanali/MediTrack.
**Produto:** assistente de tratamento e adesão medicamentosa; nome comercial provisório PillPilot.
**Stack alvo:** Flutter (Android/iOS), Firebase Auth, Cloud Firestore e notificações locais.
**Editor principal:** Flutter/VS Code; FlutterFlow é referência de protótipo, não fonte simultânea de alterações no código exportado.

## Fontes e preservação
- MediTrack: código legado de 2024 na branch `flutcode`, snapshot em `backup/legacy-2024-v1.5` (37d4f288).
- MedCheck: repositório separado, sem código confirmado na auditoria; não apagar nem arquivar até validar referências externas.
- FlutterFlow: projeto `pill-pilot-bxwppz`; código completo **não importado**. Solicitar export Flutter completo (ZIP) antes de incorporar UI, sem substituir arquivos cegamente.
- Conversa de produto: requisitos documentados em `docs/PRODUCT_REQUIREMENTS.md`.

## Problemas comprovados no legado
1. Consulta `collection('medications').snapshots()` sem filtro por UID; cadastro não associa dono.
2. Não há gate de autenticação em `main.dart`; Firebase Auth consta nas dependências, mas isso não demonstra login funcional.
3. Notificações usam ID fixo 0 e exclusão chama `cancelAll()`.
4. Cadastro escreve `name` e `timestamp`, edição escreve `reminderTime`; modelo inconsistente.
5. Repetição diária, histórico de doses e estoque não foram demonstrados.
6. Dependências de 2024 requerem compatibilidade e build verificáveis.

## Sequência de migração
1. Inventariar arquivos e testar build do legado, sem dados pessoais.
2. Exportar FlutterFlow e comparar recursos e configuração Firebase.
3. Escolher estrutura Flutter única e documentar mapeamento legado -> novo.
4. Implementar autenticação e regras Firestore **antes** de permitir usuários reais.
5. Migrar dados com scripts idempotentes, backup, dry-run e plano de rollback.
6. Implementar CRUD, horários recorrentes, logs de doses e notificações com IDs estáveis.
7. Testes unitários, widgets, integração, Android/iOS, segurança e acessibilidade.
8. Apenas após verificação: definir branch padrão `main` e arquivar MedCheck como legado com link para canônico.

## Não fazer
- Não mesclar repositórios com históricos não relacionados sem comparação.
- Não remover código ou dados de produção automaticamente.
- Não publicar credenciais, chaves privadas, service accounts ou dados clínicos.
- Não trocar configuração Firebase existente por outra sem inventário.
- Não oferecer orientação personalizada de dose/interação sem fonte clínica validada e supervisão apropriada.

## Critérios de aceite da consolidação
- Um repositório canônico; histórico preservado; README e AGENTS.md atualizados.
- Projeto compila e testes passam; Firebase Auth e regras de acesso validados.
- Nenhum paciente enxerga dados de outro.
- Notificações isoladas por medicamento/dose e recorrência testada.
- Importação FlutterFlow rastreável; MedCheck só arquivado após revisão.
