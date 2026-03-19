class ApiConstants {
  static const String baseUrl = ;
}
class ApiConstants {
  ApiConstants._(); // prevent instantiation

  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://localhost:3000/gmma/api/v1', 
  );

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 15);
}