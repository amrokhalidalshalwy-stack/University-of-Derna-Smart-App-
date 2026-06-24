import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter_project/core/models/app_notification.dart';
import 'package:flutter_project/core/models/course_enrollment.dart';
import 'package:flutter_project/core/models/course_grade.dart';

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// DatabaseService
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
//
// Central service for all student-related Firestore queries.
//
// Proposed Firestore Structure:
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// users/{uid}                      â† Profile data (gpa, completedHours â€¦)
//   â””â”€â”€ enrollments/{courseId}     â† Enrolled courses
//   â””â”€â”€ grades/{courseId}          â† Grades for each course
//   â””â”€â”€ attendance/{courseId}      â† Attendance/Absence records
//   â””â”€â”€ notifications/{notifId}    â† Student notifications
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
//
// Firestore Security Rules (add this to firestore.rules):
//   match /users/{uid} {
//     allow read, write: if request.auth.uid == uid;
//     match /{subcollection}/{docId} {
//       allow read, write: if request.auth.uid == uid;
//     }
//   }
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class DatabaseService {
  DatabaseService(this._firestore);

  final FirebaseFirestore _firestore;

  // â”€â”€ Helper for student subcollections â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  CollectionReference<Map<String, dynamic>> _sub(
    String uid,
    String collection,
  ) => _firestore.collection('users').doc(uid).collection(collection);

  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  // Enrolled Courses (Enrollments)
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

  /// Stream returns active enrolled courses for student [uid].
  /// Updates immediately on any Firestore change (delete/add/update).
  Stream<List<CourseEnrollment>> watchEnrollments(String uid) {
    return _sub(uid, 'enrollments')
        .where('status', isEqualTo: 'active')
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map(CourseEnrollment.fromFirestore).toList()
                ..sort((a, b) => a.courseName.compareTo(b.courseName)),
        );
  }

  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  // Grades
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

  /// Stream returns all grades for student [uid] sorted by semester descending.
  Stream<List<CourseGrade>> watchGrades(String uid) {
    return _firestore
        .collection('grades')
        .where('student_id', isEqualTo: uid)
        .snapshots()
        .map((snap) {
          return snap.docs.map((doc) => CourseGrade.fromFirestore(doc)).toList();
        });
  }

  /// Stream returns grades for a specific semester.
  Stream<List<CourseGrade>> watchGradesBySemester(String uid, String semester) {
    return _firestore
        .collection('grades')
        .where('student_id', isEqualTo: uid)
        .where('semester', isEqualTo: semester)
        .snapshots()
        .map((snap) => snap.docs.map(CourseGrade.fromFirestore).toList());
  }

  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  // Attendance & Absences
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

  Stream<List<AttendanceSummary>> watchAttendance(String uid) {
    return _firestore
        .collection('attendance')
        .where('student_id', isEqualTo: uid)
        .snapshots()
        .map((snap) {
          final Map<String, AttendanceSummary> summaries = {};
          for (var doc in snap.docs) {
            final data = doc.data();
            final courseId = data['course_id'] as String? ?? 'unknown';
            final isPresent = data['is_present'] as bool? ?? false;
            
            if (!summaries.containsKey(courseId)) {
              summaries[courseId] = AttendanceSummary(
                courseId: courseId,
                courseName: data['course_name'] ?? courseId,
                semester: data['semester'] ?? 'N/A',
                totalLectures: 0,
                attendedLectures: 0,
              );
            }
            
            final current = summaries[courseId]!;
            summaries[courseId] = AttendanceSummary(
              courseId: current.courseId,
              courseName: current.courseName,
              semester: current.semester,
              totalLectures: current.totalLectures + 1,
              attendedLectures: current.attendedLectures + (isPresent ? 1 : 0),
            );
          }
          final list = summaries.values.toList();
          list.sort((a, b) => a.courseName.compareTo(b.courseName));
          return list;
        });
  }

  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  // GPA Auto-Compute & Save
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

  /// Recomputes GPA and completed hours from a grades list then saves it
  /// directly to `users/{uid}` to keep local cache in sync.
  ///
  /// Call this function after any modification to student grades.
  Future<void> recomputeAndSaveGpa(String uid, List<CourseGrade> grades) async {
    final gpa = CourseGrade.calculateCumulativeGpa(grades);
    final completedHours =
        CourseGrade.calculateCompletedHours(grades).toString();

    await _firestore.collection('users').doc(uid).update({
      'gpa': gpa,
      'completedHours': completedHours,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  // Notifications
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

  /// Stream returns the last [limit] live notifications for student [uid].
  Stream<List<AppNotification>> watchNotifications(
    String uid, {
    int limit = 5,
  }) {
    return _sub(uid, 'notifications')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snap) =>
              snap.docs
                  .map((doc) => AppNotification.fromFirestore(uid, doc))
                  .toList(),
        );
  }

  /// Marks a notification as read.
  Future<void> markNotificationRead(String uid, String notificationId) async {
    await _sub(
      uid,
      'notifications',
    ).doc(notificationId).update({'read': true, 'isRead': true});
  }

  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
  // Seed/Mock Data
  // â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

  /// Seeds Firestore with mock student data using atomic WriteBatch.
  ///
  /// After committing the batch, automatically fetches the grades from Firestore
  /// and triggers [recomputeAndSaveGpa] to compute and save cumulative GPA
  /// and completed hours to `users/{uid}`.
  ///
  /// Firestore paths:
  /// - Grades: `users/{uid}/grades/{courseId}`
  /// - Attendance: `users/{uid}/attendance/{courseId}`
  Future<void> seedStudentData(String uid) async {
    // Deleted mock seeder for digital integrity.
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// AttendanceSummary (Placed here as it is exclusively linked to DatabaseService)
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
//
// Firestore path: `users/{uid}/attendance/{courseId}`
//
// Required fields in Firebase:
// ```
// courseName        : String  â€” Course Name
// semester          : String  â€” Semester
// totalLectures     : number  â€” Total Lectures
// attendedLectures  : number  â€” Attended Lectures
// updatedAt         : Timestamp
// ```

class AttendanceSummary {
  const AttendanceSummary({
    required this.courseId,
    required this.courseName,
    required this.semester,
    required this.totalLectures,
    required this.attendedLectures,
  });

  final String courseId;
  final String courseName;
  final String semester;
  final int totalLectures;
  final int attendedLectures;

  /// Number of absences
  int get absences => totalLectures - attendedLectures;

  /// Attendance percentage (0-100)
  double get attendancePercentage =>
      totalLectures == 0 ? 100 : (attendedLectures / totalLectures) * 100;

  /// Student is at risk if attendance rate is below 75%
  bool get isAtRisk => attendancePercentage < 75;

  factory AttendanceSummary.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return AttendanceSummary(
      courseId: doc.id,
      courseName: data['course_name'] ?? data['course_name'] as String? ?? '',
      semester: data['semester'] as String? ?? '',
      totalLectures: (data['total_lectures'] as num?)?.toInt() ?? (data['totalLectures'] as num?)?.toInt() ?? 0,
      attendedLectures: (data['attended_lectures'] as num?)?.toInt() ?? (data['attendedLectures'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'course_name': courseName,
      'semester': semester,
      'total_lectures': totalLectures,
      'attended_lectures': attendedLectures,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
