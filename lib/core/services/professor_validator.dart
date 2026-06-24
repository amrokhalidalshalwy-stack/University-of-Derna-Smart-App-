import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfessorValidator {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  ProfessorValidator({FirebaseFirestore? db, FirebaseAuth? auth})
      : _db = db ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  /// التحقق من أن الأستاذ يملك صلاحية تدريس هذه المادة
  Future<bool> isProfessorAssignedToCourse(String courseId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return false;

    final courseSnap = await _db
        .collection('courses')
        .doc(courseId)
        .get();

    if (!courseSnap.exists) return false;

    final data = courseSnap.data()!;
    final assignedProfessors = List<String>.from(
      data['assigned_professors'] ?? []
    );

    return assignedProfessors.contains(uid);
  }

  /// التحقق من أن الطالب مسجّل في المادة
  Future<bool> isStudentEnrolledInCourse({
    required String studentId,
    required String courseId,
  }) async {
    final enrollSnap = await _db
        .collection('users')
        .doc(studentId)
        .collection('enrollments')
        .where('course_id', isEqualTo: courseId)
        .where('is_active', isEqualTo: true)
        .limit(1)
        .get();

    return enrollSnap.docs.isNotEmpty;
  }

  /// التحقق من صلاحية الأستاذ قبل حفظ الدرجات
  Future<ValidationResult> validateGradeEntry({
    required String courseId,
    required String studentId,
  }) async {
    // 1. تحقق من الأستاذ
    final isAssigned = await isProfessorAssignedToCourse(courseId);
    if (!isAssigned) {
      return ValidationResult.failure(
        'ليس لديك صلاحية إدخال درجات لهذه المادة'
      );
    }

    // 2. تحقق من تسجيل الطالب
    final isEnrolled = await isStudentEnrolledInCourse(
      studentId: studentId,
      courseId: courseId,
    );
    if (!isEnrolled) {
      return ValidationResult.failure(
        'هذا الطالب غير مسجّل في المادة'
      );
    }

    return ValidationResult.success();
  }
}

class ValidationResult {
  final bool isValid;
  final String? errorMessage;

  ValidationResult.success()
      : isValid = true,
        errorMessage = null;

  ValidationResult.failure(this.errorMessage) : isValid = false;
}
