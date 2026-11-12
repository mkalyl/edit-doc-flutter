import 'package:flutter/material.dart';
import '../models/documento.dart';
import '../models/services/documento_storage_service.dart';

/// ViewModel responsável pela listagem, filtros e operações CRUD de documentos.
class DocumentosViewModel extends ChangeNotifier {
  final DocumentoStorageService _storageService;

  DocumentosViewModel({DocumentoStorageService? storageService})
      : _storageService = storageService ?? DocumentoStorageService();

  List<Documento> _documentos = <Documento>[];
  String _termoBusca = '';
  String _categoriaSelecionada = 'Todas';
  bool _carregando = false;
  String? _erroMensagem;
  String? _autorAtualEmail;

  String get termoBusca => _termoBusca;
  String get categoriaSelecionada => _categoriaSelecionada;
  bool get carregando => _carregando;
  String? get erroMensagem => _erroMensagem;
  String? get autorAtualEmail => _autorAtualEmail;
  int get totalDocumentos => _documentos.length;

  /// Retorna os documentos filtrados e ordenados do mais recente ao mais antigo.
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

  /// Carrega os documentos salvos para o usuário autenticado.
  Future<void> carregarDocumentos({
    required String autorEmail,
    bool semearSeNovo = true,
  }) async {
    final String emailNormalizado = autorEmail.trim().toLowerCase();
    _carregando = true;
    _erroMensagem = null;
    _autorAtualEmail = emailNormalizado;
    notifyListeners();

    try {
      if (semearSeNovo) {
        await _storageService.garantirDocumentosIniciais(emailNormalizado);
      }
      _documentos = await _storageService.listarDocumentos(
        autorEmail: emailNormalizado,
      );
    } catch (_) {
      _erroMensagem = 'Erro ao carregar os documentos salvos.';
    } finally {
      _carregando = false;
      notifyListeners();
    }
  }

  /// Atualiza o filtro de busca textual.
  void atualizarBusca(String termo) {
    _termoBusca = termo;
    notifyListeners();
  }

  /// Atualiza o filtro de categoria.
  void selecionarCategoria(String categoria) {
    _categoriaSelecionada = categoria;
    notifyListeners();
  }

  /// Cria e persiste um novo documento.
  Future<bool> criarDocumento({
    required String titulo,
    required String conteudo,
    required String categoria,
    required String autorEmail,
  }) async {
    final DateTime agora = DateTime.now();
    final Documento novoDocumento = Documento(
      id: 'doc-${agora.microsecondsSinceEpoch}',
      titulo: titulo.trim(),
      conteudo: conteudo.trim(),
      categoria: categoria,
      autorEmail: autorEmail.trim().toLowerCase(),
      criadoEm: agora,
      atualizadoEm: agora,
    );

    try {
      await _storageService.criarDocumento(novoDocumento);
      _documentos.add(novoDocumento);
      _erroMensagem = null;
      notifyListeners();
      return true;
    } catch (_) {
      _erroMensagem = 'Não foi possível salvar o documento.';
      notifyListeners();
      return false;
    }
  }

  /// Atualiza um documento existente e persiste as alterações.
  Future<bool> atualizarDocumento({
    required Documento original,
    required String titulo,
    required String conteudo,
    required String categoria,
  }) async {
    final Documento atualizado = original.copyWith(
      titulo: titulo.trim(),
      conteudo: conteudo.trim(),
      categoria: categoria,
      atualizadoEm: DateTime.now(),
    );

    try {
      await _storageService.atualizarDocumento(atualizado);
      final int indice = _documentos.indexWhere(
        (Documento doc) => doc.id == atualizado.id,
      );
      if (indice != -1) {
        _documentos[indice] = atualizado;
      } else {
        _documentos.add(atualizado);
      }
      _erroMensagem = null;
      notifyListeners();
      return true;
    } catch (_) {
      _erroMensagem = 'Não foi possível atualizar o documento.';
      notifyListeners();
      return false;
    }
  }

  /// Exclui um documento pelo ID tanto em memória quanto no armazenamento local.
  Future<bool> excluirDocumento(String id) async {
    try {
      await _storageService.excluirDocumento(id);
      _documentos.removeWhere((Documento doc) => doc.id == id);
      _erroMensagem = null;
      notifyListeners();
      return true;
    } catch (_) {
      _erroMensagem = 'Não foi possível excluir o documento.';
      notifyListeners();
      return false;
    }
  }

  /// Limpa apenas o estado em memória ao encerrar a sessão do usuário.
  void limparEstadoLocal() {
    _documentos = <Documento>[];
    _termoBusca = '';
    _categoriaSelecionada = 'Todas';
    _autorAtualEmail = null;
    _erroMensagem = null;
    notifyListeners();
  }
}
