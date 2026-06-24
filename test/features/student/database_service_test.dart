import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_project/core/models/course_grade.dart';
import 'package:flutter_project/features/student/data/database_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late DatabaseService service;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    service = DatabaseService(fakeFirestore);
  });

  group('DatabaseService Tests', () {
    test('watchEnrollments returns active enrollments correctly (Happy Path)', () async {
      await fakeFirestore
          .collection('users')
          .doc('student_1')
          .collection('enrollments')
          .doc('course_1')
          .set({
        'status': 'active',
        'course_name': 'Mathematics',
        'credits': 3,
      });

      await fakeFirestore
          .collection('users')
          .doc('student_1')
          .collection('enrollments')
          .doc('course_2')
          .set({
        'status': 'dropped', // Should be ignored
        'course_name': 'Physics',
      });

      final stream = service.watchEnrollments('student_1');
      final result = await stream.first;

      expect(result.length, 1);
      expect(result.first.courseName, 'Mathematics');
    });

    test('recomputeAndSaveGpa saves correct GPA and hours (Happy Path)', () async {
      await fakeFirestore.collection('users').doc('student_1').set({
        'gpa': 0.0,
        'completedHours': '0',
      });

      final grades = [
        CourseGrade(
          courseId: 'course_1',
          courseName: 'Mathematics',
          creditHours: 3,
          semester: 'Fall 2023',
          midterm: 28.0,
          finalExam: 67.0,
          totalScore: 95.0, // A, 4.0 * 3
          percentage: 95.0,
          gradePoints: 4.0,
          letterGrade: 'A',
        ),
        CourseGrade(
          courseId: 'course_2',
          courseName: 'Physics',
          creditHours: 3,
          semester: 'Fall 2023',
          midterm: 25.0,
          finalExam: 60.0,
          totalScore: 85.0, // B, 3.0 * 3
          percentage: 85.0,
          gradePoints: 3.0,
          letterGrade: 'B',
        ),
      ];

      await service.recomputeAndSaveGpa('student_1', grades);

      final doc = await fakeFirestore.collection('users').doc('student_1').get();
      expect(doc.data()!['gpa'], 3.5); // (4.0*3 + 3.0*3) / 6 = 3.5
      expect(doc.data()!['completedHours'], '6');
    });

    test('recomputeAndSaveGpa fails when user document does not exist (Failure Path)', () async {
      // Intentionally not creating the user document, update() should throw
      final grades = [
        CourseGrade(
          courseId: 'course_1',
          courseName: 'Mathematics',
          creditHours: 3,
          semester: 'Fall 2023',
          midterm: 28.0,
          finalExam: 67.0,
          totalScore: 95.0,
          percentage: 95.0,
          gradePoints: 4.0,
          letterGrade: 'A',
        ),
      ];

      expect(
        () => service.recomputeAndSaveGpa('student_missing', grades),
        throwsException, // fake_cloud_firestore throws StateError/Exception when updating non-existent doc
      );
    });
  });
}
