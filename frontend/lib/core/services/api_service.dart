import 'package:dio/dio.dart';
import '../constants/api_constants.dart';

class ApiService {
  late final Dio dio;

  ApiService() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ),
    );
  }

  Future<Response> post(String endpoint, {Map<String, dynamic>? data}) async {
    return await dio.post(endpoint, data: data);
  }

  Future<Response> get(String endpoint) async {
    return await dio.get(endpoint);
  }

  Future<Response> delete(String endpoint) async {
    return await dio.delete(endpoint);
  }
}
