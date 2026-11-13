import 'package:flutter/material.dart';
import '../utils/validadores.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/documentos_viewmodel.dart';
import 'widgets/botao_alternar_tema.dart';
import 'widgets/cabecalho_auth.dart';
import 'widgets/campo_texto_padrao.dart';

/// Tela inicial de autenticação (Rota: /).
class LoginView extends StatefulWidget {
  final AuthViewModel authViewModel;
  final DocumentosViewModel documentosViewModel;

  const LoginView({
    super.key,
    required this.authViewModel,
    required this.documentosViewModel,
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

  Future<void> _submeterLogin() async {
    if (widget.authViewModel.carregando ||
        !(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final bool sucesso = await widget.authViewModel.login(
      _emailController.text,
      _senhaController.text,
    );

    if (!mounted) {
      return;
    }

    if (sucesso && widget.authViewModel.usuarioAtual != null) {
      await widget.documentosViewModel.carregarDocumentos(
        autorEmail: widget.authViewModel.usuarioAtual!.email,
      );
      if (!mounted) {
        return;
      }
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
        final bool carregando = widget.authViewModel.carregando;

        return Scaffold(
          appBar: AppBar(
            title: const Text('EditDoc Flutter'),
            actions: <Widget>[
              BotaoAlternarTema(authViewModel: widget.authViewModel),
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
                            'Entre para acessar seus documentos salvos localmente.',
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
                        onPressed: carregando ? null : _submeterLogin,
                        icon: carregando
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.login),
                        label: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(carregando ? 'Entrando...' : 'Entrar'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: carregando
                            ? null
                            : () {
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
                        child: Column(
                          children: <Widget>[
                            Text(
                              'Conta de demonstração: aluno@editdoc.com / 123456',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 6),
                            TextButton(
                              onPressed: carregando
                                  ? null
                                  : () {
                                      _emailController.text =
                                          'aluno@editdoc.com';
                                      _senhaController.text = '123456';
                                    },
                              child: const Text('Preencher conta demo'),
                            ),
                          ],
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
