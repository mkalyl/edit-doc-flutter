# AGENTS.MD - Mapa Arquitetural e Registro de Evolução (`edit_doc_flutter`)

Este arquivo deve ser consultado e atualizado a cada feature, refactor ou correção neste repositório.

## 1. Visão Geral e Ambiente (GitHub Codespaces)
- **Projeto:** `edit_doc_flutter` (Editor de Documentos em Flutter Web/Mobile).
- **Arquitetura:** MVVM (Model - View - ViewModel) com `ChangeNotifier` + `ListenableBuilder`.
- **Ambiente Codespaces:**
  - `.devcontainer/devcontainer.json`: Imagem `ghcr.io/cirruslabs/flutter:stable`, porta `8080` com `onAutoForward: openPreview`, extensões Dart/Flutter e `postCreateCommand` (`safe.directory` + `flutter pub get`).
  - `.vscode/launch.json`: Configuração `Rodar App Flutter (Web Preview)` executando `-d web-server --web-port 8080 --web-hostname 0.0.0.0`.
  - `web/`: Arquivos web (`index.html` com `flutter_bootstrap.js`, `manifest.json`, ícones).

## 2. Regras de Negócio da Aplicação
1. **Autenticação e Cadastro de Usuários:**
   - Campos obrigatórios validados por `Validadores`: nome (>= 3 caracteres), e-mail válido e senha (>= 6 caracteres).
   - E-mails normalizados com `trim().toLowerCase()`.
   - Cadastro impede duplicidade de e-mail.
   - Usuário demo inicial (`aluno@editdoc.com` / `123456`).
2. **Sessão e Tema Reativo:**
   - Tema Claro/Escuro alternável via `AuthViewModel.alternarTema()` e refletido reativamente no `MaterialApp`.
3. **Gestão de Documentos (Fase 1 em memória):**
   - Cada documento possui `id`, `titulo`, `conteudo`, `categoria`, `autorEmail`, `criadoEm` e `atualizadoEm`.
   - Ordenação decrescente por `atualizadoEm`, busca por título/conteúdo e filtro por categoria (`Todas`, `Geral`, `Estudos`, `Trabalho`, `Pessoal`).

## 3. Mapa de Módulos e Funções

| Arquivo | Camada | Responsabilidade / Principais Classes e Funções |
|---|---|---|
| `lib/main.dart` | Entrada | `main()`, `EditDocApp` (tema reativo com `ListenableBuilder` e rotas nomeadas `/`, `/cadastro`, `/home`) |
| `lib/theme/app_theme.dart` | Theme | `AppTheme.claro`, `AppTheme.escuro` (Material 3 `ColorScheme.fromSeed`) |
| `lib/models/usuario.dart` | Model | Classe `Usuario` |
| `lib/models/documento.dart` | Model | Classe `Documento` (`categoriasPadrao`, `resumo`, `contagemPalavras`) |
| `lib/utils/validadores.dart` | Utils | `Validadores.validarNome`, `validarEmail`, `validarSenha`, `validarConfirmacaoSenha`, `validarCampoObrigatorio` |
| `lib/viewmodels/auth_viewmodel.dart` | ViewModel | `AuthViewModel` (`alternarTema`, `login`, `cadastrar`, `logout`, `limparErro`) |
| `lib/viewmodels/documentos_viewmodel.dart` | ViewModel | `DocumentosViewModel` (`documentos`, `atualizarBusca`, `selecionarCategoria`) |
| `lib/views/login_view.dart` | View | `LoginView` (Rota `/`) |
| `lib/views/cadastro_view.dart` | View | `CadastroView` (Rota `/cadastro`) |
| `lib/views/home_view.dart` | View | `HomeView` (Rota `/home`) |
| `lib/views/widgets/cabecalho_auth.dart` | View Widget | `CabecalhoAuth` |
| `lib/views/widgets/campo_texto_padrao.dart` | View Widget | `CampoTextoPadrao` |
| `lib/views/widgets/documento_card.dart` | View Widget | `DocumentoCard` |
| `lib/views/widgets/estado_vazio_widget.dart` | View Widget | `EstadoVazioWidget` |
| `ARQUITETURA.md` | Docs | Relatório técnico obrigatório da Etapa 4 (3 tópicos) |

## 4. Histórico de Evolução
- **Etapas 1–3 (Base):** Estrutura de diretórios MVVM, DevContainer, Launch config e manifesto Web criados.
- **Etapa 4 (Fase 1):** Migração das 3 telas iniciais (`LoginView`, `CadastroView`, `HomeView`) para arquitetura MVVM com `ChangeNotifier` + `ListenableBuilder`, remoção de `setState` de regra de negócio e elaboração do relatório em `ARQUITETURA.md`.
