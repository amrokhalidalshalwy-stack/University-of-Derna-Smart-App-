import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_project/features/faculty/models/course_model.dart';
import 'package:flutter_project/features/faculty/providers/faculty_provider.dart';
import 'package:flutter_project/l10n/app_localizations.dart';

/// Opens assignments for a faculty course. If [courseId] is provided, navigates
/// directly; otherwise shows a course picker (or auto-selects when only one course).
void openFacultyAssignments(
  BuildContext context,
  WidgetRef ref, {
  String? courseId,
}) {
  if (courseId != null && courseId.isNotEmpty) {
    context.push('/faculty/assignments/$courseId');
    return;
  }

  final l10n = AppLocalizations.of(context)!;
  final coursesAsync = ref.read(facultyCoursesProvider);

  coursesAsync.when(
    loading: () {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.loading,
            style: const TextStyle(fontFamily: 'Cairo'),
          ),
        ),
      );
    },
    error: (_, _) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.facultyErrorLoadingCourses,
            style: const TextStyle(fontFamily: 'Cairo'),
          ),
        ),
      );
    },
    data: (courses) {
      if (courses.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.facultyErrorLoadingCourses,
              style: const TextStyle(fontFamily: 'Cairo'),
            ),
          ),
        );
        return;
      }

      if (courses.length == 1) {
        context.push('/faculty/assignments/${courses.first.courseId}');
        return;
      }

      _showCoursePickerSheet(context, l10n, courses);
    },
  );
}

void _showCoursePickerSheet(
  BuildContext context,
  AppLocalizations l10n,
  List<CourseModel> courses,
) {
  final isArabic = Localizations.localeOf(context).languageCode == 'ar';

  showModalBottomSheet<void>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                l10n.selectCourse,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: courses.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (_, index) {
                  final course = courses[index];
                  final courseName =
                      isArabic ? course.nameAr : course.nameEn;

                  return ListTile(
                    title: Text(
                      courseName,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                      style: const TextStyle(fontFamily: 'Cairo'),
                    ),
                    subtitle: Text(
                      course.courseId,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_left_rounded),
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      context.push('/faculty/assignments/${course.courseId}');
                    },
                  );
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}
