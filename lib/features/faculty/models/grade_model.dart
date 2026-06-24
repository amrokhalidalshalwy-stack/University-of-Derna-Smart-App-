class GradeModel {
  final String studentUid;
  final String courseId;
  final double midterm;
  final double finalExam;
  final double assignments;

  double get total => midterm + finalExam + assignments;

  const GradeModel({
    required this.studentUid,
    required this.courseId,
    this.midterm = 0.0,
    this.finalExam = 0.0,
    this.assignments = 0.0,
  });

  factory GradeModel.fromFirestore(
    Map<String, dynamic> data,
    String studentUid,
  ) {
    return GradeModel(
      studentUid: data['student_id'] ?? studentUid,
      courseId: data['course_id'] ?? '',
      midterm: (data['midterm'] ?? 0.0).toDouble(),
      finalExam: (data['final_exam'] ?? data['final_exam'] ?? 0.0).toDouble(),
      assignments: (data['assignments'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'student_id': studentUid,
      'course_id': courseId,
      'midterm': midterm,
      'final_exam': finalExam,
      'assignments': assignments,
      'total': total,
    };
  }

  GradeModel copyWith({
    double? midterm,
    double? finalExam,
    double? assignments,
  }) {
    return GradeModel(
      studentUid: studentUid,
      courseId: courseId,
      midterm: midterm ?? this.midterm,
      finalExam: finalExam ?? this.finalExam,
      assignments: assignments ?? this.assignments,
    );
  }
}
