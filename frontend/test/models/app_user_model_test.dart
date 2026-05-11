import 'package:buscai/screens/figma_flow.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppUser.fromApi', () {
    Map<String, dynamic> _base({
      String id = 'user-1',
      String fullName = 'João Silva',
      String email = 'joao@test.com',
      String role = 'morador',
      String? phone,
    }) =>
        {
          'id': id,
          'full_name': fullName,
          'email': email,
          'role': role,
          if (phone != null) 'phone': phone,
        };

    test('mapeia id corretamente', () {
      final user = AppUser.fromApi(_base(id: 'uid-abc'));
      expect(user.id, equals('uid-abc'));
    });

    test('mapeia full_name para o campo name', () {
      final user = AppUser.fromApi(_base(fullName: 'Maria Souza'));
      expect(user.name, equals('Maria Souza'));
    });

    test('mapeia email corretamente', () {
      final user = AppUser.fromApi(_base(email: 'maria@test.com'));
      expect(user.email, equals('maria@test.com'));
    });

    test('mapeia phone quando presente', () {
      final user = AppUser.fromApi(_base(phone: '11999999999'));
      expect(user.phone, equals('11999999999'));
    });

    test('define isProvider=true quando role é prestador', () {
      final user = AppUser.fromApi(_base(role: 'prestador'));
      expect(user.isProvider, isTrue);
    });

    test('define isProvider=false quando role é morador', () {
      final user = AppUser.fromApi(_base(role: 'morador'));
      expect(user.isProvider, isFalse);
    });

    test('define isProvider=false quando role é outro valor', () {
      final user = AppUser.fromApi(_base(role: 'admin'));
      expect(user.isProvider, isFalse);
    });

    test('define isProvider=false quando role está ausente', () {
      final json = {'id': 'u1', 'full_name': 'Ana', 'email': 'a@t.com'};
      final user = AppUser.fromApi(json);
      expect(user.isProvider, isFalse);
    });

    test('usa string vazia para id quando campo ausente', () {
      final json = {'full_name': 'Ana', 'email': 'a@t.com', 'role': 'morador'};
      expect(AppUser.fromApi(json).id, equals(''));
    });

    test('usa string vazia para name quando full_name ausente', () {
      final json = {'id': 'u1', 'email': 'a@t.com', 'role': 'morador'};
      expect(AppUser.fromApi(json).name, equals(''));
    });

    test('usa string vazia para email quando campo ausente', () {
      final json = {'id': 'u1', 'full_name': 'Ana', 'role': 'morador'};
      expect(AppUser.fromApi(json).email, equals(''));
    });

    test('usa string vazia para phone quando campo ausente', () {
      final user = AppUser.fromApi(_base());
      expect(user.phone, equals(''));
    });

    test('trata null no id como string vazia', () {
      final json = {'id': null, 'full_name': 'Ana', 'email': 'a@t.com', 'role': 'morador'};
      expect(AppUser.fromApi(json).id, equals(''));
    });

    test('trata null no full_name como string vazia', () {
      final json = {'id': 'u1', 'full_name': null, 'email': 'a@t.com', 'role': 'morador'};
      expect(AppUser.fromApi(json).name, equals(''));
    });

    test('trata null no phone como string vazia', () {
      final json = {'id': 'u1', 'full_name': 'Ana', 'email': 'a@t.com', 'role': 'morador', 'phone': null};
      expect(AppUser.fromApi(json).phone, equals(''));
    });

    test('mapeia corretamente um prestador completo', () {
      final json = {
        'id': 'prest-1',
        'full_name': 'Carlos Encanador',
        'email': 'carlos@test.com',
        'phone': '21988887777',
        'role': 'prestador',
      };
      final user = AppUser.fromApi(json);
      expect(user.id, equals('prest-1'));
      expect(user.name, equals('Carlos Encanador'));
      expect(user.email, equals('carlos@test.com'));
      expect(user.phone, equals('21988887777'));
      expect(user.isProvider, isTrue);
    });
  });
}
