// ============================================================
//  forum_home_page.dart  (UPDATED — bilingual + shimmer + theme)
// ============================================================
//
//  CHANGES vs original:
//  • Major chip labels now switch between nameAr / nameEn based on Locale.
//  • Course card title + subtitle switch language dynamically.
//  • CircularProgressIndicator replaced with uod_shimmer skeleton cards.
//  • All hardcoded colors replaced with Theme.of(context).colorScheme.*
//  • Navigator.push to CourseForumPage is now uncommented & wired.
//  • AppBar title uses AppLocalizations for bilingual support.
//
// ============================================================

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import 'package:flutter_project/features/forum/data/forum_models.dart';
import 'package:flutter_project/features/forum/data/forum_service.dart';
import 'package:flutter_project/features/forum/presentation/pages/course_forum_page.dart';
import 'package:flutter_project/l10n/app_localizations.dart';

class ForumHomePage extends StatefulWidget {
  const ForumHomePage({super.key});

  @override
  State<ForumHomePage> createState() => _ForumHomePageState();
}

class _ForumHomePageState extends State<ForumHomePage> {
  final ForumService _forumService = ForumService();
  String? _selectedMajorId;

  // ── Helper: resolve display name from current locale ─────────
  String _majorName(Major major, Locale locale) =>
      locale.languageCode == 'ar' ? major.nameAr : major.nameEn;

  String _courseName(Course course, Locale locale) =>
      locale.languageCode == 'ar' ? course.nameAr : course.nameEn;

  // ── Build ─────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        surfaceTintColor: Colors.transparent,
        title: Text(
          l10n.studentForum, // key: "studentForum" in .arb files
          style: TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
            color: cs.onSurface,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildMajorSelector(locale, cs),
          Divider(color: cs.outlineVariant, height: 1),
          Expanded(child: _buildCoursesList(locale, cs)),
        ],
      ),
    );
  }

  // ── Major Selector Chips ──────────────────────────────────────
  Widget _buildMajorSelector(Locale locale, ColorScheme cs) {
    return StreamBuilder<List<Major>>(
      stream: _forumService.getMajors(),
      builder: (context, snapshot) {
        // Loading state — shimmer chips
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _ShimmerChipRow();
        }

        if (snapshot.hasError) {
          return _ErrorBanner(
            message: 'خطأ في تحميل التخصصات / Error loading majors',
            cs: cs,
          );
        }

        final majors = snapshot.data ?? [];
        if (majors.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              locale.languageCode == 'ar'
                  ? 'لا توجد تخصصات متاحة.'
                  : 'No majors available.',
              style: TextStyle(fontFamily: 'Cairo', color: cs.onSurfaceVariant),
            ),
          );
        }

        final allLabel = locale.languageCode == 'ar' ? 'الكل' : 'All';

        return SizedBox(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: majors.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return _MajorChip(
                  label: allLabel,
                  id: null,
                  selected: _selectedMajorId == null,
                  cs: cs,
                  onSelected: (_) => setState(() => _selectedMajorId = null),
                );
              }
              final major = majors[index - 1];
              return _MajorChip(
                label: _majorName(major, locale),
                id: major.id,
                selected: _selectedMajorId == major.id,
                cs: cs,
                onSelected: (_) => setState(() => _selectedMajorId = major.id),
              );
            },
          ),
        );
      },
    );
  }

  // ── Courses List ──────────────────────────────────────────────
  Widget _buildCoursesList(Locale locale, ColorScheme cs) {
    final stream =
        _selectedMajorId == null
            ? _forumService.getAllCourses()
            : _forumService.getCoursesByMajor(_selectedMajorId!);

    return StreamBuilder<List<Course>>(
      stream: stream,
      builder: (context, snapshot) {
        // Loading — shimmer cards
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _ShimmerCourseList(cs: cs);
        }

        if (snapshot.hasError) {
          return _ErrorBanner(
            message: 'خطأ في تحميل المواد / Error loading courses',
            cs: cs,
          );
        }

        final courses = snapshot.data ?? [];
        if (courses.isEmpty) {
          return Center(
            child: Text(
              locale.languageCode == 'ar'
                  ? 'لا توجد مواد دراسية في هذا التخصص.'
                  : 'No courses found for this major.',
              style: TextStyle(fontFamily: 'Cairo', color: cs.onSurfaceVariant),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: courses.length,
          itemBuilder: (context, index) {
            final course = courses[index];
            return _CourseCard(
              course: course,
              displayName: _courseName(course, locale),
              locale: locale,
              cs: cs,
            );
          },
        );
      },
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────

class _MajorChip extends StatelessWidget {
  const _MajorChip({
    required this.label,
    required this.id,
    required this.selected,
    required this.cs,
    required this.onSelected,
  });

  final String label;
  final String? id;
  final bool selected;
  final ColorScheme cs;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: ChoiceChip(
        label: Text(
          label,
          style: TextStyle(
            fontFamily: 'Cairo',
            color: selected ? cs.onPrimary : cs.onSurfaceVariant,
          ),
        ),
        selected: selected,
        selectedColor: cs.primary,
        backgroundColor: cs.surfaceContainerHighest,
        side: BorderSide(color: selected ? cs.primary : cs.outline),
        onSelected: onSelected,
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  const _CourseCard({
    required this.course,
    required this.displayName,
    required this.locale,
    required this.cs,
  });

  final Course course;
  final String displayName;
  final Locale locale;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    // Subtitle: always show course code + the OTHER language name for clarity
    final subtitle =
        locale.languageCode == 'ar'
            ? '${course.code}  •  ${course.nameEn}'
            : '${course.code}  •  ${course.nameAr}';

    // Avatar initials — first 2 chars of code
    final initials =
        course.code.length >= 2 ? course.code.substring(0, 2) : course.code;

    return Card(
      elevation: 0,
      color: cs.surfaceContainerLow,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: cs.primaryContainer,
          child: Text(
            initials,
            style: TextStyle(
              color: cs.onPrimaryContainer,
              fontFamily: 'Cairo',
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
        title: Text(
          displayName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Cairo',
            color: cs.onSurface,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontFamily: 'Cairo',
            color: cs.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 15,
          color: cs.primary,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => CourseForumPage(course: course)),
          );
        },
      ),
    );
  }
}

// ── Shimmer loading widgets (uod_shimmer pattern) ─────────────

class _ShimmerChipRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        itemCount: 5,
        itemBuilder:
            (_, _) => Shimmer.fromColors(
              baseColor: cs.surfaceContainerHighest,
              highlightColor: cs.surfaceContainerLow,
              child: Container(
                width: 80,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
      ),
    );
  }
}

class _ShimmerCourseList extends StatelessWidget {
  const _ShimmerCourseList({required this.cs});
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: 6,
      itemBuilder:
          (_, _) => Shimmer.fromColors(
            baseColor: cs.surfaceContainerHighest,
            highlightColor: cs.surfaceContainerLow,
            child: Card(
              elevation: 0,
              color: cs.surfaceContainerHighest,
              margin: const EdgeInsets.symmetric(vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: const SizedBox(height: 76),
            ),
          ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message, required this.cs});
  final String message;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: cs.error),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(fontFamily: 'Cairo', color: cs.error),
            ),
          ),
        ],
      ),
    );
  }
}
