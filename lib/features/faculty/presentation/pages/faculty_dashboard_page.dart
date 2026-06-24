import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';

import 'package:intl/intl.dart' hide TextDirection;

import 'package:flutter_animate/flutter_animate.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter_project/features/faculty/models/course_model.dart';

import 'package:flutter_project/features/faculty/providers/faculty_provider.dart';

import 'package:flutter_project/features/faculty/presentation/widgets/faculty_drawer.dart';

import 'package:flutter_project/features/auth/data/auth_service.dart';

import 'package:flutter_project/features/auth/data/cached_user_profile_provider.dart';

import 'package:flutter_project/l10n/app_localizations.dart';

import 'package:cloud_firestore/cloud_firestore.dart';



final pendingRegistrationsProvider = StreamProvider.autoDispose<int>((ref) {

  return FirebaseFirestore.instance

      .collection('registrations')

      .where('status', isEqualTo: 'pending')

      .snapshots()

      .map((snap) => snap.docs.length)

      .handleError((error, stackTrace) {

        return 0;

      });

});



class FacultyDashboardPage extends ConsumerStatefulWidget {

  const FacultyDashboardPage({super.key, this.initialTab = 0});



  final int initialTab;



  @override

  ConsumerState<FacultyDashboardPage> createState() =>

      _FacultyDashboardPageState();

}



class _FacultyDashboardPageState extends ConsumerState<FacultyDashboardPage> {

  late int _currentIndex;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();



  @override

  void initState() {

    super.initState();

    _currentIndex = widget.initialTab.clamp(0, 3);

  }



  @override

  Widget build(BuildContext context) {

    final l10n = AppLocalizations.of(context)!;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final navLabels = [

      l10n.home,

      l10n.facultyMyClasses,

      l10n.attendance,

      l10n.grades,

    ];



    return Scaffold(

      key: _scaffoldKey,

      backgroundColor:

          isDark ? const Color(0xFF132220) : const Color(0xFFF0FAFA),

      appBar: AppBar(

        title: Text(

          l10n.facultyPortalTitle,

          style: TextStyle(

            color: isDark ? const Color(0xFF10B981) : const Color(0xFF005A51),

            fontFamily: 'Cairo',

            fontWeight: FontWeight.bold,

          ),

        ),

        centerTitle: true, // لتوسط العنوان في المنتصف تماماً كما في الصورة

        backgroundColor:

            isDark

                ? const Color(0xFF0D2420)

                : const Color(0xFF00A694),

        elevation: 0,

        // إضافة خط سفلي رمادي خفيف جداً في الوضع الفاتح فقط ليفصل الـ AppBar عن الخلفية الفاتحة للموقع

        bottom:

            isDark

                ? null

                : PreferredSize(

                  preferredSize: const Size.fromHeight(1.0),

                  child: Container(

                    color: Colors.grey.withValues(alpha: 0.15),

                    height: 1.0,

                  ),

                ),

        // إضافة زر القائمة الجانبية (Drawer) لتظهر في الجهة الصحيحة وتفتح الـ Drawer

        leading: IconButton(

          icon: Icon(

            Icons.menu,

            color: isDark ? const Color(0xFF10B981) : const Color(0xFF005A51),

          ),

          onPressed: () => _scaffoldKey.currentState?.openDrawer(),

        ),

        actions: [

          IconButton(

            icon: Icon(

              Icons.notifications_none_rounded,

              color: isDark ? const Color(0xFF10B981) : const Color(0xFF005A51),

            ),

            onPressed: () => context.push('/faculty/notifications'),

          ),

          IconButton(

            icon: Icon(

              Icons.logout_rounded,

              color: isDark ? const Color(0xFF10B981) : const Color(0xFF005A51),

            ),

            onPressed: () async {

              await FirebaseAuth.instance.signOut();

              if (!context.mounted) return;

              context.go('/');

            },

          ),

        ],

      ),

      drawer: const FacultyDrawer(),

      body: IndexedStack(

        index: _currentIndex,

        children: const [

          _HomeTab(),

          _ClassesTab(),

          _AttendanceTab(),

          _GradesTab(),

        ],

      ),

      bottomNavigationBar: Container(

        decoration: BoxDecoration(

          boxShadow: [

            BoxShadow(

              color: Colors.black.withValues(alpha: 0.05),

              blurRadius: 20,

              offset: const Offset(0, -5),

            ),

          ],

        ),

        child: BottomNavigationBar(

          currentIndex: _currentIndex,

          onTap: (index) => setState(() => _currentIndex = index),

          selectedItemColor: const Color(0xFF00A694),

          unselectedItemColor: const Color(0xFF9E9E9E),

          selectedLabelStyle: const TextStyle(

            fontFamily: 'Cairo',

            fontWeight: FontWeight.bold,

            fontSize: 12,

          ),

          unselectedLabelStyle: const TextStyle(

            fontFamily: 'Cairo',

            fontSize: 11,

          ),

          type: BottomNavigationBarType.fixed,

          backgroundColor: Colors.white,

          elevation: 0,

          items: [

            BottomNavigationBarItem(

              icon: const Icon(Icons.dashboard_rounded),

              label: navLabels[0],

            ),

            BottomNavigationBarItem(

              icon: const Icon(Icons.class_rounded),

              label: navLabels[1],

            ),

            BottomNavigationBarItem(

              icon: const Icon(Icons.fact_check_rounded),

              label: navLabels[2],

            ),

            BottomNavigationBarItem(

              icon: const Icon(Icons.grade_rounded),

              label: navLabels[3],

            ),

          ],

        ),

      ),

    );

  }

}



// ── Tab 0: Home ─────────────────────────────────────────────────────────

class _HomeTab extends ConsumerWidget {

  const _HomeTab();



  @override

