import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_project/core/l10n/localized_content.dart';
import 'package:flutter_project/core/theme/app_theme.dart';
import 'package:flutter_project/features/auth/data/auth_service.dart';
import 'package:flutter_project/features/auth/data/cached_user_profile_provider.dart';
import 'package:flutter_project/features/student/data/database_service.dart';
import 'package:flutter_project/features/student/data/student_providers.dart';
import 'package:flutter_project/core/models/schedule_entry.dart';
import 'package:flutter_project/core/providers/app_providers.dart';
import 'package:flutter_project/shared/widgets/uod_shimmer.dart';
import 'package:flutter_project/l10n/app_localizations.dart';

class SemesterOverviewPage extends ConsumerWidget {
  const SemesterOverviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authAsync = ref.watch(authStateChangesProvider);
    final l10n = AppLocalizations.of(context)!;

    return authAsync.when(
      data: (user) {
        if (user == null) {
          return Scaffold(body: Center(child: Text(l10n.pleaseLogin)));
        }

        final uid = user.uid;
        final gpaAsync = ref.watch(computedGpaProvider(uid));
        final attendanceAsync = ref.watch(attendanceStreamProvider(uid));
        final scheduleAsync = ref.watch(scheduleEntriesProvider(uid));
        final profileAsync = ref.watch(userDataProvider(uid));
        final majorLabel = profileAsync.maybeWhen(
          data: (data) => localizedMajor(data?['major'] as String?, l10n),
          orElse: () => l10n.unspecifiedMajor,
        );

        return Scaffold(
          // ✅ إزالة اللون الثابت — يأخذ لون الثيم تلقائياً
          appBar: AppBar(
            title: Text(
              l10n.currentSemesterTitle,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSummarySection(
                  context,
                  gpaAsync,
                  attendanceAsync,
                  l10n,
                ).animate().fadeIn().slideY(begin: 0.1),
                const SizedBox(height: 24),
                _buildNextClassCard(
                  context,
                  scheduleAsync,
                  l10n,
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                const SizedBox(height: 24),
                _buildSectionTitle(context, l10n.quickAccessTitle),
                const SizedBox(height: 12),
                _buildQuickLinks(context, l10n),
                const SizedBox(height: 32),
                _buildInfoGrid(context, l10n, majorLabel),
              ],
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: UodScreenLoading()),
      error:
          (e, _) =>
              Scaffold(body: Center(child: Text('${l10n.errorPrefix}$e'))),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      textAlign: TextAlign.start,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onSurface,
        fontFamily: 'Cairo',
      ),
    );
  }

  Widget _buildSummarySection(
    BuildContext context,
    AsyncValue<String> gpaAsync,
    AsyncValue<List<AttendanceSummary>> attendanceAsync,
    AppLocalizations l10n,
  ) {
    final gpa = gpaAsync.value ?? '0.00';
    final totalAbsences = attendanceAsync.when(
      data: (list) => list.fold<int>(0, (sum, a) => sum + a.absences),
      loading: () => 0,
      error: (e, _) => 0,
    );

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            l10n.currentGpaLabel,
            gpa,
            Icons.auto_graph,
            [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primaryContainer,
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            context,
            l10n.totalAbsences,
            '$totalAbsences',
            Icons.warning_amber_rounded,
            [
              Theme.of(context).colorScheme.tertiary,
              Theme.of(context).colorScheme.tertiaryContainer,
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    List<Color> colors,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colors.last.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontFamily: 'Cairo',
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildNextClassCard(
    BuildContext context,
    AsyncValue<List<ScheduleEntry>> scheduleAsync,
    AppLocalizations l10n,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return scheduleAsync.when(
      data: (entries) {
        if (entries.isEmpty) return const SizedBox.shrink();

        final next = entries.first;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            // ✅ يستخدم لون السطح من الثيم
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
            ),
            boxShadow: [
              BoxShadow(
                // ✅ ظل يتكيف مع الثيم
                color: colorScheme.shadow.withValues(alpha: 0.06),
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
                  Icon(
                    Icons.timer_outlined,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.nextClassTitle,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Text(
                next.courseTitle,
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                  // ✅ يتكيف مع الثيم
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    // ✅ بدلاً من Colors.grey الثابت
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${next.startTime} - ${next.endTime}',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      next.location,
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
      loading:
          () => UodShimmer(
            width: double.infinity,
            height: 120,
            child: Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                // ✅ لون الـ shimmer من الثيم
                color: colorScheme.surfaceContainerHighest,
                borderRadius: const BorderRadius.all(Radius.circular(24)),
              ),
            ),
          ),
      error: (e, _) => const SizedBox.shrink(),
    );
  }

  Widget _buildQuickLinks(BuildContext context, AppLocalizations l10n) {
    return Row(
      children: [
        _buildLinkItem(
          context,
          label: l10n.fullScheduleLink,
          icon: Icons.calendar_today,
          onTap: () => context.go('/schedule'),
        ),
        const SizedBox(width: 12),
        _buildLinkItem(
          context,
          label: l10n.attendanceRecordLink,
          icon: Icons.fact_check,
          onTap: () => context.pushNamed('attendance'),
        ),
        const SizedBox(width: 12),
        _buildLinkItem(
          context,
          label: l10n.gradesReportLink,
          icon: Icons.grade,
          onTap: () => context.pushNamed('grades'),
        ),
      ],
    );
  }

  Widget _buildLinkItem(
    BuildContext context, {
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final color = switch (icon) {
      Icons.calendar_today => Colors.blue,
      Icons.fact_check => Colors.green,
      _ => Colors.orange,
    };

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Ink(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withValues(alpha: 0.2)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color),
                const SizedBox(height: 8),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoGrid(
    BuildContext context,
    AppLocalizations l10n,
    String majorLabel,
  ) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.35,
      children: [
        _buildInfoCard(
          context,
          title: l10n.departmentScientific,
          subtitle: majorLabel,
          icon: Icons.account_tree_outlined,
          onTap: () => context.pushNamed('department'),
        ),
        _buildInfoCard(
          context,
          title: l10n.collegeAffairs,
          subtitle: l10n.announcementsAndLocation,
          icon: Icons.account_balance_outlined,
          onTap: () => context.pushNamed('college'),
        ),
      ],
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            // ✅ يتكيف مع الثيم
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.05),
                blurRadius: 8,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
                size: 22,
              ),
              const Spacer(),
              Text(
                title,
                textAlign: TextAlign.start,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  fontFamily: 'Cairo',
                  height: 1.2,
                  // ✅ يتكيف مع الثيم
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.start,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  // ✅ بدلاً من Colors.grey الثابت
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 10,
                  fontFamily: 'Cairo',
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
