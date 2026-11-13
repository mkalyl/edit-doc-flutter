import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/json_helpers.dart';
import '../documento.dart';

/// Serviço responsável pelo CRUD persistente de documentos via JSON no shared_preferences.
class DocumentoStorageService {
  static const String _chaveDocumentos = 'edit_doc_documentos_json';
  static const String _prefixoIniciais = 'edit_doc_iniciais_';

  final List<Documento> _cacheEmMemoria = <Documento>[];
  final Set<String> _iniciaisEmMemoria = <String>{};

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  /// Lê todos os documentos armazenados no JSON local.
  Future<List<Documento>> _lerTodos() async {
    try {
      final SharedPreferences prefs = await _prefs;
      final String? jsonBruto = prefs.getString(_chaveDocumentos);
      if (jsonBruto != null && jsonBruto.trim().isNotEmpty) {
        final List<Documento> lidos = decodificarListaJson(jsonBruto)
            .map(Documento.fromMap)
            .toList();
        _cacheEmMemoria
          ..clear()
          ..addAll(lidos);
        return List<Documento>.from(lidos);
      }
    } catch (_) {
      // Usa fallback em memória se localStorage estiver restrito.
    }
    return List<Documento>.from(_cacheEmMemoria);
  }

  /// Grava a lista completa de documentos serializada em JSON.
  Future<void> _salvarTodos(List<Documento> documentos) async {
    _cacheEmMemoria
      ..clear()
      ..addAll(documentos);
    try {
      final SharedPreferences prefs = await _prefs;
      final List<Map<String, dynamic>> mapas =
          documentos.map((Documento d) => d.toMap()).toList();
      await prefs.setString(_chaveDocumentos, jsonEncode(mapas));
    } catch (_) {
      // Mantém dados em memória se localStorage estiver restrito.
    }
  }

  /// Garante documentos iniciais de boas-vindas apenas no primeiro acesso do usuário.
  Future<void> garantirDocumentosIniciais(String autorEmail) async {
    final String email = autorEmail.trim().toLowerCase();
    final String chaveInicial = '$_prefixoIniciais$email';

    bool jaInicializado = _iniciaisEmMemoria.contains(email);
    try {
      final SharedPreferences prefs = await _prefs;
      jaInicializado = jaInicializado || (prefs.getBool(chaveInicial) ?? false);
    } catch (_) {}

    if (jaInicializado) {
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

    _iniciaisEmMemoria.add(email);
    try {
      final SharedPreferences prefs = await _prefs;
      await prefs.setBool(chaveInicial, true);
    } catch (_) {}
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
