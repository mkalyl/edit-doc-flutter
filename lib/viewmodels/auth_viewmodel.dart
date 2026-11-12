import 'package:flutter/material.dart';
import '../models/services/banco_local_service.dart';
import '../models/services/preferences_service.dart';
import '../models/usuario.dart';

/// ViewModel responsável pela autenticação, cadastro, sessão e tema persistente.
class AuthViewModel extends ChangeNotifier {
  final PreferencesService _preferencesService;
  final BancoLocalService _bancoLocalService;

  AuthViewModel({
    PreferencesService? preferencesService,
    BancoLocalService? bancoLocalService,
  })  : _preferencesService = preferencesService ?? PreferencesService(),
        _bancoLocalService = bancoLocalService ?? BancoLocalService();

  Usuario? _usuarioAtual;
  bool _temaEscuro = false;
  bool _carregando = false;
  bool _inicializado = false;
  String? _erroMensagem;

  Usuario? get usuarioAtual => _usuarioAtual;
  bool get estaAutenticado => _usuarioAtual != null;
  bool get temaEscuro => _temaEscuro;
  ThemeMode get themeMode => _temaEscuro ? ThemeMode.dark : ThemeMode.light;
  bool get carregando => _carregando;
  bool get inicializado => _inicializado;
  String? get erroMensagem => _erroMensagem;

  /// Carrega tema, garante conta demo e restaura a sessão salva localmente.
  Future<void> inicializar() async {
    _temaEscuro = await _preferencesService.carregarTemaEscuro();
    await _bancoLocalService.garantirUsuarioDemo();

    final Usuario? sessaoSalva =
        await _preferencesService.carregarSessaoUsuario();
    if (sessaoSalva != null) {
      final Usuario? usuarioValido =
          await _bancoLocalService.buscarUsuarioPorEmail(sessaoSalva.email);
      if (usuarioValido != null) {
        _usuarioAtual = usuarioValido;
      } else {
        await _preferencesService.limparSessaoUsuario();
      }
    }

    _inicializado = true;
    notifyListeners();
  }

  /// Alterna entre tema claro e escuro persistindo a escolha no shared_preferences.
  Future<void> alternarTema() async {
    _temaEscuro = !_temaEscuro;
    notifyListeners();
    await _preferencesService.salvarTemaEscuro(_temaEscuro);
  }

  /// Limpa a mensagem de erro atual.
  void limparErro() {
    if (_erroMensagem != null) {
      _erroMensagem = null;
      notifyListeners();
    }
  }

  /// Autentica o usuário no repositório local e persiste a sessão ativa.
  Future<bool> login(String email, String senha) async {
    _carregando = true;
    _erroMensagem = null;
    notifyListeners();

    final Usuario? usuario = await _bancoLocalService.autenticar(email, senha);
    if (usuario != null) {
      await _preferencesService.salvarSessaoUsuario(usuario);
      _usuarioAtual = usuario;
      _carregando = false;
      notifyListeners();
      return true;
    }

    _erroMensagem = 'E-mail ou senha inválidos.';
    _carregando = false;
    notifyListeners();
    return false;
  }

  /// Cadastra um novo usuário, valida duplicidade de e-mail e inicia a sessão.
  Future<bool> cadastrar({
    required String nome,
    required String email,
    required String senha,
  }) async {
    _carregando = true;
    _erroMensagem = null;
    notifyListeners();

    final Usuario? novoUsuario = await _bancoLocalService.cadastrarUsuario(
      nome: nome,
      email: email,
      senha: senha,
    );

    if (novoUsuario == null) {
      _erroMensagem = 'Já existe uma conta cadastrada com este e-mail.';
      _carregando = false;
      notifyListeners();
      return false;
    }

    await _preferencesService.salvarSessaoUsuario(novoUsuario);
    _usuarioAtual = novoUsuario;
    _carregando = false;
    notifyListeners();
    return true;
  }

  /// Encerra a sessão atual e remove os dados persistidos da sessão.
  Future<void> logout() async {
    await _preferencesService.limparSessaoUsuario();
    _usuarioAtual = null;
    _erroMensagem = null;
    notifyListeners();
  }
}
