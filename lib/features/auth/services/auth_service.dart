import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';

class AuthService {
  final Dio _dio = ApiClient.instance.dio;

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final res = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw e.error ?? ApiException('Login failed');
    }
  }

  Future<Map<String, dynamic>> register(
    String email,
    String password, {
    String role = 'customer',
  }) async {
    try {
      final res = await _dio.post('/auth/signup', data: {
        'email': email,
        'password': password,
        'role': role,
      });
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw e.error ?? ApiException('Registration failed');
    }
  }
}