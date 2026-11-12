import 'package:flutter/material.dart';
import '../models/usuario.dart';

/// ViewModel responsável pela autenticação, cadastro e tema (Fase 1 em memória).
class AuthViewModel extends ChangeNotifier {
  final List<Usuario> _usuarios = <Usuario>[
    const Usuario(
      id: 'usr-demo',
      nome: 'Aluno Demo',
      email: 'aluno@editdoc.com',
      senha: '123456',
    ),
  ];

  Usuario? _usuarioAtual;
  bool _temaEscuro = false;
  String? _erroMensagem;

  Usuario? get usuarioAtual => _usuarioAtual;
  bool get estaAutenticado => _usuarioAtual != null;
  bool get temaEscuro => _temaEscuro;
  ThemeMode get themeMode => _temaEscuro ? ThemeMode.dark : ThemeMode.light;
  String? get erroMensagem => _erroMensagem;

  /// Alterna entre tema claro e escuro e notifica a interface.
  void alternarTema() {
    _temaEscuro = !_temaEscuro;
    notifyListeners();
  }

  /// Limpa a mensagem de erro exibida nas telas de autenticação.
  void limparErro() {
    if (_erroMensagem != null) {
      _erroMensagem = null;
      notifyListeners();
    }
  }

  /// Autentica um usuário cadastrado na lista em memória.
  bool login(String email, String senha) {
    final String emailNormalizado = email.trim().toLowerCase();
    for (final Usuario usuario in _usuarios) {
      if (usuario.email == emailNormalizado && usuario.senha == senha) {
        _usuarioAtual = usuario;
        _erroMensagem = null;
        notifyListeners();
        return true;
      }
    }

    _erroMensagem = 'E-mail ou senha inválidos.';
    notifyListeners();
    return false;
  }

  /// Cadastra um novo usuário se o e-mail ainda não existir.
  bool cadastrar({
    required String nome,
    required String email,
    required String senha,
  }) {
    final String emailNormalizado = email.trim().toLowerCase();
    final bool jaExiste = _usuarios.any(
      (Usuario u) => u.email == emailNormalizado,
    );

    if (jaExiste) {
      _erroMensagem = 'Já existe uma conta cadastrada com este e-mail.';
      notifyListeners();
      return false;
    }

    final Usuario novoUsuario = Usuario(
      id: 'usr-${DateTime.now().microsecondsSinceEpoch}',
      nome: nome.trim(),
      email: emailNormalizado,
      senha: senha,
    );

    _usuarios.add(novoUsuario);
    _usuarioAtual = novoUsuario;
    _erroMensagem = null;
    notifyListeners();
    return true;
  }

  /// Encerra a sessão atual em memória.
  void logout() {
    _usuarioAtual = null;
    _erroMensagem = null;
    notifyListeners();
  }
}
