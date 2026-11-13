# Instruções para agentes — MediTrack

Leia `docs/CONSOLIDATION.md` e `docs/PRODUCT_REQUIREMENTS.md` antes de alterar código.

1. Fonte canônica: este repositório. `flutcode` é legado; backup `backup/legacy-2024-v1.5`.
2. Trabalhe em branches de feature e PRs pequenos; não apague repositórios ou dados.
3. Nunca faça merge automático de export FlutterFlow sem revisão de diff e testes.
4. Priorize isolamento de dados, autenticação, consistência de doses e confiabilidade dos alarmes.
5. Para mudanças em Firestore, entregue regras, índices, testes de segurança e migração/rollback quando necessário.
6. Para qualquer alteração, execute `flutter analyze`, `flutter test` e builds compatíveis com ambiente; documente o que não pôde executar.
7. Não invente recomendações médicas, diagnósticos ou validação clínica. Conteúdo informativo deve ter fonte.
8. Não commite credenciais ou dados reais de pacientes. Configurações públicas do Firebase não substituem regras de segurança.
9. Preserve arquitetura existente até haver plano de migração; não refatore tudo em uma única PR.
10. Reporte funcionalidades efetivamente testadas, não apenas implementadas.
