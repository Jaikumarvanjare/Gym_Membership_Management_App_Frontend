import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../storage/token_storage.dart';

// ApiException wraps Dio errors into a clean, UI-friendly message.
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient._internal();

  // Single instance shared across the entire app.
  // Services should use ApiClient.instance.dio — not create new ApiClient().
  static final ApiClient instance = ApiClient._internal();

  late final Dio dio = _buildDio();

  Dio _buildDio() {
    final d = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        headers: {'Content-Type': 'application/json'},
      ),
    );

    d.interceptors.add(
      InterceptorsWrapper(
        // Attach the JWT before every request
        onRequest: (options, handler) async {
          final token = await TokenStorage.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },

        // Convert DioException into a readable ApiException
        onError: (DioException e, handler) {
          final response = e.response;

          if (response != null) {
            final message = response.data is Map
                ? response.data['message'] as String? ?? 'Something went wrong'
                : 'Something went wrong';
            return handler.reject(
              DioException(
                requestOptions: e.requestOptions,
                error: ApiException(message, statusCode: response.statusCode),
                response: response,
                type: e.type,
              ),
            );
          }

          // Network / timeout errors
          return handler.reject(
            DioException(
              requestOptions: e.requestOptions,
              error: const ApiException('No internet connection or server unreachable'),
              type: e.type,
            ),
          );
        },
      ),
    );

    return d;
  }
}