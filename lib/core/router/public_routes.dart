import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

import 'package:flutter_project/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:flutter_project/features/auth/presentation/pages/login_form_page.dart';
import 'package:flutter_project/features/auth/presentation/pages/login_page.dart';
import 'package:flutter_project/features/auth/presentation/pages/pending_status_page.dart';
import 'package:flutter_project/features/auth/presentation/pages/sign_up_page.dart';
import 'package:flutter_project/features/auth/presentation/pages/unauthorized_page.dart';
import 'package:flutter_project/features/auth/presentation/widgets/terms_permissions_page.dart';
import 'package:flutter_project/features/gateway/presentation/pages/gateway_page.dart';
import 'package:flutter_project/features/guest/presentation/pages/guest_portal_page.dart';
import 'package:flutter_project/features/splash/presentation/pages/splash_page.dart';

List<RouteBase> buildPublicRoutes(Ref ref, GlobalKey<NavigatorState> rootNavigatorKey) {
  return [
      GoRoute(
        path: '/',
        name: 'splash',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/terms',
        name: 'terms',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const TermsPermissionsPage(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final role = state.uri.queryParameters['role'];
          return LoginPage(role: role);
        },
      ),
      GoRoute(
        path: '/login-form',
        name: 'login-form',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final portalType = state.uri.queryParameters['portalType'] ?? 'student';
          return LoginFormPage(portalType: portalType);
        },
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final portalType = state.uri.queryParameters['portalType'] ?? 'student';
          return SignUpPage(portalType: portalType);
        },
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: '/gateway',
        name: 'gateway',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const GatewayPage(),
      ),
      GoRoute(
        path: '/guest',
        name: 'guest',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const GuestPortalPage(),
      ),
      GoRoute(
        path: '/pending',
        name: 'pending',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final extra = state.extra as Map<String, String?>?;
          return PendingStatusPage(
            status: extra?['status'] ?? 'pending_final_approval',
            rejectionReason: extra?['rejectionReason'],
          );
        },
      ),
      GoRoute(
        path: '/unauthorized',
        name: 'unauthorized',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final from = state.uri.queryParameters['from'] ?? '';
          return UnauthorizedPage(attemptedPath: from);
        },
      ),
  ];
}
