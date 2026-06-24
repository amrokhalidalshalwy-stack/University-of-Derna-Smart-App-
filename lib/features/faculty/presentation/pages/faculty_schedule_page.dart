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
  ConsumerState<FacultySchedulePage> createState() =>
      _FacultySchedulePageState();
}

class _FacultySchedulePageState extends ConsumerState<FacultySchedulePage> {
  int _selectedDayIndex = 0;

  List<Map<String, String>> _buildDaysOfWeek(AppLocalizations l10n) {
    final now = DateTime.now();
    final sunday = now.subtract(Duration(days: now.weekday % 7));
    final dayNamesAr = [
      l10n.daySunday,
      l10n.dayMonday,
      l10n.dayTuesday,
      l10n.dayWednesday,
      l10n.dayThursday,
    ];
    final dayNamesEn = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
    ];

    return List.generate(5, (i) {
      final d = sunday.add(Duration(days: i));
      return {
        'ar': dayNamesAr[i],
        'en': dayNamesEn[i],
        'date': d.day.toString(),
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final brandTeal =
        isDark
            ? const Color(0xFF10B981)
            : Theme.of(context).colorScheme.primary;
    final brandNavy =
        isDark
            ? const Color(0xFF0D2420)
            : const Color(0xFF00A694);
    final l10n = AppLocalizations.of(context)!;

    final user = ref.watch(authStateChangesProvider).value;
    final userDataAsync = ref.watch(userDataProvider(user?.uid ?? ''));
    final coursesAsync = ref.watch(facultyCoursesProvider);

    final daysOfWeek = _buildDaysOfWeek(l10n);
    final String selectedDayNameAr = daysOfWeek[_selectedDayIndex]['ar']!;
    final String selectedDayNameEn = daysOfWeek[_selectedDayIndex]['en']!;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF051412) : const Color(0xFFF0FAFA),
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(
              Icons.calendar_month_rounded,
              color: Colors.white,
              size: 22,
            ),
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
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    l10n.scheduleNotificationsEnabled,
                    style: const TextStyle(fontFamily: 'Cairo'),
                  ),
                ),
              );
            },
            icon: const Icon(Icons.notifications_none_rounded),
            tooltip: l10n.notifications,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. User Greeting Section
            Container(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
              color: isDark ? const Color(0xFF132220) : Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  userDataAsync.when(
                    data: (profile) {
                      final fullName = profile?['fullName'] as String? ?? '';
                      return Text(
                        '${l10n.scheduleGreetingDoctor} ${fullName.isNotEmpty ? fullName : 'أحمد'}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    },
                    loading: () => const SizedBox(width: 50, height: 14),
                    error: (_, _) => const SizedBox(),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: brandTeal.withValues(alpha: isDark ? 0.2 : 1.0),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      l10n.scheduleTerm,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? brandTeal : Colors.white,
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 2. Day Selector Calendar Row
            Container(
              width: double.infinity,
              color: isDark ? const Color(0xFF132220) : Colors.white,
              padding: const EdgeInsets.only(bottom: 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: List.generate(daysOfWeek.length, (index) {
                    final day = daysOfWeek[index];
                    final bool isSelected = index == _selectedDayIndex;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedDayIndex = index;
                        });
                      },
                      child: Container(
                        width: 76,
                        margin: const EdgeInsets.only(left: 10),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? brandTeal
                                  : (isDark
                                      ? const Color(0xFF0D2D2A)
                                      : Colors.white),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color:
                                isSelected
                                    ? Colors.transparent
                                    : (isDark
                                        ? Colors.white10
                                        : Colors.grey.shade200),
                          ),
                          boxShadow:
                              isSelected
                                  ? [
                                    BoxShadow(
                                      color: brandTeal.withValues(alpha: 0.35),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                  : null,
                        ),
                        child: Column(
                          children: [
                            Text(
                              day['ar']!,
                              style: TextStyle(
                                fontSize: 12,
                                color:
                                    isSelected
                                        ? (isDark
                                            ? const Color(0xFF132220)
                                            : Colors.white)
                                        : (isDark
                                            ? Colors.white54
                                            : Colors.grey),
                                fontFamily: 'Cairo',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              day['date']!,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color:
                                    isSelected
                                        ? (isDark
                                            ? const Color(0xFF132220)
                                            : Colors.white)
                                        : (isDark ? const Color(0xFFE8E8E8).withValues(alpha: 0.7) : brandNavy),
                                fontFamily: 'Cairo',
                              ),
                            ),
                          ],
                        ),
                      ).animate().scale(
                        duration: 200.ms,
                        curve: Curves.easeOut,
                      ),
                    );
                  }),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // 3. Schedule Lectures Listing
            Expanded(
              child: coursesAsync.when(
                data: (courses) {
                  final filteredCourses =
                      courses.where((c) {
                        final firstSchedule =
                            c.schedule.isNotEmpty ? c.schedule.first : '';
                        final scheduleLower = firstSchedule.toLowerCase();
                        return scheduleLower.contains(
                              selectedDayNameAr.toLowerCase(),
                            ) ||
                            scheduleLower.contains(
                              selectedDayNameEn.toLowerCase(),
                            );
                      }).toList();

                  if (filteredCourses.isEmpty) {
                    return Center(
                      child:
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.calendar_today_rounded,
                                size: 64,
                                color:
                                    isDark
                                        ? Colors.white24
                                        : Colors.grey.shade300,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                l10n.scheduleNoLecturesToday,
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 15,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ).animate().fadeIn(),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: filteredCourses.length,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      final item = filteredCourses[index];
                      final isArabic =
                          Localizations.localeOf(context).languageCode == 'ar';
                      final courseName = isArabic ? item.nameAr : item.nameEn;

                      final firstSchedule =
                          item.schedule.isNotEmpty ? item.schedule.first : '';
                      final parts = firstSchedule.split(' ');
                      final timeSlot =
                          parts.length > 1
                              ? parts.sublist(1).join(' ')
                              : '08:30 - 10:30';

                      // تنويه: هنا يفضل مستقبلاً فحص الوقت الفعلي وليس الـ index لتعيين 'ongoing'
                      final isFirst = index == 0;

                      return _buildLectureCard(
                            context: context,
                            courseId: item.courseId,
                            name: courseName,
                            room: 'قاعة تقنية المعلومات',
                            time: timeSlot,
                            type: isFirst ? 'ongoing' : 'upcoming',
                            studentsCount: item.studentCount,
                            brandTeal: brandTeal,
                            brandNavy: brandNavy,
                            isDark: isDark,
                          )
                          .animate()
                          .fadeIn(duration: 400.ms, delay: (index * 80).ms)
                          .slideY(begin: 0.1);
                    },
                  );
                },
                loading:
                    () => Center(
                      child: CircularProgressIndicator(color: brandTeal),
                    ),
                error:
                    (e, st) => Center(
                      child: Text(
                        '${l10n.errorPrefix}$e',
                        style: const TextStyle(fontFamily: 'Cairo'),
                      ),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLectureCard({
    required BuildContext context,
    required String courseId,
    required String name,
    required String room,
    required String time,
    required String type,
    required int studentsCount,
    required Color brandTeal,
    required Color brandNavy,
    required bool isDark,
  }) {
    final l10n = AppLocalizations.of(context)!;
    Color statusColor;
    bool isOngoing = type == 'ongoing';

    if (type == 'ongoing') {
      statusColor = Colors.amber.shade600;
    } else if (type == 'upcoming') {
      statusColor = brandTeal;
    } else {
      statusColor = isDark ? Colors.white24 : Colors.grey.shade300;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF132220) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color:
              isOngoing
                  ? statusColor.withValues(alpha: 0.25)
                  : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: 6,
            child: Container(color: statusColor),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark ? const Color(0xFFE8E8E8) : brandNavy,
                              fontFamily: 'Cairo',
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 14,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  room,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                    fontFamily: 'Cairo',
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          time,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? brandTeal : brandNavy,
                            fontFamily: 'Cairo',
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isOngoing ? l10n.periodMorning : l10n.periodAfternoon,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Divider(
                    height: 1,
                    color: isDark ? Colors.white10 : const Color(0xFFF1F5F9),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.people_alt_outlined,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '$studentsCount ${l10n.scheduleStudentsRegistered}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ],
                    ),
                    if (isOngoing)
                      ElevatedButton(
                        onPressed: () {
                          if (courseId.startsWith('mock_')) {
                            context.push('/faculty/attendance');
                          } else {
                            context.push(
                              '/faculty/attendance?courseId=$courseId',
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: brandTeal,
                          foregroundColor:
                              isDark ? const Color(0xFF132220) : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        child: Text(
                          l10n.scheduleAttendanceButton,
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    else if (type == 'upcoming')
                      Row(
                        children: [
                          Text(
                            l10n.scheduleUpcoming,
                            style: TextStyle(
                              color: brandTeal,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Cairo',
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.access_time_rounded,
                            size: 14,
                            color: brandTeal,
                          ),
                        ],
                      )
                    else
                      Text(
                        l10n.scheduleTheoretical,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 11,
                          fontFamily: 'Cairo',
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          if (isOngoing)
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.amber.shade500,
                  borderRadius: const BorderRadius.only(
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Text(
                  l10n.scheduleActiveNow,
                  style: TextStyle(
                    color: const Color(0xFF132220),
                    fontWeight: FontWeight.bold,
                    fontSize: 9,
                    fontFamily: 'Cairo',
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
