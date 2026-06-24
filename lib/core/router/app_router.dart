import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_project/features/auth/presentation/pages/login_form_page.dart';

import 'package:flutter_project/features/auth/presentation/pages/forgot_password_page.dart';

import 'package:flutter_project/features/auth/presentation/pages/login_page.dart';

import 'package:flutter_project/features/auth/presentation/pages/sign_up_page.dart';

import 'package:flutter_project/features/fees/presentation/pages/fees_page.dart';

import 'package:flutter_project/features/gateway/presentation/pages/gateway_page.dart';

import 'package:flutter_project/features/home/presentation/pages/home_page.dart';

import 'package:flutter_project/features/notifications/presentation/pages/notifications_page.dart';

import 'package:flutter_project/features/profile/presentation/pages/profile_page.dart';

import 'package:flutter_project/features/schedule/presentation/pages/schedule_page.dart';

import 'package:flutter_project/features/settings/presentation/pages/about_page.dart';

import 'package:flutter_project/features/settings/presentation/pages/change_password_page.dart';

import 'package:flutter_project/features/settings/presentation/pages/college_location_page.dart';

import 'package:flutter_project/features/settings/presentation/pages/developer_profile_page.dart';

import 'package:flutter_project/features/settings/presentation/pages/edit_email_page.dart';

import 'package:flutter_project/features/settings/presentation/pages/edit_profile_image_page.dart';

import 'package:flutter_project/features/faq/presentation/pages/faq_page.dart';

import 'package:flutter_project/features/settings/presentation/pages/privacy_policy_page.dart';

import 'package:flutter_project/features/support/presentation/pages/report_issue_page.dart';

import 'package:flutter_project/features/settings/presentation/pages/settings_page.dart';

import 'package:flutter_project/features/settings/presentation/pages/support_page.dart';

import 'package:flutter_project/features/splash/presentation/pages/splash_page.dart';

import 'package:flutter_project/features/timetable/presentation/pages/timetable_page.dart';

import 'package:flutter_project/shared/widgets/main_shell.dart';

import 'package:flutter_project/features/auth/data/auth_service.dart';

import 'package:flutter_project/features/auth/presentation/pages/pending_status_page.dart';

import 'package:flutter_project/features/auth/presentation/pages/unauthorized_page.dart';

import 'package:flutter_project/features/guest/presentation/pages/guest_portal_page.dart';

import 'package:flutter_project/features/admin/presentation/pages/admin_dashboard_page.dart';

import 'package:flutter_project/features/admin/presentation/pages/verification_queue_page.dart';

import 'package:flutter_project/features/grades/presentation/pages/grades_page.dart';

import 'package:flutter_project/features/attendance/presentation/pages/attendance_page.dart';

import 'package:flutter_project/features/faculty/presentation/pages/faculty_dashboard_page.dart';

import 'package:flutter_project/features/faculty/presentation/pages/class_detail_page.dart';

import 'package:flutter_project/features/study/presentation/pages/semester_page.dart';

import 'package:flutter_project/features/study/presentation/pages/department_info_page.dart';

import 'package:flutter_project/features/study/presentation/pages/college_info_page.dart';

import 'package:flutter_project/core/providers/user_role_provider.dart';

import 'package:flutter_project/core/constants/app_roles.dart';

import 'package:flutter_project/core/router/auth_navigation.dart';

import 'package:flutter_project/core/router/college_routes.dart';

import 'package:flutter_project/core/router/student_routes.dart';

import 'package:flutter_project/features/admin/presentation/pages/system_logs_page.dart';

import 'package:flutter_project/features/admin/presentation/pages/reports_page.dart';

import 'package:flutter_project/features/admin/presentation/pages/manage_users.dart';

import 'package:flutter_project/features/admin/presentation/pages/manage_courses.dart';

import 'package:flutter_project/features/admin/presentation/pages/system_settings.dart';

import 'package:flutter_project/features/admin/presentation/pages/admin_settings_page.dart';

import 'package:flutter_project/features/student/presentation/pages/enrollment_renewal_page.dart';

import 'package:flutter_project/features/student/presentation/pages/absence_excuse_page.dart';

import 'package:flutter_project/features/student/presentation/pages/exam_paper_view_page.dart';

import 'package:flutter_project/features/student/presentation/pages/registration_renewal_page.dart';

import 'package:flutter_project/features/student/presentation/pages/exam_papers_page.dart';

import 'package:flutter_project/features/student/presentation/pages/academic_plan_page.dart';

import 'package:flutter_project/features/faculty/presentation/pages/attendance_entry_page.dart';

