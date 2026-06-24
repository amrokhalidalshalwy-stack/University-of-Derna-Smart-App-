class AttendanceModel {
  final String studentUid;
  final String courseId;
  final String date;
  final bool isPresent;

  const AttendanceModel({
    required this.studentUid,
    required this.courseId,
    required this.date,
    required this.isPresent,
  });

  factory AttendanceModel.fromFirestore(
    Map<String, dynamic> data,
    String studentUid,
  ) {
    return AttendanceModel(
      studentUid: data['student_id'] ?? studentUid,
      courseId: data['course_id'] ?? '',
      date: data['date'] ?? '',
      isPresent: data['is_present'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'student_id': studentUid,
      'course_id': courseId,
      'date': date,
      'is_present': isPresent,
    };
  }

  AttendanceModel copyWith({bool? isPresent}) {
    return AttendanceModel(
      studentUid: studentUid,
      courseId: courseId,
      date: date,
      isPresent: isPresent ?? this.isPresent,
    );
  }
}
