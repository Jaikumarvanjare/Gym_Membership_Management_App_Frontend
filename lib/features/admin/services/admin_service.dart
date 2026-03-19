import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';

class AdminService {
  final Dio _dio = ApiClient.instance.dio;

  Future<Map<String, dynamic>> approveAdmin(int id) async {
    try {
      final res = await _dio.patch('/admin/approve/$id');
      return res.data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw e.error ?? ApiException('Failed to approve admin');
    }
  }

  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final res = await _dio.get('/dashboard/stats');
      return res.data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw e.error ?? ApiException('Failed to load dashboard stats');
    }
  }
}