  Widget build(BuildContext context, WidgetRef ref) {

    final user = ref.watch(authStateChangesProvider).value;

    final userDataAsync = ref.watch(userDataProvider(user?.uid ?? ''));

    final coursesAsync = ref.watch(facultyCoursesProvider);

    final pendingCountAsync = ref.watch(pendingRegistrationsProvider);

    final l10n = AppLocalizations.of(context)!;

    final primaryColor = Theme.of(context).colorScheme.primary;

    final accentColor = const Color(0xFF00A694);



    final days = [

      l10n.daySunday,

      l10n.dayMonday,

      l10n.dayTuesday,

      l10n.dayWednesday,

      l10n.dayThursday,

    ];



    return SingleChildScrollView(

      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          // 1. Welcome Card Banner matching _8/ visual specs

          Container(

            width: double.infinity,

            padding: const EdgeInsets.all(24.0),

            decoration: BoxDecoration(

              gradient: LinearGradient(

                colors: [accentColor, accentColor.withValues(alpha: 0.8)],

                begin: Alignment.topLeft,

                end: Alignment.bottomRight,

              ),

              borderRadius: BorderRadius.circular(24),

              boxShadow: [

                BoxShadow(

                  color: accentColor.withValues(alpha: 0.2),

                  blurRadius: 15,

                  offset: const Offset(0, 8),

                ),

              ],

            ),

            child: Column(

              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                Container(

                  padding: const EdgeInsets.symmetric(

                    horizontal: 10,

                    vertical: 4,

                  ),

                  decoration: BoxDecoration(

                    color: Colors.white.withValues(alpha: 0.2),

                    borderRadius: BorderRadius.circular(8),

                  ),

                  child: const Text(

                    'عضو هيئة تدريس متميز',

                    style: TextStyle(

                      color: Colors.white,

                      fontSize: 11,

                      fontFamily: 'Cairo',

                      fontWeight: FontWeight.w600,

                    ),

                  ),

                ),

                const SizedBox(height: 12),

                userDataAsync.when(

                  data: (profile) {

                    final fullName = profile?['fullName'] as String? ?? '';

                    return Text(
                      fullName.isNotEmpty
                          ? '${l10n.facultyWelcome}، $fullName'
                          : l10n.facultyWelcome,

                      style: const TextStyle(

                        color: Colors.white,

                        fontSize: 22,

                        fontWeight: FontWeight.bold,

                        fontFamily: 'Cairo',

                      ),

                    );

                  },

                  loading:

                      () => SizedBox(

                        height: 22,

                        width: 150,

                        child: Opacity(

                          opacity: 0.3,

                          child: Text(

                            l10n.loading,

                            style: TextStyle(

                              color: Colors.white,

                              fontFamily: 'Cairo',

                            ),

                          ),

                        ),

                      ),

                  error:

                      (_, _) => Text(

                        l10n.facultyWelcome,

                        style: const TextStyle(

                          color: Colors.white,

                          fontSize: 22,

                          fontWeight: FontWeight.bold,

                          fontFamily: 'Cairo',

                        ),

                      ),

                ),

                const SizedBox(height: 4),

                Text(

                  l10n.facultyWelcomeSubtitle,

                  style: const TextStyle(

                    color: Colors.white70,

                    fontSize: 13,

                    fontFamily: 'Cairo',

                  ),

                ),

              ],

            ),

          ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1),



          const SizedBox(height: 28),



          // 2. Quick Access Cards (Modern Grid Menu)

          Row(

            children: [

              Expanded(

                child: _QuickAccessCard(

                  icon: Icons.assignment_turned_in,

                  title: l10n.attendanceRecordLink,

                  onTap: () {

                    context.goNamed('faculty_attendance_sheet');

                  },

                ),

              ),

              const SizedBox(width: 16),

              Expanded(

                child: _QuickAccessCard(

                  icon: Icons.calendar_month,

                  title: l10n.fullScheduleLink,

                  onTap: () {

                    context.goNamed('faculty_schedule');

                  },

                ),

              ),

            ],

          ).animate().fadeIn(duration: 600.ms, delay: 100.ms),



          const SizedBox(height: 28),



          // 3. Daily Lectures Timeline matching _8/ visual specs

          Row(

            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [

              Text(

                l10n.dashboardTodayLectures,

                style: TextStyle(

                  fontSize: 18,

                  fontWeight: FontWeight.bold,

                  fontFamily: 'Cairo',

                  color: primaryColor,

                ),

              ),

              GestureDetector(

                onTap: () => context.push('/faculty/schedule'),

                child: Text(

                  l10n.viewAll,

                  style: TextStyle(

                    fontSize: 13,

                    fontWeight: FontWeight.bold,

                    fontFamily: 'Cairo',

                    color: accentColor,

                  ),

                ),

              ),

            ],

          ),

          const SizedBox(height: 16),



          // Real Lecture Cards from Firestore

          coursesAsync.when(

            data: (courses) {

              if (courses.isEmpty) {

                return Center(

                  child: Padding(

                    padding: const EdgeInsets.symmetric(vertical: 24),

                    child: Text(

                      l10n.dashboardNoLectures,

                      style: TextStyle(

                        fontFamily: 'Cairo',

                        color: Colors.grey,

                        fontSize: 13,

                      ),

                    ),

                  ),

                );

              }

              return Column(

                children: [

                  ...courses.asMap().entries.take(2).map((entry) {

                    final course = entry.value;

                    final isArabic =

                        Localizations.localeOf(context).languageCode == 'ar';

                    final courseName = isArabic ? course.nameAr : course.nameEn;

                    final timeSlot =

                        course.schedule.isNotEmpty

                            ? course.schedule.first.split(' ').skip(1).join(' ')

                            : '08:30 - 10:30';

                    return Column(

                      children: [

                        _buildLectureCard(

                              context: context,

                              time: timeSlot.split('-')[0].trim(),

                              period: l10n.dashboardPeriodAM,

                              name: courseName,

                              location:

                                  course.room.isNotEmpty ? course.room : l10n.hall,

                              students: '${course.studentCount} ${l10n.student}',

                            )

                            .animate()

                            .fadeIn(

                              duration: 500.ms,

                              delay: (100 + entry.key * 100).ms,

                            )

                            .slideY(begin: 0.1),

                        if (entry.key < 1) const SizedBox(height: 12),

                      ],

                    );

                  }),

                ],

              );

            },

            loading:

                () => const Padding(

                  padding: EdgeInsets.symmetric(vertical: 24),

                  child: CircularProgressIndicator(strokeWidth: 2),

                ),

            error:

                (_, _) => Padding(

                  padding: const EdgeInsets.symmetric(vertical: 24),

                  child: Text(

                    l10n.dashboardLoadError,

                    style: TextStyle(color: Colors.red, fontFamily: 'Cairo'),

                  ),

                ),

          ),



          const SizedBox(height: 28),



          // 4. Grade Distribution Reports (تقارير توزيع الدرجات)

          Row(

            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [

              Text(

                l10n.dashboardGradeReports,

                style: TextStyle(

                  fontSize: 18,

                  fontWeight: FontWeight.bold,

                  fontFamily: 'Cairo',

                  color: primaryColor,

                ),

              ),

              GestureDetector(

                onTap: () => context.push('/faculty/reports'),

                child: Text(

                  l10n.viewAll,

                  style: TextStyle(

                    fontSize: 13,

                    fontWeight: FontWeight.bold,

                    fontFamily: 'Cairo',

                    color: accentColor,

                  ),

                ),

              ),

            ],

          ),

          const SizedBox(height: 16),



          // Grade Distribution Cards

          _GradeDistributionCard(
            title: l10n.dashboardAvgGrades,
            value: '0.0',
            subtitle: 'من جميع المواد',
            icon: Icons.bar_chart_rounded,
            colorSide: primaryColor,
          ),

          const SizedBox(height: 12),

          _GradeDistributionCard(
            title: l10n.dashboardPassRate,
            value: '0%',
            subtitle: 'في الفصل الحالي',
            icon: Icons.check_circle_rounded,
            colorSide: Colors.green,
          ),



          const SizedBox(height: 28),



          // 5. 2x2 Statistics Grid (Fixed - no GridView)
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 110,
                      child: _AcademicStatCard(
                        title: l10n.facultyEnrolledStudents,
                        value:
                            coursesAsync.value
                                ?.fold<int>(0, (total, c) => total + c.studentCount)
                                .toString() ??
                            '0',
                        icon: Icons.people_alt_rounded,
                        delay: 100,
                        colorSide: Colors.blue,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SizedBox(
                      height: 110,
                      child: _AcademicStatCard(
                        title: l10n.facultyCourses,
                        value: coursesAsync.value?.length.toString() ?? '0',
                        icon: Icons.book_rounded,
                        delay: 200,
                        colorSide: primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 110,
                      child: _AcademicStatCard(
                        title: l10n.dashboardPendingRequests,
                        value: pendingCountAsync.value?.toString() ?? '0',
                        icon: Icons.assignment_late_rounded,
                        delay: 300,
                        colorSide: Colors.redAccent,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SizedBox(
                      height: 110,
                      child: _AcademicStatCard(
                        title: l10n.dashboardWeekSessions,
                        value:
                            ((coursesAsync.value?.length ?? 0) * days.length)
                                .toString(),
                        icon: Icons.calendar_today_rounded,
                        delay: 400,
                        colorSide: Colors.grey.shade400,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ).animate().fadeIn(duration: 600.ms, delay: 200.ms),

        ],

      ),

    );

  }



  Widget _buildLectureCard({

    required BuildContext context,

    required String time,

    required String period,

    required String name,

    required String location,

    required String students,

  }) {

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardBackgroundColor = isDark ? const Color(0xFF0D2420) : Colors.white;

    final borderColor =

        isDark

            ? const Color(0xFF00A694).withValues(alpha: 0.5)

            : const Color(0xFF00A694).withValues(alpha: 0.3);

    final textColor =

        isDark ? const Color(0xFF10B981) : const Color(0xFF005A51);



    return Container(

      padding: const EdgeInsets.all(16.0),

      decoration: BoxDecoration(

        color: cardBackgroundColor,

        borderRadius: BorderRadius.circular(16),

        boxShadow: [

          BoxShadow(

            color: Colors.black.withValues(alpha: 0.03),

            blurRadius: 10,

            offset: const Offset(0, 4),

          ),

        ],

        border: Border.all(color: borderColor, width: 1.5),

      ),

      child: Row(

        children: [

          Container(

            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),

            decoration: BoxDecoration(

              color: const Color(0xFF00A694).withValues(alpha: 0.08),

              borderRadius: BorderRadius.circular(12),

            ),

            child: Column(

              children: [

                Text(

                  time,

                  style: const TextStyle(

                    fontSize: 12,

                    fontWeight: FontWeight.bold,

                    color: Color(0xFF00A694),

                  ),

                ),

                Text(

                  period,

                  style: const TextStyle(

                    fontSize: 10,

                    fontWeight: FontWeight.bold,

                    color: Color(0xFF00A694),

                    fontFamily: 'Cairo',

                  ),

                ),

              ],

            ),

          ),

          const SizedBox(width: 16),

          Expanded(

            child: Column(

              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                Text(

                  name,

                  style: TextStyle(

                    fontFamily: 'Cairo',

                    fontWeight: FontWeight.bold,

                    color: textColor,

                    fontSize: 15,

                  ),

                ),

                const SizedBox(height: 4),

                Row(

                  children: [

                    Icon(

                      Icons.room_rounded,

                      size: 12,

                      color: textColor.withValues(alpha: 0.6),

                    ),

                    const SizedBox(width: 4),

                    Text(

                      location,

                      style: TextStyle(

                        fontSize: 11,

                        color: textColor.withValues(alpha: 0.7),

                        fontFamily: 'Cairo',

                      ),

                    ),

                    const SizedBox(width: 16),

                    Icon(

                      Icons.people_alt_rounded,

                      size: 12,

                      color: textColor.withValues(alpha: 0.6),

                    ),

                    const SizedBox(width: 4),

                    Text(

                      students,

                      style: TextStyle(

                        fontSize: 11,

                        color: textColor.withValues(alpha: 0.7),

                        fontFamily: 'Cairo',

                      ),

                    ),

                  ],

                ),

              ],

            ),

          ),

          Icon(Icons.chevron_left_rounded, color: Colors.grey.shade400),

        ],

      ),

    );

  }

}



