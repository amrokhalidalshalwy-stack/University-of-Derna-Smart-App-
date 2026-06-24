import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_project/core/constants/app_roles.dart';
import 'package:flutter_project/core/models/app_notification.dart';
import 'package:flutter_project/core/models/course_grade.dart';
import 'package:flutter_project/core/models/fee_record.dart';
import 'package:flutter_project/core/models/schedule_entry.dart';
import 'package:flutter_project/core/providers/user_role_provider.dart';
import 'package:flutter_project/features/auth/data/auth_service.dart';
import 'package:flutter_project/features/student/data/database_service.dart';

/// Instance مركزية لخدمة قاعدة البيانات
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService(ref.watch(firestoreProvider));
});

/// النسخة المعدلة والمستقرة (بدون الـ listen المتداخل)
final gradesStreamProvider = StreamProvider.family<List<CourseGrade>, String>((ref, uid) {
  if (uid.isEmpty) return const Stream.empty();
  return ref.watch(databaseServiceProvider).watchGrades(uid);
});

/// النسخة المستقرة لـ ScheduleEntry - Single Source of Truth
/// For students: queries schedules by course_id from enrolled courses
/// For faculty: queries schedules by faculty_id
final scheduleEntriesProvider = StreamProvider.family<List<ScheduleEntry>, String>((ref, uid) {
  final db = ref.watch(firestoreProvider);
  final userRole = ref.watch(userRoleInfoProvider).value;

  if (userRole == null) return const Stream.empty();

  // Student: Query by course_id from enrolled courses
  if (userRole.role == UserRole.student) {
    return db
        .collection('users')
        .doc(uid)
        .collection('enrollments')
        .where('status', isEqualTo: 'active')
        .snapshots()
        .asyncMap((enrollmentsSnap) async {
          final courseIds = enrollmentsSnap.docs.map((doc) => doc.id).toList();
          if (courseIds.isEmpty) return <ScheduleEntry>[];

          final schedulesSnap = await db
              .collection('schedules')
              .where('course_id', whereIn: courseIds)
              .get();

          final entries = schedulesSnap.docs
              .map((doc) => ScheduleEntry.fromFirestore(uid, doc))
              .toList();
          entries.sort((a, b) => a.weekdayIndex.compareTo(b.weekdayIndex));
          return entries;
        });
  }

  // Faculty: Query by faculty_id
  if (userRole.role == UserRole.faculty) {
    return db
        .collection('schedules')
        .where('faculty_id', isEqualTo: uid)
        .snapshots()
        .map((snapshot) {
          final entries = snapshot.docs
              .map((doc) => ScheduleEntry.fromFirestore(uid, doc))
              .toList();
          entries.sort((a, b) => a.weekdayIndex.compareTo(b.weekdayIndex));
          return entries;
        });
  }

  // Fallback: Query by user_id (legacy support)
  return db
      .collection('schedules')
      .where('user_id', isEqualTo: uid)
      .snapshots()
      .map((snapshot) {
        final entries = snapshot.docs
            .map((doc) => ScheduleEntry.fromFirestore(uid, doc))
            .toList();
        entries.sort((a, b) => a.weekdayIndex.compareTo(b.weekdayIndex));
        return entries;
      });
});

/// Merges per-user notifications with global broadcast notifications.
final notificationListProvider =
    StreamProvider.autoDispose.family<List<AppNotification>, String>((ref, uid) {
      final firestore = ref.watch(firestoreProvider);
      final controller = StreamController<List<AppNotification>>();

      List<AppNotification> userItems = [];
      List<AppNotification> globalItems = [];

      void emitMerged() {
        final seen = <String>{};
        final merged = <AppNotification>[];
        for (final item in [...userItems, ...globalItems]) {
          if (seen.add(item.id)) merged.add(item);
        }
        merged.sort(
          (a, b) => (b.createdAtMs ?? 0).compareTo(a.createdAtMs ?? 0),
        );
        if (!controller.isClosed) {
          controller.add(merged.take(50).toList());
        }
      }

      final userSub = firestore
          .collection('users')
          .doc(uid)
          .collection('notifications')
          .orderBy('createdAt', descending: true)
          .limit(50)
          .snapshots()
          .listen(
            (snapshot) {
              userItems = snapshot.docs
                  .map((doc) => AppNotification.fromFirestore(uid, doc))
                  .toList();
              emitMerged();
            },
            onError: controller.addError,
          );

      final globalSub = firestore
          .collection('notifications')
          .orderBy('createdAt', descending: true)
          .limit(30)
          .snapshots()
          .listen(
            (snapshot) {
              globalItems = snapshot.docs
                  .map((doc) {
                    final role = doc.data()['targetRole'] as String?;
                    if (role != null && role != 'all' && role != 'student') {
                      return null;
                    }
                    return AppNotification.fromGlobalFirestore(doc);
                  })
                  .whereType<AppNotification>()
                  .toList();
              emitMerged();
            },
            onError: controller.addError,
          );

      ref.onDispose(() {
        userSub.cancel();
        globalSub.cancel();
        controller.close();
      });

      return controller.stream;
    });

final feeRecordsProvider = StreamProvider.autoDispose.family<List<FeeRecord>, String>((
  ref,
  uid,
) {
  final firestore = ref.watch(firestoreProvider);
  return firestore
      .collection('users')
      .doc(uid)
      .collection('fees')
      .snapshots()
      .map((snapshot) {
        return snapshot.docs
            .map((doc) => FeeRecord.fromFirestore(uid, doc))
            .toList();
      });
});