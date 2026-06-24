import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

import 'package:flutter_project/core/constants/app_roles.dart';
import 'package:flutter_project/core/providers/user_role_provider.dart';
import 'package:flutter_project/core/router/auth_navigation.dart';

import 'package:flutter_project/features/faculty/presentation/pages/exam_paper_upload_page.dart';
import 'package:flutter_project/features/faculty/presentation/pages/faculty_assignments_page.dart';
import 'package:flutter_project/features/faculty/presentation/pages/faculty_attendance_sheet_page.dart';
import 'package:flutter_project/features/faculty/presentation/pages/faculty_profile_page.dart';
import 'package:flutter_project/features/faculty/presentation/pages/faculty_reports_page.dart';
import 'package:flutter_project/features/faculty/presentation/pages/faculty_schedule_page.dart';
import 'package:flutter_project/features/faculty/presentation/pages/faculty_settings_page.dart';
import 'package:flutter_project/features/faculty/presentation/pages/faculty_students_page.dart';
import 'package:flutter_project/features/faculty/presentation/pages/attendance_entry_page.dart';
import 'package:flutter_project/features/faculty/presentation/pages/class_detail_page.dart';
import 'package:flutter_project/features/faculty/presentation/pages/faculty_dashboard_page.dart';
import 'package:flutter_project/features/faculty/presentation/pages/grade_entry_page.dart';
import 'package:flutter_project/features/faculty/presentation/pages/faculty_excuses_page.dart';
import 'package:flutter_project/features/student/presentation/pages/exam_paper_view_page.dart';

List<RouteBase> buildFacultyRoutes(Ref ref, GlobalKey<NavigatorState> rootNavigatorKey) {
  return [
      GoRoute(
        path: '/faculty/dashboard',
        name: 'faculty_dashboard',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const FacultyDashboardPage(),
        redirect: (context, state) {
          final role = ref.read(userRoleInfoProvider).value?.role;
          if (role != null && role != UserRole.faculty) {
            return homePathForRole(role);
          }
          return null;
        },
      ),
      GoRoute(
        path: '/faculty/profile',
        name: 'faculty_profile',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const FacultyProfilePage(),
        redirect: (context, state) {
          final role = ref.read(userRoleInfoProvider).value?.role;
          if (role != null && role != UserRole.faculty) {
            return '/unauthorized?from=${state.uri.path}';
          }
          return null;
        },
      ),
      GoRoute(
        path: '/faculty/schedule',
        name: 'faculty_schedule',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const FacultySchedulePage(),
      ),
      GoRoute(
        path: '/faculty/exam-paper-upload',
        name: 'faculty_exam_paper_upload',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const ExamPaperUploadPage(),
        redirect: (context, state) {
          final role = ref.read(userRoleInfoProvider).value?.role;
          if (role != null && role != UserRole.faculty) {
            return '/unauthorized?from=${state.uri.path}';
          }
          return null;
        },
      ),
      GoRoute(
        path: '/faculty/settings',
        name: 'faculty_settings',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const FacultySettingsPage(),
        redirect: (context, state) {
          final role = ref.read(userRoleInfoProvider).value?.role;
          if (role != null && role != UserRole.faculty) {
            return '/unauthorized?from=${state.uri.path}';
          }
          return null;
        },
      ),
      GoRoute(
        path: '/faculty/attendance-sheet',
        name: 'faculty_attendance_sheet',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const FacultyAttendanceSheetPage(),
        redirect: (context, state) {
          final role = ref.read(userRoleInfoProvider).value?.role;
          if (role != null && role != UserRole.faculty) {
            return '/unauthorized?from=${state.uri.path}';
          }
          return null;
        },
      ),
      GoRoute(
        path: '/faculty/attendance',
        name: 'faculty_attendance',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const AttendanceEntryPage(),
        redirect: (context, state) {
          final role = ref.read(userRoleInfoProvider).value?.role;
          if (role != null && role != UserRole.faculty) {
            return '/unauthorized?from=${state.uri.path}';
          }
          return null;
        },
      ),
      GoRoute(
        path: '/faculty/students',
        name: 'faculty_students',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const FacultyStudentsPage(),
        redirect: (context, state) {
          final role = ref.read(userRoleInfoProvider).value?.role;
          if (role != null && role != UserRole.faculty) {
            return '/unauthorized?from=${state.uri.path}';
          }
          return null;
        },
      ),
      GoRoute(
        path: '/faculty/reports',
        name: 'faculty_reports',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const FacultyReportsPage(),
        redirect: (context, state) {
          final role = ref.read(userRoleInfoProvider).value?.role;
          if (role != null && role != UserRole.faculty) {
            return '/unauthorized?from=${state.uri.path}';
          }
          return null;
        },
      ),
      GoRoute(
        path: '/faculty/assignments/:courseId',
        name: 'faculty_assignments',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final courseId = state.pathParameters['courseId']!;
          return FacultyAssignmentsPage(courseId: courseId);
        },
        redirect: (context, state) {
          final role = ref.read(userRoleInfoProvider).value?.role;
          if (role != null && role != UserRole.faculty) {
            return '/unauthorized?from=${state.uri.path}';
          }
          return null;
        },
      ),
      GoRoute(
        path: '/faculty/grades-entry',
        name: 'faculty_grades_entry',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const GradeEntryPage(),
        redirect: (context, state) {
          final role = ref.read(userRoleInfoProvider).value?.role;
          if (role != null && role != UserRole.faculty) {
            return '/unauthorized?from=${state.uri.path}';
          }
          return null;
        },
      ),
      GoRoute(
        path: '/faculty/class/:courseId',
        name: 'faculty_class_detail',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final courseId = state.pathParameters['course_id']!;
          return ClassDetailPage(courseId: courseId);
        },
        redirect: (context, state) {
          final role = ref.read(userRoleInfoProvider).value?.role;
          if (role != null && role != UserRole.faculty) {
            return homePathForRole(role);
          }
          return null;
        },
      ),
      GoRoute(
        path: '/faculty/exam-papers',
        name: 'faculty_exam_papers',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>? ?? {};
          return ExamPaperViewPage(paperData: data);
        },
        redirect: (context, state) {
          final role = ref.read(userRoleInfoProvider).value?.role;
          if (role != null && role != UserRole.faculty) {
            return '/unauthorized?from=${state.uri.path}';
          }
          return null;
        },
      ),
      GoRoute(
        path: '/faculty/excuses',
        name: 'faculty_excuses',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const FacultyExcusesPage(),
        redirect: (context, state) {
          final role = ref.read(userRoleInfoProvider).value?.role;
          if (role != null && role != UserRole.faculty) {
            return '/unauthorized?from=${state.uri.path}';
          }
          return null;
        },
      ),
  ];
}
