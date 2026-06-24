import 'package:flutter/foundation.dart';

import 'package:flutter_project/features/transcript/data/exceptions/n8n_api_exception.dart';
import 'package:flutter_project/features/transcript/data/exceptions/offline_fallback_exception.dart';
import 'package:flutter_project/features/transcript/data/repositories/student_repository.dart';

enum TranscriptState { idle, loading, success, error }

/// Sentinel values for [errorMessage] mapped to l10n in the UI layer.
abstract final class TranscriptErrorKeys {
  static const noData = '__transcript_no_data__';
  static const noCache = '__transcript_no_cache__';
  static const generic = '__transcript_generic__';
}

class TranscriptProvider extends ChangeNotifier {
  TranscriptProvider(this._repository);

  final StudentRepository _repository;

  TranscriptState currentState = TranscriptState.idle;
  String? pdfUrl;
  String? errorMessage;
  bool isOfflineWarning = false;
  bool isGenerating = false;

  bool _forceRefreshOnNextFetch = false;

  Future<void> fetchTranscript(String studentId, String semester) async {
    currentState = TranscriptState.loading;
    isOfflineWarning = false;
    isGenerating = _forceRefreshOnNextFetch;
    errorMessage = null;
    pdfUrl = null;
    notifyListeners();

    try {
      final url = await _repository.getPdfUrl(
        studentId,
        semester,
        forceRefresh: _forceRefreshOnNextFetch,
      );
      _forceRefreshOnNextFetch = false;
      isGenerating = false;

      if (url == null || url.isEmpty) {
        currentState = TranscriptState.error;
        errorMessage = TranscriptErrorKeys.noData;
      } else {
        currentState = TranscriptState.success;
        pdfUrl = url;
        isOfflineWarning = false;
      }
    } on OfflineFallbackException catch (e) {
      _forceRefreshOnNextFetch = false;
      isGenerating = false;
      currentState = TranscriptState.success;
      pdfUrl = e.cachedPdfUrl;
      isOfflineWarning = true;
      debugPrint('[TranscriptProvider] offline fallback — showing cached PDF');
    } on N8nApiException catch (e) {
      _forceRefreshOnNextFetch = false;
      isGenerating = false;
      currentState = TranscriptState.error;
      errorMessage = e.message;
    } catch (e) {
      _forceRefreshOnNextFetch = false;
      isGenerating = false;
      currentState = TranscriptState.error;
      errorMessage = TranscriptErrorKeys.generic;
      debugPrint('[TranscriptProvider] unexpected error: $e');
    }

    notifyListeners();
  }

  void requestForceRefresh() {
    _forceRefreshOnNextFetch = true;
  }
}
