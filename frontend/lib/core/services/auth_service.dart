import '../../../core/constants/api_constants.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/storage_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  Future<bool> login({required String email, required String password}) async {
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

        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    await StorageService.clear();
  }

  Future<bool> isLoggedIn() async {
    final token = await StorageService.getToken();

    return token != null && token.isNotEmpty;
  }
}
