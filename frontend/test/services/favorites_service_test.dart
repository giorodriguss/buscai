import 'package:buscai/services/api_client.dart';
import 'package:buscai/services/favorites_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late DioAdapter dioAdapter;
  final service = FavoritesApiService.instance;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    ApiClient.instance.init();
    dioAdapter = DioAdapter(dio: ApiClient.instance.dio);
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('findMine', () {
    final mockFavorites = [
      {
        'id': 'fav-1',
        'created_at': '2024-01-01T00:00:00Z',
        'posts': {
          'id': 'post-1',
          'title': 'Encanador',
          'whatsapp_link': 'https://wa.me/5511999999999',
          'neighborhood': 'Centro',
        },
      },
      {
        'id': 'fav-2',
        'created_at': '2024-01-02T00:00:00Z',
        'posts': {
          'id': 'post-2',
          'title': 'Pintor',
          'whatsapp_link': null,
          'neighborhood': 'Pinheiros',
        },
      },
    ];

    test('retorna lista de favoritos do usuário', () async {
      dioAdapter.onGet(
        '/favorites',
        (server) => server.reply(200, mockFavorites),
      );

      final result = await service.findMine();

      expect(result, hasLength(2));
      expect(result[0]['id'], equals('fav-1'));
      expect(result[1]['posts']['title'], equals('Pintor'));
    });

    test('retorna lista vazia quando usuário não tem favoritos', () async {
      dioAdapter.onGet(
        '/favorites',
        (server) => server.reply(200, []),
      );

      final result = await service.findMine();

      expect(result, isEmpty);
    });

    test('retorna lista vazia quando resposta é null', () async {
      dioAdapter.onGet(
        '/favorites',
        (server) => server.reply(200, null),
      );

      final result = await service.findMine();

      expect(result, isEmpty);
    });

    test('preserva whatsapp_link do post associado ao favorito', () async {
      dioAdapter.onGet(
        '/favorites',
        (server) => server.reply(200, mockFavorites),
      );

      final result = await service.findMine();

      expect(result[0]['posts']['whatsapp_link'], equals('https://wa.me/5511999999999'));
      expect(result[1]['posts']['whatsapp_link'], isNull);
    });

    test('lança DioException quando não autenticado (401)', () async {
      dioAdapter.onGet(
        '/favorites',
        (server) => server.reply(401, {'message': 'Unauthorized'}),
      );

      await expectLater(service.findMine(), throwsA(isA<DioException>()));
    });

    test('lança DioException em caso de erro interno (500)', () async {
      dioAdapter.onGet(
        '/favorites',
        (server) => server.reply(500, {'message': 'Internal Server Error'}),
      );

      await expectLater(service.findMine(), throwsA(isA<DioException>()));
    });
  });

  group('add', () {
    test('adiciona post aos favoritos com sucesso', () async {
      dioAdapter.onPost(
        '/favorites/post-1',
        (server) => server.reply(201, {'id': 'fav-1', 'post_id': 'post-1'}),
      );

      await expectLater(service.add('post-1'), completes);
    });

    test('lança DioException quando post não existe (404)', () async {
      dioAdapter.onPost(
        '/favorites/inexistente',
        (server) => server.reply(404, {'message': 'Post não encontrado'}),
      );

      await expectLater(
        service.add('inexistente'),
        throwsA(isA<DioException>()),
      );
    });

    test('lança DioException quando favorito já existe (400)', () async {
      dioAdapter.onPost(
        '/favorites/post-2',
        (server) => server.reply(400, {'message': 'Favorito já adicionado'}),
      );

      await expectLater(
        service.add('post-2'),
        throwsA(isA<DioException>()),
      );
    });

    test('lança DioException quando não autenticado (401)', () async {
      dioAdapter.onPost(
        '/favorites/post-3',
        (server) => server.reply(401, {'message': 'Unauthorized'}),
      );

      await expectLater(
        service.add('post-3'),
        throwsA(isA<DioException>()),
      );
    });
  });

  group('remove', () {
    test('remove favorito com sucesso', () async {
      dioAdapter.onDelete(
        '/favorites/post-1',
        (server) => server.reply(200, {'message': 'Favorito removido'}),
      );

      await expectLater(service.remove('post-1'), completes);
    });

    test('lança DioException quando não autenticado (401)', () async {
      dioAdapter.onDelete(
        '/favorites/post-2',
        (server) => server.reply(401, {'message': 'Unauthorized'}),
      );

      await expectLater(
        service.remove('post-2'),
        throwsA(isA<DioException>()),
      );
    });

    test('lança DioException em caso de erro interno (500)', () async {
      dioAdapter.onDelete(
        '/favorites/post-3',
        (server) => server.reply(500, {'message': 'Internal Server Error'}),
      );

      await expectLater(
        service.remove('post-3'),
        throwsA(isA<DioException>()),
      );
    });
  });
}
