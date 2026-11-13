# Requisitos de produto — assistente de tratamento

## Visão
Aplicativo leve e acessível para Android e iOS, com foco em pessoas que utilizam medicamentos contínuos, múltiplos horários e precisam de apoio para manter uma rotina de tratamento.

## MVP (P0)
- Login/cadastro/recuperação de acesso, exclusão de conta e dados.
- Medicamentos por usuário: catálogo opcional, cadastro manual, dose prescrita, apresentação, horário(s), data inicial/final ou uso contínuo, edição e exclusão.
- Registro por ocorrência: tomei, adiar, pulei, não registrado; timestamp, fuso, prevenção de duplicidade e histórico.
- Lembretes locais recorrentes, permissões, reagendamento e cancelamento individuais; comportamento documentado quando sistema restringe alarmes.
- Tela Hoje com status claro, botões grandes e acessibilidade.
- Estoque opcional, decremento consistente e aviso de reposição.

## Evolução (P1)
- Diário de humor e sono simples; sintomas e efeitos relatados pelo usuário.
- Consultas, receitas e documentos com controles de acesso.
- Relatórios de adesão e exportação para profissionais.
- Cuidadores com convite, consentimento explícito, escopo limitado e revogação.
- Contatos de confiança e recursos de apoio emocional; nunca substituir serviços de emergência.

## Pesquisa e IA (P2, sujeita a validação)
- Catálogo de medicamentos curado com fontes confiáveis, versão e data.
- Solicitação de inclusão quando medicamento não constar.
- Conteúdo educativo e alertas de possível interação somente quando sustentados por base validada; encaminhar ao farmacêutico/médico.
- Nunca alterar prescrição, recomendar interrupção ou inferir diagnóstico.
- Correlações de humor/sono/adesão são descritivas, não causais.

## Requisitos transversais
- Privacidade por padrão, LGPD e minimização de dados sensíveis.
- Autenticação, regras Firestore por proprietário, testes de acesso cruzado, App Check e auditoria.
- Sem dados pessoais em Crashlytics, analytics ou logs.
- UX em português, texto ampliável, contraste, modo simples, suporte offline e estados de erro claros.
- Não declarar pronto para produção sem testes Android/iOS e revisão clínica/regulatória.
