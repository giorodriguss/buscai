import 'package:buscai/services/api_client.dart';
import 'package:buscai/services/providers_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late DioAdapter dioAdapter;
  final service = ProvidersApiService.instance;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    ApiClient.instance.init();
    dioAdapter = DioAdapter(dio: ApiClient.instance.dio);
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('findAll', () {
    final mockProviders = [
      {'id': 'p1', 'description': 'Encanador experiente', 'neighborhood': 'Centro'},
      {'id': 'p2', 'description': 'Pintor de paredes', 'neighborhood': 'Pinheiros'},
    ];

    test('retorna lista de prestadores', () async {
      dioAdapter.onGet(
        '/providers',
        (server) => server.reply(200, {'data': mockProviders, 'meta': {'total': 2}}),
        queryParameters: {'page': 1, 'limit': 20},
      );

      final result = await service.findAll();

      expect(result, hasLength(2));
      expect(result[0]['id'], equals('p1'));
      expect(result[1]['description'], equals('Pintor de paredes'));
    });

    test('retorna lista vazia quando não há prestadores', () async {
      dioAdapter.onGet(
        '/providers',
        (server) => server.reply(200, {'data': [], 'meta': {'total': 0}}),
        queryParameters: {'page': 1, 'limit': 20},
      );

      final result = await service.findAll();

      expect(result, isEmpty);
    });

    test('retorna lista vazia quando data é null na resposta', () async {
      dioAdapter.onGet(
        '/providers',
        (server) => server.reply(200, {'data': null, 'meta': {'total': 0}}),
        queryParameters: {'page': 1, 'limit': 20},
      );

      final result = await service.findAll();

      expect(result, isEmpty);
    });

    test('envia filtro de cidade quando fornecido', () async {
      dioAdapter.onGet(
        '/providers',
        (server) => server.reply(200, {'data': mockProviders, 'meta': {'total': 2}}),
        queryParameters: {'city': 'São Paulo', 'page': 1, 'limit': 20},
      );

      final result = await service.findAll(city: 'São Paulo');

      expect(result, hasLength(2));
    });

    test('envia filtro de bairro quando fornecido', () async {
      dioAdapter.onGet(
        '/providers',
        (server) => server.reply(200, {'data': [mockProviders[0]], 'meta': {'total': 1}}),
        queryParameters: {'neighborhood': 'Centro', 'page': 1, 'limit': 20},
      );

      final result = await service.findAll(neighborhood: 'Centro');

      expect(result, hasLength(1));
      expect(result[0]['neighborhood'], equals('Centro'));
    });

    test('envia filtro de categoria quando fornecido', () async {
      dioAdapter.onGet(
        '/providers',
        (server) => server.reply(200, {'data': mockProviders, 'meta': {'total': 2}}),
        queryParameters: {'category_id': 'cat-1', 'page': 1, 'limit': 20},
      );

      final result = await service.findAll(categoryId: 'cat-1');

      expect(result, hasLength(2));
    });

    test('usa paginação customizada', () async {
      dioAdapter.onGet(
        '/providers',
        (server) => server.reply(200, {'data': mockProviders, 'meta': {'total': 2}}),
        queryParameters: {'page': 2, 'limit': 10},
      );

      final result = await service.findAll(page: 2, limit: 10);

      expect(result, hasLength(2));
    });

    test('lança DioException em caso de erro 500 na API', () async {
      dioAdapter.onGet(
        '/providers',
        (server) => server.reply(500, {'message': 'Internal Server Error'}),
        queryParameters: {'page': 1, 'limit': 20},
      );

      await expectLater(service.findAll(), throwsA(isA<DioException>()));
    });
  });

  group('findOne', () {
    final mockProvider = {
      'id': 'prov-1',
      'description': 'Encanador experiente',
      'whatsapp': '11999999999',
      'neighborhood': 'Centro',
      'rating_avg': 4.5,
      'rating_count': 10,
      'is_active': true,
    };

    test('retorna dados completos do prestador pelo id', () async {
      dioAdapter.onGet(
        '/providers/prov-1',
        (server) => server.reply(200, mockProvider),
      );

      final result = await service.findOne('prov-1');

      expect(result['id'], equals('prov-1'));
      expect(result['description'], equals('Encanador experiente'));
      expect(result['rating_avg'], equals(4.5));
    });

    test('lança DioException quando prestador não encontrado (404)', () async {
      dioAdapter.onGet(
        '/providers/inexistente',
        (server) => server.reply(404, {'message': 'Prestador não encontrado'}),
      );

      await expectLater(
        service.findOne('inexistente'),
        throwsA(isA<DioException>()),
      );
    });

    test('lança DioException em caso de erro interno (500)', () async {
      dioAdapter.onGet(
        '/providers/prov-1',
        (server) => server.reply(500, {'message': 'Erro interno'}),
      );

      await expectLater(
        service.findOne('prov-1'),
        throwsA(isA<DioException>()),
      );
    });
  });
}