import 'package:flutter_project/features/faculty/presentation/pages/grade_entry_page.dart';

import 'package:flutter_project/features/faculty/presentation/pages/faculty_profile_page.dart';

import 'package:flutter_project/features/faculty/presentation/pages/faculty_schedule_page.dart';

import 'package:flutter_project/features/faculty/presentation/pages/faculty_settings_page.dart';

import 'package:flutter_project/features/faculty/presentation/pages/faculty_attendance_sheet_page.dart';

import 'package:flutter_project/features/faculty/presentation/pages/faculty_students_page.dart';

import 'package:flutter_project/features/faculty/presentation/pages/faculty_reports_page.dart';

import 'package:flutter_project/features/faculty/presentation/pages/faculty_assignments_page.dart';

import 'package:flutter_project/features/transcript/presentation/pages/transcript_route_page.dart';

import 'package:flutter_project/features/messages/presentation/pages/messages_page.dart';

import 'package:flutter_project/features/inbox/presentation/pages/inbox_page.dart';

import 'package:flutter_project/features/chat/presentation/pages/chat_page.dart';

import 'package:flutter_project/features/help/presentation/pages/help_center_page.dart';

import 'package:flutter_project/features/support/presentation/pages/support_hub_page.dart';

import 'package:flutter_project/features/contact/presentation/pages/contact_page.dart';

import 'package:flutter_project/features/forum/presentation/pages/forum_home_page.dart';

enum AuthStatus { authenticated, unauthenticated, unknown }

final authStatusProvider = Provider<AuthStatus>((ref) {
  final authState = ref.watch(authStateChangesProvider);

  return authState.when(
    data:
        (user) =>
            user != null
                ? AuthStatus.authenticated
                : AuthStatus.unauthenticated,

    loading: () => AuthStatus.unknown,

    error: (error, stack) => AuthStatus.unauthenticated,
  );
});

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen(authStatusProvider, (previous, next) {
      if (previous != next) {
        debugPrint(
          "🔄 RouterNotifier: Auth status changed from $previous to $next. Refreshing router...",
        );

        notifyListeners();
      }
    });

    _ref.listen(userRoleInfoProvider, (previous, next) {
      if (previous?.value?.role != next.value?.role) {
        debugPrint("🔄 RouterNotifier: Role changed. Refreshing router...");

        notifyListeners();
      }
    });
  }
}

