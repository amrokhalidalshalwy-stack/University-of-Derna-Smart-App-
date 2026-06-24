import 'package:cloud_firestore/cloud_firestore.dart';

class ScheduleEntry {
  const ScheduleEntry({
    required this.id,
    required this.userUid,
    required this.weekdayIndex,
    required this.startTime,
    required this.endTime,
    required this.courseTitle,
    required this.location,
    required this.instructor,
    this.roomNumber,
    this.building,
    this.semester,
    required this.updatedAtMs,
    // Core identity fields for single source of truth
    this.courseId,
    this.facultyId,
  });

  final String id;
  final String userUid;
  final int weekdayIndex;
  final String startTime;
  final String endTime;
  final String courseTitle;
  final String location;
  final String instructor;
  final String? roomNumber;
  final String? building;
  final String? semester;
  final int updatedAtMs;

  // Core identity fields for single source of truth
  final String? courseId;
  final String? facultyId;

  factory ScheduleEntry.fromFirestore(
    String userUid,
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return ScheduleEntry.fromFirestoreMap(userUid, doc.id, data);
  }

  factory ScheduleEntry.fromFirestoreMap(
    String userUid,
    String id,
    Map<String, dynamic> data,
  ) {
    return ScheduleEntry(
      id: id,
      userUid: userUid,
      weekdayIndex:
          (data['weekdayIndex'] as num?)?.toInt() ??
          (data['dayIndex'] as num?)?.toInt() ??
          0,
      startTime: data['startTime'] as String? ?? data['start'] as String? ?? '',
      endTime: data['endTime'] as String? ?? data['end'] as String? ?? '',
      courseTitle:
          data['courseTitle'] as String? ?? data['title'] as String? ?? '',
      location: data['location'] as String? ?? data['room'] as String? ?? '',
      instructor:
          data['instructor'] as String? ?? data['doctor'] as String? ?? '',
      roomNumber: data['roomNumber'] as String?,
      building: data['building'] as String?,
      semester: data['semester'] as String?,
      updatedAtMs:
          _timestampToMs(data['updatedAt']) ??
          DateTime.now().millisecondsSinceEpoch,
      // Core identity fields for single source of truth
      courseId: data['course_id'] as String?,
      facultyId: data['faculty_id'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'user_id': userUid,
      'weekdayIndex': weekdayIndex,
      'startTime': startTime,
      'endTime': endTime,
      'courseTitle': courseTitle,
      'location': location,
      'instructor': instructor,
      if (roomNumber != null) 'roomNumber': roomNumber,
      if (building != null) 'building': building,
      if (semester != null) 'semester': semester,
      'updatedAt': Timestamp.fromMillisecondsSinceEpoch(updatedAtMs),
      // Core identity fields for single source of truth
      if (courseId != null) 'course_id': courseId,
      if (facultyId != null) 'faculty_id': facultyId,
    };
  }

  factory ScheduleEntry.fromSqliteMap(Map<String, Object?> row) {
    return ScheduleEntry(
      id: row['id']! as String,
      userUid: row['user_uid']! as String,
      weekdayIndex: row['weekday_index'] as int? ?? 0,
      startTime: row['start_time'] as String? ?? '',
      endTime: row['end_time'] as String? ?? '',
      courseTitle: row['course_title'] as String? ?? '',
      location: row['location'] as String? ?? '',
      instructor: row['instructor'] as String? ?? '',
      roomNumber: row['room_number'] as String?,
      building: row['building'] as String?,
      semester: row['semester'] as String?,
      updatedAtMs: row['updated_at'] as int? ?? 0,
    );
  }

  Map<String, Object?> toSqliteMap() {
    return {
      'id': id,
      'user_uid': userUid,
      'weekday_index': weekdayIndex,
      'start_time': startTime,
      'end_time': endTime,
      'course_title': courseTitle,
      'location': location,
      'instructor': instructor,
      'room_number': roomNumber,
      'building': building,
      'semester': semester,
      'updated_at': updatedAtMs,
    };
  }

  static int? _timestampToMs(dynamic value) {
    if (value is Timestamp) return value.millisecondsSinceEpoch;
    return null;
  }
}
