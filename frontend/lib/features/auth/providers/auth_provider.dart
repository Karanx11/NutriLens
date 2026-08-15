import 'package:flutter/foundation.dart';

import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _isAuthenticated = false;

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    final result = await _authService.login(email: email, password: password);

    _isAuthenticated = result;
    _isLoading = false;

    notifyListeners();

    return result;
  }

  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    final result = await _authService.register(
      name: name,
      email: email,
      password: password,
    );

    _isAuthenticated = result;
    _isLoading = false;

    notifyListeners();

    return result;
  }

  Future<void> logout() async {
    await _authService.logout();

    _isAuthenticated = false;

    notifyListeners();
  }

  Future<void> checkAuth() async {
    _isAuthenticated = await _authService.isLoggedIn();

    notifyListeners();
  }
}