final routerNotifierProvider = Provider<RouterNotifier>(
  (ref) => RouterNotifier(ref),
);

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  final authStatus = ref.watch(authStatusProvider);

  final allRoutes = <RouteBase>[
    GoRoute(
      path: '/',

      name: 'splash',

      parentNavigatorKey: rootNavigatorKey,

      builder: (context, state) => const SplashPage(),
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

    GoRoute(path: '/admin', redirect: (_, _) => '/admin/dashboard'),

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

      builder: (context, state) => const AdminSettingsPage(),
    ),

    GoRoute(
      path: '/admin/system-settings',

      name: 'admin_system_settings',

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

      redirect: (context, state) {
        final role = ref.read(userRoleInfoProvider).value?.role;

        if (role != null && role != UserRole.faculty) {
          return '/unauthorized?from=${state.uri.path}';
        }

        return null;
      },
    ),

    GoRoute(
      path: '/student/enrollment-renewal',

      name: 'enrollment_renewal',

      parentNavigatorKey: rootNavigatorKey,

      builder: (context, state) => const EnrollmentRenewalPage(),
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

    StatefulShellRoute.indexedStack(
      parentNavigatorKey: rootNavigatorKey,

      builder: (context, state, navigationShell) {
        return MainShell(navigationShell: navigationShell);
      },

      branches: <StatefulShellBranch>[
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '/home',

              name: 'home',

              pageBuilder:
                  (context, state) =>
                      const NoTransitionPage<void>(child: HomePage()),
            ),
          ],
        ),

        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '/schedule',

              name: 'schedule',

              pageBuilder:
                  (context, state) =>
                      const NoTransitionPage<void>(child: SchedulePage()),
            ),
          ],
        ),

        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '/notifications',

              name: 'notifications',

              pageBuilder:
                  (context, state) =>
                      const NoTransitionPage<void>(child: NotificationsPage()),
            ),
          ],
        ),

        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '/semester',

              name: 'semester',

              pageBuilder:
                  (context, state) => const NoTransitionPage<void>(
                    child: SemesterOverviewPage(),
                  ),
            ),
          ],
        ),

        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: '/settings',

              name: 'settings',

              pageBuilder:
                  (context, state) =>
                      const NoTransitionPage<void>(child: SettingsPage()),
            ),
          ],
        ),
      ],
    ),

    GoRoute(
      path: '/fees',

      name: 'fees',

      parentNavigatorKey: rootNavigatorKey,

      builder: (context, state) => const FeesPage(),
    ),

    GoRoute(
      path: '/profile',

      name: 'profile',

      parentNavigatorKey: rootNavigatorKey,

      builder: (context, state) => const ProfilePage(),
    ),

    GoRoute(
      path: '/grades',

      name: 'grades',

      parentNavigatorKey: rootNavigatorKey,

      builder: (context, state) => const GradesPage(),
    ),

    GoRoute(
      path: '/academic-plan',

      name: 'academic_plan',

      parentNavigatorKey: rootNavigatorKey,

      builder: (context, state) => const AcademicPlanPage(),
    ),

    GoRoute(
      path: '/transcript',

      name: 'transcript',

      parentNavigatorKey: rootNavigatorKey,

      builder: (context, state) {
        final semester = state.uri.queryParameters['semester'];

        return TranscriptRoutePage(semester: semester);
      },
    ),

    GoRoute(
      path: '/messages',

      name: 'messages',

      parentNavigatorKey: rootNavigatorKey,

      builder: (context, state) => const MessagesPage(),
    ),

    GoRoute(
      path: '/inbox',

      name: 'inbox',

      parentNavigatorKey: rootNavigatorKey,

      builder: (context, state) => const InboxPage(),
    ),

    GoRoute(
      path: '/chat',

      name: 'chat',

      parentNavigatorKey: rootNavigatorKey,

      builder: (context, state) => const ChatPage(),
    ),

    GoRoute(
      path: '/forum',
      name: 'forum',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const ForumHomePage(),
    ),

    GoRoute(
      path: '/attendance',

      name: 'attendance',

      parentNavigatorKey: rootNavigatorKey,

      builder: (context, state) => const AttendancePage(),
    ),

    GoRoute(
      path: '/student/absence-excuse',

      name: 'absence_excuse',

      parentNavigatorKey: rootNavigatorKey,

      builder: (context, state) => const AbsenceExcusePage(),
    ),

    GoRoute(
      path: '/student/exam-paper',

      name: 'exam_paper',

      parentNavigatorKey: rootNavigatorKey,

      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>? ?? {};

        return ExamPaperViewPage(paperData: data);
      },
    ),

    GoRoute(
      path: '/department',

      name: 'department',

      parentNavigatorKey: rootNavigatorKey,

      builder: (context, state) => const DepartmentInfoPage(),
    ),

    GoRoute(
      path: '/college',

      name: 'college',

      parentNavigatorKey: rootNavigatorKey,

      builder: (context, state) => const CollegeInfoPage(),
    ),

    GoRoute(
      path: '/about',

      name: 'about',

      parentNavigatorKey: rootNavigatorKey,

      builder: (context, state) => const AboutPage(),
    ),

    GoRoute(
      path: '/timetable',

      name: 'timetable',

      parentNavigatorKey: rootNavigatorKey,

      builder: (context, state) => const TimetablePage(),
    ),

    GoRoute(
      path: '/privacy-policy',

      name: 'privacy-policy',

      parentNavigatorKey: rootNavigatorKey,

      builder: (context, state) => const PrivacyPolicyPage(),
    ),

    GoRoute(
      path: '/help',

      name: 'help',

      parentNavigatorKey: rootNavigatorKey,

      builder: (context, state) => const HelpCenterPage(),
    ),

    GoRoute(
      path: '/registration-renewal',

      name: 'registrationRenewal',

      builder: (context, state) => const RegistrationRenewalPage(),
    ),

    GoRoute(
      path: '/exam-papers',

      name: 'examPapers',

      builder: (context, state) => const ExamPapersPage(),
    ),

    GoRoute(
      path: '/absence-excuse',

      name: 'absenceExcuse',

      builder: (context, state) => const AbsenceExcusePage(),
    ),

    GoRoute(
      path: '/faq',

      name: 'faq',

      parentNavigatorKey: rootNavigatorKey,

      builder: (context, state) => const FaqPage(),
    ),

    GoRoute(
      path: '/support',

      name: 'support',

      parentNavigatorKey: rootNavigatorKey,

      builder: (context, state) => const SupportPage(),
    ),

    GoRoute(
      path: '/support-hub',

      name: 'support-hub',

      parentNavigatorKey: rootNavigatorKey,

      builder: (context, state) => const SupportHubPage(),
    ),

    GoRoute(
      path: '/contact',

      name: 'contact',

      parentNavigatorKey: rootNavigatorKey,

      builder: (context, state) => const ContactPage(),
    ),

    GoRoute(
      path: '/report-issue',

      name: 'report-issue',

      parentNavigatorKey: rootNavigatorKey,

      builder: (context, state) => const ReportIssuePage(),
    ),

    GoRoute(
      path: '/college-location',

      name: 'college-location',

      parentNavigatorKey: rootNavigatorKey,

      builder: (context, state) => const CollegeLocationPage(),
    ),

    GoRoute(
      path: '/developer',

      name: 'developer',

      parentNavigatorKey: rootNavigatorKey,

      builder: (context, state) => const DeveloperProfilePage(),
    ),

    GoRoute(
      path: '/change-password',

      name: 'change-password',

      parentNavigatorKey: rootNavigatorKey,

      builder: (context, state) => const ChangePasswordPage(),
    ),

    GoRoute(
      path: '/edit-email',

      name: 'edit-email',

      parentNavigatorKey: rootNavigatorKey,

      builder: (context, state) => const EditEmailPage(),
    ),

    GoRoute(
      path: '/edit-profile-image',

      name: 'edit-profile-image',

      parentNavigatorKey: rootNavigatorKey,

      builder: (context, state) => const EditProfileImagePage(),
    ),

    ...buildCollegeRoutes(),

    ...buildStudentAndSharedRoutes(ref, rootNavigatorKey),
  ];

  return GoRouter(
    navigatorKey: rootNavigatorKey,

    initialLocation: '/',

    refreshListenable: notifier,

    routes: allRoutes,

    redirect: (context, state) {
      debugPrint(
        "🚨 Router Redirect: path=${state.uri.path}, auth=$authStatus",
      );

      final path = state.uri.path;

      if (path == '/') return null;
      if (authStatus == AuthStatus.unknown) return null;

      const publicPaths = [
        '/login',
        '/login-form',
        '/signup',
        '/forgot-password',
        '/gateway',
        '/guest',
      ];

      const publicPathPrefixes = ['/colleges'];

      final isCollegePath = publicPathPrefixes.any(
        (prefix) => path.startsWith(prefix),
      );

      final isPublic =
          publicPaths.contains(path) ||
          path == '/' ||
          isCollegePath;

      final isAdminPath = path.startsWith('/admin');
      final isProtected = !isPublic && !isAdminPath;

      if (authStatus == AuthStatus.unauthenticated) {
        if (isProtected || isAdminPath) return '/gateway';
        return null;
      }

      final roleInfoAsync = ref.read(userRoleInfoProvider);

      if (roleInfoAsync.isLoading) {
        debugPrint(
          "🚨 Router Redirect: userRoleInfoProvider is loading. Bypassing redirect.",
        );
        return null;
      }

      final roleInfo = roleInfoAsync.value;
      final role = roleInfo?.role;
      final status = roleInfo?.status;

      if (isPublic && path != '/guest' && !isCollegePath) {
        if (role != null) return homePathForRole(role);
        return '/home';
      }

      if (role != null) {
        if (path == '/unauthorized' || path == '/pending') return null;

        if (path == '/registration-renewal' || path == '/absence-excuse') {
          return null;
        }

        // ✅ التعديل: التحقق من حالة الحساب لكلا الدورين (student و faculty)
        // باستخدام قيم RegistrationStatus الفعلية بدلاً من contains()
        // هذا يضمن توجيه هيئة التدريس لصفحة الانتظار تماماً مثل الطالب
        if (status != null &&
            (role == UserRole.student || role == UserRole.faculty)) {
          final isPending =
              status == RegistrationStatus.pendingFinalApproval ||
              status == RegistrationStatus.underReview ||
              status == RegistrationStatus.requiresAdditional ||
              status == RegistrationStatus.autoRejected;
          if (isPending && path != '/pending') return '/pending';
        }

        if (role == UserRole.admin && !path.startsWith('/admin')) {
          return '/unauthorized?from=${state.uri.path}';
        }

        if (role == UserRole.faculty &&
            !path.startsWith('/faculty') &&
            path != '/chat' &&
            path != '/forum' &&
            path != '/pending') {
          return '/unauthorized?from=${state.uri.path}';
        }

        if (role == UserRole.guest &&
            !path.startsWith('/colleges') &&
            path != '/guest') {
          return '/unauthorized?from=${state.uri.path}';
        }

        if (role == UserRole.student &&
            (path.startsWith('/admin') || path.startsWith('/faculty'))) {
          return '/unauthorized?from=${state.uri.path}';
        }
      }

      if (path == '/pending' && authStatus != AuthStatus.authenticated) {
        return '/gateway';
      }

      return null;
    },
  );
});
