import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_client.dart';

class AuthApiService {
  AuthApiService._();
  static final AuthApiService instance = AuthApiService._();

  Dio get _dio => ApiClient.instance.dio;

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final res = await _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    final body = res.data as Map<String, dynamic>;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', body['access_token'] as String);
    return body;
  }

  Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String password,
    required String role,
    String? phone,
  }) async {
    final res = await _dio.post('/auth/register', data: {
      'full_name': fullName,
      'email': email,
      'password': password,
      'role': role,
      if (phone != null && phone.isNotEmpty) 'phone': phone,
    });
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> me() async {
    final res = await _dio.get('/auth/me');
    return res.data as Map<String, dynamic>;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
  }

  Future<String?> savedToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }
}
