import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> getUserRole() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return 'guest';
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.data()?['role'] as String? ?? 'student';
  }

  Future<bool> isAdmin() async => await getUserRole() == 'admin';
  Future<bool> isFaculty() async => await getUserRole() == 'faculty';
  Future<bool> isStudent() async => await getUserRole() == 'student';

  Future<Map<String, dynamic>> getUserData() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return {};
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.data() ?? {};
  }
}
