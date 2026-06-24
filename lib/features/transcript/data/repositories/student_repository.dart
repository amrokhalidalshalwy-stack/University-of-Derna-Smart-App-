import 'package:flutter_project/core/services/error_tracking_service.dart';
import 'package:flutter_project/features/transcript/data/datasources/local_pdf_cache_data_source.dart';
import 'package:flutter_project/features/transcript/data/datasources/n8n_remote_data_source.dart';
import 'package:flutter_project/features/transcript/data/exceptions/offline_fallback_exception.dart';

class StudentRepository {
  StudentRepository({
    required this.local,
    required this.remote,
  });

  final LocalPdfCacheDataSource local;
  final N8nRemoteDataSource remote;

  Future<String?> getPdfUrl(
    String studentId,
    String semester, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh) {
      final cached = await local.getCachedPdf(studentId, semester);
      if (cached != null) return cached.pdfUrl;
    }

    try {
      final newUrl = await remote.generatePdf(studentId, semester);
      await local.savePdfUrl(studentId, semester, newUrl);
      return newUrl;
    } catch (e, stackTrace) {
      await ErrorTrackingService.recordError(e, stackTrace, context: '[StudentRepository] remote failed');
      final cached = await local.getCachedPdf(studentId, semester);
      if (cached != null) {
        throw OfflineFallbackException(cached.pdfUrl);
      }
      rethrow;
    }
  }
}
