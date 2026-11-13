import 'dart:convert';
import '../utils/json_helpers.dart';

/// Modelo de domínio de um documento com suporte a cópia e serialização JSON.
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

  /// Cria uma cópia alterando apenas os campos informados.
  Documento copyWith({
    String? id,
    String? titulo,
    String? conteudo,
    String? categoria,
    String? autorEmail,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
  }) {
    return Documento(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      conteudo: conteudo ?? this.conteudo,
      categoria: categoria ?? this.categoria,
      autorEmail: autorEmail ?? this.autorEmail,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    );
  }

  /// Converte o documento para mapa chave-valor.
  Map<String, dynamic> toMap() => <String, dynamic>{
        'id': id,
        'titulo': titulo,
        'conteudo': conteudo,
        'categoria': categoria,
        'autorEmail': autorEmail,
        'criadoEm': criadoEm.toIso8601String(),
        'atualizadoEm': atualizadoEm.toIso8601String(),
      };

  /// Reconstrói o documento a partir de um mapa chave-valor.
  factory Documento.fromMap(Map<String, dynamic> mapa) {
    final String categoriaLida = (mapa['categoria'] ?? 'Geral').toString();
    final String categoriaValida = categoriasPadrao.contains(categoriaLida)
        ? categoriaLida
        : 'Geral';

    return Documento(
      id: (mapa['id'] ?? '').toString(),
      titulo: (mapa['titulo'] ?? '').toString(),
      conteudo: (mapa['conteudo'] ?? '').toString(),
      categoria: categoriaValida,
      autorEmail: (mapa['autorEmail'] ?? '').toString(),
      criadoEm:
          DateTime.tryParse((mapa['criadoEm'] ?? '').toString()) ??
              DateTime.now(),
      atualizadoEm:
          DateTime.tryParse((mapa['atualizadoEm'] ?? '').toString()) ??
              DateTime.now(),
    );
  }

  /// Serializa o documento em string JSON.
  String toJson() => jsonEncode(toMap());

  /// Desserializa um documento a partir de uma string JSON.
  factory Documento.fromJson(String origem) {
    return Documento.fromMap(decodificarMapaJson(origem));
  }

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

  /// Conta o número de palavras presentes no conteúdo.
  int get contagemPalavras => contarPalavras(conteudo);

  /// Função utilitária compartilhada para contagem de palavras de um texto.
  static int contarPalavras(String texto) {
    final String textoLimpo = texto.trim();
    if (textoLimpo.isEmpty) {
      return 0;
    }
    return textoLimpo.split(RegExp(r'\s+')).length;
  }

  /// Conta o total de caracteres no conteúdo.
  int get contagemCaracteres => conteudo.length;
}
