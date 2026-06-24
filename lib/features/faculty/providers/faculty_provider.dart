import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_project/features/auth/data/auth_service.dart';
import 'package:flutter_project/features/faculty/models/course_model.dart';
import 'package:flutter_project/features/faculty/models/attendance_model.dart';
import 'package:flutter_project/features/faculty/models/grade_model.dart';
import 'package:flutter_project/core/models/user_profile.dart';

class FacultyCoursesNotifier extends AsyncNotifier<List<CourseModel>> {
  @override
  Future<List<CourseModel>> build() async {
    final user = ref.watch(authStateChangesProvider).value;
    if (user == null) return [];

    final snapshot =
        await FirebaseFirestore.instance
            .collection('courses')
            .where('assigned_professors', arrayContains: user.uid)
            .get();

    return snapshot.docs
        .map((doc) => CourseModel.fromFirestore(doc.data(), doc.id))
        .toList();
  }
}

final facultyCoursesProvider =
    AsyncNotifierProvider<FacultyCoursesNotifier, List<CourseModel>>(() {
      return FacultyCoursesNotifier();
    });

class AttendanceNotifier extends AsyncNotifier<List<AttendanceModel>> {
  @override
  Future<List<AttendanceModel>> build() async {
    return [];
  }

  Future<void> loadAttendance(String courseId, String date) async {
    state = const AsyncValue.loading();
    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('attendance')
              .where('course_id', isEqualTo: courseId)
              .where('date', isEqualTo: date)
              .get();

      final records =
          snapshot.docs
              .map(
                (doc) => AttendanceModel.fromFirestore(
                  doc.data(),
                  doc.data()['student_id'] ?? '',
                ),
              )
              .toList();
      state = AsyncValue.data(records);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> saveAttendance(
    String courseId,
    String date,
    String studentUid,
    bool isPresent,
  ) async {
    final docId = '${date}_$studentUid';
    await FirebaseFirestore.instance.collection('attendance').doc(docId).set({
      'student_id': studentUid,
      'course_id': courseId,
      'date': date,
      'is_present': isPresent,
    }, SetOptions(merge: true));

    final currentState = state.value ?? [];
    final existingIndex = currentState.indexWhere(
      (a) => a.studentUid == studentUid && a.date == date,
    );
    if (existingIndex >= 0) {
      currentState[existingIndex] = currentState[existingIndex].copyWith(
        isPresent: isPresent,
      );
    } else {
      currentState.add(
        AttendanceModel(
          studentUid: studentUid,
          courseId: courseId,
          date: date,
          isPresent: isPresent,
        ),
      );
    }
    state = AsyncValue.data(List.from(currentState));
  }
}

final attendanceProvider =
    AsyncNotifierProvider<AttendanceNotifier, List<AttendanceModel>>(() {
      return AttendanceNotifier();
    });

class AnnouncementsNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> addAnnouncement(String courseId, String title, String message) async {
    final user = ref.watch(authStateChangesProvider).value;
    if (user == null) return;
    
    await FirebaseFirestore.instance.collection('announcements').add({
      'course_id': courseId,
      'faculty_id': user.uid,
      'title': title,
      'message': message,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteAnnouncement(
    String courseId,
    String announcementId,
  ) async {
    await FirebaseFirestore.instance
        .collection('announcements')
        .doc(announcementId)
        .delete();
  }
}

final announcementsProvider =
    AsyncNotifierProvider<AnnouncementsNotifier, void>(() {
      return AnnouncementsNotifier();
    });

class GradesNotifier extends AsyncNotifier<List<GradeModel>> {
  @override
  Future<List<GradeModel>> build() async {
    return [];
  }

  Future<void> loadGrades(String courseId) async {
    state = const AsyncValue.loading();
    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('grades')
              .where('course_id', isEqualTo: courseId)
              .get();

      final grades =
          snapshot.docs
              .map((doc) => GradeModel.fromFirestore(doc.data(), doc.id))
              .toList();
      state = AsyncValue.data(grades);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> saveGrade(
    String courseId,
    String studentUid, {
    double? midterm,
    double? finalExam,
    double? assignments,
  }) async {
    // Strict range validation boundaries
    if (midterm != null && (midterm < 0 || midterm > 40)) {
      throw ArgumentError('Midterm out of range: $midterm');
    }
    if (finalExam != null && (finalExam < 0 || finalExam > 40)) {
      throw ArgumentError('Final out of range: $finalExam');
    }
    if (assignments != null && (assignments < 0 || assignments > 20)) {
      throw ArgumentError('Assignments out of range: $assignments');
    }

    final docId = '${courseId}_$studentUid';
    final docRef = FirebaseFirestore.instance.collection('grades').doc(docId);

    final docSnap = await docRef.get();
    GradeModel grade;
    if (docSnap.exists) {
      final existing = GradeModel.fromFirestore(docSnap.data()!, studentUid);
      grade = existing.copyWith(
        midterm: midterm,
        finalExam: finalExam,
        assignments: assignments,
      );
    } else {
      grade = GradeModel(
        studentUid: studentUid,
        courseId: courseId,
        midterm: midterm ?? 0.0,
        finalExam: finalExam ?? 0.0,
        assignments: assignments ?? 0.0,
      );
    }

    await docRef.set(grade.toFirestore(), SetOptions(merge: true));

    final currentState = state.value ?? [];
    final index = currentState.indexWhere((g) => g.studentUid == studentUid);
    if (index >= 0) {
      currentState[index] = grade;
    } else {
      currentState.add(grade);
    }
    state = AsyncValue.data(List.from(currentState));
  }
}

final gradesProvider = AsyncNotifierProvider<GradesNotifier, List<GradeModel>>(
  () {
    return GradesNotifier();
  },
);

final classStudentsProvider =
    FutureProvider.family<List<UserProfile>, CourseModel>((ref, course) async {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .where('role', isEqualTo: 'student')
              .where('faculty_id', isEqualTo: course.facultyId)
              .where('department_id', isEqualTo: course.departmentId)
              .get();

      return snapshot.docs
          .map((doc) => UserProfile.fromFirestore(doc))
          .toList();
    });
