import 'package:flutter/material.dart';
import '../utils/validadores.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/documentos_viewmodel.dart';
import 'widgets/cabecalho_auth.dart';
import 'widgets/campo_texto_padrao.dart';

/// Tela de cadastro de novo usuário (Rota: /cadastro).
class CadastroView extends StatefulWidget {
  final AuthViewModel authViewModel;
  final DocumentosViewModel documentosViewModel;

  const CadastroView({
    super.key,
    required this.authViewModel,
    required this.documentosViewModel,
  });

  @override
  State<CadastroView> createState() => _CadastroViewState();
}

class _CadastroViewState extends State<CadastroView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _confirmarController = TextEditingController();
  bool _ocultarSenha = true;

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _confirmarController.dispose();
    super.dispose();
  }

  Future<void> _submeterCadastro() async {
    if (widget.authViewModel.carregando ||
        !(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final bool sucesso = await widget.authViewModel.cadastrar(
      nome: _nomeController.text,
      email: _emailController.text,
      senha: _senhaController.text,
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
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/home',
        (Route<dynamic> route) => false,
      );
    } else {
      final String erro =
          widget.authViewModel.erroMensagem ?? 'Não foi possível cadastrar.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(erro)),
      );
    }
  }

  void _voltarParaLogin() {
    widget.authViewModel.limparErro();
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacementNamed('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.authViewModel,
      builder: (BuildContext context, _) {
        final bool carregando = widget.authViewModel.carregando;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Criar Conta'),
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
                        titulo: 'Novo Cadastro',
                        subtitulo:
                            'Preencha seus dados para salvar seus documentos.',
                      ),
                      const SizedBox(height: 24),
                      CampoTextoPadrao(
                        controller: _nomeController,
                        rotulo: 'Nome completo',
                        icone: Icons.person_outline,
                        acaoTeclado: TextInputAction.next,
                        validador: Validadores.validarNome,
                      ),
                      const SizedBox(height: 16),
                      CampoTextoPadrao(
                        controller: _emailController,
                        rotulo: 'E-mail',
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
                        acaoTeclado: TextInputAction.next,
                        validador: Validadores.validarSenha,
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
                      const SizedBox(height: 16),
                      CampoTextoPadrao(
                        controller: _confirmarController,
                        rotulo: 'Confirmar senha',
                        icone: Icons.lock_reset_outlined,
                        ocultarTexto: _ocultarSenha,
                        acaoTeclado: TextInputAction.done,
                        aoEnviar: (_) => _submeterCadastro(),
                        validador: (String? valor) =>
                            Validadores.validarConfirmacaoSenha(
                          valor,
                          _senhaController.text,
                        ),
                      ),
                      const SizedBox(height: 22),
                      FilledButton.icon(
                        onPressed: carregando ? null : _submeterCadastro,
                        icon: carregando
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.person_add_alt_1),
                        label: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            carregando
                                ? 'Cadastrando...'
                                : 'Cadastrar e Entrar',
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: carregando ? null : _voltarParaLogin,
                        child: const Text('Já tenho uma conta'),
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
