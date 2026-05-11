import 'package:dio/dio.dart';
import 'api_client.dart';

class FavoritesApiService {
  FavoritesApiService._();
  static final FavoritesApiService instance = FavoritesApiService._();

  Dio get _dio => ApiClient.instance.dio;

  Future<List<Map<String, dynamic>>> findMine() async {
    final res = await _dio.get('/favorites');
    return List<Map<String, dynamic>>.from(res.data as List? ?? []);
  }

  Future<void> add(String postId) async {
    await _dio.post('/favorites/$postId');
  }

  Future<void> remove(String postId) async {
    await _dio.delete('/favorites/$postId');
  }
}