class _GradeDistributionCard extends StatelessWidget {

  final String title;

  final String value;

  final String subtitle;

  final IconData icon;

  final Color colorSide;



  const _GradeDistributionCard({

    required this.title,

    required this.value,

    required this.subtitle,

    required this.icon,

    required this.colorSide,

  });



  @override

  Widget build(BuildContext context) {

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardBackgroundColor = isDark ? const Color(0xFF0D2420) : Colors.white;

    final borderColor =

        isDark

            ? const Color(0xFF00A694).withValues(alpha: 0.5)

            : const Color(0xFF00A694).withValues(alpha: 0.3);

    final textColor =

        isDark ? const Color(0xFF10B981) : const Color(0xFF005A51);



    return Container(

      padding: const EdgeInsets.all(20.0),

      decoration: BoxDecoration(

        color: cardBackgroundColor,

        borderRadius: BorderRadius.circular(20),

        boxShadow: [

          BoxShadow(

            color: Colors.black.withValues(alpha: 0.03),

            blurRadius: 10,

            offset: const Offset(0, 4),

          ),

        ],

        border: Border.all(color: borderColor, width: 1.5),

      ),

      child: Row(

        children: [

          Container(

            width: 56,

            height: 56,

            decoration: BoxDecoration(

              color: colorSide.withValues(alpha: 0.12),

              shape: BoxShape.circle,

            ),

            child: Icon(icon, color: colorSide, size: 28),

          ),

          const SizedBox(width: 20),

          Expanded(

            child: Column(

              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                Text(

                  title,

                  style: TextStyle(

                    fontSize: 14,

                    color: textColor.withValues(alpha: 0.7),

                    fontFamily: 'Cairo',

                    fontWeight: FontWeight.w600,

                  ),

                ),

                const SizedBox(height: 4),

                Text(

                  value,

                  style: TextStyle(

                    fontSize: 24,

                    fontWeight: FontWeight.bold,

                    color: textColor,

                    fontFamily: 'Cairo',

                  ),

                ),

                Text(

                  subtitle,

                  style: TextStyle(

                    fontSize: 12,

                    color: textColor.withValues(alpha: 0.6),

                    fontFamily: 'Cairo',

                  ),

                ),

              ],

            ),

          ),

          Icon(

            Icons.chevron_left_rounded,

            color: textColor.withValues(alpha: 0.4),

          ),

        ],

      ),

    );

  }

}



