class CourseGrade {
  final String courseId;
  final String courseName;
  final int credits;
  final double midtermGrade;
  final double finalGrade;
  final double totalGrade;
  final String letterGrade;

  const CourseGrade({
    required this.courseId,
    required this.courseName,
    required this.credits,
    required this.midtermGrade,
    required this.finalGrade,
    required this.totalGrade,
    required this.letterGrade,
  });

  factory CourseGrade.fromMap(Map<String, dynamic> map) {
    return CourseGrade(
      courseId: map['course_id'] as String? ?? '',
      courseName: map['course_name'] as String? ?? '',
      credits: map['credits'] as int? ?? 0,
      midtermGrade: (map['midterm_grade'] as num?)?.toDouble() ?? 0.0,
      finalGrade: (map['finalGrade'] as num?)?.toDouble() ?? 0.0,
      totalGrade: (map['total_grade'] as num?)?.toDouble() ?? 0.0,
      letterGrade: map['letter_grade'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'course_id': courseId,
      'course_name': courseName,
      'credits': credits,
      'midterm_grade': midtermGrade,
      'finalGrade': finalGrade,
      'total_grade': totalGrade,
      'letter_grade': letterGrade,
    };
  }
}
