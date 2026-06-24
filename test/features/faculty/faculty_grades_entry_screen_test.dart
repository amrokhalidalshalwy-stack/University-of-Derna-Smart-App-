import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_project/core/services/professor_validator.dart';

class MockProfessorValidator extends Mock implements ProfessorValidator {
  @override
  Future<ValidationResult> validateGradeEntry({required String courseId, required String studentId}) async {
    return super.noSuchMethod(
      Invocation.method(#validateGradeEntry, [], {#courseId: courseId, #studentId: studentId}),
      returnValue: Future.value(ValidationResult.success()),
      returnValueForMissingStub: Future.value(ValidationResult.success()),
    ) as Future<ValidationResult>;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MockProfessorValidator mockValidator;

  setUp(() {
    mockValidator = MockProfessorValidator();
  });

  testWidgets('_saving يُعاد إلى false فعلياً في حالة الرفض', (tester) async {
    when(mockValidator.validateGradeEntry(courseId: 'test_course', studentId: 'student_1'))
        .thenAnswer((_) async => ValidationResult.failure('هذا الطالب غير مسجّل في المادة'));

    // ...
  });
}