class _AcademicStatCard extends StatelessWidget {

  final String title;

  final String value;

  final IconData icon;

  final int delay;

  final Color colorSide;



  const _AcademicStatCard({

    required this.title,

    required this.value,

    required this.icon,

    required this.delay,

    required this.colorSide,

  });



  @override

  Widget build(BuildContext context) {

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardBackgroundColor = isDark ? const Color(0xFF0D2420) : Colors.white;

    final borderColor =

        isDark

            ? const Color(0xFF00A694).withValues(alpha: 0.5)

            : const Color(0xFF00A694).withValues(alpha: 0.3);

    final textColor =

        isDark ? const Color(0xFF10B981) : const Color(0xFF005A51);



    return Container(

      padding: const EdgeInsets.all(16.0),

      decoration: BoxDecoration(

        color: cardBackgroundColor,

        borderRadius: const BorderRadius.only(

          topLeft: Radius.circular(20),

          bottomLeft: Radius.circular(20),

          topRight: Radius.circular(4),

          bottomRight: Radius.circular(4),

        ),

        boxShadow: [

          BoxShadow(

            color: Colors.black.withValues(alpha: 0.03),

            blurRadius: 10,

            offset: const Offset(0, 4),

          ),

        ],

        border: Border(

          right: BorderSide(color: colorSide, width: 4),

          left: BorderSide(color: borderColor, width: 1),

          top: BorderSide(color: borderColor, width: 1),

          bottom: BorderSide(color: borderColor, width: 1),

        ),

      ),

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          Icon(icon, color: colorSide, size: 24),

          const Spacer(),

          Text(

            value,

            style: TextStyle(

              fontSize: 26,

              fontWeight: FontWeight.bold,

              color: textColor,

              fontFamily: 'Cairo',

            ),

          ),

          const SizedBox(height: 2),

          Text(

            title,

            maxLines: 1,

            overflow: TextOverflow.ellipsis,

            style: TextStyle(

              fontSize: 11,

              color: textColor.withValues(alpha: 0.7),

              fontFamily: 'Cairo',

              fontWeight: FontWeight.w600,

            ),

          ),

        ],

      ),

    ).animate().fadeIn(duration: 500.ms, delay: delay.ms).slideY(begin: 0.1);

  }

}



// ── Quick Access Card ───────────────────────────────────────────────────

class _QuickAccessCard extends StatelessWidget {

  final IconData icon;

  final String title;

  final VoidCallback onTap;



  const _QuickAccessCard({

    required this.icon,

    required this.title,

    required this.onTap,

  });



  @override

  Widget build(BuildContext context) {

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardBackgroundColor = isDark ? const Color(0xFF0D2420) : Colors.white;

    final borderColor =

        isDark

            ? const Color(0xFF00A694).withValues(alpha: 0.5)

            : const Color(0xFF00A694).withValues(alpha: 0.3);

    final textColor =

        isDark ? const Color(0xFF10B981) : const Color(0xFF005A51);

    final iconColor =

        isDark ? const Color(0xFF10B981) : const Color(0xFF00A694);



    return InkWell(

      onTap: onTap,

      borderRadius: BorderRadius.circular(24),

      splashColor: const Color(0xFF00A694).withValues(alpha: 0.1),

      child: Container(

        padding: const EdgeInsets.all(24.0),

        decoration: BoxDecoration(

          color: cardBackgroundColor,

          borderRadius: BorderRadius.circular(24),

          boxShadow: [

            BoxShadow(

              color: Colors.black.withValues(alpha: 0.04),

              blurRadius: 16,

              offset: const Offset(0, 6),

            ),

          ],

          border: Border.all(color: borderColor, width: 1.5),

        ),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.center,

          children: [

            Container(

              width: 64,

              height: 64,

              decoration: BoxDecoration(

                color: const Color(0xFF00A694).withValues(alpha: 0.12),

                shape: BoxShape.circle,

              ),

              child: Icon(icon, color: iconColor, size: 32),

            ),

            const SizedBox(height: 20),

            Text(

              title,

              textAlign: TextAlign.center,

              style: TextStyle(

                fontSize: 15,

                fontWeight: FontWeight.bold,

                fontFamily: 'Cairo',

                color: textColor,

              ),

            ),

            const SizedBox(height: 12),

            Container(

              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),

              decoration: BoxDecoration(

                color: const Color(0xFF00A694).withValues(alpha: 0.08),

                borderRadius: BorderRadius.circular(20),

              ),

              child: Icon(

                Icons.arrow_forward_rounded,

                size: 18,

                color: iconColor,

              ),

            ),

          ],

        ),

      ),

    );

  }

}



