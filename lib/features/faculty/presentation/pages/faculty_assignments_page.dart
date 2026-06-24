import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_project/features/faculty/providers/faculty_provider.dart';
import 'package:flutter_project/l10n/app_localizations.dart';

// ── Lightweight student item for local display ────────────────────────────────
class _AssignmentStudent {
  final String uid;
  final String name;
  final String registrationId;
  final String initials;
  final Color avatarColor;
  final Color textColor;
  String? grade;

  _AssignmentStudent({
    required this.uid,
    required this.name,
    required this.registrationId,
    required this.initials,
    required this.avatarColor,
    required this.textColor,
  }) : grade = null;
}

class FacultyAssignmentsPage extends ConsumerStatefulWidget {
  final String courseId;

  const FacultyAssignmentsPage({super.key, required this.courseId});

  @override
  ConsumerState<FacultyAssignmentsPage> createState() =>
      _FacultyAssignmentsPageState();
}

class _FacultyAssignmentsPageState
    extends ConsumerState<FacultyAssignmentsPage> {
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _maxGradeCtrl = TextEditingController(text: '20');
  final TextEditingController _dateCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isPublishing = false;
  bool _isSavingGrades = false;

  // ── Dynamic student list (to be populated from Firestore) ─────────────
  final List<_AssignmentStudent> _students = [];

  // ── Dynamic counters calculated from student list ─────────────────────
  int get _waitingCount => _students.where((s) => s.grade == null || s.grade!.isEmpty).length;
  int get _gradedCount => _students.where((s) => s.grade != null && s.grade!.isNotEmpty).length;
  int get _totalCount => _students.length;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _maxGradeCtrl.dispose();
    _dateCtrl.dispose();
    super.dispose();
  }

  String _courseName(BuildContext context, AppLocalizations l10n) {
    final coursesAsync = ref.watch(facultyCoursesProvider);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final course = coursesAsync.value
        ?.where((c) => c.courseId == widget.courseId)
        .firstOrNull;

    if (course == null) {
      return l10n.selectCourse;
    }

    final localizedName = isArabic ? course.nameAr : course.nameEn;
    return localizedName.isNotEmpty
        ? localizedName
        : (course.nameAr.isNotEmpty ? course.nameAr : course.nameEn);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final coursesAsync = ref.watch(facultyCoursesProvider);
    final courseName = _courseName(context, l10n);
    final brandTeal =
        isDark ? const Color(0xFF10B981) : const Color(0xFF00837a);
    final brandDark =
        isDark ? const Color(0xFF0D2420) : const Color(0xFF0b2447);

    if (coursesAsync.isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            l10n.assignmentsTitle,
            style: const TextStyle(fontFamily: 'Cairo'),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (coursesAsync.hasError ||
        coursesAsync.value
                ?.any((course) => course.courseId == widget.courseId) !=
            true) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            l10n.assignmentsTitle,
            style: const TextStyle(fontFamily: 'Cairo'),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ),
        body: Center(
          child: Text(
            l10n.facultyErrorLoadingCourses,
            style: const TextStyle(fontFamily: 'Cairo'),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF132220) : const Color(0xFFF0FAFA),
      appBar: AppBar(
        title: Text(
          l10n.assignmentsTitle,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark 
                  ? [const Color(0xFF0D2420), const Color(0xFF132220)]
                  : [const Color(0xFF00A694), const Color(0xFF00C4A8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        foregroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications_none_rounded),
                Positioned(
                  top: 2,
                  right: 2,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.red.shade500,
                      shape: BoxShape.circle,
                      border: Border.all(color: brandTeal, width: 1.5),
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
        physics: const BouncingScrollPhysics(),
        children: [
          // ── Page subtitle ───────────────────────────────────────────────
          Text(
            l10n.assignmentsSubtitle,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.right,
          ).animate().fadeIn(duration: 300.ms),

          const SizedBox(height: 20),

          // ── Summary Cards ───────────────────────────────────────────────
          Row(
                children: [
                  Expanded(child: _buildWaitingCard(l10n, brandDark)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildGradedCard(l10n, brandDark)),
                ],
              )
              .animate()
              .fadeIn(duration: 350.ms, delay: 50.ms)
              .slideY(begin: 0.05),

          const SizedBox(height: 24),

          // ── Add Assignment Form ─────────────────────────────────────────
          _buildAddAssignmentForm(context, l10n, brandTeal, brandDark)
              .animate()
              .fadeIn(duration: 350.ms, delay: 100.ms)
              .slideY(begin: 0.05),

          const SizedBox(height: 32),

          // ── Grading Section ─────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${l10n.assignmentsCoursePrefix} $courseName',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 10,
                    color: brandDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                l10n.assignmentsGradingSection,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: brandDark,
                ),
              ),
            ],
          ).animate().fadeIn(duration: 350.ms, delay: 150.ms),

          const SizedBox(height: 16),

          if (_students.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: [
                    Icon(
                      Icons.people_outline_rounded,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.assignmentsTotalStudents(0),
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ..._students.asMap().entries.map((entry) {
              final idx = entry.key;
              final student = entry.value;
              return _buildStudentGradeCard(student, l10n, brandTeal, brandDark)
                  .animate()
                  .fadeIn(duration: 350.ms, delay: (200 + idx * 50).ms)
                  .slideX(begin: 0.04);
            }),

          const SizedBox(height: 16),

          // ── Show More Button ────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: Colors.grey.shade300, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Colors.grey.shade500,
              ),
              label: Text(
                l10n.assignmentsShowMore,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.bold,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                ),
              ),
            ),
          ).animate().fadeIn(duration: 350.ms, delay: 350.ms),

          const SizedBox(height: 16),

          // ── Save Grades Button ────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed:
                  _isSavingGrades
                      ? null
                      : () => _saveGrades(context, l10n, brandTeal),
              style: ElevatedButton.styleFrom(
                backgroundColor: brandDark,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon:
                  _isSavingGrades
                      ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                      : const Icon(Icons.save_rounded, size: 20),
              label: Text(
                l10n.reportsExportSuccess, // Re-using success string or create new one
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ).animate().fadeIn(duration: 350.ms, delay: 400.ms),
        ],
      ),
    );
  }

  Widget _buildWaitingCard(AppLocalizations l10n, Color brandDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            l10n.assignmentsWaiting,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                l10n.assignmentsStudents,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 10,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                _waitingCount.toString().padLeft(2, '0'),
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: brandDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                l10n.assignmentsDueTomorrow,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 10,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.timer_outlined, color: Colors.red, size: 12),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGradedCard(AppLocalizations l10n, Color brandDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: brandDark,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: brandDark.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            l10n.assignmentsGraded,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.8),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                l10n.assignmentsOutOf(_totalCount),
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 10,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                _gradedCount.toString(),
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                width: 100, // Roughly 80%
                decoration: BoxDecoration(
                  color: Colors.amber.shade400,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddAssignmentForm(
    BuildContext context,
    AppLocalizations l10n,
    Color brandTeal,
    Color brandDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(right: BorderSide(color: brandTeal, width: 4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  l10n.assignmentsAddTitle,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: brandDark,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.assignment_add, color: brandTeal, size: 20),
              ],
            ),
            const SizedBox(height: 20),

            // Title Input
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  l10n.assignmentsAssignmentTitle,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _titleCtrl,
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
                  decoration: InputDecoration(
                    hintText: l10n.assignmentsAssignmentTitleHint,
                    hintStyle: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator:
                      (value) => value == null || value.isEmpty ? '*' : null,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Grades & Date
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        l10n.assignmentsMaxGrade,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 11,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _maxGradeCtrl,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13,
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) return '*';
                          final val = double.tryParse(value);
                          if (val == null || val <= 0 || val > 20) return '*';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        l10n.assignmentsDueDate,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 11,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _dateCtrl,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13,
                        ),
                        decoration: InputDecoration(
                          hintText: 'mm/dd/yyyy',
                          hintStyle: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          prefixIcon: const Icon(
                            Icons.calendar_month_rounded,
                            color: Colors.grey,
                            size: 18,
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator:
                            (value) =>
                                value == null || value.isEmpty ? '*' : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Publish Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed:
                    _isPublishing
                        ? null
                        : () => _publishAssignment(context, l10n, brandTeal),
                style: ElevatedButton.styleFrom(
                  backgroundColor: brandTeal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon:
                    _isPublishing
                        ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                        : const Icon(Icons.send_rounded, size: 18),
                label: Text(
                  l10n.assignmentsPublish,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentGradeCard(
    _AssignmentStudent student,
    AppLocalizations l10n,
    Color brandTeal,
    Color brandDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Grade Input
          Column(
            children: [
              Text(
                l10n.assignmentsGradeLabel,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 9,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: 60,
                child: TextFormField(
                  initialValue: student.grade,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: brandDark,
                  ),
                  decoration: InputDecoration(
                    hintText: '--',
                    hintStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    filled: true,
                    fillColor:
                        student.grade != null && student.grade!.isNotEmpty
                            ? Colors.blue.shade50
                            : Colors.grey.shade50,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (val) {
                    student.grade = val;
                  },
                ),
              ),
            ],
          ),

          const Spacer(),

          // Info
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    student.name,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: brandDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${l10n.registrationNumberPrefix}${student.registrationId}',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 10,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: student.avatarColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    student.initials,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: student.textColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _publishAssignment(
    BuildContext context,
    AppLocalizations l10n,
    Color brandTeal,
  ) async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.assignmentsValidationError,
            style: const TextStyle(fontFamily: 'Cairo'),
          ),
        ),
      );
      return;
    }
    setState(() => _isPublishing = true);
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    setState(() => _isPublishing = false);
    _titleCtrl.clear();
    _dateCtrl.clear();

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          l10n.reportsExportSuccess,
          style: const TextStyle(fontFamily: 'Cairo'),
        ),
        backgroundColor: brandTeal,
      ), // Re-using success string
    );
  }

  Future<void> _saveGrades(
    BuildContext context,
    AppLocalizations l10n,
    Color brandTeal,
  ) async {
    setState(() => _isSavingGrades = true);
    final notifier = ref.read(gradesProvider.notifier);

    try {
      for (final student in _students) {
        if (student.grade == null || student.grade!.isEmpty) continue;
        final val = double.tryParse(student.grade!);
        if (val != null && val >= 0 && val <= 20) {
          await notifier.saveGrade(
            widget.courseId,
            student.uid,
            assignments: val,
          );
        }
      }

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.reportsExportSuccess,
            style: const TextStyle(fontFamily: 'Cairo'),
          ),
          backgroundColor: brandTeal,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isSavingGrades = false);
    }
  }
}
