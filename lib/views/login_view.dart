import 'package:flutter/material.dart';
import '../utils/validadores.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'widgets/cabecalho_auth.dart';
import 'widgets/campo_texto_padrao.dart';

/// Tela inicial de autenticação (Rota: /).
class LoginView extends StatefulWidget {
  final AuthViewModel authViewModel;

  const LoginView({
    super.key,
    required this.authViewModel,
  });

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  bool _ocultarSenha = true;

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  void _submeterLogin() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final bool sucesso = widget.authViewModel.login(
      _emailController.text,
      _senhaController.text,
    );

    if (!mounted) {
      return;
    }

    if (sucesso) {
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      final String erro =
          widget.authViewModel.erroMensagem ?? 'Falha ao autenticar.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(erro)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cores = Theme.of(context).colorScheme;

    return ListenableBuilder(
      listenable: widget.authViewModel,
      builder: (BuildContext context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('EditDoc Flutter'),
            actions: <Widget>[
              IconButton(
                tooltip: widget.authViewModel.temaEscuro
                    ? 'Mudar para tema claro'
                    : 'Mudar para tema escuro',
                icon: Icon(
                  widget.authViewModel.temaEscuro
                      ? Icons.light_mode_outlined
                      : Icons.dark_mode_outlined,
                ),
                onPressed: widget.authViewModel.alternarTema,
              ),
            ],
          ),
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const CabecalhoAuth(
                        titulo: 'Bem-vindo de volta',
                        subtitulo:
                            'Entre para acessar seus documentos organizados em MVVM.',
                      ),
                      const SizedBox(height: 28),
                      CampoTextoPadrao(
                        controller: _emailController,
                        rotulo: 'E-mail',
                        dica: 'aluno@editdoc.com',
                        icone: Icons.email_outlined,
                        tipoTeclado: TextInputType.emailAddress,
                        acaoTeclado: TextInputAction.next,
                        validador: Validadores.validarEmail,
                      ),
                      const SizedBox(height: 16),
                      CampoTextoPadrao(
                        controller: _senhaController,
                        rotulo: 'Senha',
                        icone: Icons.lock_outline,
                        ocultarTexto: _ocultarSenha,
                        acaoTeclado: TextInputAction.done,
                        validador: Validadores.validarSenha,
                        aoEnviar: (_) => _submeterLogin(),
                        iconeSufixo: IconButton(
                          tooltip:
                              _ocultarSenha ? 'Mostrar senha' : 'Ocultar senha',
                          icon: Icon(
                            _ocultarSenha
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _ocultarSenha = !_ocultarSenha;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      FilledButton.icon(
                        onPressed: _submeterLogin,
                        icon: const Icon(Icons.login),
                        label: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Text('Entrar'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: () {
                          widget.authViewModel.limparErro();
                          Navigator.of(context).pushNamed('/cadastro');
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Text('Criar nova conta'),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: cores.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Conta de demonstração: aluno@editdoc.com / 123456',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
