import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_project/core/theme/app_theme.dart';
import 'package:flutter_project/features/auth/data/auth_service.dart';
import 'package:flutter_project/features/student/data/database_service.dart';
import 'package:flutter_project/features/student/data/student_providers.dart';
import 'package:flutter_project/l10n/app_localizations.dart';
import 'package:flutter_project/shared/widgets/empty_state_widget.dart';

class AttendancePage extends ConsumerWidget {
  const AttendancePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authAsync = ref.watch(authStateChangesProvider);
    final l10n = AppLocalizations.of(context)!;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return authAsync.when(
      data: (user) {
        if (user == null) {
          return Scaffold(body: Center(child: Text(l10n.pleaseLogin)));
        }

        final uid = user.uid;
        final attendanceAsync = ref.watch(attendanceStreamProvider(uid));

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            title: Text(
              l10n.attendanceTitle,
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
          body: attendanceAsync.when(
            data: (list) {
              if (list.isEmpty) {
                return _buildEmptyState(context);
              }
              return _buildBody(context, list, l10n, isAr);
            },
            loading: () => _buildEmptyState(context),
            error: (e, _) => _buildEmptyState(context),
          ),
        );
      },
      loading: () => Scaffold(body: _buildEmptyState(context)),
      error: (e, _) => Scaffold(body: _buildEmptyState(context)),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return EmptyStateWidget(
      icon: Icons.fact_check_outlined,
      title: l10n.noAttendanceData,
    );
  }

  Widget _buildBody(
    BuildContext context,
    List<AttendanceSummary> records,
    AppLocalizations l10n,
    bool isAr,
  ) {
    final atRiskCount = records.where((r) => r.isAtRisk).length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSummaryCard(
          records,
          atRiskCount,
          l10n,
          isAr,
        ).animate().fadeIn().slideY(begin: -0.05),
        const SizedBox(height: 16),

        if (atRiskCount > 0)
          _buildWarningBanner(
            context,
            atRiskCount,
            l10n,
            isAr,
          ).animate().fadeIn(delay: 100.ms),

        const SizedBox(height: 8),

        ...records.asMap().entries.map(
          (e) => _buildAttendanceCard(
            context,
            e.value,
            l10n,
            isAr,
          ).animate().fadeIn(delay: ((e.key + 1) * 60).ms).slideX(begin: 0.05),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    List<AttendanceSummary> records,
    int atRisk,
    AppLocalizations l10n,
    bool isAr,
  ) {
    final totalLectures = records.fold<int>(0, (s, r) => s + r.totalLectures);
    final totalAttended = records.fold<int>(
      0,
      (s, r) => s + r.attendedLectures,
    );
    final overallPct =
        totalLectures == 0 ? 100.0 : (totalAttended / totalLectures) * 100;
    final totalAbsences = records.fold<int>(0, (s, r) => s + r.absences);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.primaryContainer],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          if (isAr) ...[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$totalAbsences',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    l10n.totalAbsences,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.coursesCount(records.length),
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 12,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  l10n.totalAttendancePct,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontFamily: 'Cairo',
                  ),
                ),
                const SizedBox(height: 6),
                _buildCircularProgress(overallPct),
              ],
            ),
          ] else ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.totalAttendancePct,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontFamily: 'Cairo',
                  ),
                ),
                const SizedBox(height: 6),
                _buildCircularProgress(overallPct),
              ],
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$totalAbsences',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  l10n.totalAbsences,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontFamily: 'Cairo',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.coursesCount(records.length),
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCircularProgress(double pct) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 72,
          height: 72,
          child: CircularProgressIndicator(
            value: pct / 100,
            strokeWidth: 7,
            backgroundColor: Colors.white24,
            color: pct >= 75 ? Colors.greenAccent : Colors.orangeAccent,
          ),
        ),
        Text(
          '${pct.toStringAsFixed(0)}%',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildWarningBanner(
    BuildContext context,
    int count,
    AppLocalizations l10n,
    bool isAr,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade300),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Colors.orange,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              l10n.atRiskWarning(count),
              textAlign: isAr ? TextAlign.right : TextAlign.left,
              style: TextStyle(
                color: Colors.orange.shade800,
                fontSize: 13,
                fontFamily: 'Cairo',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceCard(
    BuildContext context,
    AttendanceSummary record,
    AppLocalizations l10n,
    bool isAr,
  ) {
    final pct = record.attendancePercentage;
    final color =
        record.isAtRisk
            ? Colors.red
            : pct >= 90
            ? Colors.green
            : Colors.orange;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color:
              record.isAtRisk
                  ? Colors.red.withValues(alpha: 0.3)
                  : AppTheme.outlineVariantColor.withValues(alpha: 0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            isAr ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (isAr) ...[
                _buildSmallCircularProgress(pct, color),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (record.isAtRisk) _buildAtRiskBadge(l10n),
                          Flexible(
                            child: Text(
                              record.courseName,
                              textAlign: TextAlign.right,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                fontFamily: 'Cairo',
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        record.semester,
                        style: const TextStyle(
                          fontSize: 11,
                          fontFamily: 'Cairo',
                          color: AppTheme.onSurfaceVariantColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Flexible(
                            child: Text(
                              record.courseName,
                              textAlign: TextAlign.left,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                fontFamily: 'Cairo',
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ),
                          if (record.isAtRisk) _buildAtRiskBadge(l10n),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        record.semester,
                        style: const TextStyle(
                          fontSize: 11,
                          fontFamily: 'Cairo',
                          color: AppTheme.onSurfaceVariantColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _buildSmallCircularProgress(pct, color),
              ],
            ],
          ),
          const SizedBox(height: 12),

          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: pct / 100,
              backgroundColor: Theme.of(
                context,
              ).dividerColor.withValues(alpha: 0.3),
              color: color,
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (isAr) ...[
                _statBadge(
                  l10n.totalLecturesLabel(record.totalLectures),
                  Colors.grey,
                ),
                _statBadge(
                  l10n.attendedLecturesLabel(record.attendedLectures),
                  Colors.green,
                ),
                _statBadge(l10n.absencesLabel(record.absences), color),
              ] else ...[
                _statBadge(l10n.absencesLabel(record.absences), color),
                _statBadge(
                  l10n.attendedLecturesLabel(record.attendedLectures),
                  Colors.green,
                ),
                _statBadge(
                  l10n.totalLecturesLabel(record.totalLectures),
                  Colors.grey,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallCircularProgress(double pct, Color color) {
    return SizedBox(
      width: 44,
      height: 44,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: pct / 100,
            strokeWidth: 5,
            backgroundColor: Colors.grey.shade200,
            color: color,
          ),
          Text(
            '${pct.toStringAsFixed(0)}%',
            style: TextStyle(
              fontSize: 9,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAtRiskBadge(AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Text(
        l10n.atRiskBadge,
        style: const TextStyle(
          fontSize: 10,
          color: Colors.red,
          fontFamily: 'Cairo',
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _statBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontFamily: 'Cairo',
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
