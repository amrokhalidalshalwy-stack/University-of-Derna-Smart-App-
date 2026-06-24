import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_project/core/theme/app_theme.dart';
import 'package:flutter_project/features/auth/data/auth_service.dart';
import 'package:flutter_project/shared/widgets/empty_state_widget.dart';
import 'package:flutter_project/l10n/app_localizations.dart';
import 'package:flutter_project/shared/widgets/uod_shimmer.dart';

/// نموذج بيانات محلي للمادة داخل الخطة الدراسية
class PlanCourse {
  final String code;
  final String name;
  final int credits;
  final int semesterNumber; // 1 = الفصل الأول، 2 = الثاني، إلخ
  final String status; // 'completed', 'in_progress', 'remaining'
  final String? gradeLetter;

  const PlanCourse({
    required this.code,
    required this.name,
    required this.credits,
    required this.semesterNumber,
    required this.status,
    this.gradeLetter,
  });
}

class AcademicPlanPage extends ConsumerStatefulWidget {
  const AcademicPlanPage({super.key});

  @override
  ConsumerState<AcademicPlanPage> createState() => _AcademicPlanPageState();
}

class _AcademicPlanPageState extends ConsumerState<AcademicPlanPage> with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  Future<List<PlanCourse>> _fetchAcademicPlan(String userId) async {
    try {
      final gradesSnapshot = await FirebaseFirestore.instance
          .collection('grades')
          .where('student_id', isEqualTo: userId)
          .get();

      final passedCourses = <String, Map<String, dynamic>>{};
      for (var doc in gradesSnapshot.docs) {
        final data = doc.data();
        final courseId = data['course_id'] as String? ?? '';
        final total = (data['total'] as num?)?.toDouble() ?? 0.0;
        
        // Assume pass mark is 50 for this example
        if (total >= 50.0) {
          passedCourses[courseId] = data;
        }
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('academic_plans')
          .where('student_id', isEqualTo: userId)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        final courseCode = data['code'] ?? '';
        
        // Dynamically compute status based on actual grades
        final isCompleted = passedCourses.containsKey(courseCode);
        final gradeData = passedCourses[courseCode];
        
        String status = isCompleted ? 'completed' : (data['status'] ?? 'remaining');
        String? gradeLetter = isCompleted ? _computeGradeLetter((gradeData?['total'] as num?)?.toDouble() ?? 0.0) : data['gradeLetter'];

        return PlanCourse(
          code: courseCode,
          name: data['name'] ?? '',
          credits: data['credits'] ?? 0,
          semesterNumber: data['semesterNumber'] ?? 1,
          status: status,
          gradeLetter: gradeLetter,
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  String _computeGradeLetter(double total) {
    if (total >= 90) return 'A+';
    if (total >= 85) return 'A';
    if (total >= 80) return 'B+';
    if (total >= 75) return 'B';
    if (total >= 70) return 'C+';
    if (total >= 65) return 'C';
    if (total >= 60) return 'D+';
    if (total >= 50) return 'D';
    return 'F';
  }

  @override
  Widget build(BuildContext context) {
    final authAsync = ref.watch(authStateChangesProvider);

    return authAsync.when(
      data: (user) {
        if (user == null) {
          return Scaffold(
            body: Center(
              child: Text(
                AppLocalizations.of(context)!.pleaseLogin,
                style: const TextStyle(fontFamily: 'Cairo'),
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            title: Text(
              AppLocalizations.of(context)!.academicPlanTitle,
              style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            elevation: 0,
            bottom: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: AppTheme.secondaryContainer,
              indicatorWeight: 3,
              labelColor: Colors.white,             // لون الخط الأبيض للتبويب النشط
              unselectedLabelColor: Colors.white70, // لون الخط الأبيض الشفاف للتبويبات الخاملة
              labelStyle: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 13),
              unselectedLabelStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 12),
              tabs: [
                Tab(text: AppLocalizations.of(context)!.semesterOne),
                Tab(text: AppLocalizations.of(context)!.semesterTwo),
                Tab(text: AppLocalizations.of(context)!.semesterThree),
                Tab(text: AppLocalizations.of(context)!.semesterFour),
              ],
            ),
          ),
          body: FutureBuilder<List<PlanCourse>>(
            future: _fetchAcademicPlan(user.uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final planCourses = snapshot.data ?? [];

              return TabBarView(
                controller: _tabController,
                children: List.generate(4, (index) {
                  final semesterKey = index + 1;
                  
                  // تصفية المواد لتشمل فقط مواد الفصل الحالي
                  final semesterCourses = planCourses
                  .where((c) => c.semesterNumber == semesterKey)
                  .toList();

              if (semesterCourses.isEmpty) {
                return EmptyStateWidget(
                  icon: Icons.auto_stories_outlined,
                  title: AppLocalizations.of(context)!.noCoursesThisSemester,
                );
              }

              // حساب إحصائيات ونسبة الفصل الحالي بالتحديد
              final completedHours = semesterCourses
                  .where((c) => c.status == 'completed')
                  .fold<int>(0, (acc, item) => acc + item.credits);
              final totalPlanHours = semesterCourses.fold<int>(0, (acc, item) => acc + item.credits);
              final progressRatio = totalPlanHours > 0 ? (completedHours / totalPlanHours) : 0.0;

              return Column(
                children: [
                  // كرت تقدم مستوى الفصل الحالي
                  _buildProgressCard(completedHours, totalPlanHours, progressRatio)
                      .animate()
                      .fadeIn()
                      .slideY(begin: -0.05),
                  
                  // قائمة المواد التابعة لهذا الفصل
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: semesterCourses.length,
                      itemBuilder: (context, i) {
                        final course = semesterCourses[i];
                        return _buildCoursePlanCard(course)
                            .animate()
                            .fadeIn(delay: (i * 50).ms)
                            .slideX(begin: -0.03);
                      },
                    ),
                  ),
                ],
              );
            }),
          );
        }),
        );
      },
      loading: () => const Scaffold(body: UodScreenLoading()),
      error: (e, _) => Scaffold(body: Center(child: Text('خطأ: $e', style: const TextStyle(fontFamily: 'Cairo')))),
    );
  }

  // ── بطاقة تقدم مستوى الخطة (محدثة بملاءمة ذكية للنص) ───────────────────

  Widget _buildProgressCard(int completed, int total, double ratio) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.outlineVariantColor.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // النسبة الدائرية مع معالجة احتواء رقم 100%
          SizedBox(
            width: 65,
            height: 65,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: ratio,
                  strokeWidth: 6,
                  backgroundColor: Colors.grey.shade100,
                  color: AppTheme.primaryColor,
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0), // يمنع النص من الالتصاق بحدود الدائرة
                  child: FittedBox(
                    fit: BoxFit.scaleDown, // يقوم بتصغير الخط تلقائياً عند زيادة الخانات لـ 100%
                    child: Text(
                      '${(ratio * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold, 
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // نصوص تفصيلية بالـ RTL
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  AppLocalizations.of(context)!.planProgressRate,
                  style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 14, color: Theme.of(context).colorScheme.primary),
                ),
                const SizedBox(height: 4),
                Text(
                  AppLocalizations.of(context)!.planProgressDetails(completed, total),
                  textAlign: TextAlign.right,
                  style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── بطاقة عرض المادة وحالتها ────────────────────────────────────────────

  Widget _buildCoursePlanCard(PlanCourse course) {
    Color statusColor;
    String statusText;
    Widget trailingWidget;

    switch (course.status) {
      case 'completed':
        statusColor = Colors.green;
        statusText = AppLocalizations.of(context)!.courseStatusCompleted;
        trailingWidget = Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            course.gradeLetter ?? 'P',
            style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
          ),
        );
        break;
      case 'in_progress':
        statusColor = Theme.of(context).colorScheme.primary;
        statusText = AppLocalizations.of(context)!.courseStatusInProgress;
        trailingWidget = Icon(Icons.hourglass_top_rounded, color: statusColor, size: 20);
        break;
      default:
        statusColor = Theme.of(context).colorScheme.onSurfaceVariant;
        statusText = AppLocalizations.of(context)!.courseStatusRemaining;
        trailingWidget = Icon(Icons.lock_outline_rounded, color: statusColor.withValues(alpha: 0.5), size: 20);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        children: [
          trailingWidget,
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(fontFamily: 'Cairo', fontSize: 10, color: statusColor, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                      course.name,
                      style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 13, color: Theme.of(context).colorScheme.onSurface),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.creditHoursLabel(course.credits),
                      style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '[${course.code}]',
                      style: TextStyle(fontFamily: 'Cairo', fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.8), fontWeight: FontWeight.w600),
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