import 'package:shared_preferences/shared_preferences.dart';
import '../usuario.dart';

/// Serviço de persistência simples (chave-valor) para tema e sessão do usuário.
class PreferencesService {
  static const String _chaveTemaEscuro = 'edit_doc_tema_escuro';
  static const String _chaveUsuarioSessao = 'edit_doc_usuario_sessao';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  /// Recupera a preferência de tema escuro salva no navegador/dispositivo.
  Future<bool> carregarTemaEscuro() async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getBool(_chaveTemaEscuro) ?? false;
  }

  /// Salva a preferência de tema (Claro/Escuro).
  Future<void> salvarTemaEscuro(bool temaEscuro) async {
    final SharedPreferences prefs = await _prefs;
    await prefs.setBool(_chaveTemaEscuro, temaEscuro);
  }

  /// Recupera os dados da sessão do usuário autenticado, caso exista.
  Future<Usuario?> carregarSessaoUsuario() async {
    final SharedPreferences prefs = await _prefs;
    final String? jsonSessao = prefs.getString(_chaveUsuarioSessao);
    if (jsonSessao == null || jsonSessao.trim().isEmpty) {
      return null;
    }
    try {
      return Usuario.fromJson(jsonSessao);
    } catch (_) {
      await prefs.remove(_chaveUsuarioSessao);
      return null;
    }
  }

  /// Persiste a sessão ativa do usuário autenticado.
  Future<void> salvarSessaoUsuario(Usuario usuario) async {
    final SharedPreferences prefs = await _prefs;
    await prefs.setString(_chaveUsuarioSessao, usuario.toJson());
  }

  /// Remove a sessão salva ao efetuar logout.
  Future<void> limparSessaoUsuario() async {
    final SharedPreferences prefs = await _prefs;
    await prefs.remove(_chaveUsuarioSessao);
  }
}
