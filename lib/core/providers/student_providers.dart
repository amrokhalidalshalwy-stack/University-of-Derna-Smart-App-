import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_project/core/models/app_notification.dart';
import 'package:flutter_project/core/models/course_grade.dart';
import 'package:flutter_project/features/auth/data/auth_service.dart';
import 'package:flutter_project/features/student/data/database_service.dart';

/// Instance مركزية لخدمة قاعدة البيانات
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService(ref.watch(firestoreProvider));
});

/// Provider لجلب الدرجات مع دعم التحديث التلقائي للمعدل في الخلفية
final gradesStreamProvider = StreamProvider.family<List<CourseGrade>, String>((
  ref,
  uid,
) {
  if (uid.isEmpty) return const Stream.empty();

  final stream = ref.watch(databaseServiceProvider).watchGrades(uid);

  // منطق احترافي: تحديث إحصائيات الطالب في Firestore تلقائياً عند تغير الدرجات
  stream.listen((grades) {
    if (grades.isNotEmpty) {
      ref.read(databaseServiceProvider).recomputeAndSaveGpa(uid, grades);
    }
  });

  return stream;
});

/// Provider للمعدل التراكمي (يقرأ من الدرجات مباشرة لضمان الدقة)
final computedGpaProvider = Provider.family<AsyncValue<String>, String>((
  ref,
  uid,
) {
  return ref
      .watch(gradesStreamProvider(uid))
      .whenData((grades) => CourseGrade.calculateCumulativeGpa(grades));
});

/// Provider للساعات المنجزة
final computedCompletedHoursProvider =
    Provider.family<AsyncValue<String>, String>((ref, uid) {
      return ref
          .watch(gradesStreamProvider(uid))
          .whenData(
            (grades) => CourseGrade.calculateCompletedHours(grades).toString(),
          );
    });

/// Provider للحضور والغياب
final attendanceStreamProvider =
    StreamProvider.family<List<AttendanceSummary>, String>((ref, uid) {
      if (uid.isEmpty) return const Stream.empty();
      return ref.watch(databaseServiceProvider).watchAttendance(uid);
    });

/// Provider للإشعارات الحية
final notificationsStreamProvider =
    StreamProvider.family<List<AppNotification>, String>((ref, uid) {
      if (uid.isEmpty) return const Stream.empty();
      return ref.watch(databaseServiceProvider).watchNotifications(uid);
    });
