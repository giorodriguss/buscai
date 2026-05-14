import 'package:buscai/screens/figma_flow.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Provider;
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  // Helpers
  AppUser _user({String id = 'u1', String name = 'João', String email = 'joao@test.com'}) =>
      AppUser(id: id, name: name, email: email);

  const _mockService = Service(id: 's1', name: 'Reparo', price: 100);
  const _mockProvider = Provider(
    id: 'p1',
    name: 'Ana Lima',
    category: 'Manicure',
    rating: 4.5,
    reviewCount: 10,
    distance: '1 km',
    image: '',
    coverImage: '',
    about: '',
    phone: '',
    portfolio: [],
    reviews: [],
    availableHours: [],
    pricePerHour: 100,
    priceRange: 'R\$ 100',
    yearsExperience: 2,
    services: [],
  );

  group('estado inicial', () {
    test('começa com 2 endereços padrão (Casa e Trabalho)', () {
      expect(container.read(sessionProvider).savedAddresses.length, equals(2));
    });

    test('começa sem usuário logado', () {
      expect(container.read(sessionProvider).currentUser, isNull);
    });

    test('começa sem favoritos', () {
      expect(container.read(sessionProvider).favoriteProviderIds, isEmpty);
    });

    test('começa com histórico vazio', () {
      expect(container.read(sessionProvider).history, isEmpty);
    });

    test('começa com endereço selecionado = 0', () {
      expect(container.read(sessionProvider).selectedAddress, equals(0));
    });
  });

  group('setUser', () {
    test('define o usuário logado', () {
      final user = _user();
      container.read(sessionProvider.notifier).setUser(user);
      expect(container.read(sessionProvider).currentUser, equals(user));
    });

    test('substitui o usuário anterior ao chamar novamente', () {
      container.read(sessionProvider.notifier).setUser(_user(name: 'João'));
      container.read(sessionProvider.notifier).setUser(_user(id: 'u2', name: 'Maria', email: 'maria@test.com'));
      expect(container.read(sessionProvider).currentUser?.name, equals('Maria'));
    });

    test('preserva os demais campos do estado', () {
      container.read(sessionProvider.notifier).toggleFavorite('prov-99');
      container.read(sessionProvider.notifier).setUser(_user());
      expect(container.read(sessionProvider).favoriteProviderIds, contains('prov-99'));
    });
  });

  group('toggleFavorite', () {
    test('adiciona id quando não está nos favoritos', () {
      container.read(sessionProvider.notifier).toggleFavorite('prov-1');
      expect(container.read(sessionProvider).favoriteProviderIds, contains('prov-1'));
    });

    test('remove id quando já está nos favoritos', () {
      container.read(sessionProvider.notifier).toggleFavorite('prov-1');
      container.read(sessionProvider.notifier).toggleFavorite('prov-1');
      expect(container.read(sessionProvider).favoriteProviderIds, isNot(contains('prov-1')));
    });

    test('mantém outros ids ao adicionar novo', () {
      container.read(sessionProvider.notifier).toggleFavorite('prov-1');
      container.read(sessionProvider.notifier).toggleFavorite('prov-2');
      final favs = container.read(sessionProvider).favoriteProviderIds;
      expect(favs, containsAll(['prov-1', 'prov-2']));
    });

    test('mantém outros ids ao remover um', () {
      container.read(sessionProvider.notifier).toggleFavorite('prov-1');
      container.read(sessionProvider.notifier).toggleFavorite('prov-2');
      container.read(sessionProvider.notifier).toggleFavorite('prov-1');
      final favs = container.read(sessionProvider).favoriteProviderIds;
      expect(favs, contains('prov-2'));
      expect(favs, isNot(contains('prov-1')));
    });

    test('não duplica ids ao acionar múltiplas vezes', () {
      container.read(sessionProvider.notifier).toggleFavorite('prov-1');
      container.read(sessionProvider.notifier).toggleFavorite('prov-2');
      container.read(sessionProvider.notifier).toggleFavorite('prov-1');
      container.read(sessionProvider.notifier).toggleFavorite('prov-1');
      expect(container.read(sessionProvider).favoriteProviderIds.length, equals(2));
    });
  });

  group('addHistoryItem', () {
    test('adiciona item ao histórico', () {
      final item = ServiceHistoryItem(provider: _mockProvider, service: _mockService, date: 'Hoje');
      container.read(sessionProvider.notifier).addHistoryItem(item);
      expect(container.read(sessionProvider).history.length, equals(1));
    });

    test('insere o mais recente no início da lista', () {
      final item1 = ServiceHistoryItem(provider: _mockProvider, service: _mockService, date: 'Ontem');
      final item2 = ServiceHistoryItem(provider: _mockProvider, service: _mockService, date: 'Hoje');
      container.read(sessionProvider.notifier).addHistoryItem(item1);
      container.read(sessionProvider.notifier).addHistoryItem(item2);
      expect(container.read(sessionProvider).history.first.date, equals('Hoje'));
    });

    test('acumula todos os itens adicionados', () {
      for (var i = 1; i <= 3; i++) {
        container.read(sessionProvider.notifier).addHistoryItem(
          ServiceHistoryItem(provider: _mockProvider, service: _mockService, date: '$i'),
        );
      }
      expect(container.read(sessionProvider).history.length, equals(3));
    });
  });

  group('selectAddress', () {
    test('altera o índice do endereço selecionado para 1', () {
      container.read(sessionProvider.notifier).selectAddress(1);
      expect(container.read(sessionProvider).selectedAddress, equals(1));
    });

    test('pode voltar ao índice 0', () {
      container.read(sessionProvider.notifier).selectAddress(1);
      container.read(sessionProvider.notifier).selectAddress(0);
      expect(container.read(sessionProvider).selectedAddress, equals(0));
    });
  });

  group('reset', () {
    test('limpa o usuário logado', () {
      container.read(sessionProvider.notifier).setUser(_user());
      container.read(sessionProvider.notifier).reset();
      expect(container.read(sessionProvider).currentUser, isNull);
    });

    test('limpa os favoritos', () {
      container.read(sessionProvider.notifier).toggleFavorite('prov-1');
      container.read(sessionProvider.notifier).reset();
      expect(container.read(sessionProvider).favoriteProviderIds, isEmpty);
    });

    test('limpa o histórico', () {
      container.read(sessionProvider.notifier).addHistoryItem(
        ServiceHistoryItem(provider: _mockProvider, service: _mockService, date: 'Hoje'),
      );
      container.read(sessionProvider.notifier).reset();
      expect(container.read(sessionProvider).history, isEmpty);
    });

    test('restaura 2 endereços padrão', () {
      container.read(sessionProvider.notifier).reset();
      expect(container.read(sessionProvider).savedAddresses.length, equals(2));
    });

    test('restaura selectedAddress para 0', () {
      container.read(sessionProvider.notifier).selectAddress(1);
      container.read(sessionProvider.notifier).reset();
      expect(container.read(sessionProvider).selectedAddress, equals(0));
    });
  });
}
