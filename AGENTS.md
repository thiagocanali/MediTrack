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

## Desenvolvimento autônomo com proteção

- Execute lotes de 5 a 10 tarefas relacionadas. Faça commits rastreáveis e um relatório consolidado ao final do lote; não pare após cada tarefa.
- Antes de abrir PR, pesquise PRs abertas da mesma frente. Atualize a existente; mantenha no máximo uma PR ativa por frente, salvo dependência técnica documentada. Não crie PR por tarefa.
- Trabalhe sempre em branch dedicada. Nunca faça commit direto em `flutcode` nem force-push para contornar conflitos ou verificações.
- Rode testes relevantes, análise estática e CI. Corrija falhas antes de integrar. Se uma verificação não puder rodar, registre o motivo e não declare sucesso.
- Prefira squash merge após aprovação das verificações e revisões obrigatórias. Auto-merge só quando habilitado no repositório e permitido pelas proteções; nunca contorne revisões ou checks.
- Não integre PR em draft, incompleta, com vulnerabilidades conhecidas ou com verificações pendentes/falhando.
- Alterações de autenticação, Firestore/PostgreSQL, RLS, permissões, segredos, migrações e produção exigem revisão adicional, testes de segurança, plano de rollback e autorização explícita quando houver impacto real.
- Não altere branch protection, rulesets, configuração de produção, deploys ou recursos pagos sem inspecionar as consequências e obter autorização específica.
- Minimize previews e deploys Vercel: use testes locais/Actions, agrupe alterações e só valide hospedado quando necessário; não desabilite verificações de segurança para economizar cota.
- Preserve a fonte canônica, backups e dados clínicos. Não exponha tokens nem dados de pacientes em logs, artefatos, commits ou fixtures.
- Atualize o planejamento com tarefas concluídas, pendentes, bloqueios, CI e PR existente. Continue tarefas independentes enquanto houver capacidade de execução.
