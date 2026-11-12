import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/documentos_viewmodel.dart';
import 'views/cadastro_view.dart';
import 'views/home_view.dart';
import 'views/login_view.dart';

void main() {
  final AuthViewModel authViewModel = AuthViewModel();
  final DocumentosViewModel documentosViewModel = DocumentosViewModel();

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
          initialRoute: '/',
          onGenerateRoute: (RouteSettings settings) {
            switch (settings.name) {
              case '/cadastro':
                return MaterialPageRoute<void>(
                  settings: settings,
                  builder: (_) => CadastroView(authViewModel: authViewModel),
                );
              case '/home':
                if (!authViewModel.estaAutenticado) {
                  return MaterialPageRoute<void>(
                    settings: const RouteSettings(name: '/'),
                    builder: (_) => LoginView(authViewModel: authViewModel),
                  );
                }
                return MaterialPageRoute<void>(
                  settings: settings,
                  builder: (_) => HomeView(
                    authViewModel: authViewModel,
                    documentosViewModel: documentosViewModel,
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
                  builder: (_) => LoginView(authViewModel: authViewModel),
                );
            }
          },
        );
      },
    );
  }
}
