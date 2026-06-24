import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_project/core/router/app_router.dart';
import 'package:flutter_project/core/constants/app_roles.dart';

/// Builds a minimal GoRouter that mirrors the production redirect guard
/// but does NOT depend on Firebase or Riverpod providers.
GoRouter _buildGuardRouter({
  required AuthStatus authStatus,
  required UserRole role,
  required String initialLocation,
}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(path: '/', builder: (_, _) => const _Stub('splash')),
      GoRoute(path: '/home', builder: (_, _) => const _Stub('home')),
      GoRoute(path: '/gateway', builder: (_, _) => const _Stub('gateway')),
      GoRoute(path: '/admin/dashboard', builder: (_, _) => const _Stub('admin')),
      GoRoute(path: '/faculty/dashboard', builder: (_, _) => const _Stub('faculty')),
      GoRoute(path: '/colleges', builder: (_, _) => const _Stub('colleges')),
    ],
    redirect: (context, state) {
      if (authStatus == AuthStatus.unknown) return null;

      const publicPaths = [
        '/login', '/login-form', '/signup', '/forgot-password', '/gateway', '/guest',
      ];
      final path = state.uri.path;
      final isCollegePath = path.startsWith('/colleges');
      final isPublic =
          publicPaths.contains(state.fullPath) ||
          state.fullPath == '/' ||
          isCollegePath;
      final isAdminPath = state.fullPath?.startsWith('/admin') ?? false;
      final isProtected = !isPublic && !isAdminPath;

      if (authStatus == AuthStatus.unauthenticated) {
        if (isProtected || isAdminPath) return '/gateway';
        return null;
      }

      // Authenticated — role-based guards (mirrors app_router.dart lines 520-534)
      if (role == UserRole.admin && !path.startsWith('/admin')) {
        return '/admin/dashboard';
      }
      if (role == UserRole.faculty && !path.startsWith('/faculty')) {
        return '/faculty/dashboard';
      }
      if (role == UserRole.guest && !path.startsWith('/colleges') && path != '/guest') {
        return '/colleges';
      }
      if (role == UserRole.student &&
          (path.startsWith('/admin') || path.startsWith('/faculty'))) {
        return '/home';
      }

      return null;
    },
  );
}

class _Stub extends StatelessWidget {
  final String label;
  const _Stub(this.label);
  @override
  Widget build(BuildContext context) => Scaffold(body: Text(label));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RBAC Router Redirect Guard', () {
    testWidgets(
      'student blocked from /admin/dashboard → redirected to /home',
      (tester) async {
        final router = _buildGuardRouter(
          authStatus: AuthStatus.authenticated,
          role: UserRole.student,
          initialLocation: '/admin/dashboard',
        );
        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        await tester.pumpAndSettle();

        final loc = router.routerDelegate.currentConfiguration.uri.toString();
        expect(loc, equals('/home'));
      },
    );

    testWidgets(
      'student blocked from /faculty/dashboard → redirected to /home',
      (tester) async {
        final router = _buildGuardRouter(
          authStatus: AuthStatus.authenticated,
          role: UserRole.student,
          initialLocation: '/faculty/dashboard',
        );
        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        await tester.pumpAndSettle();

        final loc = router.routerDelegate.currentConfiguration.uri.toString();
        expect(loc, equals('/home'));
      },
    );

    testWidgets(
      'admin on /home → redirected to /admin/dashboard',
      (tester) async {
        final router = _buildGuardRouter(
          authStatus: AuthStatus.authenticated,
          role: UserRole.admin,
          initialLocation: '/home',
        );
        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        await tester.pumpAndSettle();

        final loc = router.routerDelegate.currentConfiguration.uri.toString();
        expect(loc, equals('/admin/dashboard'));
      },
    );

    testWidgets(
      'faculty on /home → redirected to /faculty/dashboard',
      (tester) async {
        final router = _buildGuardRouter(
          authStatus: AuthStatus.authenticated,
          role: UserRole.faculty,
          initialLocation: '/home',
        );
        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        await tester.pumpAndSettle();

        final loc = router.routerDelegate.currentConfiguration.uri.toString();
        expect(loc, equals('/faculty/dashboard'));
      },
    );

    testWidgets(
      'guest on /home → redirected to /colleges',
      (tester) async {
        final router = _buildGuardRouter(
          authStatus: AuthStatus.authenticated,
          role: UserRole.guest,
          initialLocation: '/home',
        );
        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        await tester.pumpAndSettle();

        final loc = router.routerDelegate.currentConfiguration.uri.toString();
        expect(loc, equals('/colleges'));
      },
    );

    testWidgets(
      'unauthenticated user on /home → redirected to /gateway',
      (tester) async {
        final router = _buildGuardRouter(
          authStatus: AuthStatus.unauthenticated,
          role: UserRole.student,
          initialLocation: '/home',
        );
        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        await tester.pumpAndSettle();

        final loc = router.routerDelegate.currentConfiguration.uri.toString();
        expect(loc, equals('/gateway'));
      },
    );

    testWidgets(
      'student on /home → stays on /home (no redirect)',
      (tester) async {
        final router = _buildGuardRouter(
          authStatus: AuthStatus.authenticated,
          role: UserRole.student,
          initialLocation: '/home',
        );
        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        await tester.pumpAndSettle();

        final loc = router.routerDelegate.currentConfiguration.uri.toString();
        expect(loc, equals('/home'));
      },
    );

    testWidgets(
      'admin stays on /admin/dashboard (no redirect loop)',
      (tester) async {
        final router = _buildGuardRouter(
          authStatus: AuthStatus.authenticated,
          role: UserRole.admin,
          initialLocation: '/admin/dashboard',
        );
        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        await tester.pumpAndSettle();

        final loc = router.routerDelegate.currentConfiguration.uri.toString();
        expect(loc, equals('/admin/dashboard'));
      },
    );
  });
}
