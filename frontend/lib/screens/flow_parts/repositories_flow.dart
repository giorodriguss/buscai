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
    required String phone,
  }) async {
    await AuthApiService.instance.register(
      fullName: fullName,
      email: email,
      password: password,
      role: 'cliente',
      phone: phone,
    );
  }
}
