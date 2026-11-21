# Relatório Técnico e Arquitetura MVVM (`edit_doc_flutter`)

Este documento contempla o **Relatório Obrigatório da Etapa 4 (Fase 1)** e a documentação de evolução da **Etapa 5 (Fase 2 - Persistência e CRUD)**.

---

# Parte I — Relatório de Migração Arquitetural (Etapa 4 - Fase 1)

Nesta fase, o protótipo inicial de 3 telas (**Login**, **Cadastro** e **Home/Lista**) foi migrado para a arquitetura **MVVM (Model - View - ViewModel)** no GitHub Codespaces, separando responsabilidades antes de introduzir persistência e CRUD completo.

## 1. Mapeamento de Classes e Widgets

| Origem no Protótipo Único (DartPad) | Camada MVVM | Novo Arquivo / Localização | Responsabilidade Atual |
|---|---|---|---|
| Classe de dados `Usuario` | Model | `lib/models/usuario.dart` | Entidade de usuário (`id`, `nome`, `email`, `senha`). |
| Classe de dados `Documento` | Model | `lib/models/documento.dart` | Entidade de documento com getters auxiliares (`resumo`, `contagemPalavras`). |
| Funções de validação nos formulários | Utils | `lib/utils/validadores.dart` | Validações reutilizáveis (`validarNome`, `validarEmail`, `validarSenha`, `validarConfirmacaoSenha`, `validarCampoObrigatorio`). |
| Configuração inline de `ThemeData` | Theme | `lib/theme/app_theme.dart` | Definição centralizada dos temas Material 3 claro e escuro (`AppTheme.claro` e `AppTheme.escuro`). |
| Lista de usuários, login, cadastro e flag de tema em `State` | ViewModel | `lib/viewmodels/auth_viewmodel.dart` | `AuthViewModel` (`ChangeNotifier`) gerenciando sessão, cadastro, login, logout e tema reativo. |
| Lista de documentos e filtros na tela Home | ViewModel | `lib/viewmodels/documentos_viewmodel.dart` | `DocumentosViewModel` (`ChangeNotifier`) gerenciando listagem, busca textual e filtro por categoria. |
| Tela de Login (`LoginScreen`) | View | `lib/views/login_view.dart` | Interface da rota `/`, formulário de login e navegação para `/cadastro` e `/home`. |
| Tela de Cadastro (`CadastroScreen`) | View | `lib/views/cadastro_view.dart` | Interface da rota `/cadastro` com validação de senha/confirmação e registro via `AuthViewModel`. |
| Tela Inicial/Lista (`HomeScreen`) | View | `lib/views/home_view.dart` | Interface da rota `/home` com busca, chips de categoria, alternância de tema e lista de documentos. |
| Blocos visuais repetidos (cabeçalho, campo, cartão e estado vazio) | View (Widgets) | `lib/views/widgets/*.dart` | Componentes modulares (`CabecalhoAuth`, `CampoTextoPadrao`, `DocumentoCard`, `EstadoVazioWidget`). |
| `main()` e `MaterialApp` raiz | Entrada / Roteamento | `lib/main.dart` | Instanciação dos ViewModels, `ThemeData` reativo via `ListenableBuilder` e rotas nomeadas (`onGenerateRoute`). |

## 2. Alterações de Estrutura e Imports

1. **Criação de construtores com injeção explícita:**
   - Ao dividir o código em arquivos separados, cada tela recebeu construtores nomeados com suas dependências explícitas (`LoginView({required this.authViewModel, ...})`, `CadastroView(...)`, `HomeView(...)`) e `super.key`.
2. **Controle de visibilidade e encapsulamento:**
   - Estados internos dos ViewModels passaram a ser privados com prefixo `_` (`_usuarioAtual`, `_temaEscuro`, `_documentos`, `_termoBusca`, `_categoriaSelecionada`), sendo expostos somente por getters seguros (`estaAutenticado`, `themeMode`, `List.unmodifiable(...)`).
3. **Organização de imports por camadas:**
   - `models/` e `utils/` não dependem de `views/` ou `viewmodels/`.
   - `viewmodels/` importa `package:flutter/material.dart` (para `ChangeNotifier`/`ThemeMode`) e a camada `models/`.
   - `views/` importa apenas `viewmodels/`, `models/`, `utils/` e seus widgets auxiliares em `views/widgets/`.
