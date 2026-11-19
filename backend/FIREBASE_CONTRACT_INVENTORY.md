# Inventário de contratos Firebase — MediTrack

Fonte: código da branch base `flutcode`, verificado em 15/11/2026. Este documento descreve apenas os arquivos inspecionados; não representa varredura completa do repositório.

## Autenticação (`MediTrack/lib/main.dart`)

- Inicialização: `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)`.
- Sessão: `FirebaseAuth.instance.authStateChanges()`, com tela de login quando não autenticado.
- Cadastro: `createUserWithEmailAndPassword`.
- Login: `signInWithEmailAndPassword`.
- Logout: `FirebaseAuth.instance.signOut()` na tela de medicamentos.
- Identidade: `user.uid` passado como `userId` à tela de medicamentos.

## Medicamentos (`MediTrack/lib/screens/medication_list_screen.dart`)

- Coleção: `users/{userId}/medications`.
- Listagem em tempo real: `orderBy('createdAt', descending: true).snapshots()`.
- Criação: `add({name, active: true, createdAt: serverTimestamp, updatedAt: serverTimestamp})`.
- Nome limitado a 160 caracteres no formulário; a API deve impor esse limite independentemente do Flutter.
- O ID Firestore é gerado automaticamente e **não** é UUID. A migração precisa de mapeamento de IDs ou tipo de chave compatível.

## Edição e exclusão (`MediTrack/lib/screens/edit_medication_screen.dart`)

- Documento: `users/{userId}/medications/{documentId}`.
- Edição: `update({name, updatedAt: serverTimestamp})`.
- Exclusão: `delete()` após confirmação na interface.
- Atenção: `ON DELETE RESTRICT` na migration PostgreSQL impede excluir medicamentos que tenham histórico de doses. Definir política de exclusão e retenção antes de conectar a UI.

## Lacunas a resolver

1. O schema inicial não implementa ainda um mapeamento para IDs Firestore nem streaming/realtime de listagem.
2. O backend deve derivar a identidade da sessão e ignorar `userId` arbitrário fornecido pelo cliente.
3. O modelo de dose e os campos de horário precisam ser reconciliados com as PRs #9–#11 antes de criar APIs.
4. As funções de recuperação de senha e exclusão de conta constam dos requisitos, mas não foram verificadas nos arquivos de UI acima.
5. Nenhuma credencial Firebase/Neon deve ser colocada em documentação, logs ou no aplicativo.

## Próxima implementação

Criar contratos HTTP versionados para autenticação, listagem, criação, edição e exclusão; depois implementar backend e testes com dois usuários em PostgreSQL descartável.
