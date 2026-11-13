import 'package:shared_preferences/shared_preferences.dart';
import '../usuario.dart';

/// Serviço de persistência simples (chave-valor) para tema e sessão do usuário.
class PreferencesService {
  static const String _chaveTemaEscuro = 'edit_doc_tema_escuro';
  static const String _chaveUsuarioSessao = 'edit_doc_usuario_sessao';

  bool _temaFallback = false;
  Usuario? _sessaoFallback;

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  /// Recupera a preferência de tema escuro salva no navegador/dispositivo.
  Future<bool> carregarTemaEscuro() async {
    try {
      final SharedPreferences prefs = await _prefs;
      final bool? salvo = prefs.getBool(_chaveTemaEscuro);
      if (salvo != null) {
        _temaFallback = salvo;
      }
      return _temaFallback;
    } catch (_) {
      return _temaFallback;
    }
  }

  /// Salva a preferência de tema (Claro/Escuro).
  Future<void> salvarTemaEscuro(bool temaEscuro) async {
    _temaFallback = temaEscuro;
    try {
      final SharedPreferences prefs = await _prefs;
      await prefs.setBool(_chaveTemaEscuro, temaEscuro);
    } catch (_) {
      // Mantém preferência em memória caso o armazenamento do navegador bloqueie.
    }
  }

  /// Recupera os dados da sessão do usuário autenticado, caso exista.
  Future<Usuario?> carregarSessaoUsuario() async {
    try {
      final SharedPreferences prefs = await _prefs;
      final String? jsonSessao = prefs.getString(_chaveUsuarioSessao);
      if (jsonSessao == null || jsonSessao.trim().isEmpty) {
        return _sessaoFallback;
      }
      final Usuario usuario = Usuario.fromJson(jsonSessao);
      _sessaoFallback = usuario;
      return usuario;
    } catch (_) {
      try {
        final SharedPreferences prefs = await _prefs;
        await prefs.remove(_chaveUsuarioSessao);
      } catch (_) {}
      return _sessaoFallback;
    }
  }

  /// Persiste a sessão ativa do usuário autenticado.
  Future<void> salvarSessaoUsuario(Usuario usuario) async {
    _sessaoFallback = usuario;
    try {
      final SharedPreferences prefs = await _prefs;
      await prefs.setString(_chaveUsuarioSessao, usuario.toJson());
    } catch (_) {
      // Mantém sessão em memória caso o armazenamento do navegador bloqueie.
    }
  }

  /// Remove a sessão salva ao efetuar logout.
  Future<void> limparSessaoUsuario() async {
    _sessaoFallback = null;
    try {
      final SharedPreferences prefs = await _prefs;
      await prefs.remove(_chaveUsuarioSessao);
    } catch (_) {}
  }
}
