import 'package:flutter/material.dart';
import '../models/documento.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/documentos_viewmodel.dart';
import 'widgets/botao_alternar_tema.dart';
import 'widgets/confirmar_exclusao_dialog.dart';
import 'widgets/documento_card.dart';
import 'widgets/estado_vazio_widget.dart';
import 'widgets/seletor_categoria.dart';

/// Tela principal com a listagem e gestão CRUD de documentos (Rota: /home).
class HomeView extends StatefulWidget {
  final AuthViewModel authViewModel;
  final DocumentosViewModel documentosViewModel;

  const HomeView({
    super.key,
    required this.authViewModel,
    required this.documentosViewModel,
  });

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final TextEditingController _buscaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final String? email = widget.authViewModel.usuarioAtual?.email;
      if (email != null &&
          widget.documentosViewModel.autorAtualEmail != email.toLowerCase()) {
        widget.documentosViewModel.carregarDocumentos(autorEmail: email);
      }
    });
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  void _abrirEditor([Documento? documento]) {
    Navigator.of(context).pushNamed('/editor', arguments: documento);
  }

  Future<void> _excluirDocumento(Documento documento) async {
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          sucesso
              ? 'Documento excluído com sucesso!'
              : (widget.documentosViewModel.erroMensagem ??
                  'Erro ao excluir documento.'),
        ),
      ),
    );
  }

  Future<void> _sair() async {
    await widget.authViewModel.logout();
    widget.documentosViewModel.limparEstadoLocal();
    if (!mounted) {
      return;
    }
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/',
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<String> categorias = <String>[
      'Todas',
      ...Documento.categoriasPadrao,
    ];

    return ListenableBuilder(
      listenable: Listenable.merge(<Listenable>[
        widget.authViewModel,
        widget.documentosViewModel,
      ]),
      builder: (BuildContext context, _) {
        final String nomeUsuario =
            widget.authViewModel.usuarioAtual?.nome ?? 'Usuário';
        final List<Documento> documentos =
            widget.documentosViewModel.documentos;
        final bool carregando = widget.documentosViewModel.carregando;
        final bool semDocumentos =
            widget.documentosViewModel.totalDocumentos == 0;

        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('Meus Documentos'),
                Text(
                  'Olá, $nomeUsuario',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            actions: <Widget>[
              BotaoAlternarTema(authViewModel: widget.authViewModel),
              IconButton(
                tooltip: 'Sair',
                icon: const Icon(Icons.logout),
                onPressed: _sair,
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _abrirEditor(),
            icon: const Icon(Icons.add),
            label: const Text('Novo Documento'),
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 920),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    TextField(
                      controller: _buscaController,
                      onChanged: widget.documentosViewModel.atualizarBusca,
                      decoration: InputDecoration(
                        hintText: 'Buscar por título ou conteúdo...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon:
                            widget.documentosViewModel.termoBusca.isEmpty
                                ? null
                                : IconButton(
                                    tooltip: 'Limpar busca',
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      _buscaController.clear();
                                      widget.documentosViewModel
                                          .atualizarBusca('');
                                    },
                                  ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SeletorCategoria(
                      categorias: categorias,
                      selecionada:
                          widget.documentosViewModel.categoriaSelecionada,
                      aoSelecionar:
                          widget.documentosViewModel.selecionarCategoria,
                      rolavelHorizontal: true,
                    ),
                    const SizedBox(height: 12),
                    if (carregando) const LinearProgressIndicator(),
                    Expanded(
                      child: documentos.isEmpty
                          ? EstadoVazioWidget(
                              icone: Icons.article_outlined,
                              titulo: semDocumentos
                                  ? 'Nenhum documento criado ainda'
                                  : 'Nenhum documento encontrado',
                              mensagem: semDocumentos
                                  ? 'Toque em "Novo Documento" para escrever seu primeiro texto.'
                                  : 'Ajuste o filtro de busca ou a categoria selecionada.',
                              acao: semDocumentos
                                  ? FilledButton.icon(
                                      onPressed: () => _abrirEditor(),
                                      icon: const Icon(Icons.add),
                                      label: const Text('Criar documento'),
                                    )
                                  : null,
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.only(bottom: 80),
                              itemCount: documentos.length,
                              itemBuilder: (BuildContext context, int index) {
                                final Documento doc = documentos[index];
                                return DocumentoCard(
                                  documento: doc,
                                  aoTocar: () => _abrirEditor(doc),
                                  aoEditar: () => _abrirEditor(doc),
                                  aoExcluir: () => _excluirDocumento(doc),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
