import 'package:cloud_firestore/cloud_firestore.dart';

/// بيانات مادة مسجّلة للطالب.
///
/// مسار Firestore: `users/{uid}/enrollments/{courseId}`
///
/// الحقول المطلوبة في Firebase:
/// ```
/// courseName    : String   — اسم المادة (مثل "هندسة البرمجيات")
/// creditHours   : number   — عدد الساعات المعتمدة (مثل 3)
/// semester      : String   — الفصل الدراسي (مثل "خريف 2024")
/// year          : number   — السنة الدراسية (مثل 2024)
/// status        : String   — حالة التسجيل: "active" | "completed" | "dropped"
/// instructor    : String?  — اسم الدكتور (اختياري)
/// schedule      : String?  — توقيت المحاضرة (مثل "الأحد 10:00-12:00") (اختياري)
/// updatedAt     : Timestamp
/// ```
class CourseEnrollment {
  const CourseEnrollment({
    required this.courseId,
    required this.courseName,
    required this.creditHours,
    required this.semester,
    required this.year,
    required this.status,
    this.instructor,
    this.schedule,
  });

  final String courseId;
  final String courseName;
  final int creditHours;
  final String semester;
  final int year;

  /// 'active' | 'completed' | 'dropped'
  final String status;
  final String? instructor;
  final String? schedule;

  bool get isActive => status == 'active';

  factory CourseEnrollment.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return CourseEnrollment(
      courseId: doc.id,
      courseName: data['course_name'] as String? ?? '',
      creditHours: (data['credit_hours'] as num?)?.toInt() ?? 3,
      semester: data['semester'] as String? ?? '',
      year: (data['year'] as num?)?.toInt() ?? DateTime.now().year,
      status: data['status'] as String? ?? 'active',
      instructor: data['instructor'] as String?,
      schedule: data['schedule'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'course_name': courseName,
      'credit_hours': creditHours,
      'semester': semester,
      'year': year,
      'status': status,
      if (instructor != null) 'instructor': instructor,
      if (schedule != null) 'schedule': schedule,
      'updated_at': FieldValue.serverTimestamp(),
    };
  }

  @override
  String toString() =>
      'CourseEnrollment($courseId, $courseName, $creditHours hrs, $semester)';
}
