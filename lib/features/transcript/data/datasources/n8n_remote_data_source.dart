import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_project/core/services/error_tracking_service.dart';
import 'package:flutter_project/features/transcript/data/exceptions/n8n_api_exception.dart';

/// Triggers the n8n workflow that generates a transcript PDF and returns its URL.
class N8nRemoteDataSource {
  N8nRemoteDataSource(this._dio);

  final Dio _dio;

  Future<String> generatePdf(String studentId, String semester) async {
    debugPrint('[N8n] POST transcript for student=$studentId semester=$semester');
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '',
        data: {'student_id': studentId, 'semester': semester},
      );

      final data = response.data;
      final pdfUrl = data?['pdfUrl'] as String?;

      if (pdfUrl == null || pdfUrl.isEmpty) {
        throw N8nApiException(
          'The server did not return a PDF link. Please try again later.',
        );
      }

      debugPrint('[N8n] response received with pdfUrl');
      return pdfUrl;
    } on DioException catch (e, stackTrace) {
      await ErrorTrackingService.recordError(e, stackTrace, context: '[N8n] DioException');
      throw N8nApiException(_mapDioError(e));
    }
  }

  String _mapDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'The request timed out while generating your transcript. Please try again.';
      case DioExceptionType.connectionError:
        return 'No internet connection. Check your network and try again.';
      case DioExceptionType.badResponse:
        final status = e.response?.statusCode;
        if (status != null && status >= 500) {
          return 'The transcript service is temporarily unavailable ($status). Please try again later.';
        }
        if (status == 401 || status == 403) {
          return 'You are not authorized to request this transcript.';
        }
        if (status == 404) {
          return 'Transcript service not found. Contact support if this continues.';
        }
        return 'Could not generate your transcript (HTTP $status).';
      case DioExceptionType.cancel:
        return 'The request was cancelled.';
      case DioExceptionType.badCertificate:
        return 'Secure connection failed. Please try again later.';
      case DioExceptionType.unknown:
        return e.message ?? 'An unexpected network error occurred.';
    }
  }
}
