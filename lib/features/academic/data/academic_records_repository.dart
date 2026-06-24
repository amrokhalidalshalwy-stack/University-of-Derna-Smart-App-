import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_project/core/models/course_grade.dart';

/// Result of a portal sync request (Callable or future local trigger).
class AcademicSyncResult {
  const AcademicSyncResult._({
    required this.success,
    this.syncedCount = 0,
    this.message,
  });

  const AcademicSyncResult.ok(int count)
    : this._(success: true, syncedCount: count);

  const AcademicSyncResult.failure(String message)
    : this._(success: false, message: message);

  const AcademicSyncResult.unavailable()
    : this._(
        success: false,
        message:
            'المزامنة غير متاحة حالياً — جرّب لاحقاً أو استخدم البيانات المحفوظة',
      );

  final bool success;
  final int syncedCount;
  final String? message;
}

/// Reads `academic_records` and merges with legacy `users/{uid}/grades` when empty.
class AcademicRecordsRepository {
  AcademicRecordsRepository(this._firestore, this._functions);

  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;

  /// Live stream from `academic_records` (sorted by semester in memory).
  Stream<List<CourseGrade>> watchGrades(String studentUid) {
    return _firestore
        .collection('academic_records')
        .where('student_uid', isEqualTo: studentUid)
        .snapshots()
        .map((snap) {
          final grades = snap.docs.map(CourseGrade.fromAcademicRecord).toList();
          grades.sort((a, b) => b.semester.compareTo(a.semester));
          return grades;
        });
  }

  /// Prefers portal-synced records; falls back to [legacyGrades] when empty.
  Stream<List<CourseGrade>> watchGradesWithLegacyFallback(
    String studentUid,
    Stream<List<CourseGrade>> legacyGrades,
  ) {
    final controller = StreamController<List<CourseGrade>>();
    List<CourseGrade> academic = [];
    List<CourseGrade> legacy = [];

    void emit() {
      if (!controller.isClosed) {
        controller.add(academic.isNotEmpty ? academic : legacy);
      }
    }

    final subAcademic = watchGrades(studentUid).listen((value) {
      academic = value;
      emit();
    }, onError: controller.addError);

    final subLegacy = legacyGrades.listen((value) {
      legacy = value;
      emit();
    }, onError: controller.addError);

    controller.onCancel = () async {
      await subAcademic.cancel();
      await subLegacy.cancel();
    };

    return controller.stream;
  }

  /// Calls Cloud Function `syncAcademicRecords` (requires Blaze + deploy).
  Future<AcademicSyncResult> requestSync() async {
    try {
      final callable = _functions.httpsCallable('syncAcademicRecords');
      final result = await callable.call<Map<String, dynamic>>();
      final synced = result.data['synced'] as int? ?? 0;
      return AcademicSyncResult.ok(synced);
    } on FirebaseFunctionsException catch (e) {
      if (e.code == 'unavailable' || e.code == 'not-found') {
        return const AcademicSyncResult.unavailable();
      }
      return AcademicSyncResult.failure(e.message ?? e.code);
    } catch (e) {
      return AcademicSyncResult.failure(e.toString());
    }
  }
}
