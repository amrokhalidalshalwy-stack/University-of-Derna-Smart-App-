import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_project/features/attendance/data/absence_excuse_service.dart';

void main() {
  group('AbsenceExcuseService Tests', () {
    late FakeFirebaseFirestore fakeFirestore;
    late MockFirebaseAuth mockAuth;
    late AbsenceExcuseService service;

    final String studentUid = 'student_123';

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      
      final mockUser = MockUser(uid: studentUid);
      mockAuth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);

      service = AbsenceExcuseService(
        firestore: fakeFirestore,
        auth: mockAuth,
      );
    });

    test('إرسال ناجح: يجب أن تُنشأ وثيقة في مجموعة student_requests بالحقول الصحيحة', () async {
      // 1. إعداد بيانات المستخدم (الطالب)
      await fakeFirestore.collection('users').doc(studentUid).set({
        'name': 'عمر خالد',
        'role': 'student',
      });

      // 2. بيانات الطلب
      final String professorId = 'prof_001';
      final String courseId = 'course_001';
      final String courseName = 'هندسة برمجيات';
      final DateTime absenceDate = DateTime(2026, 6, 20);
      final String reason = 'عذر طبي بسبب المرض المرفق بالتقرير';

      // 3. استدعاء دالة الإرسال
      await service.submitAbsenceExcuse(
        professorId: professorId,
        courseId: courseId,
        courseName: courseName,
        absenceDate: absenceDate,
        reason: reason,
      );

      // 4. التحقق من النتيجة في قاعدة البيانات
      final snapshot = await fakeFirestore
          .collection('student_requests')
          .where('student_id', isEqualTo: studentUid)
          .get();

      // التأكد أنه تم إنشاء وثيقة واحدة
      expect(snapshot.docs.length, 1);

      final docData = snapshot.docs.first.data();
      
      // التحقق من الحقول الأساسية
      expect(docData['type'], 'absence_excuse');
      expect(docData['status'], 'pending');
      expect(docData['student_id'], studentUid);

      // التحقق من بنية الـ details
      final details = docData['details'] as Map<String, dynamic>;
      expect(details['professorId'], professorId);
      expect(details['course_id'], courseId);
      expect(details['course_name'], courseName);
      expect(details['reason'], reason);
      expect(details['studentName'], 'عمر خالد');
      
      // التحقق من حقل التاريخ
      final timestamp = details['absenceDate'] as dynamic;
      expect(timestamp.toDate(), absenceDate);
    });
  });
}