// ── Tab 1: My Classes ───────────────────────────────────────────────────

class _ClassesTab extends ConsumerWidget {

  const _ClassesTab();



  @override

  Widget build(BuildContext context, WidgetRef ref) {

    final coursesAsync = ref.watch(facultyCoursesProvider);

    final l10n = AppLocalizations.of(context)!;



    return coursesAsync.when(

      data: (courses) {

        if (courses.isEmpty) {

          return Center(

            child: Text(

              l10n.facultyNoCourses,

              style: const TextStyle(fontFamily: 'Cairo', fontSize: 16),

            ),

          );

        }

        return ListView.builder(

          padding: const EdgeInsets.all(20),

          itemCount: courses.length,

          itemBuilder: (context, index) {

            final course = courses[index];

            return Container(

                  margin: const EdgeInsets.only(bottom: 16),

                  decoration: BoxDecoration(

                    color: Colors.white,

                    borderRadius: BorderRadius.circular(16),

                    boxShadow: [

                      BoxShadow(

                        color: Colors.black.withValues(alpha: 0.04),

                        blurRadius: 8,

                        offset: const Offset(0, 4),

                      ),

                    ],

                    border: Border.all(

                      color: const Color(0xFFE0E0E0),

                      width: 0.5,

                    ),

                  ),

                  child: Material(

                    color: Colors.transparent,

                    child: InkWell(

                      borderRadius: BorderRadius.circular(16),

                      onTap:

                          () =>

                              context.push('/faculty/class/${course.courseId}'),

                      child: Padding(

                        padding: const EdgeInsets.all(16.0),

                        child: Row(

                          children: [

                            Container(

                              width: 48,

                              height: 48,

                              decoration: BoxDecoration(

                                color: const Color(

                                  0xFF005A51,

                                ).withValues(alpha: 0.05),

                                borderRadius: BorderRadius.circular(12),

                              ),

                              child: const Center(

                                child: Icon(

                                  Icons.library_books_rounded,

                                  color: Color(0xFF005A51),

                                ),

                              ),

                            ),

                            const SizedBox(width: 16),

                            Expanded(

                              child: Column(

                                crossAxisAlignment: CrossAxisAlignment.start,

                                children: [

                                  Text(

                                    course.nameAr,

                                    style: const TextStyle(

                                      fontWeight: FontWeight.bold,

                                      fontSize: 16,

                                      fontFamily: 'Cairo',

                                      color: Color(0xFF005A51),

                                    ),

                                  ),

                                  const SizedBox(height: 4),

                                  Text(

                                    l10n.facultyClassSub(

                                      course.departmentId,

                                      course.semester,

                                    ),

                                    style: const TextStyle(

                                      fontSize: 12,

                                      color: Colors.grey,

                                      fontFamily: 'Cairo',

                                    ),

                                  ),

                                ],

                              ),

                            ),

                            Container(

                              padding: const EdgeInsets.symmetric(

                                horizontal: 10,

                                vertical: 4,

                              ),

                              decoration: BoxDecoration(

                                color: const Color(

                                  0xFF00A694,

                                ).withValues(alpha: 0.1),

                                borderRadius: BorderRadius.circular(8),

                              ),

                              child: Row(

                                children: [

                                  const Icon(

                                    Icons.people_alt_rounded,

                                    size: 14,

                                    color: Color(0xFF00A694),

                                  ),

                                  const SizedBox(width: 4),

                                  Text(

                                    '${course.studentCount}',

                                    style: const TextStyle(

                                      color: Color(0xFF00A694),

                                      fontWeight: FontWeight.bold,

                                      fontSize: 12,

                                    ),

                                  ),

                                ],

                              ),

                            ),

                          ],

                        ),

                      ),

                    ),

                  ),

                )

                .animate()

                .fadeIn(duration: 400.ms, delay: (index * 100).ms)

                .slideX(begin: 0.05);

          },

        );

      },

      loading:

          () => const Center(

            child: CircularProgressIndicator(color: Color(0xFF005A51)),

          ),

      error: (e, st) => Center(child: Text('${l10n.errorPrefix}$e')),

    );

  }

}



// ── Tab 2: Attendance ───────────────────────────────────────────────────

class _AttendanceTab extends ConsumerStatefulWidget {

  const _AttendanceTab();

  @override

  ConsumerState<_AttendanceTab> createState() => _AttendanceTabState();

}



class _AttendanceTabState extends ConsumerState<_AttendanceTab> {

  CourseModel? _selectedCourse;

  DateTime _selectedDate = DateTime.now();



  @override

