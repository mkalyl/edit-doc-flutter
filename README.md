# EditDoc Flutter (`edit_doc_flutter`)

Editor de Documentos desenvolvido em **Flutter** seguindo a arquitetura **MVVM (Model - View - ViewModel)**, com **persistência local** via `shared_preferences` e pré-configurado para execução imediata no **GitHub Codespaces** (Flutter Web Preview na porta `8080`).

---

## Estrutura do Projeto (`lib/`)

```text
lib/
├── main.dart                                # Ponto de entrada, inicialização assíncrona, ThemeData reativo e rotas nomeadas
├── theme/
│   └── app_theme.dart                       # Temas Material 3 (Claro e Escuro)
├── models/
│   ├── usuario.dart                         # Modelo Usuário com serialização JSON
│   ├── documento.dart                       # Modelo Documento com copyWith, JSON e contagem de palavras
│   └── services/
│       ├── preferences_service.dart         # Persistência de Tema (bool) e Sessão (String JSON)
│       ├── documento_storage_service.dart   # CRUD completo de Documentos em JSON no shared_preferences
│       └── banco_local_service.dart         # Persistência de Usuários e fachada local
├── viewmodels/
│   ├── auth_viewmodel.dart                  # Autenticação, cadastro, sessão e tema persistente (ChangeNotifier)
│   └── documentos_viewmodel.dart            # Listagem, busca, filtros e CRUD de documentos (ChangeNotifier)
├── views/
│   ├── login_view.dart                      # Rota: /
│   ├── cadastro_view.dart                   # Rota: /cadastro
│   ├── home_view.dart                       # Rota: /home
│   ├── editor_view.dart                     # Rota: /editor (criação e edição)
│   └── widgets/                             # Componentes visuais reutilizáveis e modulares
└── utils/
    └── validadores.dart                     # Validações de Nome, E-mail, Senha e campos do editor
```

> O relatório técnico completo exigido na Etapa 4 está disponível em [`ARQUITETURA.md`](./ARQUITETURA.md).
> O histórico Git mantém a entrega intermediária na branch/tag `etapa-4-mvvm` (`etapa-4`) e a versão final completa das Etapas 1 a 5 na branch `main`.

---

## Como Rodar no GitHub Codespaces

1. Crie ou abra o repositório no GitHub e inicie um Codespace na branch `main` (**`<> Code` → `Codespaces` → `Create codespace on main`**).
2. Ao carregar o editor, clique em **Trust Folder & Continue**.
3. O `.devcontainer/devcontainer.json` usa a imagem `ghcr.io/cirruslabs/flutter:stable` e executa `flutter pub get` automaticamente no `postCreateCommand`.
4. Pressione **`F5`** (ou abra a aba **Run and Debug** e execute **`Rodar App Flutter (Web Preview)`**).
5. O Flutter Web Server subirá em `0.0.0.0:8080` e abrirá o preview automaticamente.

---

## Acesso Online e Instalador Android (Entrega Final)

- **Versão Web (GitHub Pages):** [https://mkalyl.github.io/edit-doc-flutter/](https://mkalyl.github.io/edit-doc-flutter/)
- **Instalador Android (APK `arm64`):** disponível na [Release `v1.0.0`](https://github.com/mkalyl/edit-doc-flutter/releases/tag/v1.0.0) (`app-release.apk`).

---

## Como Gerar o APK Android (Parte 2)

O projeto possui a pasta `android/` já configurada com limite de memória ajustado para ambientes como o GitHub Codespaces (`-Xmx1536m` e `org.gradle.daemon=false` em `android/gradle.properties`):

```bash
sed -i 's/-Xmx[0-9]*[gGmM]/-Xmx1536m/g' android/gradle.properties && echo "org.gradle.daemon=false" >> android/gradle.properties
flutter build apk --release --target-platform android-arm64
```

O instalador gerado fica em `build/app/outputs/flutter-apk/app-release.apk`.

---

## Como Publicar a Versão Web no GitHub Pages (Parte 3)

```bash
flutter build web --release --base-href "/edit-doc-flutter/"
cd build/web
git init
git checkout -b gh-pages
git add .
git commit -m "Publica versao Web no GitHub Pages"
git remote add origin https://github.com/mkalyl/edit-doc-flutter.git
git push -f origin gh-pages
cd ../..
```

---

## Como Validar Persistência e CRUD (Etapa 5)

1. Faça login com a conta de demonstração **`aluno@editdoc.com`** / **`123456`** ou cadastre uma nova conta em **Criar nova conta**.
2. Alterne o tema para **Escuro** no ícone da barra superior.
3. Crie um novo documento clicando em **Novo Documento**, edite um documento existente tocando no cartão e teste a exclusão com confirmação.
4. Pressione **`F5` no navegador do preview**: a escolha de tema, a sessão ativa e todos os documentos criados/editados permanecerão salvos via `shared_preferences`.

> **Atenção ao encerrar a aula:** execute `git add .`, `git commit -m "..."` e `git push`, e depois acesse [github.com/codespaces](https://github.com/codespaces) para clicar em **Stop** no seu container e economizar sua cota mensal gratuita.
