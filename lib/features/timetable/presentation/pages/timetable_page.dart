import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:flutter_project/l10n/app_localizations.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_project/core/models/schedule_entry.dart';
import 'package:flutter_project/core/providers/app_providers.dart';
import 'package:flutter_project/shared/widgets/empty_state_widget.dart';

class TimetablePage extends ConsumerWidget {
  const TimetablePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final isAr = locale == 'ar';
    final theme = Theme.of(context);
    final user = FirebaseAuth.instance.currentUser;
    final userUid = user?.uid ?? '';

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            l10n.timetableTitle,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          elevation: 0,
          bottom: TabBar(
            labelStyle: const TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.w600,
            ),
            indicatorColor: theme.colorScheme.onPrimary,
            tabs: [Tab(text: l10n.weekTabLabel), Tab(text: l10n.monthTabLabel)],
          ),
        ),
        body: TabBarView(
          children: [
            _WeekTimetableView(
              userUid: userUid,
              locale: locale,
              isAr: isAr,
            ),
            _MonthTimetableView(isAr: isAr),
          ],
        ),
      ),
    );
  }
}

class _WeekTimetableView extends ConsumerWidget {
  const _WeekTimetableView({
    required this.userUid,
    required this.locale,
    required this.isAr,
  });

  final String userUid;
  final String locale;
  final bool isAr;

  List<DateTime> _weekDates() {
    final now = DateTime.now();
    final sunday = DateTime(now.year, now.month, now.day - (now.weekday % 7));
    return List.generate(
      5,
      (i) => DateTime(sunday.year, sunday.month, sunday.day + i),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final languageCode = Localizations.localeOf(context).languageCode;
    final weekdayFormat = DateFormat.EEEE(languageCode);
    final theme = Theme.of(context);
    final weekDates = _weekDates();

    final scheduleAsync = ref.watch(scheduleEntriesProvider(userUid));

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: scheduleAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => const Center(
          child: Text(
            'حدث خطأ في تحميل الجدول',
            style: TextStyle(fontFamily: 'Cairo'),
          ),
        ),
        data: (allSessions) {
          if (allSessions.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.calendar_today_outlined,
              title: 'لا يوجد جدول دراسي',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: weekDates.length,
            itemBuilder: (context, index) {
              final date = weekDates[index];
              final weekdayLabel = weekdayFormat.format(date);
              final sessions =
                  allSessions.where((s) => s.weekdayIndex == index).toList();

              return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: theme.colorScheme.outlineVariant),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              weekdayLabel,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.onPrimaryContainer,
                                fontFamily: 'Cairo',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (sessions.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.event_busy_outlined,
                                    size: 20,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    l10n.noSessionsMessage,
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            ...sessions.map(
                              (session) => _SessionTile(session: session),
                            ),
                        ],
                      ),
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 400.ms, delay: (index * 100).ms)
                  .slideY(begin: 0.1);
            },
          );
        },
      ),
    );
  }
}

class _MonthTimetableView extends StatelessWidget {
  const _MonthTimetableView({required this.isAr});

  final bool isAr;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.calendar_month_outlined,
                  size: 64,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.noSessionsMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  const _SessionTile({required this.session});

  final ScheduleEntry session;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final title =
        session.courseTitle.isNotEmpty
            ? session.courseTitle
            : l10n.noSessionsMessage;
    final subtitle = session.location.isNotEmpty ? session.location : '';

    final timeText = l10n.sessionTimeFormat(session.startTime, session.endTime);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.class_,
              color: theme.colorScheme.onPrimaryContainer,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    timeText,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
