import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_project/core/services/error_tracking_service.dart';

/// Minimal Firestore hook for future transcript sync checks.
///
/// Not used in the offline-first path today; kept for repository composition.
class FirebaseSyncDataSource {
  FirebaseSyncDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// Fetches the transcript document from the subcollection and returns the pdfUrl.
  /// Path: users/{studentId}/transcripts/{semester}
  /// Returns null if the document doesn't exist or pdfUrl is not available.
  Future<String?> getPdfUrl(
    String studentId,
    String semester,
  ) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(studentId)
          .collection('transcripts')
          .doc(semester)
          .get();

      if (!doc.exists) {
        debugPrint('[FirebaseSync] transcript document does not exist at users/$studentId/transcripts/$semester');
        return null;
      }

      final data = doc.data();
      if (data == null) {
        debugPrint('[FirebaseSync] transcript document data is null');
        return null;
      }

      final pdfUrl = data['pdfUrl'] as String?;
      if (pdfUrl == null || pdfUrl.isEmpty) {
        debugPrint('[FirebaseSync] pdfUrl is null or empty in document');
        return null;
      }

      debugPrint('[FirebaseSync] successfully fetched pdfUrl from Firestore subcollection');
      return pdfUrl;
    } catch (e, stackTrace) {
      await ErrorTrackingService.recordError(e, stackTrace, context: '[FirebaseSync] getPdfUrl failed');
      return null;
    }
  }
}
