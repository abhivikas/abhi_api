import 'package:dio/dio.dart';

class DioClient {
  final Dio dio;

  DioClient() : dio = Dio(BaseOptions(
    baseUrl: 'https://fakestoreapi.com',
    connectTimeout: const Duration(milliseconds: 5000),
    receiveTimeout: const Duration(milliseconds: 3000),
  ));

  Future<Response> get(String path) async {
    try {
      final response = await dio.get(path);
      return response;
    } catch (e) {
      throw Exception("Error making network request: $e");
    }
  }
}