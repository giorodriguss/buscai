import 'package:dio/dio.dart';
import 'api_client.dart';

class ProvidersApiService {
  ProvidersApiService._();
  static final ProvidersApiService instance = ProvidersApiService._();

  Dio get _dio => ApiClient.instance.dio;

  Future<List<Map<String, dynamic>>> findAll({
    String? city,
    String? neighborhood,
    String? categoryId,
    int page = 1,
    int limit = 20,
  }) async {
    final res = await _dio.get('/providers', queryParameters: {
      if (city != null) 'city': city,
      if (neighborhood != null) 'neighborhood': neighborhood,
      if (categoryId != null) 'category_id': categoryId,
      'page': page,
      'limit': limit,
    });
    final body = res.data as Map<String, dynamic>;
    return List<Map<String, dynamic>>.from(body['data'] as List? ?? []);
  }

  Future<Map<String, dynamic>> findOne(String id) async {
    final res = await _dio.get('/providers/$id');
    return res.data as Map<String, dynamic>;
  }
}
