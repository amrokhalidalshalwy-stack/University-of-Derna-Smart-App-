import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_project/core/services/error_tracking_service.dart';

Future<void> runFirestoreRoleBackfill() async {
  debugPrint(
    "🚀 [Migration] Initializing Firestore user role backfill scan...",
  );
  try {
    final usersCollection = FirebaseFirestore.instance.collection('users');
    final snapshot = await usersCollection.get();
    debugPrint(
      "🚀 [Migration] Total user documents scanned: ${snapshot.docs.length}",
    );

    int backfilledCount = 0;
    int alreadyCorrectCount = 0;

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final uid = doc.id;
      final email = data['email'] ?? 'no-email';

      final hasStudentMetrics =
          data.containsKey('gpa') ||
          data.containsKey('major') ||
          data.containsKey('completedHours');

      final hasRole =
          data.containsKey('role') &&
          data['role'] != null &&
          (data['role'] as String).trim().isNotEmpty;

      if (hasStudentMetrics && !hasRole) {
        debugPrint(
          "✍️ [Migration] Backfilling UID: $uid ($email) ➔ role: 'student'",
        );
        await usersCollection.doc(uid).update({
          'role': 'student',
          'status': data['status'] ?? 'approved',
        });
        backfilledCount++;
      } else {
        alreadyCorrectCount++;
      }
    }

    debugPrint("✅ [Migration] Role backfill complete!");
    debugPrint(
      "📊 [Migration] Summary: $backfilledCount updated, $alreadyCorrectCount untouched.",
    );
  } catch (e, stackTrace) {
    ErrorTrackingService.recordError(
      e,
      stackTrace,
      context: '❌ [Migration] Critical error during role backfill',
    );
    debugPrint(stackTrace.toString()); // ← إصلاح: st ➔ stackTrace
  }
}
