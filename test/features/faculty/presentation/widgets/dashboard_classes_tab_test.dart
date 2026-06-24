import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_project/features/faculty/models/course_model.dart';
import 'package:flutter_project/features/faculty/providers/faculty_provider.dart';
import 'package:flutter_project/features/faculty/presentation/widgets/dashboard_classes_tab.dart';
import 'package:flutter_project/l10n/app_localizations.dart';

class _FakeFacultyCoursesNotifier extends FacultyCoursesNotifier {
  @override
  Future<List<CourseModel>> build() async {
    return [];
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('DashboardClassesTab renders correctly with empty courses', (tester) async {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(
            body: DashboardClassesTab(),
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          facultyCoursesProvider.overrideWith(
            () => _FakeFacultyCoursesNotifier(),
          ),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('ar'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // With no courses, the empty message should be visible
    expect(find.text('لا توجد مقررات دراسية حالياً'), findsOneWidget);
  });
}