4. **Configuração das rotas nomeadas:**
   - O `MaterialApp` em `lib/main.dart` centraliza as rotas `/`, `/cadastro`, `/home` (e `/editor` na Fase 2) em `onGenerateRoute`, com proteção contra acesso não autenticado.

## 3. Mudanças no Gerenciamento de Estado

1. **Remoção de `setState()` de regra de negócio das Views:**
   - Todos os `setState()` que alteravam usuários, sessão logada, tema claro/escuro, lista de documentos e filtros foram removidos das `views/`.
   - Apenas estado visual efêmero de widget (como `_ocultarSenha` nos campos de senha) permaneceu com `setState()` local.
2. **Estado centralizado em `ChangeNotifier`:**
   - `AuthViewModel` e `DocumentosViewModel` estendem `ChangeNotifier`, concentrando o estado da aplicação e executando `notifyListeners()` após cada alteração.
3. **Reatividade com `ListenableBuilder`:**
   - `EditDocApp` usa `ListenableBuilder` em `authViewModel` para atualizar o `themeMode` globalmente.
   - `LoginView`, `CadastroView` e `HomeView` utilizam `ListenableBuilder` (incluindo `Listenable.merge` na `HomeView`) para reconstruir apenas as partes necessárias sempre que `notifyListeners()` é chamado.

---

# Parte II — Persistência Local e CRUD Completo (Etapa 5 - Fase 2)

Na segunda fase, a aplicação passou a persistir preferências, sessão, usuários e documentos no `shared_preferences` (armazenado no `localStorage` do navegador no Flutter Web), mantendo os dados após recarregar a página (`F5`):

- **`lib/models/services/preferences_service.dart`:** Salva e carrega o tema (`bool`) e os dados da sessão ativa do usuário (`String` JSON).
- **`lib/models/services/documento_storage_service.dart`:** Implementa o CRUD completo (**Create, Read, Update, Delete**) de `Documento` serializando a lista com `dart:convert` (`jsonEncode` e `jsonDecode`) no `shared_preferences`.
- **`lib/models/services/banco_local_service.dart`:** Persiste usuários cadastrados via `shared_preferences` (com conta demo inicial `aluno@editdoc.com`) e integra o acesso ao repositório local de usuários e documentos.
- **`lib/views/editor_view.dart` (Rota `/editor`):** Quarta tela integrada ao `DocumentosViewModel`, permitindo criar novos documentos, editar existentes, escolher categoria, acompanhar contagem de palavras/caracteres em tempo real e excluir com diálogo de confirmação (`confirmarExclusaoDocumento`).

---

# Parte III — Compilação Android (APK) e Publicação Web (Etapa Final)

Com o código-fonte 100% em Dart puro e o pacote multiplataforma `shared_preferences`, a mesma base MVVM foi compilada sem alterações na lógica de negócio para **Android** e **Web em produção**:

- **Estrutura Android (`android/`):** Criada via `flutter create --platforms=android --project-name edit_doc_flutter --org com.editdoc .`, com rótulo `EditDoc Flutter` em `AndroidManifest.xml` e memória do Gradle ajustada em `android/gradle.properties` (`-Xmx1536m` e `org.gradle.daemon=false`) para compilação estável em ambientes com RAM limitada.
- **APK Release (`arm64`):** Gerado via `flutter build apk --release --target-platform android-arm64` (`build/app/outputs/flutter-apk/app-release.apk`, ~16,8 MB) e publicado na Release `v1.0.0`.
- **Web em Produção (GitHub Pages):** Compilado com `flutter build web --release --base-href "/edit-doc-flutter/"` e publicado na branch `gh-pages`, disponibilizando o app em `https://mkalyl.github.io/edit-doc-flutter/`.
- **Automação CI/CD (`.github/workflows/build-and-deploy.yml`):** Pipeline automatizado no GitHub Actions executando análise estática (`flutter analyze --no-fatal-infos`), testes unitários/widget (`flutter test`), build APK `arm64`, build Web e deploy contínuo em `gh-pages`.
