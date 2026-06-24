import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_project/features/requests/data/student_request_model.dart';

class RequestsRepository {
  final FirebaseFirestore _firestore;

  RequestsRepository({required FirebaseFirestore firestore})
    : _firestore = firestore;

  Stream<List<StudentRequest>> getUserRequests(String uid) {
    return _firestore
        .collection('student_requests')
        .where('student_id', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => StudentRequest.fromFirestore(doc))
              .toList();
        });
  }

  Future<void> submitRequest(StudentRequest request) async {
    final docRef = _firestore.collection('student_requests').doc();
    final requestWithId = request.copyWith(
      id: docRef.id,
      createdAt: FieldValue.serverTimestamp() as Timestamp,
      updatedAt: FieldValue.serverTimestamp() as Timestamp,
    );

    await docRef.set(requestWithId.toFirestore());
  }

  Future<void> cancelRequest(String requestId) async {
    await _firestore.collection('student_requests').doc(requestId).delete();
  }
}
