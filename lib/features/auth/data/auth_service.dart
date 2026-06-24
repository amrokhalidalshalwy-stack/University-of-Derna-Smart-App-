import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider للوصول إلى FirebaseAuth instance
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

// Provider للوصول إلى FirebaseFirestore instance
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

// Provider يوفر AuthService
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.read(firebaseAuthProvider));
});

// استماع لحالة مصادقة المستخدم (Stream)
final authStateChangesProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

class AuthService {
  final FirebaseAuth _firebaseAuth;

  AuthService(this._firebaseAuth);

  /// حالة تسجيل الدخول الحالية
  User? get currentUser => _firebaseAuth.currentUser;

  /// تسجيل الدخول
  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      return await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'حدث خطأ غير متوقع، يرجى المحاولة مرة أخرى';
    }
  }

  /// Client apps must not create accounts from the admin portal.
  /// Use [RegistrationService.register] for student/faculty self-registration only.
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
    required String universityId,
  }) async {
    throw UnsupportedError(
      'Account creation from the client is disabled. Use the registration flow or Firebase Console.',
    );
  }

  /// تسجيل الخروج
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  /// إعادة تعيين كلمة المرور
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// تغيير كلمة المرور للمستخدم المسجل حالياً
  Future<void> updatePassword(String newPassword) async {
    try {
      if (_firebaseAuth.currentUser == null) throw 'لا يوجد مستخدم مسجل الدخول';
      await _firebaseAuth.currentUser!.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// تحويل أخطاء Firebase إلى رسائل عربية واضحة
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-credential':
        return 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
      case 'email-already-in-use':
        return 'هذا البريد الإلكتروني مستخدم بالفعل';
      case 'invalid-email':
        return 'صيغة البريد الإلكتروني غير صحيحة';
      case 'weak-password':
        return 'كلمة المرور ضعيفة جداً';
      case 'user-disabled':
        return 'تم تعطيل هذا الحساب';
      case 'too-many-requests':
        return 'تم إجراء محاولات كثيرة جداً، يرجى المحاولة لاحقاً';
      case 'operation-not-allowed':
        return 'تسجيل الدخول بالبريد الإلكتروني وكلمة المرور غير مفعّل';
      default:
        return 'حدث خطأ في المصادقة: ${e.message}';
    }
  }
}
