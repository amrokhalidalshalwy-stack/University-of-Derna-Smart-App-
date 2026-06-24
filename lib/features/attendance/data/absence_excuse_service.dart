import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AbsenceExcuseService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  AbsenceExcuseService({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  Future<void> submitAbsenceExcuse({
    required String professorId,
    required String courseId,
    required String courseName,
    required DateTime absenceDate,
    required String reason,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw Exception('User not logged in');
    }

    final userDoc = await _firestore.collection('users').doc(uid).get();
    final studentName = userDoc.exists ? (userDoc.data()?['name'] ?? 'Unknown') : 'Unknown';

    await _firestore.collection('student_requests').add({
      'student_id': uid,
      'type': 'absence_excuse',
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'details': {
        'studentName': studentName,
        'professorId': professorId,
        'course_id': courseId,
        'course_name': courseName,
        'absenceDate': Timestamp.fromDate(absenceDate),
        'reason': reason,
        'attachmentUrl': null,
      },
    });
  }
}
