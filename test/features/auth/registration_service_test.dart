import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_project/features/auth/data/registration_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RegistrationService Tests', () {
    test('register succeeds for valid student input (Happy Path)', () async {
      final user = MockUser(isAnonymous: false, uid: 'new_uid');
      final auth = MockFirebaseAuth(mockUser: user);
      final firestore = FakeFirebaseFirestore();
      final service = RegistrationService(auth, firestore);

      final input = RegistrationInput(
        fullNameAr: 'أحمد',
        fullNameEn: 'Ahmed',
        email: 'ahmed@example.com',
        phone: '0911234567',
        dateOfBirth: DateTime(2000, 1, 1),
        nationalId: '123456789012',
        gender: 'Male',
        faculty: 'كلية العلوم',
        department: 'قسم الحاسوب',
        semester: 'الخريف',
        graduationYear: 2026,
        secondaryGpa: 85.0,
        certificateType: 'ثانوية عامة',
        password: 'password123',
        role: 'student',
        agreedToTerms: true,
        agreedToPrivacy: true,
      );

      final result = await service.register(input);

      expect(result.uid, isNotEmpty);
      
      // Verify Firestore data
      final doc = await firestore.collection('users').doc(result.uid).get();
      expect(doc.exists, true);
      expect(doc.data()!['role'], 'student');
    });

    test('register throws error for invalid national ID (Failure Path)', () async {
      final auth = MockFirebaseAuth();
      final firestore = FakeFirebaseFirestore();
      final service = RegistrationService(auth, firestore);

      final input = RegistrationInput(
        fullNameAr: 'أحمد',
        fullNameEn: 'Ahmed',
        email: 'ahmed@example.com',
        phone: '0911234567',
        dateOfBirth: DateTime(2000, 1, 1),
        nationalId: '123', // Invalid ID
        gender: 'Male',
        faculty: 'كلية العلوم',
        department: 'قسم الحاسوب',
        semester: 'الخريف',
        graduationYear: 2026,
        secondaryGpa: 85.0,
        certificateType: 'ثانوية عامة',
        password: 'password123',
        role: 'student',
        agreedToTerms: true,
        agreedToPrivacy: true,
      );

      expect(
        () => service.register(input),
        throwsA('رقم الهوية الوطنية يجب أن يكون 12 رقم'),
      );
    });

    test('score calculation gap: ignores faculty mapping edge cases (Validation Gap)', () {
      final auth = MockFirebaseAuth();
      final firestore = FakeFirebaseFirestore();
      final service = RegistrationService(auth, firestore);

      // This just tests that the score calculator works as currently coded.
      // Gap: The scoring logic doesn't strictly reject non-existent faculties, 
      // it just gives them +10.
      final score = service.calculatePreliminaryScore(
        gpa: 80,
        ageInYears: 20,
        allFieldsFilled: true,
        facultyName: 'UnknownFaculty',
      );
      
      expect(score, greaterThan(0));
    });
  });
}
