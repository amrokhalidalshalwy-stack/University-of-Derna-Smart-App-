import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_project/features/auth/data/auth_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthService Tests', () {
    test('signInWithEmailAndPassword succeeds (Happy Path)', () async {
      final user = MockUser(
        isAnonymous: false,
        uid: 'user_123',
        email: 'test@example.com',
        displayName: 'Test User',
      );
      final auth = MockFirebaseAuth(mockUser: user);
      final service = AuthService(auth);

      final result = await service.signInWithEmailAndPassword('test@example.com', 'password123');

      expect(result.user?.uid, 'user_123');
      expect(service.currentUser?.uid, 'user_123');
    });

    test('createUserWithEmailAndPassword throws UnsupportedError', () async {
      final auth = MockFirebaseAuth();
      final service = AuthService(auth);

      expect(
        () => service.createUserWithEmailAndPassword(
          email: 'test@example.com',
          password: 'pass',
          fullName: 'Test',
          universityId: '123',
        ),
        throwsA(isA<UnsupportedError>()),
      );
    });

    test('updatePassword throws when no user is logged in', () async {
      final auth = MockFirebaseAuth(); // No user
      final service = AuthService(auth);

      expect(
        () => service.updatePassword('newPass'),
        throwsA('لا يوجد مستخدم مسجل الدخول'),
      );
    });
  });
}
