import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_project/features/requests/data/requests_repository.dart';
import 'package:flutter_project/features/requests/data/student_request_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late RequestsRepository repository;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    repository = RequestsRepository(firestore: fakeFirestore);
  });

  group('RequestsRepository Tests', () {
    test('submitRequest saves correctly and getUserRequests retrieves it (Happy Path)', () async {
      final request = StudentRequest(
        id: '', // Will be generated
        studentId: 'student_123',
        type: RequestType.officialTranscript,
        status: RequestStatus.pending,
        createdAt: Timestamp.now(),
        updatedAt: Timestamp.now(),
        details: {'reason': 'Scholarship'},
      );

      await repository.submitRequest(request);

      final stream = repository.getUserRequests('student_123');
      final result = await stream.first;

      expect(result.length, 1);
      expect(result.first.studentId, 'student_123');
      expect(result.first.type, RequestType.officialTranscript);
      expect(result.first.details['reason'], 'Scholarship');
    });

    test('cancelRequest removes the request from Firestore (Happy Path)', () async {
      final docRef = fakeFirestore.collection('student_requests').doc('req_abc');
      await docRef.set({
        'student_id': 'student_123',
        'type': 'officialTranscript',
        'status': 'pending',
      });

      await repository.cancelRequest('req_abc');

      final doc = await docRef.get();
      expect(doc.exists, false);
    });

    test('submitRequest gap: lacks client-side field validation (Failure/Validation Gap)', () async {
      // Documentation gap: The repository does not enforce validation of `details`
      // before writing to Firestore. A user could submit an empty request.
      final invalidRequest = StudentRequest(
        id: '',
        studentId: '', // Empty student ID
        type: RequestType.majorChange,
        status: RequestStatus.pending,
        createdAt: Timestamp.now(),
        updatedAt: Timestamp.now(),
        details: {}, // Missing required fields for majorChange
      );

      // It will succeed because repository doesn't validate
      await expectLater(repository.submitRequest(invalidRequest), completes);
    });
  });
}
