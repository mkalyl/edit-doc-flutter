/// Modelo de domínio que representa um documento de texto no editor.
class Documento {
  static const List<String> categoriasPadrao = <String>[
    'Geral',
    'Estudos',
    'Trabalho',
    'Pessoal',
  ];

  final String id;
  final String titulo;
  final String conteudo;
  final String categoria;
  final String autorEmail;
  final DateTime criadoEm;
  final DateTime atualizadoEm;

  const Documento({
    required this.id,
    required this.titulo,
    required this.conteudo,
    required this.categoria,
    required this.autorEmail,
    required this.criadoEm,
    required this.atualizadoEm,
  });

  /// Retorna um resumo curto do conteúdo para exibição em listas.
  String get resumo {
    final String textoLimpo = conteudo.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (textoLimpo.isEmpty) {
      return 'Sem conteúdo';
    }
    if (textoLimpo.length <= 90) {
      return textoLimpo;
    }
    return '${textoLimpo.substring(0, 90)}...';
  }

  /// Conta o número de palavras presentes no conteúdo do documento.
  int get contagemPalavras {
    final String textoLimpo = conteudo.trim();
    if (textoLimpo.isEmpty) {
      return 0;
    }
    return textoLimpo.split(RegExp(r'\s+')).length;
  }
}
