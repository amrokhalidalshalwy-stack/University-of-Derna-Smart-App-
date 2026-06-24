import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_project/core/models/course_grade.dart';
import 'package:flutter_project/core/theme/app_theme.dart';
import 'package:flutter_project/features/auth/data/auth_service.dart';
import 'package:flutter_project/features/student/data/student_providers.dart';
import 'package:flutter_project/l10n/app_localizations.dart';
import 'package:flutter_project/shared/widgets/empty_state_widget.dart';
import 'package:flutter_project/shared/widgets/uod_shimmer.dart';

/// صفحة النتائج والدرجات — متصلة بـ Firestore بشكل حي (StreamProvider).
class GradesPage extends ConsumerStatefulWidget {
  const GradesPage({super.key});

  @override
  ConsumerState<GradesPage> createState() => _GradesPageState();
}

class _GradesPageState extends ConsumerState<GradesPage> {
  String? _selectedSemester;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authAsync = ref.watch(authStateChangesProvider);

    debugPrint(
      '📱 GradesPage.build: authAsync state = ${authAsync.runtimeType}',
    );

    return authAsync.when(
      data: (user) {
        debugPrint('📱 GradesPage.build: user data received, user = $user');
        if (user == null) {
          debugPrint('⚠️ GradesPage.build: user is null');
          return Scaffold(
            body: Center(
              child: Text(
                l10n.pleaseLogin,
                style: const TextStyle(fontFamily: 'Cairo'),
              ),
            ),
          );
        }

        final uid = user.uid;
        debugPrint('📱 GradesPage.build: uid = "$uid"');
        final gradesAsync = ref.watch(gradesStreamProviderDirect(uid));
        final gpaAsync = ref.watch(computedGpaProviderDirect(uid));
        final hoursAsync = ref.watch(computedCompletedHoursProviderDirect(uid));

        debugPrint(
          '📱 GradesPage.build: gradesAsync state = ${gradesAsync.runtimeType}',
        );
        debugPrint(
          '📱 GradesPage.build: gpaAsync state = ${gpaAsync.runtimeType}',
        );
        debugPrint(
          '📱 GradesPage.build: hoursAsync state = ${hoursAsync.runtimeType}',
        );

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            title: Text(
              l10n.gradesTitle,
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
          body: gradesAsync.when(
            data: (grades) {
              debugPrint(
                '📱 GradesPage.body: grades data received, ${grades.length} grades',
              );
              return _buildBody(context, grades, gpaAsync, hoursAsync);
            },
            loading: () {
              debugPrint('⏳ GradesPage.body: grades loading');
              return const UodScreenLoading();
            },
            error: (e, stack) {
              debugPrint('❌ GradesPage.body: grades error: $e');
              debugPrint('❌ GradesPage.body: stack trace: $stack');
              return Center(
                child: Text(
                  '${l10n.errorLoadingGrades}: $e',
                  style: const TextStyle(fontFamily: 'Cairo'),
                ),
              );
            },
          ),
        );
      },
      loading: () => const Scaffold(body: UodScreenLoading()),
      error:
          (e, _) => Scaffold(
            body: Center(
              child: Text(
                '${l10n.error}: $e',
                style: const TextStyle(fontFamily: 'Cairo'),
              ),
            ),
          ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    List<CourseGrade> grades,
    AsyncValue<String> gpaAsync,
    AsyncValue<String> hoursAsync,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final gpa = gpaAsync.value ?? '0.00';
    final hours = hoursAsync.value ?? '0';

    // استخراج الفصول الدراسية المتاحة وترتيبها التلقائي
    final semesters = grades.map((g) => g.semester).toSet().toList()..sort();

    // تطبيق فلاتر البحث والفصل الدراسي
    final filtered =
        grades.where((g) {
          final matchesSemester =
              _selectedSemester == null || g.semester == _selectedSemester;
          final matchesSearch =
              _searchQuery.isEmpty ||
              g.courseName.toLowerCase().contains(_searchQuery.toLowerCase());
          return matchesSemester && matchesSearch;
        }).toList();

    // تجميع الكروت ديناميكياً حسب الفصل الدراسي المختار
    final Map<String, List<CourseGrade>> bySemester = {};
    for (final g in filtered) {
      bySemester.putIfAbsent(g.semester, () => []).add(g);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // بطاقة المعدل الإجمالي
        _buildGpaCard(
          gpa,
          hours,
          grades.length,
          l10n,
        ).animate().fadeIn().slideY(begin: -0.05),
        const SizedBox(height: 16),

        // شريط البحث الذكي
        _buildSearchBar(l10n),
        const SizedBox(height: 12),

        // أشرطة اختيار الفصول الدراسية (Chips)
        if (semesters.isNotEmpty) ...[
          _buildSemesterFilter(semesters, l10n),
          const SizedBox(height: 16),
        ],

        // عرض المحتوى المفلتر بحسب حالة التوفر
        if (filtered.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 24),
            child: EmptyStateWidget(
              icon: Icons.assignment_outlined,
              title:
                  _searchQuery.isNotEmpty
                      ? l10n.noSearchResults
                      : l10n.noGradesRecorded,
              subtitle:
                  _searchQuery.isNotEmpty ? l10n.tryDifferentSearch : null,
            ),
          )
        else ...[
          for (final entry in bySemester.entries) ...[
            _buildSemesterHeader(context, entry.key, l10n),
            const SizedBox(height: 8),
            ...entry.value.asMap().entries.map(
              (e) => _buildGradeCard(context, e.value, l10n)
                  .animate()
                  .fadeIn(delay: (e.key * 60).ms)
                  .slideX(begin: -0.04), // الحركة تتبع الاتجاه العربي لليمين
            ),
            const SizedBox(height: 16),
          ],
        ],
      ],
    );
  }

  // ── شريط البحث ─────────────────────────────────────────────────────────

  Widget _buildSearchBar(AppLocalizations l10n) {
    return TextField(
      controller: _searchController,
      textDirection: TextDirection.rtl,
      style: const TextStyle(fontFamily: 'Cairo', fontSize: 14),
      decoration: InputDecoration(
        hintText: l10n.searchCourse,
        hintStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
        prefixIcon: const Icon(Icons.search_rounded, size: 20),
        suffixIcon:
            _searchQuery.isNotEmpty
                ? IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
                : null,
        filled: true,
        fillColor: Theme.of(context).cardColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppTheme.outlineVariantColor.withValues(alpha: 0.4),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppTheme.outlineVariantColor.withValues(alpha: 0.4),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppTheme.primaryColor,
            width: 1.5,
          ),
        ),
      ),
      onChanged: (val) => setState(() => _searchQuery = val),
    );
  }

  // ── فلتر الفصول الدراسية ─────────────────────────────────────────────

  Widget _buildSemesterFilter(List<String> semesters, AppLocalizations l10n) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _SemesterChip(
              label: l10n.all,
              isSelected: _selectedSemester == null,
              onTap: () => setState(() => _selectedSemester = null),
            ),
            const SizedBox(width: 8),
            ...semesters.map(
              (s) => Padding(
                padding: const EdgeInsets.only(left: 8),
                child: _SemesterChip(
                  label: s.isNotEmpty ? s : l10n.undefinedSemester,
                  isSelected: _selectedSemester == s,
                  onTap:
                      () => setState(
                        () =>
                            _selectedSemester =
                                _selectedSemester == s ? null : s,
                      ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── بطاقة المعدل الإجمالي ──────────────────────────────────────────────

  Widget _buildGpaCard(
    String gpa,
    String hours,
    int courseCount,
    AppLocalizations l10n,
  ) {
    final gpaDouble = double.tryParse(gpa) ?? 0.0;
    final gpaColor =
        gpaDouble >= 3.5
            ? Colors.greenAccent
            : gpaDouble >= 2.5
            ? Colors.orangeAccent
            : Colors.redAccent;
    final gpaFraction = (gpaDouble / 4.0).clamp(0.0, 1.0);

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
          // تفاصيل الساعات المكتسبة
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hours,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  l10n.hoursEarned,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontFamily: 'Cairo',
                  ),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (double.tryParse(hours) ?? 0) / 160,
                    backgroundColor: Colors.white24,
                    color: AppTheme.secondaryContainer,
                    minHeight: 5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$courseCount ${l10n.coursesCount}',
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 11,
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // دائرة عرض المعدل التراكمي ونوعه
          Column(
            children: [
              Text(
                l10n.gpaLabel,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontFamily: 'Cairo',
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: 80,
                height: 80,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: gpaFraction,
                      strokeWidth: 7,
                      backgroundColor: Colors.white24,
                      color: gpaColor,
                    ),
                    Text(
                      gpa,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _gpaLabel(gpaDouble, l10n),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSemesterHeader(
    BuildContext context,
    String semester,
    AppLocalizations l10n,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border(
          right: BorderSide(
            color: AppTheme.primaryColor.withValues(alpha: 0.5),
            width: 4,
          ),
        ),
      ),
      child: Text(
        semester.isNotEmpty ? semester : l10n.undefinedSemester,
        textAlign: TextAlign.right,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: 13,
          fontFamily: 'Cairo',
        ),
      ),
    );
  }

  Widget _buildGradeCard(
    BuildContext context,
    CourseGrade grade,
    AppLocalizations l10n,
  ) {
    final color = _gradeColor(grade.gradePoints);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppTheme.outlineVariantColor.withValues(alpha: 0.25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // الدرجة بالنقاط والرمز الحرفي
          Column(
            children: [
              Container(
                width: 50,
                height: 50,
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
          // تفاصيل درجات المادة (نصفي، نهائي، ساعات ومحاذاة RTL)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  grade.courseName,
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface,
                    fontFamily: 'Cairo',
                  ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: grade.totalScore / 100,
                    backgroundColor:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    color: color,
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${grade.creditHours} ${l10n.hours}',
                      style: TextStyle(
                        fontSize: 11,
                        fontFamily: 'Cairo',
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      '${l10n.finalExam}: ${grade.finalExam.toStringAsFixed(0)} | ${l10n.midtermExam}: ${grade.midterm.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 11,
                        fontFamily: 'Cairo',
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      grade.totalScore.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 12,
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
    if (gradePoints >= 3.5) return Colors.green.shade600;
    if (gradePoints >= 2.5) return Colors.blue.shade600;
    if (gradePoints >= 1.5) return Colors.orange.shade600;
    if (gradePoints > 0) return Colors.deepOrange.shade600;
    return Colors.red.shade600;
  }

  String _gpaLabel(double gpa, AppLocalizations l10n) {
    if (gpa >= 3.7) return l10n.excellent;
    if (gpa >= 3.0) return l10n.veryGood;
    if (gpa >= 2.0) return l10n.good;
    if (gpa >= 1.0) return l10n.acceptable;
    return l10n.failed;
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _SemesterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SemesterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color:
              isSelected ? AppTheme.primaryColor : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                isSelected
                    ? AppTheme.primaryColor
                    : AppTheme.outlineVariantColor.withValues(alpha: 0.4),
          ),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: AppTheme.primaryColor.withValues(alpha: 0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                  : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : AppTheme.onSurfaceVariantColor,
          ),
        ),
      ),
    );
  }
}
