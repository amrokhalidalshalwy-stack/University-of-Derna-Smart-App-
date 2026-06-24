import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_project/features/auth/data/auth_service.dart';
import 'package:flutter_project/features/auth/data/cached_user_profile_provider.dart';
import 'package:flutter_project/features/faculty/providers/faculty_provider.dart';
import 'package:flutter_project/l10n/app_localizations.dart';
import 'package:flutter_project/shared/widgets/animated_widgets.dart';
import 'package:flutter_project/features/faculty/presentation/utils/faculty_assignments_navigation.dart';

class DashboardHomeTab extends ConsumerWidget {
  const DashboardHomeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateChangesProvider).value;
    final userDataAsync = ref.watch(userDataProvider(user?.uid ?? ''));
    final coursesAsync = ref.watch(facultyCoursesProvider);
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
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1B4F8C), Color(0xFF153b69)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1B4F8C).withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                userDataAsync.when(
                  data: (profile) {
                    final firstName = profile?['firstName'] as String? ?? '';
                    final lastName = profile?['lastName'] as String? ?? '';
                    final name = [firstName, lastName].where((s) => s.isNotEmpty).join(' ');
                    return Text(
                      '${l10n.dashboardWelcome} ${name.isNotEmpty ? name : l10n.dashboardDoctorFallback}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo',
                      ),
                    );
                  },
                  loading: () => SizedBox(
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
                  error: (_, _) => Text(
                    l10n.dashboardWelcome,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${DateTime.now().day} / ${DateTime.now().month} / ${DateTime.now().year}  |  ${DateTime.now().toString().split(' ')[0]}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontSize: 13,
                    fontFamily: 'Cairo',
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FadeInScale(
                      child: _buildQuickStat(
                        value: coursesAsync.value?.length.toString() ?? '0',
                        label: l10n.dashboardCoursesTaught,
                      ),
                    ),
                    FadeInScale(
                      child: _buildQuickStat(
                        value: coursesAsync.value
                                ?.fold<int>(
                                    0, (total, c) => total + c.studentCount)
                                .toString() ??
                            '0',
                        label: l10n.dashboardStudentCount,
                      ),
                    ),
                    FadeInScale(
                      child: _buildQuickStat(
                        value: ((coursesAsync.value?.length ?? 0) * days.length)
                            .toString(),
                        label: l10n.dashboardWeeklyLectures,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1),

          const SizedBox(height: 28),

          Text(
            l10n.dashboardQuickActions,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Cairo',
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                TapScale(
                  child: _buildQuickAction(
                    context,
                    icon: Icons.fact_check_rounded,
                    label: l10n.scheduleAttendanceButton,
                    color: const Color(0xFF00A694),
                    onTap: () => context.push('/faculty/attendance-sheet'),
                  ),
                ),
                TapScale(
                  child: _buildQuickAction(
                    context,
                    icon: Icons.upload_file_rounded,
                    label: l10n.dashboardActionUploadLecture,
                    color: Colors.blue,
                    onTap: () {},
                  ),
                ),
                TapScale(
                  child: _buildQuickAction(
                    context,
                    icon: Icons.picture_as_pdf_rounded,
                    label: l10n.dashboardActionUploadExam,
                    color: Colors.indigo,
                    onTap: () => context.push('/faculty/exam-paper-upload'),
                  ),
                ),
                TapScale(
                  child: _buildQuickAction(
                    context,
                    icon: Icons.assignment_rounded,
                    label: l10n.dashboardActionAddAssignment,
                    color: Colors.orange,
                    onTap: () => openFacultyAssignments(context, ref),
                  ),
                ),
                TapScale(
                  child: _buildQuickAction(
                    context,
                    icon: Icons.grade_rounded,
                    label: l10n.facultyGradesTitle,
                    color: Colors.purple,
                    onTap: () => context.push('/faculty/grades-entry'),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 600.ms, delay: 100.ms),

          const SizedBox(height: 28),

          Text(
            l10n.dashboardRecentActivity,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Cairo',
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildRecentActivityTile(
                  title: 'تم اعتماد درجات مقرر تحليل الأنظمة',
                  time: 'منذ ساعتين',
                  icon: Icons.check_circle_rounded,
                  color: Colors.green,
                ),
                const Divider(height: 1),
                _buildRecentActivityTile(
                  title: 'إشعار من الإدارة: موعد امتحانات النصفي',
                  time: 'أمس',
                  icon: Icons.campaign_rounded,
                  color: Colors.orange,
                ),
                const Divider(height: 1),
                _buildRecentActivityTile(
                  title: 'تسجيل حضور برمجة الويب مكتمل',
                  time: 'منذ يومين',
                  icon: Icons.fact_check_rounded,
                  color: Colors.blue,
                ),
              ],
            ),
          ).animate().fadeIn(duration: 600.ms, delay: 200.ms),

          const SizedBox(height: 28),

          const SizedBox(height: 28),

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
                  l10n.dashboardViewAll,
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
                        StaggeredFadeInSlideY(
                          index: entry.key,
                          child: _buildLectureCard(
                                context: context,
                                time: timeSlot.split('-')[0].trim(),
                                period: l10n.dashboardPeriodAM,
                                name: courseName,
                                location:
                                    course.room.isNotEmpty ? course.room : l10n.hall,
                                students: '${course.studentCount} ${l10n.student}',
                              ),
                        ),
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

          Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.dashboardGradesProgress,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 20),
                _buildProgressItem('تحليل الأنظمة', 0.85, accentColor),
                const SizedBox(height: 16),
                _buildProgressItem('الذكاء الاصطناعي', 0.40, Colors.redAccent),
                const SizedBox(height: 16),
                _buildProgressItem('برمجة الويب', 1.0, primaryColor),
              ],
            ),
          ).animate().fadeIn(duration: 600.ms, delay: 300.ms),

          const SizedBox(height: 28),

          Text(
            l10n.facultyWeeklyAttendance,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Cairo',
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 200,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
            ),
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 20,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        const style = TextStyle(
                          color: Color(0xFF757575),
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          fontFamily: 'Cairo',
                        );
                        final int index = value.toInt();
                        final String text =
                            (index >= 0 && index < days.length)
                                ? days[index]
                                : '';
                        return SideTitleWidget(
                          meta: meta,
                          child: Text(text, style: style),
                        );
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: [
                  _buildBarGroup(0, 15, accentColor),
                  _buildBarGroup(1, 18, accentColor),
                  _buildBarGroup(2, 14, accentColor),
                  _buildBarGroup(3, 19, accentColor),
                  _buildBarGroup(4, 12, accentColor),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 600.ms, delay: 400.ms),
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
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
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
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.room_rounded,
                      size: 12,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      location,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.people_alt_rounded,
                      size: 12,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      students,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
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

  Widget _buildQuickStat({required String value, required String label}) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Cairo',
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
            fontFamily: 'Cairo',
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0),
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivityTile({
    required String title,
    required String time,
    required IconData icon,
    required Color color,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        time,
        style: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 11,
          color: Colors.grey,
        ),
      ),
      trailing: const Icon(Icons.chevron_left_rounded, size: 20, color: Colors.grey),
    );
  }

  Widget _buildProgressItem(String title, double value, Color barColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF424242),
              ),
            ),
            Text(
              '${(value * 100).toInt()}%',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: barColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 8,
            backgroundColor: Colors.grey.shade100,
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
          ),
        ),
      ],
    );
  }

  BarChartGroupData _buildBarGroup(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          width: 14,
          color: color,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
}
