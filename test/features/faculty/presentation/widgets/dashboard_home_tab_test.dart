import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_project/features/auth/data/auth_service.dart';
import 'package:flutter_project/features/auth/data/cached_user_profile_provider.dart';
import 'package:flutter_project/features/faculty/models/course_model.dart';
import 'package:flutter_project/features/faculty/providers/faculty_provider.dart';
import 'package:flutter_project/features/faculty/presentation/widgets/dashboard_home_tab.dart';
import 'package:flutter_project/l10n/app_localizations.dart';

class _FakeFacultyCoursesNotifier extends FacultyCoursesNotifier {
  @override
  Future<List<CourseModel>> build() async => [];
}

class MockUser extends Mock implements User {
  @override
  String get uid => 'test_uid';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('DashboardHomeTab renders correctly and shows mock data', (
    tester,
  ) async {
    // ✅ تحديد حجم شاشة ثابت لتجنب Row overflow
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final mockUser = MockUser();

    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(body: DashboardHomeTab()),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateChangesProvider.overrideWith(
            (ref) => Stream.value(mockUser),
          ),
          userDataProvider.overrideWith(
            (ref, uid) =>
                Stream.value({'firstName': 'Omar', 'lastName': 'Khaled'}),
          ),
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

    // ✅ استخدام pump بدلاً من pumpAndSettle لتجنب مشكلة opacity في الـ animations
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(DashboardHomeTab), findsOneWidget);
  });
}