  Widget build(BuildContext context) {

    final coursesAsync = ref.watch(facultyCoursesProvider);

    final l10n = AppLocalizations.of(context)!;



    return Column(

      children: [

        Container(

          padding: const EdgeInsets.all(20.0),

          decoration: BoxDecoration(

            color: Colors.white,

            boxShadow: [

              BoxShadow(

                color: Colors.black.withValues(alpha: 0.02),

                blurRadius: 10,

                offset: const Offset(0, 4),

              ),

            ],

          ),

          child: Column(

            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              Text(

                l10n.attendanceTitle,

                style: const TextStyle(

                  fontFamily: 'Cairo',

                  fontWeight: FontWeight.bold,

                  fontSize: 18,

                  color: Color(0xFF005A51),

                ),

              ),

              const SizedBox(height: 16),

              Row(

                children: [

                  Expanded(

                    child: coursesAsync.when(

                      data: (courses) {

                        if (courses.isEmpty) {

                          return Text(l10n.facultyNoCourses);

                        }

                        return InputDecorator(

                          decoration: InputDecoration(

                            contentPadding: const EdgeInsets.symmetric(

                              horizontal: 16,

                              vertical: 4,

                            ),

                            border: OutlineInputBorder(

                              borderRadius: BorderRadius.circular(12),

                              borderSide: BorderSide(

                                color: Colors.grey.shade300,

                              ),

                            ),

                            enabledBorder: OutlineInputBorder(

                              borderRadius: BorderRadius.circular(12),

                              borderSide: BorderSide(

                                color: Colors.grey.shade300,

                              ),

                            ),

                            filled: true,

                            fillColor: const Color(0xFFF9FAFB),

                          ),

                          child: DropdownButtonHideUnderline(

                            child: DropdownButton<CourseModel>(

                              value: _selectedCourse,

                              isExpanded: true,

                              hint: Text(

                                l10n.facultySelectCourse,

                                style: const TextStyle(

                                  fontFamily: 'Cairo',

                                  fontSize: 13,

                                ),

                              ),

                              items:

                                  courses

                                      .map(

                                        (c) => DropdownMenuItem(

                                          value: c,

                                          child: Text(

                                            c.nameAr,

                                            style: const TextStyle(

                                              fontFamily: 'Cairo',

                                              fontSize: 14,

                                            ),

                                          ),

                                        ),

                                      )

                                      .toList(),

                              onChanged: (val) {

                                setState(() => _selectedCourse = val);

                                if (val != null) {

                                  ref

                                      .read(attendanceProvider.notifier)

                                      .loadAttendance(

                                        val.courseId,

                                        DateFormat(

                                          'yyyy-MM-dd',

                                        ).format(_selectedDate),

                                      );

                                }

                              },

                            ),

                          ),

                        );

                      },

                      loading: () => const LinearProgressIndicator(),

                      error: (e, st) => Text(l10n.facultyErrorLoadingCourses),

                    ),

                  ),

                  const SizedBox(width: 12),

                  InkWell(

                    onTap: () async {

                      final d = await showDatePicker(

                        context: context,

                        initialDate: _selectedDate,

                        firstDate: DateTime(2020),

                        lastDate: DateTime(2100),

                      );

                      if (d != null) {

                        setState(() => _selectedDate = d);

                        if (_selectedCourse != null) {

                          ref

                              .read(attendanceProvider.notifier)

                              .loadAttendance(

                                _selectedCourse!.courseId,

                                DateFormat('yyyy-MM-dd').format(d),

                              );

                        }

                      }

                    },

                    borderRadius: BorderRadius.circular(12),

                    child: Container(

                      padding: const EdgeInsets.symmetric(

                        horizontal: 16,

                        vertical: 14,

                      ),

                      decoration: BoxDecoration(

                        border: Border.all(color: Colors.grey.shade300),

                        borderRadius: BorderRadius.circular(12),

                        color: Colors.white,

                      ),

                      child: Row(

                        children: [

                          const Icon(

                            Icons.calendar_today_rounded,

                            size: 18,

                            color: Color(0xFF005A51),

                          ),

                          const SizedBox(width: 8),

                          Text(

                            DateFormat('MM/dd').format(_selectedDate),

                            style: const TextStyle(

                              fontWeight: FontWeight.bold,

                              color: Color(0xFF005A51),

                            ),

                          ),

                        ],

                      ),

                    ),

                  ),

                ],

              ),

            ],

          ),

        ),

        Expanded(

          child:

              _selectedCourse == null

                  ? Center(

                    child: Column(

                      mainAxisAlignment: MainAxisAlignment.center,

                      children: [

                        Icon(

                          Icons.fact_check_outlined,

                          size: 60,

                          color: Colors.grey.shade300,

                        ),

                        const SizedBox(height: 16),

                        Text(

                          l10n.facultySelectCourseForStudents,

                          style: TextStyle(

                            fontFamily: 'Cairo',

                            color: Colors.grey.shade500,

                            fontSize: 16,

                          ),

                        ),

                      ],

                    ).animate().fadeIn(duration: 800.ms),

                  )

                  : _AttendanceList(

                    course: _selectedCourse!,

                    date: DateFormat('yyyy-MM-dd').format(_selectedDate),

                  ),

        ),

      ],

    );

  }

}



class _AttendanceList extends ConsumerWidget {

  final CourseModel course;

  final String date;

  const _AttendanceList({required this.course, required this.date});



  @override

  Widget build(BuildContext context, WidgetRef ref) {

    final studentsAsync = ref.watch(classStudentsProvider(course));

    final attendanceAsync = ref.watch(attendanceProvider);

    final l10n = AppLocalizations.of(context)!;



    return studentsAsync.when(

      data: (students) {

        if (students.isEmpty) {

          return Center(

            child: Text(

              l10n.facultyNoStudents,

              style: const TextStyle(fontFamily: 'Cairo'),

            ),

          );

        }

        return ListView.separated(

          padding: const EdgeInsets.all(20),

          itemCount: students.length,

          separatorBuilder: (context, index) => const Divider(height: 1),

          itemBuilder: (context, index) {

            final student = students[index];

            final records = attendanceAsync.value ?? [];

            final record =

                records.where((r) => r.studentUid == student.uid).firstOrNull;

            final isPresent = record?.isPresent ?? false;



            return ListTile(

              contentPadding: const EdgeInsets.symmetric(

                vertical: 8,

                horizontal: 8,

              ),

              leading: CircleAvatar(

                backgroundColor: const Color(

                  0xFF001835,

                ).withValues(alpha: 0.05),

                child: const Icon(Icons.person, color: Color(0xFF005A51)),

              ),

              title: Text(

                student.fullNameAr.isNotEmpty

                    ? student.fullNameAr

                    : student.fullName,

                style: const TextStyle(

                  fontFamily: 'Cairo',

                  fontWeight: FontWeight.bold,

                  fontSize: 14,

                ),

              ),

              subtitle: Text(

                student.universityId,

                style: const TextStyle(

                  fontFamily: 'Cairo',

                  fontSize: 12,

                  color: Colors.grey,

                ),

              ),

              trailing: Transform.scale(

                scale: 1.2,

                child: Checkbox(

                  value: isPresent,

                  activeColor: const Color(0xFF00A694),

                  shape: RoundedRectangleBorder(

                    borderRadius: BorderRadius.circular(4),

                  ),

                  onChanged: (val) {

                    if (val != null) {

                      ref

                          .read(attendanceProvider.notifier)

                          .saveAttendance(

                            course.courseId,

                            date,

                            student.uid,

                            val,

                          );

                    }

                  },

                ),

              ),

            ).animate().fadeIn(duration: 300.ms, delay: (index * 50).ms);

          },

        );

      },

      loading:

          () => const Center(

            child: CircularProgressIndicator(color: Color(0xFF005A51)),

          ),

      error: (e, st) => Center(child: Text('${l10n.errorPrefix}$e')),

    );

  }

}



