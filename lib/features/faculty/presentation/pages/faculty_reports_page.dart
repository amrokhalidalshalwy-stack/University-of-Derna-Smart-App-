import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_project/l10n/app_localizations.dart';
import 'package:flutter_project/features/faculty/providers/faculty_provider.dart';

class FacultyReportsPage extends ConsumerStatefulWidget {
  const FacultyReportsPage({super.key});

  @override
  ConsumerState<FacultyReportsPage> createState() => _FacultyReportsPageState();
}

class _FacultyReportsPageState extends ConsumerState<FacultyReportsPage> {
  String _selectedSemester = '';
  String _selectedCourse = '';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final brandNavy =
        isDark ? const Color(0xFF0D2420) : const Color(0xFF00A694);
    final brandTeal =
        isDark ? const Color(0xFF10B981) : const Color(0xFF0DB5A2);
    final brandGold = const Color(0xFFEBB44D);

    // Fetch courses from Firestore
    final coursesAsync = ref.watch(facultyCoursesProvider);
    final coursesList = coursesAsync.value ?? [];

    // Dynamic semester list (can be fetched from Firestore in the future)
    final semestersList = [
      'خريف 2023 - 2024',
      'ربيع 2023 - 2024',
    ];

    // Set default values if not set
    if (_selectedSemester.isEmpty && semestersList.isNotEmpty) {
      _selectedSemester = semestersList.first;
    }
    if (_selectedCourse.isEmpty && coursesList.isNotEmpty) {
      _selectedCourse = coursesList.first.courseId;
    }

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF132220) : const Color(0xFFF0FAFA),
      appBar: AppBar(
        title: Text(
          l10n.reportsTitle,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0DB5A2), Color(0xFF031E39)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        foregroundColor: Colors.white,
        elevation: 4,
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
                      color: brandGold,
                      shape: BoxShape.circle,
                      border: Border.all(color: brandNavy, width: 1.5),
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
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
        physics: const BouncingScrollPhysics(),
        children: [
          // ── Selectors Section ──────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0D2420) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildDropdown(
                  label: l10n.reportsSelectSemester,
                  value: _selectedSemester,
                  items: semestersList,
                  onChanged: (v) => setState(() => _selectedSemester = v!),
                  brandTeal: brandTeal,
                  brandNavy: brandNavy,
                  isDark: isDark,
                ),
                const SizedBox(height: 16),
                coursesAsync.when(
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (error, stack) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        l10n.facultyErrorLoadingCourses,
                        style: TextStyle(fontFamily: 'Cairo', color: Colors.red),
                      ),
                    ),
                  ),
                  data: (_) => _buildDropdown(
                    label: l10n.reportsSelectCourse,
                    value: _selectedCourse,
                    items: coursesList.map((c) => '${c.nameAr} (${c.courseId})').toList(),
                    onChanged: (v) => setState(() => _selectedCourse = v!),
                    brandTeal: brandTeal,
                    brandNavy: brandNavy,
                    isDark: isDark,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.05),

          const SizedBox(height: 16),

          // ── Success Rate Card ──────────────────────────────────────────
          Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [brandTeal, brandNavy],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: brandNavy.withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.stars_rounded,
                        color: brandGold,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.reportsSuccessRate,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '0.0%',
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              )
              .animate()
              .fadeIn(duration: 350.ms, delay: 100.ms)
              .scale(begin: const Offset(0.95, 0.95)),

          const SizedBox(height: 16),

          // ── Secondary Stats Grid ───────────────────────────────────────
          Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      label: l10n.reportsTotalStudents,
                      value: '0',
                      borderColor: brandTeal,
                      brandNavy: brandNavy,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      label: l10n.reportsAverageGrade,
                      value: '0.0',
                      borderColor: brandGold,
                      brandNavy: brandNavy,
                      isDark: isDark,
                    ),
                  ),
                ],
              )
              .animate()
              .fadeIn(duration: 350.ms, delay: 150.ms)
              .slideY(begin: 0.05),

          const SizedBox(height: 16),

          // ── Grades Distribution Chart ──────────────────────────────────
          Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0D2420) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          l10n.reportsDistributionTitle,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.bold,
                            color: brandNavy,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 4,
                          height: 20,
                          decoration: BoxDecoration(
                            color: brandTeal,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      height: 180,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _buildBar(
                            label: 'F',
                            subtitle: l10n.reportsGradeF,
                            heightPercent: 0.0,
                            color: Colors.red.shade500,
                            brandNavy: brandNavy,
                            isDark: isDark,
                          ),
                          _buildBar(
                            label: 'D',
                            subtitle: l10n.reportsGradeD,
                            heightPercent: 0.0,
                            color: brandNavy,
                            brandNavy: brandNavy,
                            isDark: isDark,
                          ),
                          _buildBar(
                            label: 'C',
                            subtitle: l10n.reportsGradeC,
                            heightPercent: 0.0,
                            color: brandNavy,
                            brandNavy: brandNavy,
                            isDark: isDark,
                          ),
                          _buildBar(
                            label: 'B',
                            subtitle: l10n.reportsGradeB,
                            heightPercent: 0.0,
                            color: brandNavy,
                            brandNavy: brandNavy,
                            isDark: isDark,
                          ),
                          _buildBar(
                            label: 'A',
                            subtitle: l10n.reportsGradeA,
                            heightPercent: 0.0,
                            color: brandNavy,
                            brandNavy: brandNavy,
                            isDark: isDark,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
              .animate()
              .fadeIn(duration: 350.ms, delay: 200.ms)
              .slideY(begin: 0.05),

          const SizedBox(height: 24),

          // Export Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      l10n.reportsExportSuccess,
                      style: const TextStyle(fontFamily: 'Cairo'),
                    ),
                    backgroundColor: brandTeal,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: brandNavy,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.picture_as_pdf_rounded, size: 20),
              label: Text(
                l10n.reportsExportPdf,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ).animate().fadeIn(duration: 350.ms, delay: 250.ms),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required Color brandTeal,
    required Color brandNavy,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0D2420) : Colors.white,
            border: Border.all(color: isDark ? const Color(0xFF10B981).withValues(alpha: 0.3) : Colors.grey.shade200),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Colors.grey,
              ),
              dropdownColor: isDark ? const Color(0xFF0D2420) : Colors.white,
              style: TextStyle(
                fontFamily: 'Cairo',
                color: isDark ? const Color(0xFFE8E8E8) : brandNavy,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              onChanged: onChanged,
              items:
                  items.map((item) {
                    return DropdownMenuItem(
                      value: item,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(item),
                      ),
                    );
                  }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required Color borderColor,
    required Color brandNavy,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0D2420) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(right: BorderSide(color: borderColor, width: 4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 11,
              color: isDark ? const Color(0xFFE8E8E8).withValues(alpha: 0.6) : Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? const Color(0xFFE8E8E8) : brandNavy,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar({
    required String label,
    required String subtitle,
    required double heightPercent,
    required Color color,
    required Color brandNavy,
    required bool isDark,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 30,
          height: 110, // max height
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF132220).withValues(alpha: 0.3) : brandNavy.withValues(alpha: 0.05),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
          alignment: Alignment.bottomCenter,
          child: Container(
            width: 30,
            height: 110 * heightPercent,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(4),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: isDark ? const Color(0xFFE8E8E8) : color,
          ),
        ),
        Text(
          subtitle,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 10,
            color: isDark ? const Color(0xFFE8E8E8).withValues(alpha: 0.6) : (color == Colors.red.shade500 ? color : Colors.grey),
          ),
        ),
      ],
    );
  }
}
