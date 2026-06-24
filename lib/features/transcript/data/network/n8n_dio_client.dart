import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Dio client configured for the n8n transcript PDF webhook.
class N8nDioClient {
  N8nDioClient._();

  static const _defaultWebhook =
      'https://your-n8n-instance.com/webhook/transcript-generator';

  static Dio create() {
    final baseUrl =
        dotenv.env['N8N_TRANSCRIPT_WEBHOOK_URL']?.trim().isNotEmpty == true
            ? dotenv.env['N8N_TRANSCRIPT_WEBHOOK_URL']!.trim()
            : _defaultWebhook;

    final token = dotenv.env['N8N_TRANSCRIPT_TOKEN']?.trim() ?? '';

    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      ),
    );

    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(requestBody: true, responseBody: true),
      );
    }

    return dio;
  }
}
