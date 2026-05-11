import 'package:buscai/services/api_client.dart';
import 'package:buscai/services/auth_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late DioAdapter dioAdapter;
  final service = AuthApiService.instance;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    ApiClient.instance.init();
    dioAdapter = DioAdapter(dio: ApiClient.instance.dio, matcher: const UrlRequestMatcher());
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('login', () {
    const loginResponse = {
      'access_token': 'jwt-token-123',
      'user': {'id': 'user-1', 'full_name': 'João', 'role': 'morador'},
    };

    test('retorna access_token e dados do usuário', () async {
      dioAdapter.onPost(
        '/auth/login',
        (server) => server.reply(200, loginResponse),
      );

      final result = await service.login(
        email: 'joao@test.com',
        password: 'senha123',
      );

      expect(result['access_token'], equals('jwt-token-123'));
      expect(result['user']['id'], equals('user-1'));
    });

    test('persiste access_token no SharedPreferences', () async {
      dioAdapter.onPost(
        '/auth/login',
        (server) => server.reply(200, loginResponse),
      );

      await service.login(email: 'joao@test.com', password: 'senha123');

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('access_token'), equals('jwt-token-123'));
    });

    test('lança DioException quando credenciais inválidas (401)', () async {
      dioAdapter.onPost(
        '/auth/login',
        (server) => server.reply(401, {'message': 'Credenciais inválidas'}),
      );

      await expectLater(
        service.login(email: 'errado@test.com', password: 'errado'),
        throwsA(isA<DioException>()),
      );
    });

    test('lança DioException quando e-mail não cadastrado (400)', () async {
      dioAdapter.onPost(
        '/auth/login',
        (server) => server.reply(400, {'message': 'Usuário não encontrado'}),
      );

      await expectLater(
        service.login(email: 'naoexiste@test.com', password: 'qualquer'),
        throwsA(isA<DioException>()),
      );
    });
  });

  group('register', () {
    const registerResponse = {
      'message': 'Verifique seu e-mail para confirmar o cadastro',
      'user': {'id': 'user-2', 'email': 'novo@test.com', 'full_name': 'Novo Usuário'},
    };

    test('retorna mensagem de verificação após cadastro com sucesso', () async {
      dioAdapter.onPost(
        '/auth/register',
        (server) => server.reply(201, registerResponse),
      );

      final result = await service.register(
        fullName: 'Novo Usuário',
        email: 'novo@test.com',
        password: 'senha123',
        role: 'morador',
      );

      expect(result['message'], contains('Verifique'));
      expect(result['user']['email'], equals('novo@test.com'));
    });

    test('envia phone quando fornecido', () async {
      dioAdapter.onPost(
        '/auth/register',
        (server) => server.reply(201, registerResponse),
      );

      final result = await service.register(
        fullName: 'Usuário',
        email: 'novo@test.com',
        password: 'senha123',
        role: 'prestador',
        phone: '11999999999',
      );

      expect(result, isA<Map<String, dynamic>>());
    });

    test('lança DioException quando e-mail já está cadastrado (400)', () async {
      dioAdapter.onPost(
        '/auth/register',
        (server) => server.reply(400, {'message': 'Email já cadastrado'}),
      );

      await expectLater(
        service.register(
          fullName: 'Usuário',
          email: 'existente@test.com',
          password: 'senha123',
          role: 'morador',
        ),
        throwsA(isA<DioException>()),
      );
    });
  });

  group('me', () {
    test('retorna perfil do usuário autenticado', () async {
      dioAdapter.onGet(
        '/auth/me',
        (server) => server.reply(200, {
          'id': 'user-1',
          'full_name': 'João',
          'role': 'morador',
          'email': 'joao@test.com',
        }),
      );

      final result = await service.me();

      expect(result['id'], equals('user-1'));
      expect(result['full_name'], equals('João'));
    });

    test('lança DioException quando token é inválido ou expirado (401)', () async {
      dioAdapter.onGet(
        '/auth/me',
        (server) => server.reply(401, {'message': 'Unauthorized'}),
      );

      await expectLater(service.me(), throwsA(isA<DioException>()));
    });
  });

  group('logout', () {
    test('remove access_token do SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({'access_token': 'token-ativo'});

      await service.logout();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('access_token'), isNull);
    });

    test('não lança erro quando não há token salvo', () async {
      SharedPreferences.setMockInitialValues({});

      await expectLater(service.logout(), completes);
    });
  });

  group('savedToken', () {
    test('retorna token quando existe no SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({'access_token': 'token-salvo'});

      final token = await service.savedToken();

      expect(token, equals('token-salvo'));
    });

    test('retorna null quando não há token salvo', () async {
      SharedPreferences.setMockInitialValues({});

      final token = await service.savedToken();

      expect(token, isNull);
    });

    test('retorna o token correto quando há múltiplas chaves', () async {
      SharedPreferences.setMockInitialValues({
        'access_token': 'meu-jwt',
        'outro_dado': 'valor',
      });

      final token = await service.savedToken();

      expect(token, equals('meu-jwt'));
    });
  });
}
