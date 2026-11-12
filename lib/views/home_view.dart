import 'package:flutter/material.dart';
import '../models/documento.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/documentos_viewmodel.dart';
import 'widgets/documento_card.dart';
import 'widgets/estado_vazio_widget.dart';

/// Tela principal com a listagem de documentos (Rota: /home).
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
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  void _abrirVisualizacao(Documento documento) {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(documento.titulo),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Chip(label: Text(documento.categoria)),
                const SizedBox(height: 12),
                Text(documento.conteudo),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  void _sair() {
    widget.authViewModel.logout();
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
              IconButton(
                tooltip: widget.authViewModel.temaEscuro
                    ? 'Tema claro'
                    : 'Tema escuro',
                icon: Icon(
                  widget.authViewModel.temaEscuro
                      ? Icons.light_mode_outlined
                      : Icons.dark_mode_outlined,
                ),
                onPressed: widget.authViewModel.alternarTema,
              ),
              IconButton(
                tooltip: 'Sair',
                icon: const Icon(Icons.logout),
                onPressed: _sair,
              ),
            ],
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
                        suffixIcon: widget.documentosViewModel.termoBusca.isEmpty
                            ? null
                            : IconButton(
                                tooltip: 'Limpar busca',
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _buscaController.clear();
                                  widget.documentosViewModel.atualizarBusca('');
                                },
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: categorias.map((String categoria) {
                          final bool selecionada = widget.documentosViewModel
                                  .categoriaSelecionada ==
                              categoria;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(categoria),
                              selected: selecionada,
                              onSelected: (_) {
                                widget.documentosViewModel
                                    .selecionarCategoria(categoria);
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: documentos.isEmpty
                          ? const EstadoVazioWidget(
                              icone: Icons.article_outlined,
                              titulo: 'Nenhum documento encontrado',
                              mensagem:
                                  'Ajuste o filtro de busca ou a categoria selecionada.',
                            )
                          : ListView.builder(
                              itemCount: documentos.length,
                              itemBuilder: (BuildContext context, int index) {
                                final Documento doc = documentos[index];
                                return DocumentoCard(
                                  documento: doc,
                                  aoTocar: () => _abrirVisualizacao(doc),
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
