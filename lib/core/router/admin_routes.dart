import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

import 'package:flutter_project/core/constants/app_roles.dart';
import 'package:flutter_project/core/providers/user_role_provider.dart';
import 'package:flutter_project/core/router/auth_navigation.dart';
import 'package:flutter_project/features/admin/presentation/pages/admin_dashboard_page.dart';
import 'package:flutter_project/features/admin/presentation/pages/manage_courses.dart';
import 'package:flutter_project/features/admin/presentation/pages/manage_users.dart';
import 'package:flutter_project/features/admin/presentation/pages/reports_page.dart';
import 'package:flutter_project/features/admin/presentation/pages/system_logs_page.dart';
import 'package:flutter_project/features/admin/presentation/pages/system_settings.dart';
import 'package:flutter_project/features/admin/presentation/pages/verification_queue_page.dart';

List<RouteBase> buildAdminRoutes(Ref ref, GlobalKey<NavigatorState> rootNavigatorKey) {
  return [
      GoRoute(
        path: '/admin/dashboard',
        name: 'admin_dashboard',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const AdminDashboardPage(),
        redirect: (context, state) {
          final role = ref.read(userRoleInfoProvider).value?.role;
          if (role != null && role != UserRole.admin) {
            return homePathForRole(role);
          }
          return null;
        },
      ),
      GoRoute(
        path: '/admin',
        parentNavigatorKey: rootNavigatorKey,
        redirect: (_, _) => '/admin/dashboard',
      ),
      GoRoute(
        path: '/admin/verifications',
        name: 'verifications',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const VerificationQueuePage(),
      ),
      GoRoute(
        path: '/admin/users',
        name: 'admin_users',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const ManageUsersPage(),
      ),
      GoRoute(
        path: '/admin/courses',
        name: 'admin_courses',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const ManageCoursesPage(),
      ),
      GoRoute(
        path: '/admin/settings',
        name: 'admin_settings',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const SystemSettingsPage(),
      ),
      GoRoute(
        path: '/admin/reports',
        name: 'admin_reports',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const ReportsPage(),
      ),
      GoRoute(
        path: '/admin/logs',
        name: 'admin_logs',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const SystemLogsPage(),
      ),
  ];
}
