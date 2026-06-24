import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_project/core/services/notification_service.dart';

void main() {
  group('NotificationService Tests', () {
    late FakeFirebaseFirestore fakeFirestore;
    late NotificationService service;
    const String studentId = 'student_001';
    const String studentName = 'محمد سالم';
    const String fcmToken = 'fake_fcm_token';
    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      service = NotificationService.forTesting(firestore: fakeFirestore);
    });
    // ── اختبار 1: إشعار قبول تجديد القيد ──────────────────────────────
    test(
      'sendEnrollmentStatusNotification — approved: يحفظ إشعاراً بعنوان صحيح',
      () async {
        await service.sendEnrollmentStatusNotification(
          studentFcmToken: fcmToken,
          status: 'approved',
          studentName: studentName,
          studentId: studentId,
        );

        final snap =
            await fakeFirestore
                .collection('users')
                .doc(studentId)
                .collection('notifications')
                .get();

        expect(snap.docs.length, 1);

        final data = snap.docs.first.data();
        expect(data['type'], 'enrollment_status');
        expect(data['title'], contains('قبول'));
        expect(data['is_read'], false);
        expect(data['userId'], studentId);
      },
    );

    // ── اختبار 2: إشعار رفض تجديد القيد مع سبب ───────────────────────
    test(
      'sendEnrollmentStatusNotification — rejected: يحفظ سبب الرفض في الـ body',
      () async {
        const String rejectionReason = 'الأوراق غير مكتملة';

        await service.sendEnrollmentStatusNotification(
          studentFcmToken: fcmToken,
          status: 'rejected',
          studentName: studentName,
          studentId: studentId,
          rejectionReason: rejectionReason,
        );

        final snap =
            await fakeFirestore
                .collection('users')
                .doc(studentId)
                .collection('notifications')
                .get();

        final data = snap.docs.first.data();
        expect(data['type'], 'enrollment_status');
        expect(data['title'], contains('مرفوض'));
        expect((data['body'] as String), contains(rejectionReason));
      },
    );

    // ── اختبار 3: إشعار قبول عذر الغياب ──────────────────────────────
    test(
      'sendAbsenceExcuseNotification — approved: يحفظ إشعاراً بنوع absence_excuse',
      () async {
        await service.sendAbsenceExcuseNotification(
          studentFcmToken: fcmToken,
          studentName: studentName,
          studentId: studentId,
          decision: 'approved',
          courseName: 'برمجة الويب',
        );

        final snap =
            await fakeFirestore
                .collection('users')
                .doc(studentId)
                .collection('notifications')
                .get();

        expect(snap.docs.length, 1);

        final data = snap.docs.first.data();
        expect(data['type'], 'absence_excuse');
        expect(data['category'], 'absence_excuse');
        expect(data['is_read'], false);
      },
    );

    // ── اختبار 4: markAsRead ──────────────────────────────────────────
    test('markAsRead: يُحدّث الحقول الثلاثة إلى true', () async {
      // إنشاء إشعار وهمي
      final docRef = await fakeFirestore
          .collection('users')
          .doc(studentId)
          .collection('notifications')
          .add({
            'isRead': false,
            'is_read': false,
            'read': false,
            'title': 'اختبار',
          });

      await service.markAsRead(studentId, docRef.id);

      final doc =
          await fakeFirestore
              .collection('users')
              .doc(studentId)
              .collection('notifications')
              .doc(docRef.id)
              .get();

      expect(doc.data()!['isRead'], true);
      expect(doc.data()!['is_read'], true);
      expect(doc.data()!['read'], true);
    });

    // ── اختبار 5: deleteNotification ─────────────────────────────────
    test('deleteNotification: يحذف الوثيقة من Firestore', () async {
      final docRef = await fakeFirestore
          .collection('users')
          .doc(studentId)
          .collection('notifications')
          .add({'title': 'إشعار للحذف', 'is_read': false});

      await service.deleteNotification(studentId, docRef.id);

      final doc =
          await fakeFirestore
              .collection('users')
              .doc(studentId)
              .collection('notifications')
              .doc(docRef.id)
              .get();

      expect(doc.exists, false);
    });
  });
}
