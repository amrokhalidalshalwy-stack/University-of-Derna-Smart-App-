import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class HifzhApiClient {
  HifzhApiClient._();

  static Dio create() {
    final dio = Dio(
      BaseOptions(
        baseUrl: dotenv.env['API_BASE_URL'] ?? '',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    const storage = FlutterSecureStorage();

    // Request interceptor — attach Bearer token
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Attempt to load token from Secure Storage
          String? token;
          try {
            token = await storage.read(key: 'auth_token');
          } catch (_) {
            // Safe fallback if secure storage is not accessible in current platform
          }

          // Fallback to env token if secure storage token is empty
          if (token == null || token.isEmpty) {
            token = dotenv.env['AUTH_TOKEN'] ?? '';
          }

          if (token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          // Refresh token logic if 401
          if (error.response?.statusCode == 401) {
            // emit token refresh here if needed
          }
          return handler.next(error);
        },
      ),
    );

    // Logging interceptor (debug only)
    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(requestBody: true, responseBody: true),
      );
    }

    return dio;
  }
}
