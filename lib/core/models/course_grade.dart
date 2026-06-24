import 'package:cloud_firestore/cloud_firestore.dart';

/// درجات الطالب في مادة واحدة + منطق حساب المعدل التراكمي (GPA).
///
/// مسار Firestore: `users/{uid}/grades/{courseId}`
///
/// الحقول المطلوبة في Firebase:
/// ```
/// courseName    : String   — اسم المادة
/// creditHours   : number   — الساعات المعتمدة (مثل 3)
/// semester      : String   — الفصل الدراسي (مثل "خريف 2024")
/// midterm       : number   — درجة الامتحان النصفي  (من 30)
/// finalExam     : number   — درجة الامتحان النهائي (من 70)
/// totalScore    : number   — المجموع (محسوب تلقائياً من الكود)
/// gradePoints   : number   — نقاط الجودة 0.0-4.0 (محسوب)
/// letterGrade   : String   — الدرجة الحرفية A/B+/B/C+/C/D+/D/F (محسوب)
/// updatedAt     : Timestamp
/// ```
///
/// ─────────────────────────────────────────────
/// جدول التحويل (النظام الليبي الجامعي):
///   A   90-100  →  4.0
///   B+  85-89   →  3.5
///   B   80-84   →  3.0
///   C+  75-79   →  2.5
///   C   70-74   →  2.0
///   D+  65-69   →  1.5
///   D   60-64   →  1.0
///   F    <60    →  0.0
/// ─────────────────────────────────────────────
class CourseGrade {
  const CourseGrade({
    required this.courseId,
    required this.courseName,
    required this.creditHours,
    required this.semester,
    required this.midterm,
    required this.finalExam,
    required this.totalScore,
    required this.percentage,
    required this.gradePoints,
    required this.letterGrade,
    this.updatedAt,
  });

  final String courseId;
  final String courseName;
  final int creditHours;
  final String semester;

  /// من 30
  final double midterm;

  /// من 70
  final double finalExam;

  /// من 100 (midterm + finalExam)
  final double totalScore;

  /// النسبة المئوية
  final double percentage;

  /// نقاط الجودة على مقياس 0.0 – 4.0
  final double gradePoints;

  /// الرمز الحرفي: A, B+, B, C+, C, D+, D, F
  final String letterGrade;

  final DateTime? updatedAt;

  // ── حساب نقاط الجودة ──────────────────────────────────────────────────

  /// يحوّل المجموع (0-100) إلى نقاط جودة (GPA points).
  static double calculateGradePoints(double totalScore) {
    if (totalScore >= 90) return 4.0;
    if (totalScore >= 85) return 3.7;
    if (totalScore >= 80) return 3.3;
    if (totalScore >= 75) return 3.0;
    if (totalScore >= 70) return 2.7;
    if (totalScore >= 65) return 2.3;
    if (totalScore >= 60) return 2.0;
    if (totalScore >= 50) return 1.5;
    return 0.0;
  }

  /// يحوّل المجموع (0-100) إلى الدرجة الحرفية.
  static String calculateLetterGrade(double totalScore) {
    if (totalScore >= 90) return 'A+';
    if (totalScore >= 85) return 'A';
    if (totalScore >= 80) return 'B+';
    if (totalScore >= 75) return 'B';
    if (totalScore >= 70) return 'C+';
    if (totalScore >= 65) return 'C';
    if (totalScore >= 60) return 'D+';
    if (totalScore >= 50) return 'D';
    return 'F';
  }

  /// يحسب المعدل التراكمي (GPA) كـ String منسق.
  static String calculateCumulativeGpa(List<CourseGrade> grades) {
    return formatGpa(calculateCumulativeGpaRaw(grades));
  }

  /// يحسب المعدل التراكمي (GPA) كـ double.
  static double calculateCumulativeGpaRaw(List<CourseGrade> grades) {
    if (grades.isEmpty) return 0.0;

    double totalWeighted = 0;
    int totalHours = 0;

    for (final g in grades) {
      if (g.creditHours <= 0) continue;
      totalWeighted += g.percentage * g.creditHours;
      totalHours += g.creditHours;
    }

    if (totalHours == 0) return 0.0;
    return totalWeighted / totalHours;
  }

