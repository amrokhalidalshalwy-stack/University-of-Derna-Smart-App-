import 'package:cloud_firestore/cloud_firestore.dart';

/// IntegrationService manages all crossâ€‘portal Firestore operations using
/// WriteBatch. Every write is mirrored to the relevant student collection and
/// aggregated stats are updated. All operations are wrapped in try/catch and
/// errors are expected to be shown via Arabic SnackBar in UI layers.
class IntegrationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // â”€â”€ BRIDGE 1: Attendance â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Future<void> saveAttendanceSession({
    required String courseId,
    required String courseName,
    required String professorId,
    required String semester,
    required String sessionDate, // "yyyy-MM-dd"
    required int weekNumber,
    required List<Map<String, dynamic>> students,
    // [{studentId, studentName, studentNumber, status}]
    required List<Map<String, dynamic>> lectureFiles,
  }) async {
    final batch = _db.batch();

    // Compute summary
    int present = students.where((s) => s['status'] == 'present').length;
    int late = students.where((s) => s['status'] == 'late').length;
    int absent = students.where((s) => s['status'] == 'absent').length;
    double rate =
        students.isEmpty ? 0 : (present + late) / students.length * 100;

    // WRITE: Flat Collection attendance
    for (final student in students) {
      final studentId = student['student_id'] as String;
      final status = student['status'] as String?;
      final isPresent = status == 'present' || status == 'late';

      DateTime parsedDate;
      try {
        parsedDate = DateTime.parse(sessionDate);
      } catch (_) {
        parsedDate = DateTime.now();
      }

      final docId = '${studentId}_${courseId}_$sessionDate';
      final studentAttendanceRef = _db.collection('attendance').doc(docId);

      batch.set(studentAttendanceRef, {
        'student_id': studentId,
        'course_id': courseId,
        'course_name': courseName,
        'is_present': isPresent,
        'session_date': Timestamp.fromDate(parsedDate),
        'semester': semester,
        'recorded_by': professorId,
        'recorded_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    // UPDATE courses/{courseId}.weeklyAttendanceRate
    final courseRef = _db.collection('courses').doc(courseId);
    batch.update(courseRef, {
      'weeklyAttendanceRate': rate,
      'lastAttendanceSession': FieldValue.serverTimestamp(),
    });

    await batch.commit();

    // Log the action
    await _logAction(
      action: 'record_attendance',
      userId: professorId,
      courseId: courseId,
      details: {
        'sessionDate': sessionDate,
        'presentCount': present,
        'absentCount': absent,
        'totalCount': students.length,
      },
    );
  }

  // ØªÙ… ØªØ¹Ø·ÙŠÙ„ Ù‡Ø°Ù‡ Ø§Ù„Ø¯Ø§Ù„Ø© Ø¨Ù†Ø§Ø¡Ù‹ Ø¹Ù„Ù‰ Ø§Ù„Ù‡ÙŠÙƒÙ„ Ø§Ù„Ù…Ø³Ø·Ø­ Ø§Ù„Ø¬Ø¯ÙŠØ¯ (Flat Collection)
  /*
  Future<void> _recalculateAttendancePercentages(
    String courseId,
    List<Map<String, dynamic>> students,
  ) async {
    // ...
  }
  */

  // â”€â”€ BRIDGE 2: Grades â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  /// التحقق من صحة الدرجة قبل الحفظ
  bool _isValidScore(double score, {double max = 100.0}) {
    return score >= 0.0 && score <= max && !score.isNaN && !score.isInfinite;
  }

  /// التحقق من صحة بيانات الطالب قبل الحفظ
  bool _validateGradeData({
    required double midterm,
    required double finalExam,
    required double maxMidterm,
    required double maxFinal,
  }) {
    return _isValidScore(midterm, max: maxMidterm) &&
           _isValidScore(finalExam, max: maxFinal) &&
           (midterm + finalExam) <= 100.0;
  }

  Future<void> saveStudentGrades({
    required String courseId,
    required String courseName,
    required String professorId,
    required String professorName,
    required String semester,
    required String academicYear,
    required String studentId,
    required String studentName,
    required String studentNumber,
    required double? courseworkScore,
    required double? midtermScore,
    required double? finalScore,
    required double maxCoursework,
    required double maxMidterm,
    required double maxFinal,
  }) async {
    if (!_validateGradeData(
      midterm: (courseworkScore ?? 0) + (midtermScore ?? 0),
      finalExam: finalScore ?? 0,
      maxMidterm: maxCoursework + maxMidterm,
      maxFinal: maxFinal,
    )) {
      throw Exception('❌ بيانات الدرجات غير صالحة — تم رفض الحفظ');
    }

    final batch = _db.batch();

    // Compute total & letter grade
    final totalScore =
        (courseworkScore ?? 0) + (midtermScore ?? 0) + (finalScore ?? 0);
    final gradeInfo = _calculateGradeFromScore(totalScore);

    // WRITE 1: grades (Flat Collection)
    final gradeRef = _db.collection('grades').doc('${courseId}_$studentId');

    batch.set(gradeRef, {
      'student_id': studentId,
      'course_id': courseId,
      'course_name': courseName,
      'semester': semester,
      'midterm': midtermScore,
      'final_exam': finalScore,
      'total_score': totalScore,
      'percentage': gradeInfo['percentage'],
      'letter_grade': gradeInfo['letter_grade'],
      'grade_points': gradeInfo['grade_points'],
      'grade_label': gradeInfo['grade_label'],
      'recorded_by': professorId,
      'recorded_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await batch.commit();

    // WRITE 2 (POST-BATCH): recalculate student GPA
    await _recalculateStudentGPA(studentId);

    // WRITE 3: update course gradingStats
    await _updateCourseGradingStats(courseId);

    // Log
    await _logAction(
      action: 'enter_grades',
      userId: professorId,
      courseId: courseId,
      details: {
        'student_id': studentId,
        'total': totalScore,
        'letter_grade': gradeInfo['letter_grade'],
      },
    );
  }

  Future<void> _recalculateStudentGPA(String studentId) async {
    final gradesSnap =
        await _db
            .collection('grades')
            .where('student_id', isEqualTo: studentId)
            .get();

    final gradesData = <Map<String, dynamic>>[];
    
    for (final doc in gradesSnap.docs) {
      final data = doc.data();
      final courseId = data['course_id'] as String? ?? doc.id.split('_').first;
      
      final courseSnap = await _db.collection('courses').doc(courseId).get();
      final credits =
          (courseSnap.data()?['credits'] as num?)?.toDouble() ?? 3.0;

      gradesData.add({
        'percentage': data['percentage'] ?? 0.0,
        'credits': credits,
      });
    }

    final cumulativeGPA = _calculateCumulativeGPA(gradesData);

    await _db.collection('users').doc(studentId).update({
      'gpa': cumulativeGPA,
      'gpa_display': '$cumulativeGPA%',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _updateCourseGradingStats(String courseId) async {
    final studentsSnap =
        await _db
            .collection('grades')
            .where('course_id', isEqualTo: courseId)
            .get();

    final total = studentsSnap.docs.length;
    int gradedCoursework = 0, gradedMidterm = 0, gradedFinal = 0;

    for (final doc in studentsSnap.docs) {
      final data = doc.data();
      final midterm = data['midterm'];
      final finalExam = data['final_exam'];
      final coursework = data['coursework']; // If you store coursework in the future

      if (coursework != null) {
        gradedCoursework++;
      }
      if (midterm != null) {
        gradedMidterm++;
      }
      if (finalExam != null) gradedFinal++;
    }

    final minGraded = [
      gradedCoursework,
      gradedMidterm,
      gradedFinal,
    ].reduce((a, b) => a < b ? a : b);
    final completion = total == 0 ? 0.0 : minGraded / total * 100;

    await _db.collection('courses').doc(courseId).update({
      'gradingStats.totalStudents': total,
      'gradingStats.gradedCoursework': gradedCoursework,
      'gradingStats.gradedMidterm': gradedMidterm,
      'gradingStats.gradedFinal': gradedFinal,
      'gradingStats.fullyGraded': minGraded,
      'gradingStats.completionPercentage': completion,
    });
  }

  // â”€â”€ BRIDGE 3: Course Announcements â†’ Students â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Future<void> createCourseAnnouncement({
    required String courseId,
    required String courseName,
    required String professorId,
    required String professorName,
    required String title,
    required String body,
    required String targetGroup, // 'all' | 'groupA' | 'groupB' | 'struggling'
  }) async {
    // Resolve target student IDs from course document
    final courseSnap = await _db.collection('courses').doc(courseId).get();
    final courseData = courseSnap.data() ?? {};

    List<String> targetStudentIds;
    switch (targetGroup) {
      case 'groupA':
        targetStudentIds = List<String>.from(courseData['groupA'] ?? []);
        break;
      case 'groupB':
        targetStudentIds = List<String>.from(courseData['groupB'] ?? []);
        break;
      case 'struggling':
        targetStudentIds = List<String>.from(
          courseData['strugglingStudents'] ?? [],
        );
        break;
      default: // 'all'
        targetStudentIds = List<String>.from(courseData['students'] ?? []);
    }

    String targetLabel = 'Ø§Ù„Ø¬Ù…ÙŠØ¹';
    if (targetGroup == 'struggling') targetLabel = 'Ø§Ù„Ù…ØªØ¹Ø«Ø±ÙŠÙ†';
    if (targetGroup == 'groupA') targetLabel = 'Ù…Ø¬Ù…ÙˆØ¹Ø© Ø£';
    if (targetGroup == 'groupB') targetLabel = 'Ù…Ø¬Ù…ÙˆØ¹Ø© Ø¨';

    final text = '[$targetLabel] $title\n$body';

    await _db.collection('announcements').add({
      'course_id': courseId,
      'text': text,
      'course_name': courseName,
      'professorId': professorId,
      'professorName': professorName,
      'targetGroup': targetGroup,
      'targetStudentIds': targetStudentIds,
      'totalTargeted': targetStudentIds.length,
      'views': [],
      'viewCount': 0,
      'readReceipts': [],
      'readCount': 0,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'timestamp': FieldValue.serverTimestamp(),
    });

    await _logAction(
      action: 'send_announcement',
      userId: professorId,
      courseId: courseId,
      details: {
        'targetGroup': targetGroup,
        'targetCount': targetStudentIds.length,
        'title': title,
      },
    );
  }

  // â”€â”€ BRIDGE 3b: Student marks announcement as viewed â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Future<void> markAnnouncementViewed({
    required String announcementId,
    required String studentId,
  }) async {
    final ref = _db.collection('announcements').doc(announcementId);
    final snap = await ref.get();
    if (!snap.exists) return;

    final data = snap.data()!;
    final views = List<Map<String, dynamic>>.from(data['views'] ?? []);
    final alreadyViewed = views.any((v) => v['student_id'] == studentId);
    if (alreadyViewed) return;

    await ref.update({
      'views': FieldValue.arrayUnion([
        {'student_id': studentId, 'viewedAt': Timestamp.now()},
      ]),
      'viewCount': FieldValue.increment(1),
    });
  }

  // â”€â”€ BRIDGE 3c: Student confirms receipt â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Future<void> confirmAnnouncementReceipt({
    required String announcementId,
    required String studentId,
    required String studentName,
  }) async {
    await _db.collection('announcements').doc(announcementId).update({
      'readReceipts': FieldValue.arrayUnion([
        {
          'student_id': studentId,
          'studentName': studentName,
          'confirmedAt': Timestamp.now(),
        },
      ]),
      'readCount': FieldValue.increment(1),
    });
  }

  // â”€â”€ BRIDGE 4: Excuse Request â€” Student â†’ Professor â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Future<void> submitAbsenceExcuse({
    required String studentId,
    required String studentName,
    required String studentNumber,
    required String courseId,
    required String courseName,
    required String professorId,
    required DateTime absenceDate,
    required String reason,
    String? attachmentUrl,
    String? attachmentType,
  }) async {
    await _db.collection('student_requests').add({
      'student_id': studentId,
      'type': 'absence_excuse',
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'details': {
        'studentName': studentName,
        'studentNumber': studentNumber,
        'course_id': courseId,
        'course_name': courseName,
        'professorId': professorId,
        'absenceDate': Timestamp.fromDate(absenceDate),
        'reason': reason,
        'attachmentUrl': attachmentUrl,
        'attachmentType': attachmentType,
      },
    });
  }

  // â”€â”€ BRIDGE 4b: Professor approves/rejects excuse â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Future<void> reviewAbsenceExcuse({
    required String requestId,
    required String reviewerId,
    required String reviewerName,
    required String newStatus, // 'approved' | 'rejected'
    required String? reviewNotes,
    // Pass these only when approved, to fix attendance
    String? studentId,
    String? courseId,
  }) async {
    final batch = _db.batch();

    // WRITE 1: update request status
    final requestRef = _db.collection('student_requests').doc(requestId);
    batch.update(requestRef, {
      'status': newStatus,
      'updatedAt': FieldValue.serverTimestamp(),
      if (reviewNotes != null) 'adminNote': reviewNotes,
      'details.reviewedBy': reviewerId,
      'details.reviewerName': reviewerName,
      'details.reviewedAt': FieldValue.serverTimestamp(),
    });

    // WRITE 2: if approved â†’ fix student attendance record
    if (newStatus == 'approved' && studentId != null && courseId != null) {
      final summaryRef = _db
          .collection('attendance')
          .doc(studentId)
          .collection('summary')
          .doc(courseId);

      batch.update(summaryRef, {
        'absentSessions': FieldValue.increment(-1),
        'attendedSessions': FieldValue.increment(1),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();

    // Postâ€‘batch: recalculate attendance percentage
    if (newStatus == 'approved' && studentId != null && courseId != null) {
      final snap =
          await _db
              .collection('attendance')
              .doc(studentId)
              .collection('summary')
              .doc(courseId)
              .get();

      if (snap.exists) {
        final data = snap.data()!;
        final total = (data['totalSessions'] ?? 0) as int;
        final attended = (data['attendedSessions'] ?? 0) as int;
        final late = (data['lateSessions'] ?? 0) as int;
        final percentage = total == 0 ? 0.0 : (attended + late) / total * 100;

        await snap.reference.update({
          'attendancePercentage': percentage,
          'isAtRisk': percentage < 75.0,
        });
      }
    }

    await _logAction(
      action: 'review_excuse',
      userId: reviewerId,
      courseId: courseId,
      details: {'requestId': requestId, 'decision': newStatus},
    );
  }

  // â”€â”€ BRIDGE 5: Update struggling students list â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // Call this after saving grades to keep the targeting list fresh
  Future<void> updateStrugglingStudents(String courseId) async {
    final gradesSnap =
        await _db
            .collection('grades')
            .where('course_id', isEqualTo: courseId)
            .get();

    final struggling =
        gradesSnap.docs
            .where((doc) => (doc.data()['percentage'] as num? ?? 100) < 50)
            .map((doc) => doc.data()['student_id'] as String)
            .toList();

    await _db.collection('courses').doc(courseId).update({
      'strugglingStudents': struggling,
    });
  }

  /// ÙŠØ­ÙˆÙ‘Ù„ Ù…Ø¬Ù…ÙˆØ¹ Ø§Ù„Ø¯Ø±Ø¬Ø§Øª (Ù…Ù† 100) Ø¥Ù„Ù‰ Ù†Ø³Ø¨Ø© Ù…Ø¦ÙˆÙŠØ© Ù…Ø¹ Ø§Ù„ØªÙ‚Ø¯ÙŠØ± Ø§Ù„Ø­Ø±ÙÙŠ
  Map<String, dynamic> _calculateGradeFromScore(double totalScore) {
    final percentage = totalScore.clamp(0.0, 100.0);
    
    String letterGrade;
    double gradePoints;
    String gradeLabel;

    if (percentage >= 90) {
      letterGrade = 'A+'; gradePoints = 4.0; gradeLabel = 'Ù…Ù…ØªØ§Ø²';
    } else if (percentage >= 85) {
      letterGrade = 'A';  gradePoints = 3.7; gradeLabel = 'Ù…Ù…ØªØ§Ø²';
    } else if (percentage >= 80) {
      letterGrade = 'B+'; gradePoints = 3.3; gradeLabel = 'Ø¬ÙŠØ¯ Ø¬Ø¯Ø§Ù‹';
    } else if (percentage >= 75) {
      letterGrade = 'B';  gradePoints = 3.0; gradeLabel = 'Ø¬ÙŠØ¯ Ø¬Ø¯Ø§Ù‹';
    } else if (percentage >= 70) {
      letterGrade = 'C+'; gradePoints = 2.7; gradeLabel = 'Ø¬ÙŠØ¯';
    } else if (percentage >= 65) {
      letterGrade = 'C';  gradePoints = 2.3; gradeLabel = 'Ø¬ÙŠØ¯';
    } else if (percentage >= 60) {
      letterGrade = 'D+'; gradePoints = 2.0; gradeLabel = 'Ù…Ù‚Ø¨ÙˆÙ„';
    } else if (percentage >= 50) {
      letterGrade = 'D';  gradePoints = 1.5; gradeLabel = 'Ù…Ù‚Ø¨ÙˆÙ„';
    } else {
      letterGrade = 'F';  gradePoints = 0.0; gradeLabel = 'Ø±Ø§Ø³Ø¨';
    }

    return {
      'percentage': double.parse(percentage.toStringAsFixed(1)),
      'letter_grade': letterGrade,
      'grade_points': gradePoints,
      'grade_label': gradeLabel,
    };
  }

  /// ÙŠØ­Ø³Ø¨ Ø§Ù„Ù…Ø¹Ø¯Ù„ Ø§Ù„ØªØ±Ø§ÙƒÙ…ÙŠ ÙƒÙ†Ø³Ø¨Ø© Ù…Ø¦ÙˆÙŠØ© Ù…Ø±Ø¬Ù‘Ø­Ø© Ø¨Ø§Ù„Ø³Ø§Ø¹Ø§Øª Ø§Ù„Ù…Ø¹ØªÙ…Ø¯Ø©
  double _calculateCumulativeGPA(List<Map<String, dynamic>> gradesData) {
    double totalWeightedPercentage = 0;
    double totalCredits = 0;

    for (final grade in gradesData) {
      final percentage = (grade['percentage'] as num?)?.toDouble() ?? 0.0;
      final credits = (grade['credits'] as num?)?.toDouble() ?? 3.0;
      totalWeightedPercentage += percentage * credits;
      totalCredits += credits;
    }

    if (totalCredits == 0) return 0.0;
    return double.parse(
      (totalWeightedPercentage / totalCredits).toStringAsFixed(1)
    );
  }

  // â”€â”€ Helper: System Log â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Future<void> _logAction({
    required String action,
    required String userId,
    String? courseId,
    Map<String, dynamic>? details,
  }) async {
    String detailString = courseId != null ? 'Course: $courseId' : 'Professor Action';
    if (details != null && details.isNotEmpty) {
      detailString += ' - ${details.toString()}';
    }

    await _db.collection('activityLogs').add({
      'action': action,
      'adminUid': userId, // The professor performing the action
      'targetUid': details?['student_id'] as String?,
      'detail': detailString,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
