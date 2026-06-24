import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_project/core/models/course_grade.dart';
import 'package:flutter_project/core/theme/app_theme.dart';
import 'package:flutter_project/features/auth/data/auth_service.dart';
import 'package:flutter_project/features/student/data/student_providers.dart';
import 'package:flutter_project/shared/widgets/uod_shimmer.dart';

/// صفحة النتائج والدرجات — متصلة بـ Firestore بشكل حي (StreamProvider).
///
/// تعرض:
///   • المعدل التراكمي المحسوب تلقائياً
///   • إجمالي الساعات المعتمدة
///   • درجات كل مادة مع الدرجة الحرفية ونقاط الجودة
///   • مؤشر لوني لكل درجة (ممتاز / جيد / راسب)
class GradesPage extends ConsumerWidget {
  const GradesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authAsync = ref.watch(authStateChangesProvider);

    return authAsync.when(
      data: (user) {
        if (user == null) {
          return const Scaffold(body: Center(child: Text('يرجى تسجيل الدخول')));
        }

        final uid = user.uid;
        final gradesAsync = ref.watch(gradesStreamProvider(uid));
        final gpaAsync = ref.watch(computedGpaProvider(uid));
        final hoursAsync = ref.watch(computedCompletedHoursProvider(uid));

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            title: const Text(
              'النتائج والدرجات',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          body: gradesAsync.when(
            data: (grades) => _buildBody(context, grades, gpaAsync, hoursAsync),
            loading: () => const UodScreenLoading(),
            error: (e, _) => Center(child: Text('خطأ في تحميل الدرجات: $e')),
          ),
        );
      },
      loading: () => const Scaffold(body: UodScreenLoading()),
      error: (e, _) => Scaffold(body: Center(child: Text('خطأ: $e'))),
    );
  }

  Widget _buildBody(
    BuildContext context,
    List<CourseGrade> grades,
    AsyncValue<String> gpaAsync,
    AsyncValue<String> hoursAsync,
  ) {
    final gpa = gpaAsync.value ?? '0.00';
    final hours = hoursAsync.value ?? '0';

    // تجميع المواد حسب الفصل الدراسي
    final Map<String, List<CourseGrade>> bySemester = {};
    for (final g in grades) {
      bySemester.putIfAbsent(g.semester, () => []).add(g);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ── بطاقة المعدل الإجمالي ──────────────────────────────────────
        _buildGpaCard(
          context,
          gpa,
          hours,
          grades.length,
        ).animate().fadeIn().slideY(begin: -0.05),
        const SizedBox(height: 20),

        if (grades.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: Text(
                'لا توجد درجات مسجّلة بعد',
                style: TextStyle(
                  color: AppTheme.onSurfaceVariantColor,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          )
        else ...[
          // ── مواد كل فصل دراسي ──────────────────────────────────────
          for (final entry in bySemester.entries) ...[
            _buildSemesterHeader(entry.key),
            const SizedBox(height: 8),
            ...entry.value.asMap().entries.map(
              (e) => _buildGradeCard(
                context,
                e.value,
              ).animate().fadeIn(delay: (e.key * 60).ms).slideX(begin: 0.05),
            ),
            const SizedBox(height: 16),
          ],
        ],
      ],
    );
  }

  Widget _buildGpaCard(BuildContext context, String gpa, String hours, int courseCount) {
    final gpaDouble = double.tryParse(gpa) ?? 0.0;
    final gpaColor =
        gpaDouble >= 85
            ? Colors.green
            : gpaDouble >= 65
            ? Colors.blue
            : gpaDouble >= 50
            ? Colors.orange
            : Colors.red;

    return Container(
      padding: const EdgeInsets.all(24),
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
          // الساعات والمواد
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hours,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'ساعة مكتسبة',
                  style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Text(
                  '$courseCount مادة',
                  style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer, fontSize: 12),
                ),
              ],
            ),
          ),
          // المعدل التراكمي
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'المعدل التراكمي',
                style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer, fontSize: 13),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  '$gpa%',
                  style: TextStyle(
                    color:
                        gpaDouble >= 50.0 ? Colors.white : Colors.red.shade200,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _gpaLabel(gpaDouble),
                style: TextStyle(
                  color: gpaColor.withValues(alpha: 0.9),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSemesterHeader(String semester) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        semester.isNotEmpty ? semester : 'فصل غير محدد',
        textAlign: TextAlign.right,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryColor,
          fontSize: 14,
          fontFamily: 'Cairo',
        ),
      ),
    );
  }

  Widget _buildGradeCard(BuildContext context, CourseGrade grade) {
    final color = _gradeColor(grade.gradePoints);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppTheme.outlineVariantColor.withValues(alpha: 0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // درجة حرفية ونقاط جودة
          Column(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 2),
                ),
                child: Center(
                  child: Text(
                    grade.letterGrade,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${grade.gradePoints.toStringAsFixed(1)} GP',
                style: TextStyle(
                  fontSize: 10,
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          // تفاصيل المادة
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  grade.courseName,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 6),
                // شريط التقدم
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: grade.totalScore / 100,
                    backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    color: color,
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${grade.creditHours} ساعة',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.onSurfaceVariantColor,
                      ),
                    ),
                    Text(
                      'نهائي: ${grade.finalExam.toStringAsFixed(0)} | نصفي: ${grade.midterm.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.onSurfaceVariantColor,
                      ),
                    ),
                    Text(
                      'المجموع: ${grade.totalScore.toStringAsFixed(1)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
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

  Color _gradeColor(double gradePoints) {
    if (gradePoints >= 3.5) return Colors.green;
    if (gradePoints >= 2.5) return Colors.blue;
    if (gradePoints >= 1.5) return Colors.orange;
    if (gradePoints > 0) return Colors.deepOrange;
    return Colors.red;
  }

  String _gpaLabel(double gpa) {
    if (gpa >= 85) return 'ممتاز';
    if (gpa >= 75) return 'جيد جداً';
    if (gpa >= 65) return 'جيد';
    if (gpa >= 50) return 'مقبول';
    return 'راسب';
  }
}
