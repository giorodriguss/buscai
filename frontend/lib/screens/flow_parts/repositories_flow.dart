part of '../figma_flow.dart';

class ProvidersRepository {
  static Future<List<Provider>> getAll() async {
    final data = await ProvidersApiService.instance.findAll();
    return data.map(Provider.fromApi).toList();
  }
}

class FavoritesRepository {
  static Future<List<Provider>> getMine() async {
    final data = await FavoritesApiService.instance.findMine();
    return data
        .map((item) {
          final post = item['posts'] as Map<String, dynamic>?;
          if (post == null) return null;
          return Provider.fromApi(post);
        })
        .whereType<Provider>()
        .toList();
  }
}

class AuthRepository {
  static Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    final result = await AuthApiService.instance.login(
      email: email,
      password: password,
    );
    return AppUser.fromApi(result['user'] as Map<String, dynamic>);
  }

  static Future<void> register({
    required String fullName,
    required String email,
    required String password,
    required String cpf,
    required String phone,
  }) async {
    await AuthApiService.instance.register(
      fullName: fullName,
      email: email,
      password: password,
      cpf: cpf,
      // O backend aceita apenas "morador" ou "prestador".
      // No front a tela chama de usuário/cliente, mas para a API o papel correto é morador.
      role: 'morador',
      phone: phone,
    );
  }

  static Future<void> registerProvider({
    required String fullName,
    required String email,
    required String password,
    required String cpf,
    required String phone,
  }) async {
    await AuthApiService.instance.register(
      fullName: fullName,
      email: email,
      password: password,
      cpf: cpf,
      role: 'prestador',
      phone: phone,
    );
  }

  static Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) =>
      AuthApiService.instance.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

  static Future<void> verifyPassword({required String currentPassword}) =>
      AuthApiService.instance.verifyPassword(currentPassword: currentPassword);

  static Future<AppUser> updateMe({
    String? fullName,
    String? cpf,
    String? phone,
  }) async {
    final result = await AuthApiService.instance.updateMe(
      fullName: fullName,
      cpf: cpf,
      phone: phone,
    );
    return AppUser.fromApi(result);
  }
}
