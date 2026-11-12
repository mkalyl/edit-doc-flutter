import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../documento.dart';

/// Serviço responsável pelo CRUD persistente de documentos via JSON no shared_preferences.
class DocumentoStorageService {
  static const String _chaveDocumentos = 'edit_doc_documentos_json';
  static const String _prefixoIniciais = 'edit_doc_iniciais_';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  /// Lê todos os documentos armazenados no JSON local.
  Future<List<Documento>> _lerTodos() async {
    final SharedPreferences prefs = await _prefs;
    final String? jsonBruto = prefs.getString(_chaveDocumentos);
    if (jsonBruto == null || jsonBruto.trim().isEmpty) {
      return <Documento>[];
    }

    try {
      final Object? decodificado = jsonDecode(jsonBruto);
      if (decodificado is! List<dynamic>) {
        return <Documento>[];
      }
      return decodificado
          .whereType<Map<String, dynamic>>()
          .map(Documento.fromMap)
          .toList();
    } catch (_) {
      return <Documento>[];
    }
  }

  /// Grava a lista completa de documentos serializada em JSON.
  Future<void> _salvarTodos(List<Documento> documentos) async {
    final SharedPreferences prefs = await _prefs;
    final List<Map<String, dynamic>> mapas =
        documentos.map((Documento d) => d.toMap()).toList();
    await prefs.setString(_chaveDocumentos, jsonEncode(mapas));
  }

  /// Garante documentos iniciais de boas-vindas apenas no primeiro acesso do usuário.
  Future<void> garantirDocumentosIniciais(String autorEmail) async {
    final String email = autorEmail.trim().toLowerCase();
    final SharedPreferences prefs = await _prefs;
    final String chaveInicial = '$_prefixoIniciais$email';
    if (prefs.getBool(chaveInicial) ?? false) {
      return;
    }

    final List<Documento> todos = await _lerTodos();
    final bool jaPossuiDocs = todos.any(
      (Documento doc) => doc.autorEmail.toLowerCase() == email,
    );

    if (!jaPossuiDocs) {
      final DateTime agora = DateTime.now();
      todos.addAll(<Documento>[
        Documento(
          id: 'doc-inicial-1-${agora.microsecondsSinceEpoch}',
          titulo: 'Guia Rápido do EditDoc',
          conteudo:
              'Use o botão "Novo Documento" para criar textos, toque em um cartão '
              'para editar e teste pressionar F5 para confirmar a persistência local.',
          categoria: 'Geral',
          autorEmail: email,
          criadoEm: agora,
          atualizadoEm: agora,
        ),
        Documento(
          id: 'doc-inicial-2-${agora.microsecondsSinceEpoch + 1}',
          titulo: 'Anotações de Arquitetura MVVM',
          conteudo:
              'Models e Services lidam com dados e shared_preferences. '
              'ViewModels gerenciam estado com ChangeNotifier e notificam as Views.',
          categoria: 'Estudos',
          autorEmail: email,
          criadoEm: agora,
          atualizadoEm: agora.subtract(const Duration(minutes: 5)),
        ),
      ]);
      await _salvarTodos(todos);
    }

    await prefs.setBool(chaveInicial, true);
  }

  /// Lista os documentos pertencentes ao usuário autenticado.
  Future<List<Documento>> listarDocumentos({required String autorEmail}) async {
    final String email = autorEmail.trim().toLowerCase();
    final List<Documento> todos = await _lerTodos();
    return todos
        .where((Documento doc) => doc.autorEmail.toLowerCase() == email)
        .toList();
  }

  /// Cria e persiste um novo documento.
  Future<void> criarDocumento(Documento documento) async {
    final List<Documento> todos = await _lerTodos();
    todos.add(documento);
    await _salvarTodos(todos);
  }

  /// Atualiza um documento existente localizado pelo seu ID.
  Future<void> atualizarDocumento(Documento documento) async {
    final List<Documento> todos = await _lerTodos();
    final int indice = todos.indexWhere((Documento d) => d.id == documento.id);
    if (indice == -1) {
      todos.add(documento);
    } else {
      todos[indice] = documento;
    }
    await _salvarTodos(todos);
  }

  /// Remove permanentemente um documento pelo seu ID.
  Future<void> excluirDocumento(String id) async {
    final List<Documento> todos = await _lerTodos();
    todos.removeWhere((Documento d) => d.id == id);
    await _salvarTodos(todos);
  }
}
