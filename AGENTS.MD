# AGENTS.MD - Mapa Arquitetural e Registro de Evolução (`edit_doc_flutter`)

Este arquivo deve ser consultado e atualizado a cada feature, refactor ou correção neste repositório.

## 1. Visão Geral e Ambiente (GitHub Codespaces)
- **Projeto:** `edit_doc_flutter` (Editor de Documentos em Flutter Web/Mobile).
- **Arquitetura:** MVVM (Model - View - ViewModel) com `ChangeNotifier` + `ListenableBuilder` e persistência via `shared_preferences`.
- **Ambiente Codespaces:**
  - `.devcontainer/devcontainer.json`: Imagem `ghcr.io/cirruslabs/flutter:stable`, porta `8080` com `onAutoForward: openPreview`, extensões Dart/Flutter e `postCreateCommand` (`safe.directory` + `flutter pub get`).
  - `.vscode/launch.json`: Configuração `Rodar App Flutter (Web Preview)` executando `-d web-server --web-port 8080 --web-hostname 0.0.0.0`.
  - `web/`: Arquivos web (`index.html` com `flutter_bootstrap.js`, `manifest.json`, ícones) prontos para execução imediata.

## 2. Regras de Negócio da Aplicação
1. **Autenticação e Cadastro de Usuários:**
   - Campos obrigatórios validados por `Validadores`: nome (>= 3 caracteres), e-mail válido e senha (>= 6 caracteres).
   - E-mails normalizados com `trim().toLowerCase()`.
   - Cadastro impede duplicidade de e-mail.
   - Usuário demo inicial (`aluno@editdoc.com` / `123456`) disponível apenas quando não houver usuários cadastrados.
2. **Sessão e Tema Reativo:**
   - Tema Claro/Escuro alternável via `AuthViewModel.alternarTema()` e refletido reativamente no `MaterialApp`.
   - Na Fase 2 (Etapa 5), tema e sessão do usuário são persistidos via `PreferencesService` (`shared_preferences`), sobrevivendo a recarregamentos (`F5`).
3. **Gestão de Documentos:**
   - Cada documento possui `id`, `titulo`, `conteudo`, `categoria`, `autorEmail`, `criadoEm` e `atualizadoEm`.
   - Documentos são isolados por `autorEmail` e ordenados do mais recente (`atualizadoEm`) para o mais antigo.
   - Busca textual por título/conteúdo e filtro por categoria (`Todas`, `Geral`, `Estudos`, `Trabalho`, `Pessoal`).
   - Exclusão exige confirmação explícita do usuário.

## 3. Mapa de Módulos e Funções
*(Em construção conforme etapas do roteiro — será alimentado na Etapa 4 e Etapa 5).*

| Arquivo | Responsabilidade | Principais Classes / Funções |
|---|---|---|
| `.devcontainer/devcontainer.json` | Container Flutter Web para Codespaces | Configura SDK, porta 8080 e `flutter pub get` |
| `.vscode/launch.json` | Atalho F5 para `web-server` na porta 8080 | Perfil `Rodar App Flutter (Web Preview)` |
| `pubspec.yaml` | Dependências do projeto | `flutter`, `shared_preferences`, `flutter_lints` |
| `analysis_options.yaml` | Regras de lint Dart/Flutter | `flutter_lints`, `prefer_single_quotes`, `prefer_const_constructors` |

## 4. Histórico de Evolução
- **Etapas 1–3 (Base):** Estrutura de diretórios MVVM, DevContainer, Launch config e manifesto Web criados.
