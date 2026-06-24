import 'package:flutter_project/features/transcript/data/models/course_grade.dart';

class SemesterRecord {
  final String semesterId;
  final String semesterName;
  final double semesterGpa;
  final double cumulativeGpa;
  final int totalCredits;
  final List<CourseGrade> courses;

  const SemesterRecord({
    required this.semesterId,
    required this.semesterName,
    required this.semesterGpa,
    required this.cumulativeGpa,
    required this.totalCredits,
    required this.courses,
  });

  factory SemesterRecord.fromMap(Map<String, dynamic> map, String id) {
    return SemesterRecord(
      semesterId: id,
      semesterName: map['semesterName'] as String? ?? '',
      semesterGpa: (map['semesterGpa'] as num?)?.toDouble() ?? 0.0,
      cumulativeGpa: (map['cumulativeGpa'] as num?)?.toDouble() ?? 0.0,
      totalCredits: map['totalCredits'] as int? ?? 0,
      courses: (map['courses'] as List<dynamic>?)
              ?.map((e) => CourseGrade.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'semesterName': semesterName,
      'semesterGpa': semesterGpa,
      'cumulativeGpa': cumulativeGpa,
      'totalCredits': totalCredits,
      'courses': courses.map((e) => e.toMap()).toList(),
    };
  }
}
