import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_project/core/theme/app_theme.dart';
import 'package:flutter_project/features/auth/data/auth_service.dart';
import 'package:flutter_project/features/student/data/database_service.dart';
import 'package:flutter_project/features/student/data/student_providers.dart';
import 'package:flutter_project/shared/widgets/empty_state_widget.dart';
import 'package:flutter_project/shared/widgets/uod_shimmer.dart';

/// صفحة الحضور والغياب — متصلة بـ Firestore بشكل حي (StreamProvider).
///
/// المميزات الجديدة:
///   • ترتيب المواد — المواد في خطر أولاً
///   • بطاقة ملخص محسّنة مع نسبة دائرية
///   • حالة فارغة باستخدام EmptyStateWidget
///   • تلوين تكيّفي للبطاقات (خطر / بخير / ممتاز)
class AttendancePage extends ConsumerWidget {
  const AttendancePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authAsync = ref.watch(authStateChangesProvider);

    return authAsync.when(
      data: (user) {
        if (user == null) {
          return const Scaffold(
              body: Center(child: Text('يرجى تسجيل الدخول')));
        }

        final uid = user.uid;
        final attendanceAsync = ref.watch(attendanceStreamProvider(uid));

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            title: const Text(
              'الحضور والغياب',
              style:
                  TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          body: attendanceAsync.when(
            data: (records) => _buildBody(context, records),
            loading: () => const UodScreenLoading(),
            error: (e, _) =>
                Center(child: Text('خطأ في تحميل بيانات الحضور: $e')),
          ),
        );
      },
      loading: () => const Scaffold(body: UodScreenLoading()),
      error: (e, _) => Scaffold(body: Center(child: Text('خطأ: $e'))),
    );
  }

  Widget _buildBody(
      BuildContext context, List<AttendanceSummary> records) {
    if (records.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: EmptyStateWidget(
          icon: Icons.event_available_outlined,
          title: 'لا توجد سجلات حضور بعد',
          subtitle: 'ستظهر هنا بيانات حضورك بعد بدء المحاضرات',
        ),
      );
    }

    // ترتيب: المواد في خطر أولاً
    final sorted = [...records]
      ..sort((a, b) {
        if (a.isAtRisk && !b.isAtRisk) return -1;
        if (!a.isAtRisk && b.isAtRisk) return 1;
        return a.attendancePercentage.compareTo(b.attendancePercentage);
      });

    final atRiskCount = sorted.where((r) => r.isAtRisk).length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ── ملخص الحضور الإجمالي
        _buildSummaryCard(context, sorted, atRiskCount)
            .animate()
            .fadeIn()
            .slideY(begin: -0.05),
        const SizedBox(height: 16),

        // ── تحذير إذا كانت هناك مواد في خطر
        if (atRiskCount > 0) ...[
          _buildWarningBanner(atRiskCount)
              .animate()
              .fadeIn(delay: 100.ms),
          const SizedBox(height: 8),
        ],

        // ── بطاقة لكل مادة
        ...sorted.asMap().entries.map(
              (e) => _buildAttendanceCard(context, e.value)
                  .animate()
                  .fadeIn(delay: ((e.key + 1) * 60).ms)
                  .slideX(begin: 0.04),
            ),
      ],
    );
  }

  Widget _buildSummaryCard(BuildContext context,
      List<AttendanceSummary> records, int atRisk) {
    final totalLectures =
        records.fold<int>(0, (s, r) => s + r.totalLectures);
    final totalAttended =
        records.fold<int>(0, (s, r) => s + r.attendedLectures);
    final overallPct = totalLectures == 0
        ? 100.0
        : (totalAttended / totalLectures) * 100;
    final totalAbsences =
        records.fold<int>(0, (s, r) => s + r.absences);

    final overallColor = overallPct >= 85
        ? Colors.greenAccent
        : overallPct >= 75
            ? Colors.orange
            : Colors.redAccent;

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
          // إحصاءات يسار
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$totalAbsences',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.bold),
                ),
                Text('إجمالي الغيابات',
                    style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer, fontSize: 13)),
                const SizedBox(height: 10),
                _summaryBadge('${records.length} مادة', Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.7)),
                if (atRisk > 0) ...[
                  const SizedBox(height: 6),
                  _summaryBadge(
                      '$atRisk ${atRisk == 1 ? 'مادة' : 'مواد'} في خطر',
                      Colors.orangeAccent),
                ],
              ],
            ),
          ),
          // نسبة الحضور الكلية
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('نسبة الحضور',
                  style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer, fontSize: 12)),
              const SizedBox(height: 8),
              SizedBox(
                width: 76,
                height: 76,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: overallPct / 100,
                      strokeWidth: 7,
                      backgroundColor: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.15),
                      color: overallColor,
                    ),
                    Text(
                      '${overallPct.toStringAsFixed(0)}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryBadge(String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.only(left: 6),
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        Text(text, style: TextStyle(color: color, fontSize: 12)),
      ],
    );
  }

  Widget _buildWarningBanner(int count) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade300),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: Colors.orange, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'تحذير: $count ${count == 1 ? 'مادة' : 'مواد'} بنسبة حضور أقل من 75% — خطر الحرمان',
              textAlign: TextAlign.right,
              style: TextStyle(
                color: Colors.orange.shade800,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceCard(
      BuildContext context, AttendanceSummary record) {
    final pct = record.attendancePercentage;
    final Color statusColor;
    final String statusLabel;

    if (record.isAtRisk) {
      statusColor = Colors.red.shade600;
      statusLabel = '⚠️ في خطر';
    } else if (pct >= 90) {
      statusColor = Colors.green.shade600;
      statusLabel = '✓ ممتاز';
    } else {
      statusColor = Colors.orange.shade600;
      statusLabel = 'مقبول';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: record.isAtRisk
              ? Colors.red.withValues(alpha: 0.25)
              : AppTheme.outlineVariantColor.withValues(alpha: 0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // ── رأس البطاقة: اسم المادة + نسبة
            Row(
              children: [
                // نسبة دائرية صغيرة
                SizedBox(
                  width: 46,
                  height: 46,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: pct / 100,
                        strokeWidth: 5,
                        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                        color: statusColor,
                      ),
                      Text(
                        '${pct.toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 9,
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                  color: statusColor.withValues(alpha: 0.3)),
                            ),
                            child: Text(
                              statusLabel,
                              style: TextStyle(
                                fontSize: 10,
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Flexible(
                            child: Text(
                              record.courseName,
                              textAlign: TextAlign.right,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: AppTheme.primaryColor,
                                fontFamily: 'Cairo',
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
                          color: AppTheme.onSurfaceVariantColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ── شريط التقدم
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: pct / 100,
                backgroundColor: Colors.grey.shade200,
                color: statusColor,
                minHeight: 7,
              ),
            ),
            const SizedBox(height: 8),

            // ── إحصاءات
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _statBadge('${record.totalLectures} كلي', Colors.grey.shade600),
                _statBadge(
                    '${record.attendedLectures} حضور', Colors.green.shade600),
                _statBadge(
                    '${record.absences} غياب', statusColor),
              ],
            ),
          ],
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
          fontWeight: FontWeight.bold,
          fontFamily: 'Cairo',
        ),
      ),
    );
  }
}