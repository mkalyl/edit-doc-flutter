/// Funções utilitárias de validação para formulários do aplicativo.
abstract final class Validadores {
  static final RegExp _regexEmail = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$');

  /// Valida o nome completo ou de exibição do usuário.
  static String? validarNome(String? valor) {
    final String texto = (valor ?? '').trim();
    if (texto.isEmpty) {
      return 'Informe seu nome.';
    }
    if (texto.length < 3) {
      return 'O nome deve ter pelo menos 3 caracteres.';
    }
    return null;
  }

  /// Valida o formato de endereço de e-mail.
  static String? validarEmail(String? valor) {
    final String texto = (valor ?? '').trim();
    if (texto.isEmpty) {
      return 'Informe seu e-mail.';
    }
    if (!_regexEmail.hasMatch(texto)) {
      return 'Informe um e-mail válido.';
    }
    return null;
  }

  /// Valida o tamanho mínimo da senha de acesso.
  static String? validarSenha(String? valor) {
    final String texto = valor ?? '';
    if (texto.trim().isEmpty) {
      return 'Informe sua senha.';
    }
    if (texto.length < 6) {
      return 'A senha deve ter pelo menos 6 caracteres.';
    }
    return null;
  }

  /// Verifica se a confirmação corresponde à senha digitada.
  static String? validarConfirmacaoSenha(String? valor, String senhaOriginal) {
    final String texto = valor ?? '';
    if (texto.trim().isEmpty) {
      return 'Confirme sua senha.';
    }
    if (texto != senhaOriginal) {
      return 'As senhas não coincidem.';
    }
    return null;
  }

  /// Valida campos de texto obrigatórios com tamanho mínimo configurável.
  static String? validarCampoObrigatorio(
    String? valor,
    String nomeCampo, {
    int minimo = 2,
  }) {
    final String texto = (valor ?? '').trim();
    if (texto.isEmpty) {
      return 'Informe $nomeCampo.';
    }
    if (texto.length < minimo) {
      return '$nomeCampo deve ter pelo menos $minimo caracteres.';
    }
    return null;
  }
}
