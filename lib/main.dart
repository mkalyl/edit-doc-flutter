import 'package:flutter/material.dart';
import 'models/documento.dart';
import 'models/services/banco_local_service.dart';
import 'models/services/preferences_service.dart';
import 'theme/app_theme.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/documentos_viewmodel.dart';
import 'views/cadastro_view.dart';
import 'views/editor_view.dart';
import 'views/home_view.dart';
import 'views/login_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final PreferencesService preferencesService = PreferencesService();
  final BancoLocalService bancoLocalService = BancoLocalService();
  final AuthViewModel authViewModel = AuthViewModel(
    preferencesService: preferencesService,
    bancoLocalService: bancoLocalService,
  );
  final DocumentosViewModel documentosViewModel = DocumentosViewModel(
    storageService: bancoLocalService.documentos,
  );

  await authViewModel.inicializar();
  if (authViewModel.estaAutenticado && authViewModel.usuarioAtual != null) {
    await documentosViewModel.carregarDocumentos(
      autorEmail: authViewModel.usuarioAtual!.email,
    );
  }

  runApp(
    EditDocApp(
      authViewModel: authViewModel,
      documentosViewModel: documentosViewModel,
    ),
  );
}

/// Widget raiz da aplicação com ThemeData reativo e rotas nomeadas.
class EditDocApp extends StatelessWidget {
  final AuthViewModel authViewModel;
  final DocumentosViewModel documentosViewModel;

  const EditDocApp({
    super.key,
    required this.authViewModel,
    required this.documentosViewModel,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: authViewModel,
      builder: (BuildContext context, _) {
        return MaterialApp(
          title: 'EditDoc Flutter',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.claro,
          darkTheme: AppTheme.escuro,
          themeMode: authViewModel.themeMode,
          initialRoute: authViewModel.estaAutenticado ? '/home' : '/',
          onGenerateRoute: (RouteSettings settings) {
            switch (settings.name) {
              case '/cadastro':
                return MaterialPageRoute<void>(
                  settings: settings,
                  builder: (_) => CadastroView(
                    authViewModel: authViewModel,
                    documentosViewModel: documentosViewModel,
                  ),
                );
              case '/home':
                if (!authViewModel.estaAutenticado) {
                  return MaterialPageRoute<void>(
                    settings: const RouteSettings(name: '/'),
                    builder: (_) => LoginView(
                      authViewModel: authViewModel,
                      documentosViewModel: documentosViewModel,
                    ),
                  );
                }
                return MaterialPageRoute<void>(
                  settings: settings,
                  builder: (_) => HomeView(
                    authViewModel: authViewModel,
                    documentosViewModel: documentosViewModel,
                  ),
                );
              case '/editor':
                if (!authViewModel.estaAutenticado) {
                  return MaterialPageRoute<void>(
                    settings: const RouteSettings(name: '/'),
                    builder: (_) => LoginView(
                      authViewModel: authViewModel,
                      documentosViewModel: documentosViewModel,
                    ),
                  );
                }
                final Object? argumentos = settings.arguments;
                final Documento? doc =
                    argumentos is Documento ? argumentos : null;
                return MaterialPageRoute<void>(
                  settings: settings,
                  builder: (_) => EditorView(
                    authViewModel: authViewModel,
                    documentosViewModel: documentosViewModel,
                    documento: doc,
                  ),
                );
              case '/':
              default:
                if (authViewModel.estaAutenticado) {
                  return MaterialPageRoute<void>(
                    settings: const RouteSettings(name: '/home'),
                    builder: (_) => HomeView(
                      authViewModel: authViewModel,
                      documentosViewModel: documentosViewModel,
                    ),
                  );
                }
                return MaterialPageRoute<void>(
                  settings: settings,
                  builder: (_) => LoginView(
                    authViewModel: authViewModel,
                    documentosViewModel: documentosViewModel,
                  ),
                );
            }
          },
        );
      },
    );
  }
}
