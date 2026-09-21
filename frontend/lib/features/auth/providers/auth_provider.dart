import 'package:flutter/foundation.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/services/storage_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _isAuthenticated = false;
  bool _isGuest = false;
  String _userName = 'there';
  String _userEmail = '';

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  bool get isGuest => _isGuest;
  String get userName => _userName;
  String get userEmail => _userEmail;

  Future<bool> login(String email, String password) async {
    _setLoading(true);

    final result = await _authService.login(email: email, password: password);

    if (result) {
      _isGuest = false;
      await _loadProfile();
    }
    _isAuthenticated = result;
    _setLoading(false);

    return result;
  }

  Future<bool> register(String name, String email, String password) async {
    _setLoading(true);

    final result = await _authService.register(
      name: name,
      email: email,
      password: password,
    );

    if (result) {
      _isGuest = false;
      await _loadProfile();
    }
    _isAuthenticated = result;
    _setLoading(false);

    return result;
  }

  void continueAsGuest() {
    _isAuthenticated = true;
    _isGuest = true;
    _userName = 'Guest';
    _userEmail = '';
    notifyListeners();
  }

  Future<void> logout() async {
    await _authService.logout();
    _isAuthenticated = false;
    _isGuest = false;
    _userName = 'there';
    _userEmail = '';
    notifyListeners();
  }

  Future<void> checkAuth() async {
    try {
      _isAuthenticated = await _authService.isLoggedIn();
      if (_isAuthenticated) {
        await _loadProfile();
      }
    } catch (_) {
      // Secure storage can be unavailable (e.g. first launch, web sandbox).
      // Fail closed: treat the user as signed out rather than crashing.
      _isAuthenticated = false;
    }
    notifyListeners();
  }

  Future<void> _loadProfile() async {
    _userName = await StorageService.getUserName() ?? 'there';
    _userEmail = await StorageService.getUserEmail() ?? '';
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