// ── Tab 3: Grades ───────────────────────────────────────────────────────

class _GradesTab extends ConsumerStatefulWidget {

  const _GradesTab();

  @override

  ConsumerState<_GradesTab> createState() => _GradesTabState();

}



class _GradesTabState extends ConsumerState<_GradesTab> {

  CourseModel? _selectedCourse;



  @override

  Widget build(BuildContext context) {

    final coursesAsync = ref.watch(facultyCoursesProvider);

    final l10n = AppLocalizations.of(context)!;



    return Column(

      children: [

        Container(

          padding: const EdgeInsets.all(20.0),

          decoration: BoxDecoration(

            color: Colors.white,

            boxShadow: [

              BoxShadow(

                color: Colors.black.withValues(alpha: 0.02),

                blurRadius: 10,

                offset: const Offset(0, 4),

              ),

            ],

          ),

          child: Column(

            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              Text(

                l10n.facultyGradesTitle,

                style: const TextStyle(

                  fontFamily: 'Cairo',

                  fontWeight: FontWeight.bold,

                  fontSize: 18,

                  color: Color(0xFF005A51),

                ),

              ),

              const SizedBox(height: 16),

              coursesAsync.when(

                data: (courses) {

                  if (courses.isEmpty) return Text(l10n.facultyNoCourses);

                  return InputDecorator(

                    decoration: InputDecoration(

                      contentPadding: const EdgeInsets.symmetric(

                        horizontal: 16,

                        vertical: 4,

                      ),

                      border: OutlineInputBorder(

                        borderRadius: BorderRadius.circular(12),

                        borderSide: BorderSide(color: Colors.grey.shade300),

                      ),

                      enabledBorder: OutlineInputBorder(

                        borderRadius: BorderRadius.circular(12),

                        borderSide: BorderSide(color: Colors.grey.shade300),

                      ),

                      filled: true,

                      fillColor: const Color(0xFFF9FAFB),

                    ),

                    child: DropdownButtonHideUnderline(

                      child: DropdownButton<CourseModel>(

                        value: _selectedCourse,

                        isExpanded: true,

                        hint: Text(

                          l10n.facultySelectCourse,

                          style: const TextStyle(

                            fontFamily: 'Cairo',

                            fontSize: 13,

                          ),

                        ),

                        items:

                            courses

                                .map(

                                  (c) => DropdownMenuItem(

                                    value: c,

                                    child: Text(

                                      c.nameAr,

                                      style: const TextStyle(

                                        fontFamily: 'Cairo',

                                        fontSize: 14,

                                      ),

                                    ),

                                  ),

                                )

                                .toList(),

                        onChanged: (val) {

                          setState(() => _selectedCourse = val);

                          if (val != null) {

                            ref

                                .read(gradesProvider.notifier)

                                .loadGrades(val.courseId);

                          }

                        },

                      ),

                    ),

                  );

                },

                loading: () => const LinearProgressIndicator(),

                error: (e, st) => Text(l10n.facultyErrorLoadingCourses),

              ),

            ],

          ),

        ),

        Expanded(

          child:

              _selectedCourse == null

                  ? Center(

                    child: Column(

                      mainAxisAlignment: MainAxisAlignment.center,

                      children: [

                        Icon(

                          Icons.grade_outlined,

                          size: 60,

                          color: Colors.grey.shade300,

                        ),

                        const SizedBox(height: 16),

                        Text(

                          l10n.facultySelectCourseForGrades,

                          style: TextStyle(

                            fontFamily: 'Cairo',

                            color: Colors.grey.shade500,

                            fontSize: 16,

                          ),

                        ),

                      ],

                    ).animate().fadeIn(duration: 800.ms),

                  )

                  : _GradesList(course: _selectedCourse!),

        ),

      ],

    );

  }

}



class _GradesList extends ConsumerWidget {

  final CourseModel course;

  const _GradesList({required this.course});



  @override

