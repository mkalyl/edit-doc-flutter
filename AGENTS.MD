# AGENTS.MD - Mapa Arquitetural e Registro de Evolução (`edit_doc_flutter`)

Este arquivo deve ser consultado e atualizado a cada feature, refactor ou correção neste repositório.

## 1. Visão Geral e Ambiente (GitHub Codespaces)
- **Projeto:** `edit_doc_flutter` (Editor de Documentos em Flutter Web/Mobile).
- **Arquitetura:** MVVM (Model - View - ViewModel) com `ChangeNotifier` + `ListenableBuilder` + `shared_preferences`.
- **Ambiente Codespaces:**
  - `.devcontainer/devcontainer.json`: Imagem `ghcr.io/cirruslabs/flutter:stable`, porta `8080` com `onAutoForward: openPreview`, extensões Dart/Flutter e `postCreateCommand` (`git config --global --add safe.directory '*' && flutter pub get`).
  - `.vscode/launch.json`: Configuração `Rodar App Flutter (Web Preview)` executando `-d web-server --web-port 8080 --web-hostname 0.0.0.0`.
  - `web/`: `index.html` (`flutter_bootstrap.js`), `manifest.json`, `favicon.png` e ícones PWA prontos para execução imediata.

## 2. Regras de Negócio da Aplicação
1. **Autenticação, Cadastro e Sessão:**
   - Campos validados via `Validadores`: nome (>= 3 chars), e-mail válido, senha (>= 6 chars) e confirmação igual à senha.
   - E-mails normalizados com `trim().toLowerCase()`.
   - Cadastro bloqueia e-mail duplicado via `BancoLocalService.cadastrarUsuario`.
   - Conta demo inicial (`aluno@editdoc.com` / `123456`) garantida na primeira execução caso não existam usuários salvos.
   - Sessão ativa e tema Claro/Escuro persistidos via `PreferencesService` e restaurados antes de `runApp()` para evitar flicker ou perda de rota ao pressionar `F5`.
   - Rotas `/home` e `/editor` bloqueiam acesso não autenticado em `onGenerateRoute`.
2. **CRUD e Persistência de Documentos:**
   - Documentos possuem `id`, `titulo`, `conteudo`, `categoria` (`Geral`, `Estudos`, `Trabalho`, `Pessoal`), `autorEmail`, `criadoEm` e `atualizadoEm`.
   - Armazenados em JSON (`jsonEncode` / `jsonDecode`) no `shared_preferences` via `DocumentoStorageService`.
   - Documentos iniciais de boas-vindas são criados apenas uma vez por usuário (`_prefixoIniciais`), nunca ressuscitados após exclusão manual.
   - Isolamento por `autorEmail`, ordenação decrescente por `atualizadoEm`, busca textual e filtro por categoria.
   - Exclusão exige confirmação pelo diálogo compartilhado `confirmarExclusaoDocumento`.

## 3. Mapa de Módulos e Funções

