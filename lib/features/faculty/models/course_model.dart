class CourseModel {
  final String courseId;
  final String nameAr;
  final String nameEn;
  final String teacherUid;
  final String facultyId;
  final String departmentId;
  final String semester;
  final int studentCount;
  final List<String> schedule;
  final String room; // ✅ جديد

  const CourseModel({
    required this.courseId,
    required this.nameAr,
    required this.nameEn,
    required this.teacherUid,
    required this.facultyId,
    required this.departmentId,
    required this.semester,
    required this.studentCount,
    required this.schedule,
    this.room = '', // ✅ جديد - قيمة افتراضية فارغة
  });

  factory CourseModel.fromFirestore(
    Map<String, dynamic> data,
    String documentId,
  ) {
    return CourseModel(
      courseId: documentId,
      nameAr: data['name_ar'] ?? data['nameAr'] ?? '',
      nameEn: data['name_en'] ?? data['nameEn'] ?? '',
      teacherUid: data['teacher_id'] ?? data['teacherUid'] ?? '',
      facultyId: data['faculty_id'] ?? data['facultyId'] ?? '',
      departmentId: data['department_id'] ?? data['departmentId'] ?? '',
      semester: data['semester'] ?? '',
      studentCount: data['student_count'] ?? data['studentCount'] ?? 0,
      schedule: List<String>.from(data['schedule'] ?? []),
      room: data['room'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name_ar': nameAr,
      'name_en': nameEn,
      'teacher_id': teacherUid,
      'faculty_id': facultyId,
      'department_id': departmentId,
      'semester': semester,
      'student_count': studentCount,
      'schedule': schedule,
      'room': room,
    };
  }
}