  Widget build(BuildContext context, WidgetRef ref) {

    final studentsAsync = ref.watch(classStudentsProvider(course));

    final gradesAsync = ref.watch(gradesProvider);

    final l10n = AppLocalizations.of(context)!;



    return studentsAsync.when(

      data: (students) {

        if (students.isEmpty) {

          return Center(

            child: Text(

              l10n.facultyNoStudents,

              style: const TextStyle(fontFamily: 'Cairo'),

            ),

          );

        }

        return ListView.builder(

          padding: const EdgeInsets.all(20),

          itemCount: students.length,

          itemBuilder: (context, index) {

            final student = students[index];

            final grades = gradesAsync.value ?? [];

            final grade =

                grades.where((g) => g.studentUid == student.uid).firstOrNull;



            return Container(

                  margin: const EdgeInsets.only(bottom: 16),

                  padding: const EdgeInsets.all(16.0),

                  decoration: BoxDecoration(

                    color: Colors.white,

                    borderRadius: BorderRadius.circular(16),

                    border: Border.all(color: Colors.grey.shade200),

                    boxShadow: [

                      BoxShadow(

                        color: Colors.black.withValues(alpha: 0.02),

                        blurRadius: 10,

                        offset: const Offset(0, 4),

                      ),

                    ],

                  ),

                  child: Column(

                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [

                      Row(

                        children: [

                          CircleAvatar(

                            radius: 16,

                            backgroundColor: const Color(

                              0xFF005A51,

                            ).withValues(alpha: 0.1),

                            child: const Icon(

                              Icons.person,

                              size: 16,

                              color: Color(0xFF005A51),

                            ),

                          ),

                          const SizedBox(width: 12),

                          Expanded(

                            child: Column(

                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [

                                Text(

                                  student.fullNameAr.isNotEmpty

                                      ? student.fullNameAr

                                      : student.fullName,

                                  style: const TextStyle(

                                    fontWeight: FontWeight.bold,

                                    fontFamily: 'Cairo',

                                    fontSize: 14,

                                  ),

                                ),

                                Text(

                                  student.universityId,

                                  style: const TextStyle(

                                    color: Colors.grey,

                                    fontSize: 12,

                                    fontFamily: 'Cairo',

                                  ),

                                ),

                              ],

                            ),

                          ),

                          Container(

                            padding: const EdgeInsets.symmetric(

                              horizontal: 12,

                              vertical: 6,

                            ),

                            decoration: BoxDecoration(

                              color: const Color(0xFF005A51),

                              borderRadius: BorderRadius.circular(8),

                            ),

                            child: Text(

                              l10n.facultyTotalScorePrefix(

                                (grade?.total ?? 0).toDouble(),

                              ),

                              style: const TextStyle(

                                fontWeight: FontWeight.bold,

                                color: Colors.white,

                                fontFamily: 'Cairo',

                                fontSize: 12,

                              ),

                            ),

                          ),

                        ],

                      ),

                      const SizedBox(height: 16),

                      Form(

                        autovalidateMode: AutovalidateMode.onUserInteraction,

                        child: Row(

                          children: [

                            Expanded(

                              child: TextFormField(

                                initialValue: grade?.midterm.toString() ?? '0',

                                decoration: InputDecoration(

                                  labelText: l10n.facultyMidtermLabel,

                                  labelStyle: const TextStyle(

                                    fontFamily: 'Cairo',

                                    fontSize: 12,

                                  ),

                                  border: OutlineInputBorder(

                                    borderRadius: BorderRadius.circular(8),

                                  ),

                                  contentPadding: const EdgeInsets.symmetric(

                                    horizontal: 12,

                                    vertical: 8,

                                  ),

                                ),

                                keyboardType: TextInputType.number,

                                validator: (val) {

                                  final v = double.tryParse(val ?? '');

                                  if (v == null) return l10n.gradeInvalidNumber;

                                  if (v < 0 || v > 40) {

                                    return l10n.gradeMaxMidterm;

                                  }

                                  return null;

                                },

                                onFieldSubmitted: (val) {

                                  final v = double.tryParse(val);

                                  if (v == null || v < 0 || v > 40) return;

                                  ref

                                      .read(gradesProvider.notifier)

                                      .saveGrade(

                                        course.courseId,

                                        student.uid,

                                        midterm: v,

                                        finalExam: grade?.finalExam,

                                        assignments: grade?.assignments,

                                      );

                                },

                              ),

                            ),

                            const SizedBox(width: 8),

                            Expanded(

                              child: TextFormField(

                                initialValue:

                                    grade?.finalExam.toString() ?? '0',

                                decoration: InputDecoration(

                                  labelText: l10n.facultyFinalLabel,

                                  labelStyle: const TextStyle(

                                    fontFamily: 'Cairo',

                                    fontSize: 12,

                                  ),

                                  border: OutlineInputBorder(

                                    borderRadius: BorderRadius.circular(8),

                                  ),

                                  contentPadding: const EdgeInsets.symmetric(

                                    horizontal: 12,

                                    vertical: 8,

                                  ),

                                ),

                                keyboardType: TextInputType.number,

                                validator: (val) {

                                  final v = double.tryParse(val ?? '');

                                  if (v == null) return l10n.gradeInvalidNumber;

                                  if (v < 0 || v > 40) {

                                    return l10n.gradeMaxFinal;

                                  }

                                  return null;

                                },

                                onFieldSubmitted: (val) {

                                  final v = double.tryParse(val);

                                  if (v == null || v < 0 || v > 40) return;

                                  ref

                                      .read(gradesProvider.notifier)

                                      .saveGrade(

                                        course.courseId,

                                        student.uid,

                                        finalExam: v,

                                        midterm: grade?.midterm,

                                        assignments: grade?.assignments,

                                      );

                                },

                              ),

                            ),

                            const SizedBox(width: 8),

                            Expanded(

                              child: TextFormField(

                                initialValue:

                                    grade?.assignments.toString() ?? '0',

                                decoration: InputDecoration(

                                  labelText: l10n.facultyAssignmentsLabel,

                                  labelStyle: const TextStyle(

                                    fontFamily: 'Cairo',

                                    fontSize: 12,

                                  ),

                                  border: OutlineInputBorder(

                                    borderRadius: BorderRadius.circular(8),

                                  ),

                                  contentPadding: const EdgeInsets.symmetric(

                                    horizontal: 12,

                                    vertical: 8,

                                  ),

                                ),

                                keyboardType: TextInputType.number,

                                validator: (val) {

                                  final v = double.tryParse(val ?? '');

                                  if (v == null) return l10n.gradeInvalidNumber;

                                  if (v < 0 || v > 20) {

                                    return l10n.gradeMaxAssignments;

                                  }

                                  return null;

                                },

                                onFieldSubmitted: (val) {

                                  final v = double.tryParse(val);

                                  if (v == null || v < 0 || v > 20) return;

                                  ref

                                      .read(gradesProvider.notifier)

                                      .saveGrade(

                                        course.courseId,

                                        student.uid,

                                        assignments: v,

                                        midterm: grade?.midterm,

                                        finalExam: grade?.finalExam,

                                      );

                                },

                              ),

                            ),

                          ],

                        ),

                      ),

                    ],

                  ),

                )

                .animate()

                .fadeIn(duration: 400.ms, delay: (index * 50).ms)

                .slideY(begin: 0.05);

          },

        );

      },

      loading:

          () => const Center(

            child: CircularProgressIndicator(color: Color(0xFF005A51)),

          ),

      error: (e, st) => Center(child: Text('${l10n.errorPrefix}$e')),

    );

  }

}

