import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_project/features/requests/data/requests_repository.dart';
import 'package:flutter_project/features/requests/data/student_request_model.dart';

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final requestsRepositoryProvider = Provider<RequestsRepository>((ref) {
  return RequestsRepository(firestore: ref.watch(firestoreProvider));
});

final userRequestsProvider = StreamProvider.autoDispose
    .family<List<StudentRequest>, String>((ref, uid) {
      final repository = ref.watch(requestsRepositoryProvider);
      return repository.getUserRequests(uid);
    });
