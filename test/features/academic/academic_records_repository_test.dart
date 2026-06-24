import 'package:cloud_functions/cloud_functions.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_project/features/academic/data/academic_records_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseFunctions extends Mock implements FirebaseFunctions {}
class MockHttpsCallable extends Mock implements HttpsCallable {}
class MockHttpsCallableResult<T> extends Mock implements HttpsCallableResult<T> {}

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late MockFirebaseFunctions mockFunctions;
  late AcademicRecordsRepository repository;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    mockFunctions = MockFirebaseFunctions();
    repository = AcademicRecordsRepository(fakeFirestore, mockFunctions);
  });

  group('AcademicRecordsRepository Tests', () {
    test('watchGrades streams empty list initially (Happy Path)', () async {
      final stream = repository.watchGrades('student_123');
      final result = await stream.first;
      expect(result, isEmpty);
    });

    test('requestSync returns ok when function succeeds (Happy Path)', () async {
      final mockCallable = MockHttpsCallable();
      final mockResult = MockHttpsCallableResult<Map<String, dynamic>>();

      when(() => mockFunctions.httpsCallable('syncAcademicRecords')).thenReturn(mockCallable);
      when(() => mockCallable.call<Map<String, dynamic>>()).thenAnswer((_) async {
        when(() => mockResult.data).thenReturn({'synced': 5});
        return mockResult;
      });

      final result = await repository.requestSync();

      expect(result.success, true);
      expect(result.syncedCount, 5);
    });

    test('requestSync returns unavailable when not-found exception occurs (Failure Path)', () async {
      final mockCallable = MockHttpsCallable();

      when(() => mockFunctions.httpsCallable('syncAcademicRecords')).thenReturn(mockCallable);
      when(() => mockCallable.call<Map<String, dynamic>>()).thenThrow(
        FirebaseFunctionsException(code: 'not-found', message: 'Function not found'),
      );

      final result = await repository.requestSync();

      expect(result.success, false);
      expect(result.message, 'المزامنة غير متاحة حالياً — جرّب لاحقاً أو استخدم البيانات المحفوظة');
    });
  });
}
