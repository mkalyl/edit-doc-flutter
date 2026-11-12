import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../documento.dart';
import '../usuario.dart';
import 'documento_storage_service.dart';

/// Repositório local centralizado para persistência de Usuários e Documentos.
class BancoLocalService {
  static const String _chaveUsuarios = 'edit_doc_usuarios_json';

  final DocumentoStorageService documentos;

  BancoLocalService({DocumentoStorageService? documentoStorageService})
      : documentos = documentoStorageService ?? DocumentoStorageService();

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<List<Usuario>> _lerUsuarios() async {
    final SharedPreferences prefs = await _prefs;
    final String? jsonBruto = prefs.getString(_chaveUsuarios);
    if (jsonBruto == null || jsonBruto.trim().isEmpty) {
      return <Usuario>[];
    }

    try {
      final Object? decodificado = jsonDecode(jsonBruto);
      if (decodificado is! List<dynamic>) {
        return <Usuario>[];
      }
      return decodificado
          .whereType<Map<String, dynamic>>()
          .map(Usuario.fromMap)
          .toList();
    } catch (_) {
      return <Usuario>[];
    }
  }

  Future<void> _salvarUsuarios(List<Usuario> usuarios) async {
    final SharedPreferences prefs = await _prefs;
    final List<Map<String, dynamic>> mapas =
        usuarios.map((Usuario u) => u.toMap()).toList();
    await prefs.setString(_chaveUsuarios, jsonEncode(mapas));
  }

  /// Cria a conta padrão de demonstração caso ainda não exista nenhum usuário salvo.
  Future<void> garantirUsuarioDemo() async {
    final List<Usuario> usuarios = await _lerUsuarios();
    if (usuarios.isNotEmpty) {
      return;
    }

    usuarios.add(
      const Usuario(
        id: 'usr-demo',
        nome: 'Aluno Demo',
        email: 'aluno@editdoc.com',
        senha: '123456',
      ),
    );
    await _salvarUsuarios(usuarios);
  }

  /// Lista todos os usuários cadastrados localmente.
  Future<List<Usuario>> listarUsuarios() => _lerUsuarios();

  /// Busca um usuário pelo e-mail normalizado.
  Future<Usuario?> buscarUsuarioPorEmail(String email) async {
    final String emailNormalizado = email.trim().toLowerCase();
    final List<Usuario> usuarios = await _lerUsuarios();
    for (final Usuario usuario in usuarios) {
      if (usuario.email.toLowerCase() == emailNormalizado) {
        return usuario;
      }
    }
    return null;
  }

  /// Valida credenciais e retorna o usuário autenticado ou null.
  Future<Usuario?> autenticar(String email, String senha) async {
    await garantirUsuarioDemo();
    final Usuario? usuario = await buscarUsuarioPorEmail(email);
    if (usuario != null && usuario.senha == senha) {
      return usuario;
    }
    return null;
  }

  /// Cadastra um novo usuário se o e-mail ainda não estiver em uso.
  Future<Usuario?> cadastrarUsuario({
    required String nome,
    required String email,
    required String senha,
  }) async {
    await garantirUsuarioDemo();
    final String emailNormalizado = email.trim().toLowerCase();
    final Usuario? existente = await buscarUsuarioPorEmail(emailNormalizado);
    if (existente != null) {
      return null;
    }

    final List<Usuario> usuarios = await _lerUsuarios();
    final Usuario novoUsuario = Usuario(
      id: 'usr-${DateTime.now().microsecondsSinceEpoch}',
      nome: nome.trim(),
      email: emailNormalizado,
      senha: senha,
    );
    usuarios.add(novoUsuario);
    await _salvarUsuarios(usuarios);
    return novoUsuario;
  }

  /// Atalho delegado para listagem de documentos do usuário.
  Future<List<Documento>> listarDocumentos(String autorEmail) =>
      documentos.listarDocumentos(autorEmail: autorEmail);
}
