// ═══════════════════════════════════════════════════════════════════════════
// college_routes.dart
// Dynamic college routes from [kUodColleges]. Wire via `...buildCollegeRoutes()`
// in app_router.dart when ready.
// ═══════════════════════════════════════════════════════════════════════════

import 'package:go_router/go_router.dart';
import 'package:flutter_project/core/colleges/college_registry.dart';
import 'package:flutter_project/features/colleges/presentation/college_departments_page.dart';
import 'package:flutter_project/features/colleges/presentation/college_home_page.dart';
import 'package:flutter_project/features/colleges/presentation/college_news_page.dart';
import 'package:flutter_project/features/colleges/presentation/college_shell_page.dart';

/// Resolves slug from `/colleges/:slug/...` path segments.
String _slugFromState(GoRouterState state) {
  final segments = state.uri.pathSegments;
  if (segments.length >= 2 && segments.first == 'colleges') {
    return segments[1];
  }
  return state.pathParameters['collegeSlug'] ?? kUodColleges.first.slug;
}

/// Null-safe college lookup for shell and redirects.
CollegeDefinition collegeFromState(GoRouterState state) {
  final slug = _slugFromState(state);
  return collegeBySlug(slug) ?? kUodColleges.first;
}

/// All college routes: one [ShellRoute] + per-college [GoRoute] trees from [kUodColleges].
List<RouteBase> buildCollegeRoutes() {
  return [
    ShellRoute(
      builder: (context, state, child) {
        final college = collegeFromState(state);
        return CollegeShellPage(college: college, child: child);
      },
      routes: [
        for (final college in kUodColleges) ..._routesForCollege(college),
      ],
    ),
  ];
}

List<RouteBase> _routesForCollege(CollegeDefinition college) {
  final basePath = '/colleges/${college.slug}';

  return [
    GoRoute(
      path: basePath,
      redirect: (context, state) {
        final path = state.uri.path;
        if (path == basePath || path == '$basePath/') {
          return '$basePath/overview';
        }
        return null;
      },
      routes: [
        GoRoute(
          path: 'overview',
          name: 'college_${college.id}_overview',
          builder: (context, state) => CollegeHomePage(college: college),
        ),
        GoRoute(
          path: 'news',
          name: 'college_${college.id}_news',
          builder: (context, state) => CollegeNewsPage(college: college),
        ),
        GoRoute(
          path: 'departments',
          name: 'college_${college.id}_departments',
          builder: (context, state) => CollegeDepartmentsPage(college: college),
        ),
      ],
    ),
  ];
}
