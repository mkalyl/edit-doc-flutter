import 'package:flutter/material.dart';
import '../models/documento.dart';
import '../utils/validadores.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/documentos_viewmodel.dart';
import 'widgets/campo_texto_padrao.dart';
import 'widgets/confirmar_exclusao_dialog.dart';
import 'widgets/seletor_categoria.dart';

/// Tela de criação e edição de documentos integrada ao DocumentosViewModel (Rota: /editor).
class EditorView extends StatefulWidget {
  final AuthViewModel authViewModel;
  final DocumentosViewModel documentosViewModel;
  final Documento? documento;

  const EditorView({
    super.key,
    required this.authViewModel,
    required this.documentosViewModel,
    this.documento,
  });

  @override
  State<EditorView> createState() => _EditorViewState();
}

class _EditorViewState extends State<EditorView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _tituloController;
  late final TextEditingController _conteudoController;
  late String _categoriaSelecionada;
  bool _salvando = false;

  bool get _estaEditando => widget.documento != null;

  @override
  void initState() {
    super.initState();
    _tituloController = TextEditingController(
      text: widget.documento?.titulo ?? '',
    );
    _conteudoController = TextEditingController(
      text: widget.documento?.conteudo ?? '',
    );
    _categoriaSelecionada = widget.documento?.categoria ?? 'Geral';
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _conteudoController.dispose();
    super.dispose();
  }

  void _voltarParaHome() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  Future<void> _salvar() async {
    if (_salvando || !(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final String? autorEmail = widget.authViewModel.usuarioAtual?.email;
    if (autorEmail == null) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/',
        (Route<dynamic> route) => false,
      );
      return;
    }

    setState(() {
      _salvando = true;
    });

    final bool sucesso = _estaEditando
        ? await widget.documentosViewModel.atualizarDocumento(
            original: widget.documento!,
            titulo: _tituloController.text,
            conteudo: _conteudoController.text,
            categoria: _categoriaSelecionada,
          )
        : await widget.documentosViewModel.criarDocumento(
            titulo: _tituloController.text,
            conteudo: _conteudoController.text,
            categoria: _categoriaSelecionada,
            autorEmail: autorEmail,
          );

    if (!mounted) {
      return;
    }

    setState(() {
      _salvando = false;
    });

    if (sucesso) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _estaEditando
                ? 'Documento atualizado com sucesso!'
                : 'Documento criado com sucesso!',
          ),
        ),
      );
      _voltarParaHome();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.documentosViewModel.erroMensagem ??
                'Erro ao salvar documento.',
          ),
        ),
      );
    }
  }

  Future<void> _excluir() async {
    final Documento? documento = widget.documento;
    if (documento == null || _salvando) {
      return;
    }

    final bool confirmado = await confirmarExclusaoDocumento(context, documento);
    if (!confirmado || !mounted) {
      return;
    }

    final bool sucesso = await widget.documentosViewModel.excluirDocumento(
      documento.id,
    );
    if (!mounted) {
      return;
    }

    if (sucesso) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Documento excluído com sucesso!')),
      );
      _voltarParaHome();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cores = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Voltar',
          icon: const Icon(Icons.arrow_back),
          onPressed: _voltarParaHome,
        ),
        title: Text(_estaEditando ? 'Editar Documento' : 'Novo Documento'),
        actions: <Widget>[
          if (_estaEditando)
            IconButton(
              tooltip: 'Excluir documento',
              icon: Icon(Icons.delete_outline, color: cores.error),
              onPressed: _salvando ? null : _excluir,
            ),
          IconButton(
            tooltip: 'Salvar documento',
            icon: const Icon(Icons.check),
            onPressed: _salvando ? null : _salvar,
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  CampoTextoPadrao(
                    controller: _tituloController,
                    rotulo: 'Título do documento',
                    dica: 'Ex.: Resumo da aula de Flutter',
                    icone: Icons.title,
                    acaoTeclado: TextInputAction.next,
                    validador: (String? valor) =>
                        Validadores.validarCampoObrigatorio(
                      valor,
                      'o título',
                      minimo: 2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Categoria',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 8),
                  SeletorCategoria(
                    categorias: Documento.categoriasPadrao,
                    selecionada: _categoriaSelecionada,
                    aoSelecionar: (String cat) {
                      setState(() {
                        _categoriaSelecionada = cat;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _conteudoController,
                    minLines: 10,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    validator: (String? valor) =>
                        Validadores.validarCampoObrigatorio(
                      valor,
                      'o conteúdo',
                      minimo: 3,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Conteúdo',
                      hintText: 'Escreva aqui o texto do seu documento...',
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _conteudoController,
                    builder: (BuildContext context, TextEditingValue valor, _) {
                      final int palavras = Documento.contarPalavras(valor.text);
                      final int caracteres = valor.text.length;
                      return Text(
                        '$palavras palavras • $caracteres caracteres',
                        textAlign: TextAlign.end,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: cores.onSurfaceVariant,
                            ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: _salvando ? null : _salvar,
                    icon: _salvando
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save_outlined),
                    label: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        _salvando ? 'Salvando...' : 'Salvar Documento',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
