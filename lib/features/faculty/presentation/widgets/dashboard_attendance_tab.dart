import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_project/features/faculty/models/course_model.dart';
import 'package:flutter_project/features/faculty/providers/faculty_provider.dart';
import 'package:flutter_project/l10n/app_localizations.dart';
import 'package:flutter_project/shared/widgets/animated_widgets.dart';

class DashboardAttendanceTab extends ConsumerStatefulWidget {
  const DashboardAttendanceTab({super.key});
  @override
  ConsumerState<DashboardAttendanceTab> createState() =>
      DashboardAttendanceTabState();
}

class DashboardAttendanceTabState
    extends ConsumerState<DashboardAttendanceTab> {
  CourseModel? _selectedCourse;
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final coursesAsync = ref.watch(facultyCoursesProvider);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.attendanceTitle,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xFF005A51),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: coursesAsync.when(
                      data: (courses) {
                        if (courses.isEmpty) {
                          return Text(l10n.facultyNoCourses);
                        }
                        return InputDecorator(
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF9FAFB),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<CourseModel>(
                              value: _selectedCourse,
                              isExpanded: true,
                              hint: Text(
                                l10n.facultySelectCourse,
                                style: const TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 13,
                                ),
                              ),
                              items:
                                  courses
                                      .map(
                                        (c) => DropdownMenuItem(
                                          value: c,
                                          child: Text(
                                            c.nameAr,
                                            style: const TextStyle(
                                              fontFamily: 'Cairo',
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                              onChanged: (val) {
                                setState(() => _selectedCourse = val);
                                if (val != null) {
                                  ref
                                      .read(attendanceProvider.notifier)
                                      .loadAttendance(
                                        val.courseId,
                                        DateFormat(
                                          'yyyy-MM-dd',
                                        ).format(_selectedDate),
                                      );
                                }
                              },
                            ),
                          ),
                        );
                      },
                      loading: () => const LinearProgressIndicator(),
                      error: (e, st) => Text(l10n.facultyErrorLoadingCourses),
                    ),
                  ),
                  const SizedBox(width: 12),
                  InkWell(
                    onTap: () async {
                      final d = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (d != null) {
                        setState(() => _selectedDate = d);
                        if (_selectedCourse != null) {
                          ref
                              .read(attendanceProvider.notifier)
                              .loadAttendance(
                                _selectedCourse!.courseId,
                                DateFormat('yyyy-MM-dd').format(d),
                              );
                        }
                      }
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_rounded,
                            size: 18,
                            color: Color(0xFF005A51),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat('MM/dd').format(_selectedDate),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF005A51),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child:
              _selectedCourse == null
                  ? FadeInScale(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.fact_check_outlined,
                            size: 60,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.facultySelectCourseForStudents,
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              color: Colors.grey.shade500,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  : DashboardAttendanceList(
                    course: _selectedCourse!,
                    date: DateFormat('yyyy-MM-dd').format(_selectedDate),
                  ),
        ),
      ],
    );
  }
}

class DashboardAttendanceList extends ConsumerWidget {
  final CourseModel course;
  final String date;
  const DashboardAttendanceList({
    super.key,
    required this.course,
    required this.date,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentsAsync = ref.watch(classStudentsProvider(course));
    final attendanceAsync = ref.watch(attendanceProvider);
    final l10n = AppLocalizations.of(context)!;

    return studentsAsync.when(
      data: (students) {
        if (students.isEmpty) {
          return Center(
            child: Text(
              l10n.facultyNoStudents,
              style: const TextStyle(fontFamily: 'Cairo'),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: students.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final student = students[index];
            final records = attendanceAsync.value ?? [];
            final record =
                records.where((r) => r.studentUid == student.uid).firstOrNull;
            final isPresent = record?.isPresent ?? false;

            return StaggeredFadeInSlideY(
              index: index,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 8,
                ),
                leading: CircleAvatar(
                  backgroundColor: const Color(
                    0xFF005A51,
                  ).withValues(alpha: 0.05),
                  child: const Icon(Icons.person, color: Color(0xFF005A51)),
                ),
                title: Text(
                  student.fullNameAr.isNotEmpty
                      ? student.fullNameAr
                      : student.fullName,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                subtitle: Text(
                  student.universityId,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                trailing: Transform.scale(
                  scale: 1.2,
                  child: Checkbox(
                    value: isPresent,
                    activeColor: const Color(0xFF00A694),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    onChanged: (val) {
                      if (val != null) {
                        ref
                            .read(attendanceProvider.notifier)
                            .saveAttendance(
                              course.courseId,
                              date,
                              student.uid,
                              val,
                            );
                      }
                    },
                  ),
                ),
              ),
            );
          },
        );
      },
      loading:
          () => const Center(
            child: CircularProgressIndicator(color: Color(0xFF005A51)),
          ),
      error: (e, st) => Center(child: Text('${l10n.errorPrefix}$e')),
    );
  }
}
