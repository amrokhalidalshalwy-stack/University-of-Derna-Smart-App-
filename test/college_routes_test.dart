import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_project/core/colleges/college_registry.dart';
import 'package:flutter_project/core/router/college_routes.dart';
import 'package:flutter_project/features/colleges/presentation/college_home_page.dart';
import 'package:flutter_project/features/colleges/presentation/college_shell_page.dart';
import 'package:flutter_project/l10n/app_localizations.dart';

void main() {
  testWidgets(
    '/colleges/medicine/overview loads CollegeShellPage with medicine theme',
    (tester) async {
      final router = GoRouter(
        initialLocation: '/colleges/medicine/overview',
        routes: buildCollegeRoutes(),
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: router,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('ar'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CollegeShellPage), findsOneWidget);
      expect(find.byType(CollegeHomePage), findsOneWidget);

      final medicine = collegeById('medicine')!;
      expect(medicine.primaryColor, const Color(0xFF003366));
    },
  );
}
