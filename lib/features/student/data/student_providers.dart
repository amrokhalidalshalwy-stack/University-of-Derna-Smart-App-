import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_project/core/models/app_notification.dart';
import 'package:flutter_project/core/models/course_enrollment.dart';
import 'package:flutter_project/core/models/course_grade.dart';
import 'package:flutter_project/features/auth/data/auth_service.dart';
import 'package:flutter_project/features/academic/data/academic_providers.dart';
import 'package:flutter_project/features/student/data/database_service.dart';

/// `academic_records` with fallback to `users/{uid}/grades`.
Stream<List<CourseGrade>> gradesListStream(Ref ref, String uid) {
  if (uid.isEmpty) return const Stream.empty();
  final repo = ref.watch(academicRecordsRepositoryProvider);
  final legacy = ref.watch(databaseServiceProvider).watchGrades(uid);
  return repo.watchGradesWithLegacyFallback(uid, legacy);
}

// ─────────────────────────────────────────────────────────────────────────────
// Student Providers
// ─────────────────────────────────────────────────────────────────────────────
// All these providers use StreamProvider.autoDispose.family:
//   • Filters data automatically by the current student's uid.
//   • Updates the UI immediately on any Firestore change (Real-time).
//   • No student can see another student's data.
// ─────────────────────────────────────────────────────────────────────────────

/// Single instance of DatabaseService shared across the app.
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService(ref.watch(firestoreProvider));
});

// ══════════════════════════════════════════════════════════════════════════════
// Enrolled Courses
// ══════════════════════════════════════════════════════════════════════════════

/// Stream of active enrolled courses for student [uid].
/// Source: `users/{uid}/enrollments` (where status == 'active')
final enrollmentsStreamProvider =
    StreamProvider.autoDispose.family<List<CourseEnrollment>, String>((ref, uid) {
      if (uid.isEmpty) return const Stream.empty();
      return ref.watch(databaseServiceProvider).watchEnrollments(uid);
    });

// ══════════════════════════════════════════════════════════════════════════════
// Grades
// ══════════════════════════════════════════════════════════════════════════════

/// Stream of all grades for student [uid] across all semesters.
/// Source: `academic_records` (portal sync) with fallback to `users/{uid}/grades`.
final gradesStreamProvider = StreamProvider.autoDispose.family<List<CourseGrade>, String>((
  ref,
  uid,
) {
  return gradesListStream(ref, uid);
});

/// Direct stream from `users/{uid}/grades` (bypasses academic_records fallback).
/// Pure, real-time stream driven directly by production Firestore data.
final gradesStreamProviderDirect = StreamProvider.autoDispose.family<List<CourseGrade>, String>((
  ref,
  uid,
) {
  debugPrint('📂 gradesStreamProviderDirect: Fetching real grades for users/$uid/grades');
  if (uid.isEmpty) return const Stream.empty();
  return ref.watch(databaseServiceProvider).watchGrades(uid);
});

// ══════════════════════════════════════════════════════════════════════════════
// Cumulative GPA (Automatically calculated – not manually entered)
// ══════════════════════════════════════════════════════════════════════════════

/// Stream that emits the calculated cumulative GPA from student grades.
/// GPA = Σ(gradePoints × creditHours) / Σ(creditHours)
final computedGpaProvider = StreamProvider.autoDispose.family<String, String>((ref, uid) {
  if (uid.isEmpty) return Stream.value('0.00');
  return gradesListStream(ref, uid).map((grades) => CourseGrade.calculateCumulativeGpa(grades));
});

/// Stream that emits the calculated cumulative GPA from student grades (direct stream).
/// Uses `users/{uid}/grades` directly, bypassing academic_records fallback.
final computedGpaProviderDirect = StreamProvider.autoDispose.family<String, String>((ref, uid) {
  if (uid.isEmpty) return Stream.value('0.00');
  debugPrint('📊 computedGpaProviderDirect: Computing real GPA for uid = "$uid"');
  
  return ref.watch(databaseServiceProvider).watchGrades(uid).map((grades) {
    return CourseGrade.calculateCumulativeGpa(grades);
  });
});

/// Stream that emits the total earned credit hours (passed courses only).
final computedCompletedHoursProvider = StreamProvider.autoDispose.family<String, String>((ref, uid) {
  if (uid.isEmpty) return Stream.value('0');
  return gradesListStream(ref, uid).map((grades) => CourseGrade.calculateCompletedHours(grades).toString());
});

/// Stream that emits the total earned credit hours (passed courses only) - direct stream.
/// Uses `users/{uid}/grades` directly, bypassing academic_records fallback.
final computedCompletedHoursProviderDirect = StreamProvider.autoDispose.family<String, String>((ref, uid) {
  if (uid.isEmpty) return Stream.value('0');
  debugPrint('📊 computedCompletedHoursProviderDirect: Computing real hours for uid = "$uid"');
  
  return ref.watch(databaseServiceProvider).watchGrades(uid).map((grades) {
    return CourseGrade.calculateCompletedHours(grades).toString();
  });
});

// ══════════════════════════════════════════════════════════════════════════════
// Attendance & Absences
// ══════════════════════════════════════════════════════════════════════════════

/// Stream of attendance records for all courses of student [uid].
/// Source: `users/{uid}/attendance`
final attendanceStreamProvider =
    StreamProvider.autoDispose.family<List<AttendanceSummary>, String>((ref, uid) {
      if (uid.isEmpty) return const Stream.empty();
      return ref.watch(databaseServiceProvider).watchAttendance(uid);
    });

// ══════════════════════════════════════════════════════════════════════════════
// Live Notifications (Real-time)
// ══════════════════════════════════════════════════════════════════════════════

/// Stream that emits the last 5 notifications for student [uid] live.
/// Source: `users/{uid}/notifications` (orderBy createdAt DESC, limit 5)
final notificationsStreamProvider =
    StreamProvider.autoDispose.family<List<AppNotification>, String>((ref, uid) {
      if (uid.isEmpty) return const Stream.empty();
      return ref.watch(databaseServiceProvider).watchNotifications(uid, limit: 5);
    });