import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_project/features/faculty/presentation/pages/faculty_attendance_sheet_page.dart';
import 'package:flutter_project/core/services/professor_validator.dart';
import 'package:flutter_project/l10n/app_localizations.dart';

class MockProfessorValidator extends Mock implements ProfessorValidator {
  @override
  Future<bool> isProfessorAssignedToCourse(String courseId) async {
    return super.noSuchMethod(
      Invocation.method(#isProfessorAssignedToCourse, [courseId]),
      returnValue: Future.value(false),
      returnValueForMissingStub: Future.value(false),
    ) as Future<bool>;
  }

  @override
  Future<bool> isStudentEnrolledInCourse({required String studentId, required String courseId}) async {
    return super.noSuchMethod(
      Invocation.method(#isStudentEnrolledInCourse, [], {#studentId: studentId, #courseId: courseId}),
      returnValue: Future.value(false),
      returnValueForMissingStub: Future.value(false),
    ) as Future<bool>;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MockProfessorValidator mockValidator;

  setUp(() {
    mockValidator = MockProfessorValidator();
  });

  Widget createWidget() {
    return ProviderScope(
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('ar'),
        home: Scaffold(
          body: FacultyAttendanceSheetPage(validator: mockValidator),
        ),
      ),
    );
  }

  testWidgets('أستاذ غير معين للمادة يحاول حفظ حضور -> يُرفض ولا يتغير saving', (tester) async {
    when(mockValidator.isProfessorAssignedToCourse('default_course')).thenAnswer((_) async => false);

    await tester.pumpWidget(createWidget());
    await tester.pumpAndSettle();

    final saveButton = find.text('حفظ سجل الحضور');
    expect(saveButton, findsOneWidget);
    
    // محاكاة الضغط
    await tester.tap(saveButton);
    await tester.pump();

    // يجب ظهور رسالة خطأ
    expect(find.text('❌ ليس لديك صلاحية تسجيل حضور هذه المادة'), findsOneWidget);
    
    // _saving يجب أن يعود لـ false وتختفي الرسالة بعد pump
    await tester.pumpAndSettle();
  });

  testWidgets('أستاذ معين للمادة لكن طالب غير مسجل -> يتم تخطيه', (tester) async {
    when(mockValidator.isProfessorAssignedToCourse('default_course')).thenAnswer((_) async => true);
    when(mockValidator.isStudentEnrolledInCourse(studentId: 'uid_1', courseId: 'default_course')).thenAnswer((_) async => false);
    when(mockValidator.isStudentEnrolledInCourse(studentId: 'uid_2', courseId: 'default_course')).thenAnswer((_) async => true);

    await tester.pumpWidget(createWidget());
    await tester.pumpAndSettle();

    final saveButton = find.text('حفظ سجل الحضور');
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    // The validation passes but student 1 is skipped, student 2 is saved. 
    // We expect the success message.
    expect(find.text('تم حفظ سجل الحضور بنجاح'), findsOneWidget);
  });

  testWidgets('حالة انقطاع الاتصال (استثناء) -> لا كراش وتظهر رسالة', (tester) async {
    when(mockValidator.isProfessorAssignedToCourse('default_course')).thenThrow(Exception('No internet'));

    await tester.pumpWidget(createWidget());
    await tester.pumpAndSettle();

    final saveButton = find.text('حفظ سجل الحضور');
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    // رسالة الخطأ
    expect(find.textContaining('حدث خطأ: Exception: No internet'), findsOneWidget);
  });

}