| Arquivo | Camada | Responsabilidade / Principais Classes e Funções |
|---|---|---|
| `lib/main.dart` | Entrada | `main()` (init assíncrono), `EditDocApp` (tema reativo com `ListenableBuilder`, rotas `/`, `/cadastro`, `/home`, `/editor`) |
| `lib/theme/app_theme.dart` | Theme | `AppTheme.claro`, `AppTheme.escuro` (Material 3) |
| `lib/models/usuario.dart` | Model | `Usuario` (`toMap`, `fromMap`, `toJson`, `fromJson`) |
| `lib/models/documento.dart` | Model | `Documento` (`categoriasPadrao`, `copyWith`, `toMap`, `fromMap`, `toJson`, `fromJson`, `resumo`, `contagemPalavras`, `contarPalavras`, `contagemCaracteres`) |
| `lib/models/services/preferences_service.dart` | Service | `PreferencesService` (`carregarTemaEscuro`, `salvarTemaEscuro`, `carregarSessaoUsuario`, `salvarSessaoUsuario`, `limparSessaoUsuario`) |
| `lib/models/services/documento_storage_service.dart` | Service | `DocumentoStorageService` (`garantirDocumentosIniciais`, `listarDocumentos`, `criarDocumento`, `atualizarDocumento`, `excluirDocumento`) |
| `lib/models/services/banco_local_service.dart` | Service | `BancoLocalService` (`garantirUsuarioDemo`, `listarUsuarios`, `buscarUsuarioPorEmail`, `autenticar`, `cadastrarUsuario`, delegação `documentos`) |
| `lib/utils/validadores.dart` | Utils | `Validadores` (`validarNome`, `validarEmail`, `validarSenha`, `validarConfirmacaoSenha`, `validarCampoObrigatorio`) |
| `lib/utils/json_helpers.dart` | Utils | `decodificarListaJson`, `decodificarMapaJson` (conversão segura Web/VM) |
| `lib/viewmodels/auth_viewmodel.dart` | ViewModel | `AuthViewModel` (`inicializar`, `alternarTema`, `login`, `cadastrar`, `logout`, `limparErro`) |
| `lib/viewmodels/documentos_viewmodel.dart` | ViewModel | `DocumentosViewModel` (`carregarDocumentos`, `criarDocumento`, `atualizarDocumento`, `excluirDocumento`, `atualizarBusca`, `selecionarCategoria`, `limparEstadoLocal`) |
| `lib/views/login_view.dart` | View | `LoginView` (Rota `/`) |
| `lib/views/cadastro_view.dart` | View | `CadastroView` (Rota `/cadastro`) |
| `lib/views/home_view.dart` | View | `HomeView` (Rota `/home`) |
| `lib/views/editor_view.dart` | View | `EditorView` (Rota `/editor` — criação, edição, exclusão e contador em tempo real) |
| `lib/views/widgets/cabecalho_auth.dart` | View Widget | `CabecalhoAuth` |
| `lib/views/widgets/campo_texto_padrao.dart` | View Widget | `CampoTextoPadrao` |
| `lib/views/widgets/documento_card.dart` | View Widget | `DocumentoCard` |
| `lib/views/widgets/estado_vazio_widget.dart` | View Widget | `EstadoVazioWidget` |
| `lib/views/widgets/confirmar_exclusao_dialog.dart` | View Widget | `confirmarExclusaoDocumento` |
| `lib/views/widgets/botao_alternar_tema.dart` | View Widget | `BotaoAlternarTema` |
| `lib/views/widgets/seletor_categoria.dart` | View Widget | `SeletorCategoria` |
| `test/widget_test.dart` | Testes | Testes unitários e de widget com `SharedPreferences.setMockInitialValues` |
| `ARQUITETURA.md` | Docs | Relatório técnico da Etapa 4 (3 tópicos) + arquitetura da Etapa 5 |

## 4. Histórico de Evolução
- **Etapas 1–3 (Base):** Estrutura MVVM, DevContainer, Launch config e manifesto Web criados.
- **Etapa 4 (Fase 1):** Migração das 3 telas iniciais para MVVM (`ChangeNotifier` + `ListenableBuilder`) e criação do relatório em `ARQUITETURA.md` (tag `etapa-4` / branch `etapa-4-mvvm`).
- **Etapa 5 (Fase 2):** Persistência local com `shared_preferences` (`PreferencesService`, `DocumentoStorageService`, `BancoLocalService`), adição da tela `EditorView` (`/editor`) e CRUD completo com preservação de estado após reload (`F5`).
- **Fix Web JSON/Storage:** Adicionado `lib/utils/json_helpers.dart` com conversão segura de `Map<dynamic, dynamic>` para `Map<String, dynamic>` em Flutter Web debug (`dartdevc`), garantia contínua da conta demo em `BancoLocalService.garantirUsuarioDemo()` e fallback em memória nos serviços caso o `localStorage` esteja restrito em iframes, além de botão rápido para preencher conta demo na `LoginView`.
- **Etapa Final (Android APK + GitHub Pages + CI/CD):** Adicionada estrutura `android/` com `android/gradle.properties` configurado (`-Xmx1536m`, `org.gradle.daemon=false`) e `android:label="EditDoc Flutter"`, pipeline `.github/workflows/build-and-deploy.yml`, publicação do APK `arm64` na Release `v1.0.0` e deploy Web na branch `gh-pages` (`--base-href "/edit-doc-flutter/"`).
