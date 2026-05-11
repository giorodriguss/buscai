import 'package:buscai/screens/figma_flow.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Map<String, dynamic> _base({
    String id = 'prov-1',
    Map? users,
    Map? categories,
    List? postPhotos,
    List? reviews,
    double ratingAvg = 4.7,
    int reviewCount = 25,
    double? distanceKm = 2.3,
    String bio = 'Eletricista com 8 anos de experiência.',
    int priceFrom = 150,
    int priceTo = 300,
    int yearsExperience = 8,
  }) =>
      {
        'id': id,
        'users': users ??
            {
              'full_name': 'Carlos Eletricista',
              'avatar_url': 'https://img.com/avatar.jpg',
              'phone': '11999999999',
            },
        'categories': categories ?? {'name': 'Eletricista'},
        'post_photos': postPhotos ??
            [
              {'storage_url': 'https://img.com/p1.jpg'},
              {'storage_url': 'https://img.com/p2.jpg'},
            ],
        'reviews': reviews ?? [],
        'rating_avg': ratingAvg,
        'review_count': reviewCount,
        'distance_km': distanceKm,
        'bio': bio,
        'price_from': priceFrom,
        'price_to': priceTo,
        'years_experience': yearsExperience,
      };

  group('Provider.fromApi', () {
    group('campos básicos', () {
      test('mapeia id corretamente', () {
        expect(Provider.fromApi(_base(id: 'prov-abc')).id, equals('prov-abc'));
      });

      test('mapeia nome a partir de users.full_name', () {
        expect(Provider.fromApi(_base()).name, equals('Carlos Eletricista'));
      });

      test('mapeia categoria a partir de categories.name', () {
        expect(Provider.fromApi(_base()).category, equals('Eletricista'));
      });

      test('mapeia rating_avg como double', () {
        expect(Provider.fromApi(_base(ratingAvg: 4.7)).rating, equals(4.7));
      });

      test('mapeia review_count corretamente', () {
        expect(Provider.fromApi(_base(reviewCount: 25)).reviewCount, equals(25));
      });

      test('mapeia bio para o campo about', () {
        expect(Provider.fromApi(_base()).about, contains('Eletricista'));
      });

      test('mapeia years_experience corretamente', () {
        expect(Provider.fromApi(_base(yearsExperience: 8)).yearsExperience, equals(8));
      });

      test('mapeia avatar_url do usuário como imagem', () {
        expect(Provider.fromApi(_base()).image, equals('https://img.com/avatar.jpg'));
      });
    });

    group('distância', () {
      test('formata distance_km com 1 decimal e sufixo km', () {
        expect(Provider.fromApi(_base(distanceKm: 2.3)).distance, equals('2.3 km'));
      });

      test('formata distância com uma casa decimal', () {
        expect(Provider.fromApi(_base(distanceKm: 10.0)).distance, equals('10.0 km'));
      });

      test('fica vazia quando distance_km é null', () {
        expect(Provider.fromApi(_base(distanceKm: null)).distance, equals(''));
      });
    });

    group('portfólio (post_photos)', () {
      test('mapeia URLs de storage_url das fotos', () {
        final prov = Provider.fromApi(_base());
        expect(prov.portfolio, equals(['https://img.com/p1.jpg', 'https://img.com/p2.jpg']));
      });

      test('usa a primeira foto do portfólio como coverImage', () {
        expect(Provider.fromApi(_base()).coverImage, equals('https://img.com/p1.jpg'));
      });

      test('coverImage fica vazia quando não há fotos', () {
        expect(Provider.fromApi(_base(postPhotos: [])).coverImage, equals(''));
      });

      test('portfólio fica vazio quando post_photos é null', () {
        final json = _base()..['post_photos'] = null;
        expect(Provider.fromApi(json).portfolio, isEmpty);
      });

      test('filtra URLs vazias do portfólio', () {
        final prov = Provider.fromApi(_base(postPhotos: [
          {'storage_url': 'https://img.com/p1.jpg'},
          {'storage_url': ''},
          {'storage_url': null},
        ]));
        expect(prov.portfolio, equals(['https://img.com/p1.jpg']));
      });

      test('portfólio vazio quando todas as URLs são vazias', () {
        final prov = Provider.fromApi(_base(postPhotos: [
          {'storage_url': ''},
          {'storage_url': null},
        ]));
        expect(prov.portfolio, isEmpty);
      });
    });

    group('preço', () {
      test('formata priceRange com price_from e price_to', () {
        expect(Provider.fromApi(_base(priceFrom: 150, priceTo: 300)).priceRange, equals('R\$ 150–300'));
      });

      test('formata priceRange apenas com price_from quando price_to é 0', () {
        expect(Provider.fromApi(_base(priceFrom: 150, priceTo: 0)).priceRange, equals('R\$ 150+'));
      });

      test('priceRange fica vazio quando price_from é 0', () {
        expect(Provider.fromApi(_base(priceFrom: 0, priceTo: 0)).priceRange, equals(''));
      });

      test('mapeia pricePerHour a partir de price_from', () {
        expect(Provider.fromApi(_base(priceFrom: 150)).pricePerHour, equals(150));
      });
    });

    group('avaliações', () {
      test('retorna lista vazia quando reviews é vazio', () {
        expect(Provider.fromApi(_base(reviews: [])).reviews, isEmpty);
      });

      test('mapeia uma avaliação com nome e rating', () {
        final prov = Provider.fromApi(_base(reviews: [
          {
            'rating': 5,
            'comment': 'Excelente!',
            'created_at': '2024-01-01T00:00:00Z',
            'users': {'full_name': 'João'},
          },
        ]));
        expect(prov.reviews.length, equals(1));
        expect(prov.reviews.first.name, equals('João'));
        expect(prov.reviews.first.rating, equals(5));
        expect(prov.reviews.first.comment, equals('Excelente!'));
      });

      test('mapeia múltiplas avaliações preservando a ordem', () {
        final prov = Provider.fromApi(_base(reviews: [
          {'rating': 5, 'comment': 'A', 'created_at': null, 'users': {'full_name': 'Ana'}},
          {'rating': 3, 'comment': 'B', 'created_at': null, 'users': {'full_name': 'Bob'}},
        ]));
        expect(prov.reviews.length, equals(2));
        expect(prov.reviews[0].name, equals('Ana'));
        expect(prov.reviews[1].name, equals('Bob'));
      });

      test('usa Usuário como nome padrão quando users está ausente na avaliação', () {
        final prov = Provider.fromApi(_base(reviews: [
          {'rating': 4, 'comment': 'Ok', 'created_at': null},
        ]));
        expect(prov.reviews.first.name, equals('Usuário'));
      });

      test('usa 5 como rating padrão quando campo ausente', () {
        final prov = Provider.fromApi(_base(reviews: [
          {'comment': 'Sem nota', 'created_at': null, 'users': {'full_name': 'Ana'}},
        ]));
        expect(prov.reviews.first.rating, equals(5));
      });
    });

    group('campos nulos/ausentes', () {
      test('usa defaults quando users é null', () {
        final json = _base()..['users'] = null;
        final prov = Provider.fromApi(json);
        expect(prov.name, equals(''));
        expect(prov.image, equals(''));
      });

      test('usa defaults quando categories é null', () {
        final json = _base()..['categories'] = null;
        expect(Provider.fromApi(json).category, equals(''));
      });

      test('usa 0 para rating quando rating_avg é null', () {
        final json = _base()..['rating_avg'] = null;
        expect(Provider.fromApi(json).rating, equals(0.0));
      });

      test('usa 0 para reviewCount quando review_count é null', () {
        final json = _base()..['review_count'] = null;
        expect(Provider.fromApi(json).reviewCount, equals(0));
      });

      test('usa 0 para yearsExperience quando years_experience é null', () {
        final json = _base()..['years_experience'] = null;
        expect(Provider.fromApi(json).yearsExperience, equals(0));
      });

      test('usa string vazia para about quando bio é null', () {
        final json = _base()..['bio'] = null;
        expect(Provider.fromApi(json).about, equals(''));
      });

      test('availableHours sempre retorna lista vazia (não vem da API ainda)', () {
        expect(Provider.fromApi(_base()).availableHours, isEmpty);
      });

      test('services sempre retorna lista vazia (não vem da API ainda)', () {
        expect(Provider.fromApi(_base()).services, isEmpty);
      });
    });
  });
}
