# أكواد بوابة هيئة التدريس - جامعة درنة

هذا الملف يحتوي على جميع أكواد صفحات بوابة هيئة التدريس في تطبيق جامعة درنة الذكي.

---

## جدول المحتويات

1. [صفحة تسجيل الدخول](#1-صفحة-تسجيل-الدخول)
2. [ملفات التوجيه (Routing)](#2-ملفات-التوجيه-routing)
3. [صفحة لوحة التحكم الرئيسية](#3-صفحة-لوحة-التحكم-الرئيسية)
4. [صفحة الجدول الدراسي](#4-صفحة-الجدول-الدراسي)
5. [صفحة الطلاب](#5-صفحة-الطلاب)
6. [صفحة ورقة الحضور](#6-صفحة-ورقة-الحضور)
7. [صفحة الواجبات](#7-صفحة-الواجبات)
8. [صفحة الملف الشخصي](#8-صفحة-الملف-الشخصي)
9. [صفحة الإعدادات](#9-صفحة-الإعدادات)
10. [صفحة التقارير](#10-صفحة-التقارير)
11. [صفحة تفاصيل الفصل](#11-صفحة-تفاصيل-الفصل)

---

## 1. صفحة تسجيل الدخول

**المسار:** `lib/features/auth/presentation/pages/login_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_project/features/auth/data/auth_service.dart';
import 'package:flutter_project/features/auth/data/cached_user_profile_provider.dart';
import 'package:flutter_project/l10n/app_localizations.dart';
import 'package:flutter_project/core/models/user_profile.dart';
import 'package:flutter_project/core/models/enums.dart';

class LoginPage extends ConsumerStatefulWidget {
  final String? role;
  final String? portalType;

  const LoginPage({super.key, this.role, this.portalType});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.fillAllFields)),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final auth = ref.read(authServiceProvider);
      await auth.signInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (mounted) {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final roleInfo = await ref.read(userRoleInfoProvider.future);
          final role = roleInfo?.role;
          
          if (role == UserRole.faculty) {
            context.go('/faculty/dashboard');
          } else if (role == UserRole.student) {
            context.go('/student/dashboard');
          } else if (role == UserRole.admin) {
            context.go('/admin/dashboard');
          } else {
            context.go('/gateway');
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Login failed')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isFaculty = widget.role == 'faculty' || widget.portalType == 'faculty';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final brandColor = isFaculty 
        ? (isDark ? const Color(0xFF001835) : const Color(0xFF00A694))
        : (isDark ? const Color(0xFF1E3A8A) : const Color(0xFF3B82F6));
    
    final subtitleColor = isDark ? Colors.white70 : Colors.grey.shade600;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo and Title
                  Icon(
                    Icons.school_rounded,
                    size: 80,
                    color: brandColor,
                  ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
                  
                  const SizedBox(height: 16),
                  
                  Text(
                    l10n.universityName,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: brandColor,
                      fontFamily: 'Cairo',
                    ),
                  ).animate().fadeIn(delay: 200.ms),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    isFaculty ? l10n.facultyPortal : l10n.studentPortal,
                    style: TextStyle(
                      fontSize: 16,
                      color: subtitleColor,
                      fontFamily: 'Cairo',
                    ),
                  ).animate().fadeIn(delay: 300.ms),
                  
                  const SizedBox(height: 48),
                  
                  // Email Field
                  _buildFieldLabel(l10n.email, subtitleColor),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(fontFamily: 'Cairo'),
                    decoration: InputDecoration(
                      hintText: l10n.emailHint,
                      prefixIcon: const Icon(Icons.email_outlined),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.1),
                  
                  const SizedBox(height: 20),
                  
                  // Password Field
                  _buildFieldLabel(l10n.password, subtitleColor),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: const TextStyle(fontFamily: 'Cairo'),
                    decoration: InputDecoration(
                      hintText: l10n.passwordHint,
                      prefixIcon: const Icon(Icons.lock_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                      ),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.1),
                  
                  const SizedBox(height: 24),
                  
                  // Terms and Forgot Password
                  _buildTermsAndForgotRow(l10n, subtitleColor),
                  
                  const SizedBox(height: 24),
                  
                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: brandColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              l10n.login,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                fontFamily: 'Cairo',
                              ),
                            ),
                    ),
                  ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1),
                  
                  const SizedBox(height: 20),
                  
                  // Sign Up Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        l10n.noAccount,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          color: subtitleColor,
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.go(
                          '/signup?portalType=${widget.role ?? 'student'}',
                        ),
                        child: Text(
                          l10n.createAccount,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: brandColor,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 700.ms),
                  
                  const SizedBox(height: 20),
                  
                  _buildSecureFooter(l10n, subtitleColor),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTermsAndForgotRow(AppLocalizations l10n, Color subtitleColor) {
    if (widget.role == 'admin' || widget.role == 'gateway') {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Checkbox(
              value: _rememberMe,
              onChanged: (v) => setState(() => _rememberMe = v ?? false),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            Text(
              l10n.rememberMe,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13,
                color: subtitleColor,
              ),
            ),
          ],
        ),
        TextButton(
          onPressed: () => context.push('/forgot-password'),
          child: Text(
            l10n.forgotPassword,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13,
              color: subtitleColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSecureFooter(AppLocalizations l10n, Color subtitleColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.verified_user_outlined,
          size: 16,
          color: subtitleColor.withValues(alpha: 0.7),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            l10n.secureSystem,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: subtitleColor.withValues(alpha: 0.6),
              fontFamily: 'Cairo',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFieldLabel(String label, Color color) {
    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: color,
          fontFamily: 'Cairo',
        ),
      ),
    );
  }
}
```

---

## 2. ملفات التوجيه (Routing)

### 2.1 الموجه الرئيسي

**المسار:** `lib/core/router/app_router.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_project/features/auth/data/auth_service.dart';
import 'package:flutter_project/features/auth/data/cached_user_profile_provider.dart';
import 'package:flutter_project/core/models/enums.dart';
import 'package:flutter_project/core/router/faculty_routes.dart';
import 'package:flutter_project/core/router/auth_navigation.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateChangesProvider);
  final roleInfo = ref.watch(userRoleInfoProvider);

  return GoRouter(
    initialLocation: '/gateway',
    refreshListenable: authState,
    redirect: (context, state) {
      final authStatus = authState.value;
      final role = roleInfo.value?.role;
      final path = state.uri.path;

      // Redirect to gateway if not authenticated
      if (authStatus == null && path != '/gateway' && path != '/login') {
        return '/gateway';
      }

      // Role-based redirects
      if (authStatus != null) {
        if (role == UserRole.faculty && !path.startsWith('/faculty')) {
          return '/faculty/dashboard';
        }
        if (role == UserRole.student && !path.startsWith('/student')) {
          return '/student/dashboard';
        }
        if (role == UserRole.admin && !path.startsWith('/admin')) {
          return '/admin/dashboard';
        }
      }

      return null;
    },
    routes: [
      // Gateway Route
      GoRoute(
        path: '/gateway',
        builder: (context, state) => const GatewayPage(),
      ),
      
      // Login Route
      GoRoute(
        path: '/login',
        builder: (context, state) {
          final role = state.uri.queryParameters['role'];
          return LoginPage(role: role);
        },
      ),
      
      // Faculty Routes
      ...facultyRoutes,
      
      // Student Routes
      GoRoute(
        path: '/student/dashboard',
        builder: (context, state) => const StudentDashboardPage(),
      ),
      
      // Admin Routes
      GoRoute(
        path: '/admin/dashboard',
        builder: (context, state) => const AdminDashboardPage(),
      ),
    ],
  );
});
```

### 2.2 مسارات هيئة التدريس

**المسار:** `lib/core/router/faculty_routes.dart`

```dart
import 'package:go_router/go_router.dart';
import 'package:flutter_project/features/faculty/pages/faculty_dashboard_page.dart';
import 'package:flutter_project/features/faculty/pages/faculty_schedule_page.dart';
import 'package:flutter_project/features/faculty/pages/faculty_students_page.dart';
import 'package:flutter_project/features/faculty/pages/faculty_attendance_sheet_page.dart';
import 'package:flutter_project/features/faculty/pages/faculty_assignments_page.dart';
import 'package:flutter_project/features/faculty/pages/faculty_profile_page.dart';
import 'package:flutter_project/features/faculty/pages/faculty_settings_page.dart';
import 'package:flutter_project/features/faculty/pages/faculty_reports_page.dart';
import 'package:flutter_project/features/faculty/pages/class_detail_page.dart';

final facultyRoutes = [
  GoRoute(
    path: '/faculty/dashboard',
    builder: (context, state) => const FacultyDashboardPage(),
  ),
  GoRoute(
    path: '/faculty/schedule',
    builder: (context, state) => const FacultySchedulePage(),
  ),
  GoRoute(
    path: '/faculty/students',
    builder: (context, state) => const FacultyStudentsPage(),
  ),
  GoRoute(
    path: '/faculty/attendance',
    builder: (context, state) => const FacultyAttendanceSheetPage(),
  ),
  GoRoute(
    path: '/faculty/assignments',
    builder: (context, state) => const FacultyAssignmentsPage(),
  ),
  GoRoute(
    path: '/faculty/profile',
    builder: (context, state) => const FacultyProfilePage(),
  ),
  GoRoute(
    path: '/faculty/settings',
    builder: (context, state) => const FacultySettingsPage(),
  ),
  GoRoute(
    path: '/faculty/reports',
    builder: (context, state) => const FacultyReportsPage(),
  ),
  GoRoute(
    path: '/faculty/class/:courseId',
    builder: (context, state) {
      final courseId = state.pathParameters['courseId']!;
      return ClassDetailPage(courseId: courseId);
    },
  ),
];
```

### 2.3 مساعدات التوجيه

**المسار:** `lib/core/router/auth_navigation.dart`

```dart
import 'package:flutter_project/core/models/enums.dart';

String homePathForRole(UserRole role) {
  switch (role) {
    case UserRole.faculty:
      return '/faculty/dashboard';
    case UserRole.student:
      return '/student/dashboard';
    case UserRole.admin:
      return '/admin/dashboard';
    default:
      return '/gateway';
  }
}

Future<void> navigateAfterLogin(
  UserRole role,
  bool isPending,
  Function(String) navigate,
) async {
  if (role == UserRole.student && isPending) {
    navigate('/pending');
  } else {
    navigate(homePathForRole(role));
  }
}
```

---

## 3. صفحة لوحة التحكم الرئيسية

**المسار:** `lib/features/faculty/pages/faculty_dashboard_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_project/features/auth/data/auth_service.dart';
import 'package:flutter_project/features/auth/data/cached_user_profile_provider.dart';
import 'package:flutter_project/features/faculty/providers/faculty_provider.dart';
import 'package:flutter_project/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

class FacultyDashboardPage extends ConsumerStatefulWidget {
  const FacultyDashboardPage({super.key});

  @override
  ConsumerState<FacultyDashboardPage> createState() => _FacultyDashboardPageState();
}

class _FacultyDashboardPageState extends ConsumerState<FacultyDashboardPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    _HomeTab(),
    _ClassesTab(),
    _AttendanceTab(),
    _GradesTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(authStateChangesProvider).value;
    final userDataAsync = ref.watch(userDataProvider(user?.uid ?? ''));

    final brandTeal = const Color(0xFF00A694);
    final brandNavy = const Color(0xFF001835);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.dashboard_rounded, color: Colors.white, size: 22),
            const SizedBox(width: 8),
            Text(
              l10n.facultyDashboard,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        backgroundColor: brandNavy,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded),
          ),
          IconButton(
            onPressed: () => context.push('/faculty/settings'),
            icon: const Icon(Icons.settings_rounded),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [brandTeal, brandNavy],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: userDataAsync.when(
                data: (profile) {
                  final fullName = profile?['fullName'] as String? ?? 'عضو هيئة التدريس';
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person, color: brandNavy, size: 30),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        fullName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'أستاذ مشارك',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const SizedBox(),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home_rounded),
              title: const Text('الرئيسية', style: TextStyle(fontFamily: 'Cairo')),
              onTap: () {
                Navigator.pop(context);
                setState(() => _selectedIndex = 0);
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month_rounded),
              title: const Text('الجدول', style: TextStyle(fontFamily: 'Cairo')),
              onTap: () {
                Navigator.pop(context);
                context.push('/faculty/schedule');
              },
            ),
            ListTile(
              leading: const Icon(Icons.people_rounded),
              title: const Text('الطلاب', style: TextStyle(fontFamily: 'Cairo')),
              onTap: () {
                Navigator.pop(context);
                context.push('/faculty/students');
              },
            ),
            ListTile(
              leading: const Icon(Icons.assignment_rounded),
              title: const Text('الواجبات', style: TextStyle(fontFamily: 'Cairo')),
              onTap: () {
                Navigator.pop(context);
                context.push('/faculty/assignments');
              },
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart_rounded),
              title: const Text('التقارير', style: TextStyle(fontFamily: 'Cairo')),
              onTap: () {
                Navigator.pop(context);
                context.push('/faculty/reports');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.person_rounded),
              title: const Text('الملف الشخصي', style: TextStyle(fontFamily: 'Cairo')),
              onTap: () {
                Navigator.pop(context);
                context.push('/faculty/profile');
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: Colors.red),
              title: const Text('تسجيل الخروج', style: TextStyle(fontFamily: 'Cairo', color: Colors.red)),
              onTap: () async {
                await ref.read(authServiceProvider).signOut();
                context.go('/gateway');
              },
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_rounded),
            label: l10n.home,
          ),
          NavigationDestination(
            icon: const Icon(Icons.library_books_rounded),
            label: l10n.facultyClasses,
          ),
          NavigationDestination(
            icon: const Icon(Icons.fact_check_rounded),
            label: l10n.attendance,
          ),
          NavigationDestination(
            icon: const Icon(Icons.grade_rounded),
            label: l10n.grades,
          ),
        ],
      ),
    );
  }
}

// Tab implementations continue...
class _HomeTab extends ConsumerWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(authStateChangesProvider).value;
    final userDataAsync = ref.watch(userDataProvider(user?.uid ?? ''));
    final pendingAsync = ref.watch(pendingRegistrationsProvider);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Welcome Card
        userDataAsync.when(
          data: (profile) {
            final fullName = profile?['fullName'] as String? ?? 'أستاذ';
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${l10n.welcome} $fullName',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.facultyDashboardSubtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const SizedBox(),
        ),
        const SizedBox(height: 20),
        
        // Pending Registrations
        pendingAsync.when(
          data: (count) {
            if (count > 0) {
              return Card(
                color: Colors.amber.shade50,
                child: ListTile(
                  leading: const Icon(Icons.person_add_rounded, color: Colors.amber),
                  title: Text('$count ${l10n.pendingRegistrations}', style: const TextStyle(fontFamily: 'Cairo')),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded),
                ),
              );
            }
            return const SizedBox();
          },
          loading: () => const SizedBox(),
          error: (_, __) => const SizedBox(),
        ),
      ],
    );
  }
}

class _ClassesTab extends ConsumerWidget {
  const _ClassesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coursesAsync = ref.watch(facultyCoursesProvider);
    final l10n = AppLocalizations.of(context)!;

    return coursesAsync.when(
      data: (courses) {
        if (courses.isEmpty) {
          return Center(child: Text(l10n.facultyNoCourses, style: const TextStyle(fontFamily: 'Cairo')));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: courses.length,
          itemBuilder: (context, index) {
            final course = courses[index];
            return Card(
              child: ListTile(
                leading: const Icon(Icons.library_books_rounded),
                title: Text(course.nameAr, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                subtitle: Text('${course.departmentId} - ${course.semester}', style: const TextStyle(fontFamily: 'Cairo')),
                trailing: Text('${course.studentCount} طالب', style: const TextStyle(fontFamily: 'Cairo')),
                onTap: () => context.push('/faculty/class/${course.courseId}'),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

class _AttendanceTab extends ConsumerStatefulWidget {
  const _AttendanceTab();
  @override
  ConsumerState<_AttendanceTab> createState() => _AttendanceTabState();
}

class _AttendanceTabState extends ConsumerState<_AttendanceTab> {
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Attendance Tab', style: TextStyle(fontFamily: 'Cairo')));
  }
}

class _GradesTab extends ConsumerStatefulWidget {
  const _GradesTab();
  @override
  ConsumerState<_GradesTab> createState() => _GradesTabState();
}

class _GradesTabState extends ConsumerState<_GradesTab> {
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Grades Tab', style: TextStyle(fontFamily: 'Cairo')));
  }
}
```

---

## 4. صفحة الجدول الدراسي

**المسار:** `lib/features/faculty/pages/faculty_schedule_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_project/features/auth/data/auth_service.dart';
import 'package:flutter_project/features/auth/data/cached_user_profile_provider.dart';
import 'package:flutter_project/features/faculty/providers/faculty_provider.dart';
import 'package:flutter_project/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

class FacultySchedulePage extends ConsumerStatefulWidget {
  const FacultySchedulePage({super.key});

  @override
  ConsumerState<FacultySchedulePage> createState() => _FacultySchedulePageState();
}

class _FacultySchedulePageState extends ConsumerState<FacultySchedulePage> {
  final List<Map<String, String>> _daysOfWeek = (() {
    final now = DateTime.now();
    final sunday = now.subtract(Duration(days: now.weekday % 7));
    final dayNamesAr = ['الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس'];
    final dayNamesEn = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday'];
    return List.generate(5, (i) {
      final d = sunday.add(Duration(days: i));
      return {'ar': dayNamesAr[i], 'en': dayNamesEn[i], 'date': d.day.toString()};
    });
  })();

  int _selectedDayIndex = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(authStateChangesProvider).value;
    final userDataAsync = ref.watch(userDataProvider(user?.uid ?? ''));
    final coursesAsync = ref.watch(facultyCoursesProvider);

    final brandTeal = Theme.of(context).colorScheme.primary;
    final brandNavy = Theme.of(context).colorScheme.secondary;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.calendar_month_rounded, color: Colors.white, size: 22),
            const SizedBox(width: 8),
            Text(
              l10n.scheduleTitle,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        backgroundColor: brandNavy,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Day Selector
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(_daysOfWeek.length, (index) {
                  final day = _daysOfWeek[index];
                  final isSelected = index == _selectedDayIndex;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedDayIndex = index),
                    child: Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? brandTeal : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(day['ar']!, style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.grey)),
                          const SizedBox(height: 4),
                          Text(day['date']!, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.white : brandNavy)),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Schedule List
          Expanded(
            child: coursesAsync.when(
              data: (courses) {
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: courses.length,
                  itemBuilder: (context, index) {
                    final course = courses[index];
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.book_rounded),
                        title: Text(course.nameAr, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                        subtitle: Text(course.schedule.join(', '), style: const TextStyle(fontFamily: 'Cairo')),
                        trailing: Text('${course.studentCount} طالب', style: const TextStyle(fontFamily: 'Cairo')),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## 5. صفحة الطلاب

**المسار:** `lib/features/faculty/pages/faculty_students_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_project/features/faculty/providers/faculty_provider.dart';
import 'package:flutter_project/l10n/app_localizations.dart';

class FacultyStudentsPage extends ConsumerStatefulWidget {
  const FacultyStudentsPage({super.key});

  @override
  ConsumerState<FacultyStudentsPage> createState() => _FacultyStudentsPageState();
}

class _FacultyStudentsPageState extends ConsumerState<FacultyStudentsPage> {
  final TextEditingController _announcementCtrl = TextEditingController();
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String? _selectedCourseId;
  bool _isSending = false;

  @override
  void dispose() {
    _announcementCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final brandTeal = Theme.of(context).colorScheme.primary;
    final brandNavy = Theme.of(context).colorScheme.secondary;
    final coursesAsync = ref.watch(facultyCoursesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(l10n.studentsTitle, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 15)),
        backgroundColor: brandNavy,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: coursesAsync.when(
        data: (courses) {
          if (_selectedCourseId == null && courses.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() => _selectedCourseId = courses.first.courseId);
            });
          }

          final selectedCourse = _selectedCourseId != null
              ? courses.firstWhere((c) => c.courseId == _selectedCourseId, orElse: () => courses.first)
              : null;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Course Selector
              DropdownButton<String>(
                value: _selectedCourseId ?? (courses.isNotEmpty ? courses.first.courseId : null),
                onChanged: (value) => setState(() => _selectedCourseId = value),
                items: courses.map((c) => DropdownMenuItem(value: c.courseId, child: Text(c.nameAr, style: const TextStyle(fontFamily: 'Cairo')))).toList(),
              ),
              const SizedBox(height: 20),
              
              // Search Field
              TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: l10n.studentsSearch,
                  prefixIcon: const Icon(Icons.search_rounded),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),
              
              // Students List
              if (selectedCourse != null)
                ref.watch(classStudentsProvider(selectedCourse)).when(
                  data: (students) {
                    final filtered = students.where((s) => s.fullName.contains(_searchQuery) || s.uid.contains(_searchQuery)).toList();
                    return Column(
                      children: filtered.map((student) {
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(child: Text(student.fullName[0])),
                            title: Text(student.fullName, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                            subtitle: Text(student.universityId, style: const TextStyle(fontFamily: 'Cairo')),
                          ),
                        );
                      }).toList(),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
```

---

## 6. صفحة ورقة الحضور

**المسار:** `lib/features/faculty/pages/faculty_attendance_sheet_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_project/features/faculty/providers/faculty_provider.dart';
import 'package:flutter_project/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

enum AttendanceStatus { none, present, late, absent }

class _StudentRow {
  final String id;
  final String name;
  final String registrationNo;
  AttendanceStatus status;

  _StudentRow({
    required this.id,
    required this.name,
    required this.registrationNo,
    this.status = AttendanceStatus.none,
  });
}

class FacultyAttendanceSheetPage extends ConsumerStatefulWidget {
  const FacultyAttendanceSheetPage({super.key});

  @override
  ConsumerState<FacultyAttendanceSheetPage> createState() => _FacultyAttendanceSheetPageState();
}

class _FacultyAttendanceSheetPageState extends ConsumerState<FacultyAttendanceSheetPage> {
  final List<_StudentRow> _students = [
    _StudentRow(id: 'uid_1', name: 'أحمد محمد الفيتوري', registrationNo: '20210045', status: AttendanceStatus.present),
    _StudentRow(id: 'uid_2', name: 'سارة إبراهيم العبيدي', registrationNo: '20210112', status: AttendanceStatus.late),
    _StudentRow(id: 'uid_3', name: 'علي محمود الورفلي', registrationNo: '20210089', status: AttendanceStatus.absent),
  ];

  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final brandTeal = Theme.of(context).colorScheme.primary;
    final brandNavy = Theme.of(context).colorScheme.secondary;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F7F9),
      appBar: AppBar(
        title: Text(l10n.attendanceSheetTitle, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: brandNavy,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Stats Row
                Row(
                  children: [
                    _buildStatChip(label: l10n.attendancePresent, count: _students.where((s) => s.status == AttendanceStatus.present).length, color: brandTeal),
                    const SizedBox(width: 8),
                    _buildStatChip(label: l10n.attendanceLate, count: _students.where((s) => s.status == AttendanceStatus.late).length, color: Colors.amber.shade700),
                    const SizedBox(width: 8),
                    _buildStatChip(label: l10n.attendanceAbsent, count: _students.where((s) => s.status == AttendanceStatus.absent).length, color: Colors.red.shade600),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Student List
                ..._students.asMap().entries.map((entry) {
                  final student = entry.value;
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // Status Buttons
                          Wrap(
                            spacing: 4,
                            children: [
                              _statusBtn(l10n.attendancePresent, student.status == AttendanceStatus.present, brandTeal, () => setState(() => student.status = AttendanceStatus.present)),
                              _statusBtn(l10n.attendanceLate, student.status == AttendanceStatus.late, Colors.amber.shade700, () => setState(() => student.status = AttendanceStatus.late)),
                              _statusBtn(l10n.attendanceAbsent, student.status == AttendanceStatus.absent, Colors.red.shade600, () => setState(() => student.status = AttendanceStatus.absent)),
                            ],
                          ),
                          const Spacer(),
                          // Student Info
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(student.name, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                              Text('رقم قيد: ${student.registrationNo}', style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
          // Save Button
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: ElevatedButton.icon(
              onPressed: _isSaving ? null : () => _saveAll(context, brandTeal),
              icon: _isSaving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.send_rounded),
              label: Text(l10n.attendanceSaveReport, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: brandTeal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip({required String label, required int count, required Color color}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text('$count', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 20, color: color)),
            Text(label, style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: color, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _statusBtn(String label, bool active, Color activeColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: active ? activeColor : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(label, style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 11, color: active ? Colors.white : Colors.grey)),
      ),
    );
  }

  Future<void> _saveAll(BuildContext context, Color brandTeal) async {
    setState(() => _isSaving = true);
    // Save logic here
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.attendanceSaved, style: const TextStyle(fontFamily: 'Cairo')), backgroundColor: brandTeal),
      );
      setState(() => _isSaving = false);
    }
  }
}
```

---

## 7. صفحة الواجبات

**المسار:** `lib/features/faculty/pages/faculty_assignments_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_project/features/faculty/providers/faculty_provider.dart';
import 'package:flutter_project/l10n/app_localizations.dart';

class FacultyAssignmentsPage extends ConsumerStatefulWidget {
  const FacultyAssignmentsPage({super.key});

  @override
  ConsumerState<FacultyAssignmentsPage> createState() => _FacultyAssignmentsPageState();
}

class _FacultyAssignmentsPageState extends ConsumerState<FacultyAssignmentsPage> {
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _maxGradeCtrl = TextEditingController(text: '20');
  final _formKey = GlobalKey<FormState>();
  bool _isPublishing = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _maxGradeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final brandTeal = const Color(0xFF00837a);
    final brandDark = const Color(0xFF0b2447);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(l10n.assignmentsTitle, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: brandDark,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Summary Cards
          Row(
            children: [
              Expanded(child: _buildWaitingCard(l10n, brandDark)),
              const SizedBox(width: 16),
              Expanded(child: _buildGradedCard(l10n, brandDark)),
            ],
          ),
          const SizedBox(height: 24),
          
          // Add Assignment Form
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border(right: BorderSide(color: brandTeal, width: 4)),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _titleCtrl,
                    decoration: InputDecoration(labelText: l10n.assignmentsAssignmentTitle, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                    validator: (value) => value == null || value.isEmpty ? '*' : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _maxGradeCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(labelText: l10n.assignmentsMaxGrade, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _isPublishing ? null : () => _publishAssignment(context, l10n, brandTeal),
                    icon: _isPublishing ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.send_rounded),
                    label: Text(l10n.assignmentsPublish, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(backgroundColor: brandTeal, foregroundColor: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaitingCard(AppLocalizations l10n, Color brandDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(l10n.assignmentsWaiting, style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 8),
          Text('06', style: TextStyle(fontFamily: 'Cairo', fontSize: 28, fontWeight: FontWeight.bold, color: brandDark)),
        ],
      ),
    );
  }

  Widget _buildGradedCard(AppLocalizations l10n, Color brandDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: brandDark, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(l10n.assignmentsGraded, style: const TextStyle(fontFamily: 'Cairo', fontSize: 12, color: Colors.white70)),
          const SizedBox(height: 8),
          const Text('24', style: TextStyle(fontFamily: 'Cairo', fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
        ],
      ),
    );
  }

  Future<void> _publishAssignment(BuildContext context, AppLocalizations l10n, Color brandTeal) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isPublishing = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() => _isPublishing = false);
      _titleCtrl.clear();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.reportsExportSuccess, style: const TextStyle(fontFamily: 'Cairo')), backgroundColor: brandTeal));
    }
  }
}
```

---

## 8. صفحة الملف الشخصي

**المسار:** `lib/features/faculty/pages/faculty_profile_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_project/features/auth/data/auth_service.dart';
import 'package:flutter_project/features/auth/data/cached_user_profile_provider.dart';
import 'package:flutter_project/l10n/app_localizations.dart';

class FacultyProfilePage extends ConsumerWidget {
  const FacultyProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(authStateChangesProvider).value;
    final userDataAsync = ref.watch(userDataProvider(user?.uid ?? ''));

    final brandTeal = Theme.of(context).colorScheme.primary;
    final brandNavy = Theme.of(context).colorScheme.secondary;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F7F9),
      body: userDataAsync.when(
        data: (profileData) {
          if (profileData == null) {
            return Center(child: Text(l10n.notFoundError, style: const TextStyle(fontFamily: 'Cairo')));
          }

          final fullName = profileData['fullName'] as String? ?? 'د. محمد علي';
          final email = profileData['email'] as String? ?? 'm.ali@uod.edu.ly';
          final phone = profileData['phone'] as String? ?? '092-1234567';
          final major = profileData['major'] as String? ?? 'هندسة البرمجيات';

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                backgroundColor: brandNavy,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [brandTeal, brandNavy], begin: Alignment.topRight, end: Alignment.bottomLeft),
                    ),
                    child: SafeArea(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircleAvatar(radius: 50, backgroundColor: Colors.white, child: Icon(Icons.person, size: 50, color: brandNavy)),
                          const SizedBox(height: 12),
                          Text(fullName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Cairo')),
                          const SizedBox(height: 4),
                          Text(l10n.profileFacultyMember, style: const TextStyle(fontSize: 12, color: Colors.white70, fontFamily: 'Cairo')),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Personal Info
                    _buildInfoCard(Icons.badge_outlined, l10n.profileJobId, '202105423', brandTeal),
                    _buildInfoCard(Icons.lan_outlined, l10n.profileSpecialization, major, brandTeal),
                    _buildInfoCard(Icons.email_outlined, l10n.profileEmail, email, brandTeal),
                    _buildInfoCard(Icons.phone_android_outlined, l10n.profilePhone, phone, brandTeal),
                    const SizedBox(height: 24),
                    // Logout Button
                    OutlinedButton.icon(
                      onPressed: () async {
                        await ref.read(authServiceProvider).signOut();
                        context.go('/gateway');
                      },
                      icon: const Icon(Icons.logout_rounded),
                      label: Text(l10n.profileLogout, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.redAccent),
                    ),
                  ]),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value, Color brandTeal) {
    return Card(
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: brandTeal.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: brandTeal),
        ),
        title: Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontFamily: 'Cairo')),
        subtitle: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
      ),
    );
  }
}
```

---

## 9. صفحة الإعدادات

**المسار:** `lib/features/faculty/pages/faculty_settings_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_project/features/auth/data/auth_service.dart';
import 'package:flutter_project/features/auth/data/cached_user_profile_provider.dart';
import 'package:flutter_project/l10n/app_localizations.dart';
import 'package:flutter_project/core/localization/locale_provider.dart';
import 'package:flutter_project/core/preferences/app_preferences.dart';
import 'package:go_router/go_router.dart';

class FacultySettingsPage extends ConsumerStatefulWidget {
  const FacultySettingsPage({super.key});

  @override
  ConsumerState<FacultySettingsPage> createState() => _FacultySettingsPageState();
}

class _FacultySettingsPageState extends ConsumerState<FacultySettingsPage> {
  bool _notificationsEnabled = true;
  bool _biometricEnabled = true;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(authStateChangesProvider).value;
    final userDataAsync = ref.watch(userDataProvider(user?.uid ?? ''));
    final themeMode = ref.watch(themeModeNotifierProvider);
    final locale = ref.watch(localeProvider);
    final isDark = themeMode == ThemeMode.dark;

    final brandTeal = Theme.of(context).colorScheme.primary;
    final brandNavy = Theme.of(context).colorScheme.secondary;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: Text(l10n.settingsTitle, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: brandNavy,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: userDataAsync.when(
        data: (profile) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Account Settings
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.person_outline_rounded, color: brandTeal),
                      title: Text(l10n.settingsEditProfile, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                      onTap: () => context.push('/faculty/profile'),
                    ),
                    const Divider(),
                    ListTile(
                      leading: Icon(Icons.language_rounded, color: brandTeal),
                      title: Text(l10n.settingsLanguage, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                      subtitle: Text(locale.languageCode == 'ar' ? 'العربية' : 'English'),
                      onTap: () => _pickLocale(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // System Preferences
              Card(
                child: Column(
                  children: [
                    SwitchListTile(
                      secondary: Icon(Icons.dark_mode_outlined, color: brandTeal),
                      title: Text(l10n.settingsDarkMode, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                      value: isDark,
                      onChanged: (val) => ref.read(themeModeNotifierProvider.notifier).setThemeMode(val ? ThemeMode.dark : ThemeMode.light),
                    ),
                    const Divider(),
                    SwitchListTile(
                      secondary: Icon(Icons.notifications_none_rounded, color: brandTeal),
                      title: Text(l10n.settingsNotifications, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                      value: _notificationsEnabled,
                      onChanged: (val) => setState(() => _notificationsEnabled = val),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Sign Out
              ElevatedButton.icon(
                onPressed: () => _confirmSignOut(context),
                icon: const Icon(Icons.logout_rounded),
                label: Text(l10n.profileLogout, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.red.shade600),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Future<void> _pickLocale(BuildContext ctx) async {
    final chosen = await showModalBottomSheet<String>(
      context: ctx,
      builder: (sheetCtx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(title: const Text('تلقائي (النظام)'), leading: const Icon(Icons.language), onTap: () => Navigator.pop(sheetCtx, 'system')),
              ListTile(title: const Text('العربية'), onTap: () => Navigator.pop(sheetCtx, 'ar')),
              ListTile(title: const Text('English'), onTap: () => Navigator.pop(sheetCtx, 'en')),
            ],
          ),
        );
      },
    );
    if (chosen == null || !mounted) return;
    if (chosen == 'system') {
      await ref.read(localeProvider.notifier).setSystemLocale();
    } else {
      await ref.read(localeProvider.notifier).setLocale(Locale(chosen));
    }
  }

  void _confirmSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد تسجيل الخروج', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
        content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج؟', style: TextStyle(fontFamily: 'Cairo')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo'))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authServiceProvider).signOut();
              context.go('/gateway');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade600),
            child: const Text('تسجيل خروج', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
```

---

## 10. صفحة التقارير

**المسار:** `lib/features/faculty/pages/faculty_reports_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_project/l10n/app_localizations.dart';

class FacultyReportsPage extends ConsumerStatefulWidget {
  const FacultyReportsPage({super.key});

  @override
  ConsumerState<FacultyReportsPage> createState() => _FacultyReportsPageState();
}

class _FacultyReportsPageState extends ConsumerState<FacultyReportsPage> {
  String _selectedSemester = 'خريف 2023 - 2024';
  String _selectedCourse = 'هندسة البرمجيات (CS302)';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final brandNavy = const Color(0xFF031E39);
    final brandTeal = const Color(0xFF0DB5A2);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(l10n.reportsTitle, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: brandNavy,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Selectors
          Card(
            child: Column(
              children: [
                DropdownButtonFormField(
                  value: _selectedSemester,
                  items: ['خريف 2023 - 2024', 'ربيع 2023 - 2024'].map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontFamily: 'Cairo')))).toList(),
                  onChanged: (v) => setState(() => _selectedSemester = v!),
                  decoration: InputDecoration(labelText: l10n.reportsSelectSemester, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField(
                  value: _selectedCourse,
                  items: ['هندسة البرمجيات (CS302)', 'قواعد البيانات (CS305)'].map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontFamily: 'Cairo')))).toList(),
                  onChanged: (v) => setState(() => _selectedCourse = v!),
                  decoration: InputDecoration(labelText: l10n.reportsSelectCourse, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Success Rate Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [brandTeal, brandNavy], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(l10n.reportsSuccessRate, style: const TextStyle(color: Colors.white70, fontFamily: 'Cairo')),
                const SizedBox(height: 8),
                const Text('84.5%', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white, fontFamily: 'Cairo')),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Export Button
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.reportsExportSuccess, style: const TextStyle(fontFamily: 'Cairo')), backgroundColor: brandTeal));
            },
            icon: const Icon(Icons.picture_as_pdf_rounded),
            label: Text(l10n.reportsExportPdf, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(backgroundColor: brandNavy, foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }
}
```

---

## 11. صفحة تفاصيل الفصل

**المسار:** `lib/features/faculty/pages/class_detail_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_project/features/faculty/providers/faculty_provider.dart';
import 'package:flutter_project/features/faculty/models/course_model.dart';
import 'package:flutter_project/core/models/user_profile.dart';
import 'package:flutter_project/l10n/app_localizations.dart';

class ClassDetailPage extends ConsumerStatefulWidget {
  final String courseId;

  const ClassDetailPage({super.key, required this.courseId});

  @override
  ConsumerState<ClassDetailPage> createState() => _ClassDetailPageState();
}

class _ClassDetailPageState extends ConsumerState<ClassDetailPage> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final coursesAsync = ref.watch(facultyCoursesProvider);
    final course = coursesAsync.value?.where((c) => c.courseId == widget.courseId).firstOrNull;

    final primaryColor = Theme.of(context).colorScheme.primary;
    final accentColor = const Color(0xFF00A694);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: Text(course?.nameAr ?? l10n.classDetailTitle, style: const TextStyle(color: Colors.white, fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
          backgroundColor: primaryColor,
          bottom: TabBar(
            tabs: [
              Tab(icon: const Icon(Icons.people_rounded), text: l10n.studentsListTab),
              Tab(icon: const Icon(Icons.campaign_rounded), text: l10n.announcementsTab),
            ],
          ),
        ),
        body: course == null
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  // Student Roster
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: l10n.searchStudent,
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
                        ),
                      ),
                      Expanded(
                        child: _StudentRosterList(course: course, searchQuery: _searchQuery),
                      ),
                    ],
                  ),
                  // Announcements History
                  _AnnouncementsHistory(courseId: course.courseId),
                ],
              ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: accentColor,
          onPressed: () => _showAddAnnouncementDialog(context, ref, course.courseId),
          icon: const Icon(Icons.campaign_rounded, color: Colors.white),
          label: Text(l10n.addAnnouncement, style: const TextStyle(color: Colors.white, fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  void _showAddAnnouncementDialog(BuildContext context, WidgetRef ref, String courseId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _AddAnnouncementDialogContent(courseId: courseId, ref: ref),
    );
  }
}

