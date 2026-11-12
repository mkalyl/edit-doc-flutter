import 'package:edit_doc_flutter/main.dart';
import 'package:edit_doc_flutter/models/documento.dart';
import 'package:edit_doc_flutter/models/services/banco_local_service.dart';
import 'package:edit_doc_flutter/models/services/documento_storage_service.dart';
import 'package:edit_doc_flutter/models/services/preferences_service.dart';
import 'package:edit_doc_flutter/models/usuario.dart';
import 'package:edit_doc_flutter/utils/validadores.dart';
import 'package:edit_doc_flutter/viewmodels/auth_viewmodel.dart';
import 'package:edit_doc_flutter/viewmodels/documentos_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  group('Validadores e Serialização de Modelos', () {
    test('Validadores validam nome, e-mail, senha e confirmação', () {
      expect(Validadores.validarNome('Ab'), isNotNull);
      expect(Validadores.validarNome('Pedro Tigre'), isNull);

      expect(Validadores.validarEmail('invalido'), isNotNull);
      expect(Validadores.validarEmail('aluno@editdoc.com'), isNull);

      expect(Validadores.validarSenha('123'), isNotNull);
      expect(Validadores.validarSenha('123456'), isNull);

      expect(
        Validadores.validarConfirmacaoSenha('654321', '123456'),
        isNotNull,
      );
      expect(
        Validadores.validarConfirmacaoSenha('123456', '123456'),
        isNull,
      );
    });

    test('Documento e Usuario serializam e desserializam via JSON', () {
      const Usuario usuario = Usuario(
        id: 'u1',
        nome: 'Pedro',
        email: 'pedro@teste.com',
        senha: '123456',
      );
      final Usuario usuarioCopia = Usuario.fromJson(usuario.toJson());
      expect(usuarioCopia.id, usuario.id);
      expect(usuarioCopia.email, usuario.email);

      final DateTime agora = DateTime(2026, 11, 12, 20, 0);
      final Documento doc = Documento(
        id: 'd1',
        titulo: 'Plano de Aula',
        conteudo: 'Conteúdo de teste para contagem de palavras.',
        categoria: 'Estudos',
        autorEmail: 'pedro@teste.com',
        criadoEm: agora,
        atualizadoEm: agora,
      );
      final Documento docCopia = Documento.fromJson(doc.toJson());
      expect(docCopia.titulo, doc.titulo);
      expect(docCopia.categoria, 'Estudos');
      expect(docCopia.contagemPalavras, 7);
    });
  });

  group('Serviços de Persistência e ViewModels (Etapa 5)', () {
    test('PreferencesService persiste tema e sessão do usuário', () async {
      final PreferencesService prefs = PreferencesService();
      expect(await prefs.carregarTemaEscuro(), isFalse);

      await prefs.salvarTemaEscuro(true);
      expect(await prefs.carregarTemaEscuro(), isTrue);

      const Usuario usuario = Usuario(
        id: 'u1',
        nome: 'Pedro',
        email: 'pedro@teste.com',
        senha: '123456',
      );
      await prefs.salvarSessaoUsuario(usuario);
      final Usuario? sessao = await prefs.carregarSessaoUsuario();
      expect(sessao?.email, 'pedro@teste.com');

      await prefs.limparSessaoUsuario();
      expect(await prefs.carregarSessaoUsuario(), isNull);
    });

    test('DocumentoStorageService executa CRUD completo com shared_preferences',
        () async {
      final DocumentoStorageService storage = DocumentoStorageService();
      final DateTime agora = DateTime(2026, 11, 12, 20, 0);
      final Documento doc = Documento(
        id: 'doc-crud-1',
        titulo: 'Rascunho Inicial',
        conteudo: 'Texto inicial do documento.',
        categoria: 'Geral',
        autorEmail: 'aluno@editdoc.com',
        criadoEm: agora,
        atualizadoEm: agora,
      );

      await storage.criarDocumento(doc);
      List<Documento> lista = await storage.listarDocumentos(
        autorEmail: 'aluno@editdoc.com',
      );
      expect(lista.length, 1);
      expect(lista.first.titulo, 'Rascunho Inicial');

      await storage.atualizarDocumento(
        doc.copyWith(titulo: 'Título Editado'),
      );
      lista = await storage.listarDocumentos(autorEmail: 'aluno@editdoc.com');
      expect(lista.first.titulo, 'Título Editado');

      await storage.excluirDocumento('doc-crud-1');
      lista = await storage.listarDocumentos(autorEmail: 'aluno@editdoc.com');
      expect(lista, isEmpty);
    });

    test('AuthViewModel e DocumentosViewModel mantêm estado após reinicialização',
        () async {
      final AuthViewModel auth = AuthViewModel();
      await auth.inicializar();

      await auth.alternarTema();
      final bool cadastrou = await auth.cadastrar(
        nome: 'Maria Silva',
        email: 'maria@editdoc.com',
        senha: '123456',
      );
      expect(cadastrou, isTrue);

      final DocumentosViewModel docsVm = DocumentosViewModel();
      await docsVm.carregarDocumentos(
        autorEmail: 'maria@editdoc.com',
        semearSeNovo: false,
      );
      final bool criou = await docsVm.criarDocumento(
        titulo: 'Nota Persistente',
        conteudo: 'Deve permanecer após recarregar.',
        categoria: 'Trabalho',
        autorEmail: 'maria@editdoc.com',
      );
      expect(criou, isTrue);

      // Simula recarregamento (F5) com novas instâncias dos ViewModels.
      final AuthViewModel authRecarregado = AuthViewModel();
      await authRecarregado.inicializar();
      expect(authRecarregado.temaEscuro, isTrue);
      expect(authRecarregado.estaAutenticado, isTrue);
      expect(authRecarregado.usuarioAtual?.email, 'maria@editdoc.com');

      final DocumentosViewModel docsRecarregado = DocumentosViewModel();
      await docsRecarregado.carregarDocumentos(
        autorEmail: authRecarregado.usuarioAtual!.email,
      );
      expect(docsRecarregado.documentos.length, 1);
      expect(docsRecarregado.documentos.first.titulo, 'Nota Persistente');
    });

    test('BancoLocalService impede cadastro duplicado', () async {
      final BancoLocalService banco = BancoLocalService();
      await banco.garantirUsuarioDemo();
      final Usuario? duplicado = await banco.cadastrarUsuario(
        nome: 'Duplicado',
        email: 'aluno@editdoc.com',
        senha: '123456',
      );
      expect(duplicado, isNull);
    });
  });

  testWidgets('EditDocApp inicia no Login quando não há sessão salva',
      (WidgetTester tester) async {
    final AuthViewModel auth = AuthViewModel();
    await auth.inicializar();
    final DocumentosViewModel docs = DocumentosViewModel();

    await tester.pumpWidget(
      EditDocApp(
        authViewModel: auth,
        documentosViewModel: docs,
      ),
    );

    expect(find.text('Bem-vindo de volta'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
  });
}
