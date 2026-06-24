import 'package:flutter_project/core/services/error_tracking_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_project/core/providers/app_providers.dart';
import 'package:flutter_project/core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_project/features/auth/data/auth_service.dart';
import 'package:flutter_project/features/student/data/university_database_seeder.dart';
import 'package:flutter_project/shared/widgets/empty_state_widget.dart';
import 'package:flutter_project/shared/widgets/uod_shimmer.dart';
import 'package:flutter_project/l10n/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SchedulePage extends ConsumerStatefulWidget {
  const SchedulePage({super.key});

  @override
  ConsumerState<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends ConsumerState<SchedulePage> {
  late int _selectedDay;
  bool _isSeeding = false;

  @override
  void initState() {
    super.initState();
    _selectedDay = _todayIndex();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authStateChangesProvider).value;
      if (kDebugMode && user != null) _seedStudentData(user);
    });
  }

  Future<void> _seedStudentData(User user) async {
    if (!kDebugMode) return;
    if (_isSeeding) return;
    setState(() => _isSeeding = true);
    try {
      await UniversityDatabaseSeeder.seedStudentData(
        currentUid: user.uid,
        studentName: user.displayName ?? 'Student',
        email: user.email,
      );
      if (mounted) ref.invalidate(scheduleEntriesProvider(user.uid));
    } catch (e, stackTrace) {
      ErrorTrackingService.recordError(e, stackTrace, context: '❌ Error seeding student data');
    } finally {
      if (mounted) setState(() => _isSeeding = false);
    }
  }

  static int _todayIndex() {
    switch (DateTime.now().weekday) {
      case DateTime.saturday:
        return 0;
      case DateTime.sunday:
        return 1;
      case DateTime.monday:
        return 2;
      case DateTime.tuesday:
        return 3;
      case DateTime.wednesday:
        return 4;
      case DateTime.thursday:
        return 5;
      default:
        return 1;
    }
  }

  List<String> _getDays(AppLocalizations l10n) => [
    l10n.daySaturday,
    l10n.daySunday,
    l10n.dayMonday,
    l10n.dayTuesday,
    l10n.dayWednesday,
    l10n.dayThursday,
  ];

  // ألوان التدرج لكل بطاقة بالتناوب
  static final _cardGradients = [
    [AppTheme.primaryColor, AppTheme.primaryContainer],
    [Color(0xFF1A1A3A), Color(0xFF0F2040)],
    [Color(0xFF2D1A0F), Color(0xFF3D2A0A)],
    [Color(0xFF1A0F2D), Color(0xFF200F3D)],
  ];
  static final _cardBorderColors = [
    AppTheme.primaryColor,
    Color(0xFF635AD2),
    Color(0xFFBA7517),
    Color(0xFF8B5CF6),
  ];
  static final _timeChipGradients = [
    [AppTheme.primaryColor, AppTheme.primaryContainer],
    [Color(0xFF635AD2), Color(0xFF4A43A8)],
    [Color(0xFFBA7517), Color(0xFF854F0B)],
    [Color(0xFF8B5CF6), Color(0xFF6D3ED6)],
  ];
  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authStateChangesProvider);
    final l10n = AppLocalizations.of(context)!;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final days = _getDays(l10n);
    final todayIndex = _todayIndex();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.scheduleTitle), centerTitle: true),
      body: auth.when(
        data: (user) {
          if (user == null) return Center(child: Text(l10n.pleaseLogin));

          final async = ref.watch(scheduleEntriesProvider(user.uid));

          return async.when(
            data: (entries) {
              final filtered =
                  entries.where((e) => e.weekdayIndex == _selectedDay).toList();

              final Map<int, int> lectureCount = {};
              for (final e in entries) {
                lectureCount[e.weekdayIndex] =
                    (lectureCount[e.weekdayIndex] ?? 0) + 1;
              }

              return Column(
                children: [
                  _buildDaySelector(days, isAr, todayIndex, lectureCount),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async => _seedStudentData(user),
                      child:
                          _isSeeding
                              ? const Center(child: CircularProgressIndicator())
                              : filtered.isEmpty
                              ? ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.all(24),
                                children: [
                                  EmptyStateWidget(
                                    icon: Icons.calendar_today_outlined,
                                    title: l10n.noLecturesTitle,
                                    subtitle: l10n.noLecturesSubtitle,
                                    actionLabel: l10n.refreshAction,
                                    onAction: () => _seedStudentData(user),
                                  ),
                                ],
                              )
                              : ListView(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  20,
                                  16,
                                  32,
                                ),
                                children:
                                    filtered
                                        .asMap()
                                        .entries
                                        .map(
                                          (e) => _buildScheduleItem(
                                            context,
                                            '${e.value.startTime} - ${e.value.endTime}',
                                            e.value.courseTitle,
                                            e.value.location,
                                            e.value.instructor,
                                            e.value.roomNumber,
                                            e.value.building,
                                            isAr,
                                            index: e.key,
                                          ),
                                        )
                                        .toList(),
                              ),
                    ),
                  ),
                ],
              );
            },
            loading: () => const UodScreenLoading(),
            error: (e, _) => Center(child: Text('${l10n.errorPrefix}$e')),
          );
        },
        loading: () => const UodScreenLoading(),
        error: (e, _) => Center(child: Text('${l10n.errorPrefix}$e')),
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  // Day Selector
  // ══════════════════════════════════════════════════════
  Widget _buildDaySelector(
    List<String> days,
    bool isAr,
    int todayIndex,
    Map<int, int> lectureCount,
  ) {
    // ✅ نقرأ الثيم الحالي لنختار الألوان المناسبة
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.outlineVariantColor.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        reverse: isAr,
        itemCount: days.length,
        itemBuilder: (context, index) {
          final isSelected = index == _selectedDay;
          final isToday = index == todayIndex;
          final count = lectureCount[index] ?? 0;

          // ✅ ألوان تتكيف مع الثيم
          final unselectedBg =
              isDark
                  ? Colors.white.withValues(alpha: 0.07)
                  : Colors.black.withValues(alpha: 0.04);
          final unselectedBorder =
              isDark
                  ? Colors.white.withValues(alpha: 0.15)
                  : Colors.black.withValues(alpha: 0.12);
          final unselectedText =
              isDark ? Colors.white : AppTheme.onSurfaceColor;

          return GestureDetector(
            onTap: () => setState(() => _selectedDay = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 5),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
              decoration: BoxDecoration(
                gradient:
                    isSelected
                        ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppTheme.primaryColor,
                            AppTheme.primaryColor.withValues(alpha: 0.75),
                          ],
                        )
                        : null,
                color: isSelected ? null : unselectedBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color:
                      isSelected
                          ? AppTheme.primaryColor
                          : isToday
                          ? AppTheme.tertiaryColor
                          : unselectedBorder,
                  width: isToday && !isSelected ? 1.5 : 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    days[index],
                    style: TextStyle(
                      color:
                          isSelected
                              ? Colors.white
                              : isToday
                              ? AppTheme.tertiaryColor
                              : unselectedText, // ✅ يتكيف مع الثيم
                      fontWeight:
                          isSelected || isToday
                              ? FontWeight.bold
                              : FontWeight.normal,
                      fontFamily: 'Cairo',
                      fontSize: 13,
                    ),
                  ),
                  if (count > 0) ...[
                    const SizedBox(height: 3),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? Colors.white.withValues(alpha: 0.25)
                                : AppTheme.primaryColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$count',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color:
                              isSelected
                                  ? Colors.white
                                  : (isDark
                                      ? Colors.white70
                                      : AppTheme.primaryColor),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  // Schedule Card
  // ══════════════════════════════════════════════════════
  Widget _buildScheduleItem(
    BuildContext context,
    String time,
    String subject,
    String location,
    String doctor,
    String? roomNumber,
    String? building,
    bool isAr, {
    int index = 0,
  }) {
    final colorIndex = index % _cardGradients.length;
    final gradientColors = _cardGradients[colorIndex];
    final borderColor = _cardBorderColors[colorIndex];
    final chipColors = _timeChipGradients[colorIndex];

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          // Glow effect
          // Glow effect — يتبع الاتجاه تلقائياً
          Positioned(
            top: 0,
            right: 0, // ✅ دائماً في اليمين (يعمل مع RTL وLTR)
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    borderColor.withValues(alpha: 0.25),
                    Colors.transparent,
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(16),
                ),
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment:
                  isAr ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                // Time chip + type badge
                Row(
                  mainAxisAlignment:
                      isAr
                          ? MainAxisAlignment.spaceBetween
                          : MainAxisAlignment.spaceBetween,
                  children: [
                    if (!isAr)
                      _GradientTimeChip(time: time, colors: chipColors),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: borderColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: borderColor.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.lecture,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (isAr) _GradientTimeChip(time: time, colors: chipColors),
                  ],
                ),

                const SizedBox(height: 14),

                // Course title
                Text(
                  subject,
                  textAlign: isAr ? TextAlign.right : TextAlign.left,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Cairo',
                  ),
                ),

                const SizedBox(height: 12),

                // Location & instructor
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  alignment: isAr ? WrapAlignment.end : WrapAlignment.start,
                  textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
                  children: [
                    _DetailChip(icon: Icons.person_outline, text: doctor),
                    _DetailChip(
                      icon: Icons.location_on_outlined,
                      text: location,
                    ),
                    if (roomNumber != null || building != null)
                      _DetailChip(
                        icon: Icons.meeting_room_outlined,
                        text: [
                          if (building != null) building,
                          if (roomNumber != null) roomNumber,
                        ].join(' - '),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════
// Gradient Time Chip
// ══════════════════════════════════════════════════════
class _GradientTimeChip extends StatelessWidget {
  final String time;
  final List<Color> colors;

  const _GradientTimeChip({required this.time, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        time,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 13,
          fontFamily: 'Cairo',
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════
// Detail Chip (location / instructor)
// ══════════════════════════════════════════════════════
class _DetailChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _DetailChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    // ✅ النص دائماً أبيض لأن الخلفية داكنة دائماً (gradient card)
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.white.withValues(alpha: 0.8)),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white,
            fontFamily: 'Cairo',
          ),
        ),
      ],
    );
  }
}

