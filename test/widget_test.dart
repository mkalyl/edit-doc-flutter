import 'package:edit_doc_flutter/main.dart';
import 'package:edit_doc_flutter/utils/validadores.dart';
import 'package:edit_doc_flutter/viewmodels/auth_viewmodel.dart';
import 'package:edit_doc_flutter/viewmodels/documentos_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Fase 1 - Validadores e ViewModels MVVM', () {
    test('Validadores validam nome, e-mail e senha corretamente', () {
      expect(Validadores.validarNome('Ab'), isNotNull);
      expect(Validadores.validarNome('Pedro Tigre'), isNull);

      expect(Validadores.validarEmail('invalido'), isNotNull);
      expect(Validadores.validarEmail('aluno@editdoc.com'), isNull);

      expect(Validadores.validarSenha('123'), isNotNull);
      expect(Validadores.validarSenha('123456'), isNull);
    });

    test('AuthViewModel autentica conta demo, alterna tema e impede duplicidade', () {
      final AuthViewModel auth = AuthViewModel();

      expect(auth.estaAutenticado, isFalse);
      expect(auth.temaEscuro, isFalse);

      auth.alternarTema();
      expect(auth.temaEscuro, isTrue);

      final bool loginOk = auth.login('aluno@editdoc.com', '123456');
      expect(loginOk, isTrue);
      expect(auth.estaAutenticado, isTrue);

      final bool duplicado = auth.cadastrar(
        nome: 'Outro Aluno',
        email: 'aluno@editdoc.com',
        senha: '123456',
      );
      expect(duplicado, isFalse);
      expect(auth.erroMensagem, isNotNull);
    });

    test('DocumentosViewModel filtra por busca e categoria', () {
      final DocumentosViewModel vm = DocumentosViewModel();
      expect(vm.documentos.length, 3);

      vm.selecionarCategoria('Estudos');
      expect(vm.documentos.length, 1);

      vm.selecionarCategoria('Todas');
      vm.atualizarBusca('Codespaces');
      expect(vm.documentos.length, 1);
    });
  });

  testWidgets('EditDocApp inicia na tela de Login', (WidgetTester tester) async {
    await tester.pumpWidget(
      EditDocApp(
        authViewModel: AuthViewModel(),
        documentosViewModel: DocumentosViewModel(),
      ),
    );

    expect(find.text('Bem-vindo de volta'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
    expect(find.text('Criar nova conta'), findsOneWidget);
  });
}
