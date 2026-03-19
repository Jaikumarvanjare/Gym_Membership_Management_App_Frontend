import 'package:flutter/material.dart';
import '../../../core/storage/token_storage.dart';
import '../../../models/user_model.dart';
import '../services/auth_service.dart';
import '../../../core/api/api_client.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _service = AuthService();

  bool _isLoading = false;
  User? _user;
  String? _error;

  bool get isLoading => _isLoading;
  User? get user => _user;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _error = null;

    try {
      final data = await _service.login(email, password);

      final token = data['data']['token'] as String;
      await TokenStorage.saveToken(token);

      if (data['data']['user'] != null) {
        _user = User.fromJson(data['data']['user'] as Map<String, dynamic>);
      }

      return true;
    } on ApiException catch (e) {
      _error = e.message;
      return false;
    } catch (_) {
      _error = 'An unexpected error occurred';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register(String email, String password) async {
    _setLoading(true);
    _error = null;

    try {
      await _service.register(email, password);
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      return false;
    } catch (_) {
      _error = 'An unexpected error occurred';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await TokenStorage.deleteToken();
    _user = null;
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}