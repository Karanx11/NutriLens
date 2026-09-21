import '../constants/api_constants.dart';
import 'api_service.dart';
import 'storage_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  Future<bool> login({required String email, required String password}) async {
    if (ApiConstants.useMockData) {
      return _mockAuth(email: email, password: password);
    }
    try {
      final response = await _apiService.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        final data = response.data;

        await StorageService.saveToken(data['token']);

        if (data['user'] != null && data['user']['id'] != null) {
          await StorageService.saveUserId(data['user']['id'].toString());
        }
        if (data['user'] != null && data['user']['name'] != null) {
          await StorageService.saveUserName(data['user']['name'].toString());
        }
        await StorageService.saveUserEmail(email);

        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    if (ApiConstants.useMockData) {
      return _mockAuth(email: email, password: password, name: name);
    }
    try {
      final response = await _apiService.post(
        ApiConstants.register,
        data: {'name': name, 'email': email, 'password': password},
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = response.data;

        if (data['token'] != null) {
          await StorageService.saveToken(data['token']);
        }
        if (data['user'] != null && data['user']['id'] != null) {
          await StorageService.saveUserId(data['user']['id'].toString());
        }
        await StorageService.saveUserName(name);
        await StorageService.saveUserEmail(email);

        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  /// Demo authentication — accepts any well-formed credentials and persists a
  /// local session so the rest of the app behaves as if signed in.
  Future<bool> _mockAuth({
    required String email,
    required String password,
    String? name,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));
    if (email.trim().isEmpty || password.isEmpty) return false;

    final displayName = (name != null && name.trim().isNotEmpty)
        ? name.trim()
        : _nameFromEmail(email);

    await StorageService.saveToken('demo-token');
    await StorageService.saveUserId('demo-user');
    await StorageService.saveUserName(displayName);
    await StorageService.saveUserEmail(email.trim());
    return true;
  }

  String _nameFromEmail(String email) {
    final local = email.split('@').first.replaceAll(RegExp(r'[._]+'), ' ').trim();
    if (local.isEmpty) return 'Explorer';
    return local
        .split(' ')
        .where((w) => w.isNotEmpty)
        .map((w) => w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }

  Future<void> logout() async {
    await StorageService.clear();
  }

  Future<bool> isLoggedIn() async {
    final token = await StorageService.getToken();
    return token != null && token.isNotEmpty;
  }
}
