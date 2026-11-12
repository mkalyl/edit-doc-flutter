# EditDoc Flutter (`edit_doc_flutter`)

Aplicativo Flutter de gerenciamento e edição de documentos estruturado em **MVVM (Model-View-ViewModel)** e configurado para execução direta no **GitHub Codespaces** (Flutter Web Preview na porta `8080`).

## Estado Atual (Etapa 4 - Fase 1)
- Estrutura completa de pastas MVVM (`models`, `viewmodels`, `views`, `utils`, `theme`).
- Telas migradas: **Login** (`/`), **Cadastro** (`/cadastro`) e **Home/Lista** (`/home`) com estado gerenciado por `ChangeNotifier` e `ListenableBuilder`.
- Relatório Técnico de Migração disponível em [`ARQUITETURA.md`](./ARQUITETURA.md).

## Como Executar no GitHub Codespaces
1. Abra o repositório no **GitHub Codespaces** (a imagem `ghcr.io/cirruslabs/flutter:stable` e o `flutter pub get` serão configurados automaticamente via `.devcontainer/devcontainer.json`).
2. Pressione **`F5`** (ou abra **Run and Debug** -> `Rodar App Flutter (Web Preview)`).
3. O preview web abrirá automaticamente na porta **`8080`**.
4. Conta demo para teste rápido: `aluno@editdoc.com` / `123456` (ou crie uma nova conta em **Criar nova conta**).

> **Lembrete:** Ao encerrar a atividade, realize `git add .`, `git commit`, `git push` e encerre (Stop) o Codespace em `github.com/codespaces` para economizar sua cota mensal gratuita.
