import 'dart:convert';

/// Modelo de domínio que representa um usuário com suporte a serialização JSON.
class Usuario {
  final String id;
  final String nome;
  final String email;
  final String senha;

  const Usuario({
    required this.id,
    required this.nome,
    required this.email,
    required this.senha,
  });

  /// Converte o usuário em mapa chave-valor para persistência.
  Map<String, dynamic> toMap() => <String, dynamic>{
        'id': id,
        'nome': nome,
        'email': email,
        'senha': senha,
      };

  /// Reconstrói um usuário a partir de um mapa chave-valor.
  factory Usuario.fromMap(Map<String, dynamic> mapa) {
    return Usuario(
      id: (mapa['id'] ?? '').toString(),
      nome: (mapa['nome'] ?? '').toString(),
      email: (mapa['email'] ?? '').toString(),
      senha: (mapa['senha'] ?? '').toString(),
    );
  }

  /// Serializa o usuário para uma string JSON.
  String toJson() => jsonEncode(toMap());

  /// Desserializa um usuário a partir de uma string JSON.
  factory Usuario.fromJson(String origem) {
    final Map<String, dynamic> mapa =
        jsonDecode(origem) as Map<String, dynamic>;
    return Usuario.fromMap(mapa);
  }
}
