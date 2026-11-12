import 'package:flutter/material.dart';
import '../models/documento.dart';

/// ViewModel responsável pela listagem e filtragem de documentos (Fase 1 em memória).
class DocumentosViewModel extends ChangeNotifier {
  final List<Documento> _documentos = <Documento>[
    Documento(
      id: 'doc-1',
      titulo: 'Bem-vindo ao EditDoc Flutter',
      conteudo:
          'Este projeto foi migrado do protótipo inicial para a arquitetura MVVM '
          'com separação clara entre Models, ViewModels e Views.',
      categoria: 'Geral',
      autorEmail: 'aluno@editdoc.com',
      criadoEm: DateTime(2026, 11, 10, 9, 0),
      atualizadoEm: DateTime(2026, 11, 12, 14, 30),
    ),
    Documento(
      id: 'doc-2',
      titulo: 'Resumo de Arquitetura MVVM',
      conteudo:
          'ViewModels estendem ChangeNotifier e notificam as Views via '
          'ListenableBuilder sempre que o estado da aplicação muda.',
      categoria: 'Estudos',
      autorEmail: 'aluno@editdoc.com',
      criadoEm: DateTime(2026, 11, 11, 10, 15),
      atualizadoEm: DateTime(2026, 11, 12, 11, 20),
    ),
    Documento(
      id: 'doc-3',
      titulo: 'Checklist do Codespaces',
      conteudo:
          '1. Conferir devcontainer.json\n'
          '2. Conferir launch.json na porta 8080\n'
          '3. Validar rotas nomeadas e tema reativo.',
      categoria: 'Trabalho',
      autorEmail: 'aluno@editdoc.com',
      criadoEm: DateTime(2026, 11, 12, 8, 0),
      atualizadoEm: DateTime(2026, 11, 12, 8, 45),
    ),
  ];

  String _termoBusca = '';
  String _categoriaSelecionada = 'Todas';

  String get termoBusca => _termoBusca;
  String get categoriaSelecionada => _categoriaSelecionada;
  int get totalDocumentos => _documentos.length;

  /// Retorna os documentos filtrados por busca e categoria, ordenados pelo mais recente.
  List<Documento> get documentos {
    final String termo = _termoBusca.trim().toLowerCase();
    final List<Documento> filtrados = _documentos.where((Documento doc) {
      final bool combinaCategoria = _categoriaSelecionada == 'Todas' ||
          doc.categoria == _categoriaSelecionada;
      if (!combinaCategoria) {
        return false;
      }
      if (termo.isEmpty) {
        return true;
      }
      return doc.titulo.toLowerCase().contains(termo) ||
          doc.conteudo.toLowerCase().contains(termo);
    }).toList();

    filtrados.sort(
      (Documento a, Documento b) => b.atualizadoEm.compareTo(a.atualizadoEm),
    );
    return List<Documento>.unmodifiable(filtrados);
  }

  /// Atualiza o termo de busca e notifica a interface.
  void atualizarBusca(String termo) {
    _termoBusca = termo;
    notifyListeners();
  }

  /// Seleciona a categoria de filtro e notifica a interface.
  void selecionarCategoria(String categoria) {
    _categoriaSelecionada = categoria;
    notifyListeners();
  }
}