class _AddAnnouncementDialogContent extends StatefulWidget {
  final String courseId;
  final WidgetRef ref;
  const _AddAnnouncementDialogContent({required this.courseId, required this.ref});

  @override
  State<_AddAnnouncementDialogContent> createState() => _AddAnnouncementDialogContentState();
}

class _AddAnnouncementDialogContentState extends State<_AddAnnouncementDialogContent> {
  final _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.addAnnouncementTitle, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor, fontFamily: 'Cairo')),
          const SizedBox(height: 16),
          TextField(
            controller: _textController,
            maxLines: 4,
            decoration: InputDecoration(hintText: l10n.announcementHint, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16))),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              if (_textController.text.isNotEmpty) {
                widget.ref.read(announcementsProvider.notifier).addAnnouncement(widget.courseId, _textController.text);
                Navigator.pop(context);
              }
            },
            icon: const Icon(Icons.send_rounded, color: Colors.white),
            label: const Text('بث الإعلان الآن', style: TextStyle(color: Colors.white, fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
          ),
        ],
      ),
    );
  }
}

class _StudentRosterList extends ConsumerWidget {
  final CourseModel course;
  final String searchQuery;

  const _StudentRosterList({required this.course, required this.searchQuery});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final studentsAsync = ref.watch(classStudentsProvider(course));

