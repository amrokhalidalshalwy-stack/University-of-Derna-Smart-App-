import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_project/core/services/professor_validator.dart';

void main() {
  group('ProfessorValidator Tests', () {
    late FakeFirebaseFirestore fakeFirestore;
    late MockFirebaseAuth mockAuth;
    late ProfessorValidator validator;
    late MockUser mockUser;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      mockUser = MockUser(isAnonymous: false, uid: 'prof_123');
      mockAuth = MockFirebaseAuth(mockUser: mockUser, signedIn: true);
      
      validator = ProfessorValidator(db: fakeFirestore, auth: mockAuth);
    });

    test('isProfessorAssignedToCourse returns true if assigned', () async {
      await fakeFirestore.collection('courses').doc('course_1').set({
        'assigned_professors': ['prof_123', 'prof_456']
      });

      final result = await validator.isProfessorAssignedToCourse('course_1');
      expect(result, isTrue);
    });

    test('isProfessorAssignedToCourse returns false if not assigned', () async {
      await fakeFirestore.collection('courses').doc('course_1').set({
        'assigned_professors': ['prof_456']
      });

      final result = await validator.isProfessorAssignedToCourse('course_1');
      expect(result, isFalse);
    });

    test('isStudentEnrolledInCourse returns true if active enrollment exists', () async {
      await fakeFirestore
          .collection('users')
          .doc('student_1')
          .collection('enrollments')
          .doc('enroll_1')
          .set({
        'course_id': 'course_1',
        'is_active': true,
      });

      final result = await validator.isStudentEnrolledInCourse(
        studentId: 'student_1',
        courseId: 'course_1',
      );
      expect(result, isTrue);
    });

    test('isStudentEnrolledInCourse returns false if enrollment is inactive', () async {
      await fakeFirestore
          .collection('users')
          .doc('student_1')
          .collection('enrollments')
          .doc('enroll_1')
          .set({
        'course_id': 'course_1',
        'is_active': false, // inactive
      });

      final result = await validator.isStudentEnrolledInCourse(
        studentId: 'student_1',
        courseId: 'course_1',
      );
      expect(result, isFalse);
    });

    test('validateGradeEntry fails if professor not assigned', () async {
      await fakeFirestore.collection('courses').doc('course_1').set({
        'assigned_professors': ['prof_456'] // not prof_123
      });

      final result = await validator.validateGradeEntry(
        courseId: 'course_1',
        studentId: 'student_1',
      );
      
      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('ليس لديك صلاحية'));
    });

    test('validateGradeEntry fails if student not enrolled', () async {
      // Professor is assigned
      await fakeFirestore.collection('courses').doc('course_1').set({
        'assigned_professors': ['prof_123']
      });
      // Student has no enrollment

      final result = await validator.validateGradeEntry(
        courseId: 'course_1',
        studentId: 'student_1',
      );
      
      expect(result.isValid, isFalse);
      expect(result.errorMessage, contains('هذا الطالب غير مسجّل'));
    });

    test('validateGradeEntry succeeds if both valid', () async {
      await fakeFirestore.collection('courses').doc('course_1').set({
        'assigned_professors': ['prof_123']
      });
      await fakeFirestore
          .collection('users')
          .doc('student_1')
          .collection('enrollments')
          .doc('enroll_1')
          .set({
        'course_id': 'course_1',
        'is_active': true,
      });

      final result = await validator.validateGradeEntry(
        courseId: 'course_1',
        studentId: 'student_1',
      );
      
      expect(result.isValid, isTrue);
      expect(result.errorMessage, isNull);
    });
  });
}
