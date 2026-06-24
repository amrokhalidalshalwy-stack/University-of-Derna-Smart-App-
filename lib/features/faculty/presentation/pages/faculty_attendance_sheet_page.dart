import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:flutter_project/features/faculty/providers/faculty_provider.dart';
import 'package:flutter_project/features/faculty/models/course_model.dart';
import 'package:flutter_project/core/models/user_profile.dart';

import 'package:flutter_project/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_project/core/services/professor_validator.dart';

// ── Attendance status enum ────────────────────────────────────────────────────
enum AttendanceStatus { none, present, late, absent }

class FacultyAttendanceSheetPage extends ConsumerStatefulWidget {
  final ProfessorValidator? validator;
  const FacultyAttendanceSheetPage({super.key, this.validator});

  @override
  ConsumerState<FacultyAttendanceSheetPage> createState() =>
      _FacultyAttendanceSheetPageState();
}

class _FacultyAttendanceSheetPageState
    extends ConsumerState<FacultyAttendanceSheetPage> {
  late final ProfessorValidator _validator = widget.validator ?? ProfessorValidator();

  CourseModel? _selectedCourse;
  final Map<String, AttendanceStatus> _studentAttendanceStatus = {};
  bool _isSaving = false;

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
    final coursesAsync = ref.watch(facultyCoursesProvider);
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final todayAr = DateFormat(
      'EEEE، d MMMM yyyy',
      'ar',
    ).format(DateTime.now());

    // Load attendance for selected course and date
    if (_selectedCourse != null) {
      ref.read(attendanceProvider.notifier).loadAttendance(
            _selectedCourse!.courseId,
            today,
          );
    }

    final attendanceAsync = ref.watch(attendanceProvider);

    // Stats derived from attendance data
    final presentCount =
        _studentAttendanceStatus.values.where((s) => s == AttendanceStatus.present).length;
    final lateCount =
        _studentAttendanceStatus.values.where((s) => s == AttendanceStatus.late).length;
    final absentCount =
        _studentAttendanceStatus.values.where((s) => s == AttendanceStatus.absent).length;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF132220) : const Color(0xFFF0FAFA),
      appBar: AppBar(
        title: Text(
          l10n.attendanceSheetTitle,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        backgroundColor: brandNavy,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: Column(
        children: [
          // ── Scrollable content area ─────────────────────────────────────
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
              physics: const BouncingScrollPhysics(),
              children: [
                // ── Page subtitle ─────────────────────────────────────────
                Text(
                  l10n.attendanceSheetSubtitle,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.right,
                ).animate().fadeIn(duration: 300.ms),

                const SizedBox(height: 16),

                // ── Course Selection Dropdown ─────────────────────────────────
                coursesAsync.when(
                  data: (courses) {
                    if (courses.isEmpty) {
                      return const SizedBox();
                    }
                    return Card(
                      margin: const EdgeInsets.only(bottom: 20),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: DropdownButtonFormField<CourseModel>(
                          decoration: InputDecoration(
                            labelText: 'اختر المادة',
                            prefixIcon: const Icon(Icons.book_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          initialValue: _selectedCourse ?? courses.first,
                          items: courses.map((course) {
                            final locale = Localizations.localeOf(context).languageCode;
                            final name = locale == 'ar' ? course.nameAr : course.nameEn;
                            return DropdownMenuItem<CourseModel>(
                              value: course,
                              child: Text(name, style: const TextStyle(fontFamily: 'Cairo')),
                            );
                          }).toList(),
                          onChanged: (course) {
                            setState(() {
                              _selectedCourse = course;
                              _studentAttendanceStatus.clear();
                            });
                          },
                        ),
                      ),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, _) => const SizedBox(),
                ).animate().fadeIn(duration: 300.ms),

                const SizedBox(height: 20),

                // ── Lecture Info Card ─────────────────────────────────────
                if (_selectedCourse != null)
                  _buildLectureInfoCard(
                    context: context,
                    courseName: Localizations.localeOf(context).languageCode == 'ar'
                        ? _selectedCourse!.nameAr
                        : _selectedCourse!.nameEn,
                    dateStr: todayAr,
                    brandTeal: brandTeal,
                    brandNavy: brandNavy,
                    isDark: isDark,
                  ).animate().fadeIn(duration: 350.ms, delay: 50.ms).slideY(begin: 0.05),

                const SizedBox(height: 20),

                // ── Summary Stats Row ─────────────────────────────────────
                Row(
                  children: [
                    _buildStatChip(
                      label: l10n.attendancePresent,
                      count: presentCount,
                      color: brandTeal,
                      isDark: isDark,
                    ),
                    const SizedBox(width: 8),
                    _buildStatChip(
                      label: l10n.attendanceLate,
                      count: lateCount,
                      color: Colors.amber.shade700,
                      isDark: isDark,
                    ),
                    const SizedBox(width: 8),
                    _buildStatChip(
                      label: l10n.attendanceAbsent,
                      count: absentCount,
                      color: Colors.red.shade600,
                      isDark: isDark,
                    ),
                  ],
                ).animate().fadeIn(duration: 350.ms, delay: 80.ms),

                const SizedBox(height: 20),

                // ── Student List (Live Data) ───────────────────────────────────
                if (_selectedCourse != null)
                  Consumer(
                    builder: (context, ref, child) {
                      final studentsAsync = ref.watch(classStudentsProvider(_selectedCourse!));
                      final attendanceRecords = attendanceAsync.value ?? [];

                      // Initialize attendance status from records
                      for (final record in attendanceRecords) {
                        if (!_studentAttendanceStatus.containsKey(record.studentUid)) {
                          _studentAttendanceStatus[record.studentUid] =
                              record.isPresent ? AttendanceStatus.present : AttendanceStatus.absent;
                        }
                      }

                      return studentsAsync.when(
                        data: (students) {
                          if (students.isEmpty) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(32),
                                child: Text(
                                  'لا يوجد طلاب مسجلين في هذه المادة',
                                  style: TextStyle(fontFamily: 'Cairo', fontSize: 16),
                                ),
                              ),
                            );
                          }

                          // ── Student List Header ───────────────────────────────────
                          return Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 4,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFB08B1A),
                                          borderRadius: BorderRadius.circular(2),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        l10n.attendanceStudentList,
                                        style: TextStyle(
                                          fontFamily: 'Cairo',
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: brandNavy,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '${l10n.attendanceStudentCount}: ${students.length}',
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 12,
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // ── Student Cards ─────────────────────────────────────────
                              ...students.asMap().entries.map((entry) {
                                final idx = entry.key;
                                final student = entry.value;
                                final status = _studentAttendanceStatus[student.uid] ?? AttendanceStatus.none;

                                return _buildStudentCard(
                                  student: student,
                                  status: status,
                                  onStatusChanged: (newStatus) {
                                    setState(() {
                                      _studentAttendanceStatus[student.uid] = newStatus;
                                    });
                                  },
                                  brandTeal: brandTeal,
                                  brandNavy: brandNavy,
                                  l10n: l10n,
                                  isDark: isDark,
                                )
                                    .animate()
                                    .fadeIn(duration: 350.ms, delay: (100 + idx * 60).ms)
                                    .slideX(begin: 0.05);
                              }),
                            ],
                          );
                        },
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (error, _) => Center(
                          child: Text(
                            'خطأ في تحميل الطلاب: $error',
                            style: const TextStyle(fontFamily: 'Cairo'),
                          ),
                        ),
                      );
                    },
                  ),
                if (_selectedCourse == null)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text(
                        'الرجاء اختيار مادة لعرض الطلاب',
                        style: TextStyle(fontFamily: 'Cairo', fontSize: 16),
                      ),
                    ),
                  ),

                const SizedBox(height: 24),

                // ── File Upload Section ───────────────────────────────────
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 20,
                      decoration: BoxDecoration(
                        color: const Color(0xFFB08B1A),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.attendanceUploadSection,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: brandNavy,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          l10n.attendanceUploadMobileOnly,
                          style: TextStyle(fontFamily: 'Cairo'),
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 36),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: brandTeal.withValues(alpha: 0.3),
                        width: 2,
                        style: BorderStyle.solid,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: brandTeal.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            Icons.cloud_upload_outlined,
                            size: 32,
                            color: brandTeal,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.attendanceUploadHint,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: brandNavy,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.attendanceUploadTypes,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(duration: 400.ms, delay: 200.ms),

                const SizedBox(height: 24),
              ],
            ),
          ),

          // ── Bottom Action Bar ─────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0D2420) : Colors.white,
              border: Border(
                top: BorderSide(
                  color:
                      isDark
                          ? const Color(0xFF10B981).withValues(alpha: 0.2)
                          : const Color(0xFFF1F5F9),
                ),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed:
                    _isSaving
                        ? null
                        : () => _saveAll(context, today, brandTeal),
                style: ElevatedButton.styleFrom(
                  backgroundColor: brandTeal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 0,
                ),
                icon:
                    _isSaving
                        ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                        : const Icon(Icons.send_rounded, size: 20),
                label: Text(
                  l10n.attendanceSaveReport,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Lecture info card ───────────────────────────────────────────────────────
  Widget _buildLectureInfoCard({
    required BuildContext context,
    required String courseName,
    required String dateStr,
    required Color brandTeal,
    required Color brandNavy,
    required bool isDark,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0D2420) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border(right: BorderSide(color: brandTeal, width: 4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time display
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                TimeOfDay.now().format(context),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: brandTeal,
                  fontFamily: 'Cairo',
                ),
              ),
              Text(
                Localizations.localeOf(context).languageCode == 'ar'
                    ? l10n.am
                    : 'AM',
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          // Course info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: brandTeal.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    courseName,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: brandTeal,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      dateStr,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 13,
                      color: Colors.grey,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      l10n.attendanceRoom,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.location_on_outlined,
                      size: 13,
                      color: Colors.grey,
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

  // ── Stat chip ───────────────────────────────────────────────────────────────
  Widget _buildStatChip({
    required String label,
    required int count,
    required Color color,
    required bool isDark,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color:
              isDark
                  ? color.withValues(alpha: 0.12)
                  : color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Individual student card ─────────────────────────────────────────────────
  Widget _buildStudentCard({
    required UserProfile student,
    required AttendanceStatus status,
    required Function(AttendanceStatus) onStatusChanged,
    required Color brandTeal,
    required Color brandNavy,
    required AppLocalizations l10n,
    required bool isDark,
  }) {
    Color cardBorder = Colors.transparent;
    if (status == AttendanceStatus.present) { cardBorder = brandTeal; }
    if (status == AttendanceStatus.late) {
      cardBorder = Colors.amber.shade700;
    }
    if (status == AttendanceStatus.absent) {
      cardBorder = Colors.red.shade600;
    }

    // Avatar letter from Arabic name
    final firstLetter = student.fullNameAr.isNotEmpty ? student.fullNameAr[0] : '؟';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: cardBorder.withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // ── Attendance toggle buttons ──────────────────────────────────
          Wrap(
            spacing: 6,
            children: [
              _statusBtn(
                label: l10n.attendancePresent,
                active: status == AttendanceStatus.present,
                activeColor: brandTeal,
                onTap: () => onStatusChanged(AttendanceStatus.present),
                isDark: isDark,
              ),
              _statusBtn(
                label: l10n.attendanceLate,
                active: status == AttendanceStatus.late,
                activeColor: Colors.amber.shade700,
                onTap: () => onStatusChanged(AttendanceStatus.late),
                isDark: isDark,
              ),
              _statusBtn(
                label: l10n.attendanceAbsent,
                active: status == AttendanceStatus.absent,
                activeColor: Colors.red.shade600,
                onTap: () => onStatusChanged(AttendanceStatus.absent),
                isDark: isDark,
              ),
            ],
          ),

          const Spacer(),

          // ── Student info ───────────────────────────────────────────────
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    student.fullNameAr,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: brandNavy,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${l10n.registrationNumberPrefix}${student.universityId}',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 10),
              // Avatar circle
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: brandTeal.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    firstLetter,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: brandTeal,
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

  // ── Small status toggle button ──────────────────────────────────────────────
  Widget _statusBtn({
    required String label,
    required bool active,
    required Color activeColor,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color:
              active
                  ? activeColor
                  : (isDark
                      ? const Color(0xFF0A3330)
                      : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(10),
          boxShadow:
              active
                  ? [
                    BoxShadow(
                      color: activeColor.withValues(alpha: 0.25),
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
            fontWeight: FontWeight.bold,
            fontSize: 11,
            color:
                active ? const Color(0xFFE8E8E8) : (isDark ? const Color(0xFFE8E8E8).withValues(alpha: 0.54) : Colors.grey),
          ),
        ),
      ),
    );
  }

  // ── Save all attendance records to Firestore ────────────────────────────────
  Future<void> _saveAll(
    BuildContext context,
    String today,
    Color brandTeal,
  ) async {
    if (_selectedCourse == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'الرجاء اختيار مادة أولاً',
            style: TextStyle(fontFamily: 'Cairo'),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    final notifier = ref.read(attendanceProvider.notifier);
    final l10n = AppLocalizations.of(context)!;

    try {
      // ✅ الخطوة الأولى: تحقق من صلاحية الأستاذ قبل أي حفظ
      final courseId = _selectedCourse!.courseId;
      final professorUid = FirebaseAuth.instance.currentUser?.uid ?? '';

      if (professorUid.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '❌ ${l10n.attendanceLoginRequired}',
                style: const TextStyle(fontFamily: 'Cairo'),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // ✅ التحقق من أن الأستاذ مُعيَّن لهذه المادة
      final isAssigned = await _validator.isProfessorAssignedToCourse(courseId);
      if (!isAssigned) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '❌ ${l10n.attendanceNoPermission}',
                style: const TextStyle(fontFamily: 'Cairo'),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // ✅ التحقق نجح — ابدأ الحفظ
      for (final entry in _studentAttendanceStatus.entries) {
        final studentUid = entry.key;
        final status = entry.value;
        if (status == AttendanceStatus.none) continue;

        final isPresent = status == AttendanceStatus.present;
        await notifier.saveAttendance(
          courseId,
          today,
          studentUid,
          isPresent,
        );
      }

      if (context.mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  l10n.attendanceSaved,
                  style: const TextStyle(fontFamily: 'Cairo'),
                ),
              ],
            ),
            backgroundColor: brandTeal,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.excusesErrorOccurred(e.toString()),
              style: const TextStyle(fontFamily: 'Cairo'),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