    return studentsAsync.when(
      data: (students) {
        final filtered = students.where((s) => s.fullName.toLowerCase().contains(searchQuery) || s.universityId.toLowerCase().contains(searchQuery)).toList();
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final student = filtered[index];
            return Card(
              child: ListTile(
                leading: CircleAvatar(child: Text(student.fullName[0])),
                title: Text(student.fullName, style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
                subtitle: Text('ID: ${student.universityId}', style: const TextStyle(fontFamily: 'Cairo')),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

class _AnnouncementsHistory extends ConsumerWidget {
  final String courseId;
  const _AnnouncementsHistory({required this.courseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('announcements').doc(courseId).collection('posts').orderBy('createdAt', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) return const Center(child: Text('لا توجد إعلانات', style: TextStyle(fontFamily: 'Cairo')));
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            return Card(
              child: ListTile(
                title: Text(data['text'] ?? '', style: const TextStyle(fontFamily: 'Cairo')),
                subtitle: Text(data['createdAt']?.toString() ?? '', style: const TextStyle(fontFamily: 'Cairo', fontSize: 12)),
              ),
            );
          },
        );
      },
    );
  }
}
```

---

## ملخص

هذا الملف يحتوي على جميع أكواد صفحات بوابة هيئة التدريس في تطبيق جامعة درنة الذكي. تتضمن:

- **صفحة تسجيل الدخول**: معالجة Firebase Auth والتحقق من الأدوار
- **ملفات التوجيه**: إدارة المسارات والتحويلات بناءً على الأدوار
- **لوحة التحكم**: الواجهة الرئيسية مع التبويبات والقائمة الجانبية
- **الجدول الدراسي**: عرض المحاضرات اليومية
- **الطلاب**: إدارة قوائم الطلاب وبث الإعلانات
- **ورقة الحضور**: تسجيل الحضور والغياب
- **الواجبات**: إدارة الواجبات والتقييمات
- **الملف الشخصي**: عرض معلومات عضو هيئة التدريس
- **الإعدادات**: تخصيص التطبيق
- **التقارير**: عرض الإحصائيات والتقارير
- **تفاصيل الفصل**: عرض تفاصيل المقرر والإعلانات

جميع الصفحات تستخدم:
- Flutter مع Riverpod لإدارة الحالة
- Firebase Auth و Firestore للمصادقة والبيانات
- GoRouter للتوجيه
- flutter_animate للرسوم المتحركة
- التوطين (localization) للغات المتعددة
