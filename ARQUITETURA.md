# Relatório de Migração Arquitetural (Etapa 4 - Fase 1 MVVM)

Este documento registra a refatoração do protótipo monolítico inicial (3 telas: Login, Cadastro e Home/Lista) para a arquitetura **MVVM (Model - View - ViewModel)** no projeto `edit_doc_flutter`, preparando a base para o CRUD e persistência local da Etapa 5.

---

## 1. Mapeamento de Classes e Widgets

| Origem no Protótipo Único (DartPad) | Camada MVVM | Novo Arquivo / Localização | Responsabilidade Atual |
|---|---|---|---|
| Classe de dados `Usuario` | Model | `lib/models/usuario.dart` | Entidade de usuário (`id`, `nome`, `email`, `senha`). |
| Classe de dados `Documento` | Model | `lib/models/documento.dart` | Entidade de documento com getters auxiliares (`resumo`, `contagemPalavras`). |
| Funções de validação nos formulários | Utils | `lib/utils/validadores.dart` | Validações reutilizáveis (`validarNome`, `validarEmail`, `validarSenha`, `validarConfirmacaoSenha`, `validarCampoObrigatorio`). |
| Configuração inline de `ThemeData` | Theme | `lib/theme/app_theme.dart` | Definição centralizada dos temas Material 3 claro e escuro (`AppTheme.claro` e `AppTheme.escuro`). |
| Lista de usuários, login, cadastro e flag de tema em `State` | ViewModel | `lib/viewmodels/auth_viewmodel.dart` | `AuthViewModel` (`ChangeNotifier`) gerenciando sessão, cadastro, login, logout e tema reativo. |
| Lista de documentos e filtros na tela Home | ViewModel | `lib/viewmodels/documentos_viewmodel.dart` | `DocumentosViewModel` (`ChangeNotifier`) gerenciando listagem, busca textual e filtro por categoria. |
| Tela de Login (`LoginScreen` / widget único) | View | `lib/views/login_view.dart` | Interface da rota `/`, formulário de login e navegação para `/cadastro` e `/home`. |
| Tela de Cadastro (`CadastroScreen`) | View | `lib/views/cadastro_view.dart` | Interface da rota `/cadastro` com validação de senha/confirmação e registro via `AuthViewModel`. |
| Tela Inicial/Lista (`HomeScreen`) | View | `lib/views/home_view.dart` | Interface da rota `/home` com busca, chips de categoria, alternância de tema e visualização de documentos. |
| Blocos visuais repetidos (cabeçalho, campo de texto, cartão e estado vazio) | View (Widgets) | `lib/views/widgets/*.dart` | Componentes modulares (`CabecalhoAuth`, `CampoTextoPadrao`, `DocumentoCard`, `EstadoVazioWidget`). |
| `main()` e `MaterialApp` raiz | Entrada / Roteamento | `lib/main.dart` | Instanciação dos ViewModels, `ThemeData` reativo via `ListenableBuilder` e rotas nomeadas (`onGenerateRoute`). |

---

## 2. Alterações de Estrutura e Imports

Ao separar o código de um único arquivo Dart para múltiplos módulos em `lib/`, foram necessárias as seguintes adaptações estruturais:

1. **Criação de construtores com injeção explícita:**
   - Como as telas e os ViewModels deixaram de compartilhar o mesmo escopo de arquivo, cada `View` passou a receber explicitamente suas dependências via construtor (`LoginView({required this.authViewModel})`, `CadastroView({required this.authViewModel})`, `HomeView({required this.authViewModel, required this.documentosViewModel})`), além do parâmetro padrão `super.key`.
2. **Controle de visibilidade e encapsulamento:**
   - Campos internos de estado nos ViewModels passaram a ser privados com prefixo `_` (ex.: `_usuarios`, `_usuarioAtual`, `_temaEscuro`, `_documentos`, `_termoBusca`, `_categoriaSelecionada`), impedindo mutação direta pelas `Views`.
   - O acesso externo ocorre apenas por getters somente leitura (`usuarioAtual`, `estaAutenticado`, `themeMode`, `List.unmodifiable(filtrados)`).
3. **Organização de imports por camadas:**
   - `models/` e `utils/` permanecem independentes de interface gráfica (`dart` puro ou sem dependência de `views/`/`viewmodels/`).
   - `viewmodels/` importa `package:flutter/material.dart` (para `ChangeNotifier` e `ThemeMode`) e `../models/...`.
   - `views/` importa apenas `../viewmodels/...`, `../models/...`, `../utils/...` e `./widgets/...`, mantendo a UI desacoplada das regras de negócio.
4. **Configuração de rotas nomeadas (`onGenerateRoute`):**
   - No `lib/main.dart`, a navegação direta com `MaterialPageRoute` espalhada pelos botões foi substituída por rotas nomeadas (`/`, `/cadastro`, `/home`) centralizadas em `onGenerateRoute`, incluindo guarda de autenticação (redirecionando acessos não autenticados em `/home` para `/`).

---

## 3. Mudanças no Gerenciamento de Estado

1. **Remoção de `setState()` de regra de negócio das Views:**
   - Foram removidos das telas todos os `setState()` que manipulavam lista de usuários cadastrados, usuário autenticado, troca de tema claro/escuro, lista de documentos, termo de busca e categoria ativa.
   - Nas `Views`, `setState()` ficou restrito exclusivamente a estado visual efêmero local de widget (como `_ocultarSenha` nos campos de senha de `LoginView` e `CadastroView`).
2. **Centralização do estado nos ViewModels (`ChangeNotifier`):**
   - `AuthViewModel` passou a manter `_usuarios`, `_usuarioAtual`, `_temaEscuro` e `_erroMensagem`.
   - `DocumentosViewModel` passou a manter `_documentos`, `_termoBusca` e `_categoriaSelecionada`.
   - Sempre que uma ação altera qualquer um desses estados (`login`, `cadastrar`, `logout`, `alternarTema`, `atualizarBusca`, `selecionarCategoria`), o ViewModel executa `notifyListeners()`.
3. **Reatividade nas telas com `ListenableBuilder`:**
   - Em `EditDocApp` (`lib/main.dart`), um `ListenableBuilder` escuta `authViewModel` para atualizar `themeMode` dinamicamente em toda a árvore de widgets.
   - Em `LoginView`, `ListenableBuilder` escuta `authViewModel` para atualizar o ícone de alternância de tema e estado de erro.
   - Em `HomeView`, `ListenableBuilder` com `Listenable.merge([authViewModel, documentosViewModel])` reconstrói a lista filtrada, saudação ao usuário e ícone de tema sempre que qualquer ViewModel notifica mudança.