  /// ينسق المعدل التراكمي إلى رقمين عشريين.
  static String formatGpa(double gpa) {
    return gpa.toStringAsFixed(2);
  }

  /// إجمالي الساعات المعتمدة المكتسبة (gradePoints > 0 = ناجح).
  static int calculateCompletedHours(List<CourseGrade> grades) {
    return grades
        .where((g) => g.gradePoints > 0)
        .fold<int>(0, (acc, g) => acc + g.creditHours);
  }

  // ── Firestore ────────────────────────────────────────────────────────────

  /// Maps `academic_records/{id}` (portal sync) → [CourseGrade] for UI reuse.
  factory CourseGrade.fromAcademicRecord(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    final parts = doc.id.split('_');
    final courseId =
        data['course_id'] as String? ??
        (parts.isNotEmpty ? parts.last : doc.id);
    final courseName = data['course_name_ar'] as String? ?? '';
    final semester = data['semester'] as String? ?? '';
    final gradeRaw = data['grade']?.toString() ?? '';
    final total = _parsePortalGradeToTotal(gradeRaw);

    return CourseGrade(
      courseId: courseId,
      courseName: courseName,
      creditHours: (data['credit_hours'] as num?)?.toInt() ?? 3,
      semester: semester,
      midterm: 0,
      finalExam: total,
      totalScore: total,
      percentage: total, // Since totalScore is out of 100
      gradePoints: calculateGradePoints(total),
      letterGrade:
          data['letter_grade'] as String? ?? calculateLetterGrade(total),
      updatedAt: (data['synced_at'] as Timestamp?)?.toDate(),
    );
  }

  static double _parsePortalGradeToTotal(String raw) {
    final cleaned = raw.replaceAll('%', '').trim();
    final numeric = double.tryParse(cleaned);
    if (numeric != null) return numeric.clamp(0, 100).toDouble();

    switch (cleaned.toUpperCase()) {
      case 'A':
        return 95;
      case 'B+':
        return 87;
      case 'B':
        return 82;
      case 'C+':
        return 77;
      case 'C':
        return 72;
      case 'D+':
        return 67;
      case 'D':
        return 62;
      case 'F':
        return 50;
      default:
        return 0;
    }
  }

  factory CourseGrade.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    final midterm = (data['midterm'] as num?)?.toDouble() ?? 0.0;
    final finalExam = (data['final_exam'] as num?)?.toDouble() ?? 0.0;

    // إذا لم يُخزَّن totalScore، يُحسب تلقائياً
    final total =
        (data['total_score'] as num?)?.toDouble() ??
        (midterm + finalExam).clamp(0, 100).toDouble();

    return CourseGrade(
      courseId: doc.id,
      courseName: data['course_name'] as String? ?? '',
      creditHours: (data['credit_hours'] as num?)?.toInt() ?? 3,
      semester: data['semester'] as String? ?? '',
      midterm: midterm,
      finalExam: finalExam,
      totalScore: total,
      percentage: (data['percentage'] as num?)?.toDouble() ?? total,
      gradePoints:
          (data['grade_points'] as num?)?.toDouble() ??
          calculateGradePoints(total),
      letterGrade:
          data['letter_grade'] as String? ?? calculateLetterGrade(total),
      updatedAt: (data['updated_at'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'course_name': courseName,
      'credit_hours': creditHours,
      'semester': semester,
      'midterm': midterm,
      'final_exam': finalExam,
      'total_score': totalScore,
      'percentage': percentage,
      'grade_points': gradePoints,
      'letter_grade': letterGrade,
      'updated_at': FieldValue.serverTimestamp(),
    };
  }

  @override
  String toString() =>
      'CourseGrade($courseId, $courseName, $letterGrade, gp=$gradePoints)';
}
