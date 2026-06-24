import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_project/features/faculty/models/course_model.dart';

import 'package:flutter_project/features/faculty/providers/faculty_provider.dart';

import 'package:flutter_project/l10n/app_localizations.dart';

import 'package:flutter_project/shared/widgets/animated_widgets.dart';



class DashboardGradesTab extends ConsumerStatefulWidget {

  const DashboardGradesTab({super.key});

  @override

  ConsumerState<DashboardGradesTab> createState() => DashboardGradesTabState();

}



class DashboardGradesTabState extends ConsumerState<DashboardGradesTab> {

  CourseModel? _selectedCourse;



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

                l10n.facultyGradesTitle,

                style: const TextStyle(

                  fontFamily: 'Cairo',

                  fontWeight: FontWeight.bold,

                  fontSize: 18,

                  color: Color(0xFF001835),

                ),

              ),

              const SizedBox(height: 16),

              coursesAsync.when(

                data: (courses) {

                  if (courses.isEmpty) return Text(l10n.facultyNoCourses);

                  return InputDecorator(

                    decoration: InputDecoration(

                      contentPadding: const EdgeInsets.symmetric(

                        horizontal: 16,

                        vertical: 4,

                      ),

                      border: OutlineInputBorder(

                        borderRadius: BorderRadius.circular(12),

                        borderSide: BorderSide(color: Colors.grey.shade300),

                      ),

                      enabledBorder: OutlineInputBorder(

                        borderRadius: BorderRadius.circular(12),

                        borderSide: BorderSide(color: Colors.grey.shade300),

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

                                .read(gradesProvider.notifier)

                                .loadGrades(val.courseId);

                          }

                        },

                      ),

                    ),

                  );

                },

                loading: () => const LinearProgressIndicator(),

                error: (e, st) => Text(l10n.facultyErrorLoadingCourses),

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

                            Icons.grade_outlined,

                            size: 60,

                            color: Colors.grey.shade300,

                          ),

                          const SizedBox(height: 16),

                          Text(

                            l10n.facultySelectCourseForGrades,

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

                  : DashboardGradesList(course: _selectedCourse!),

        ),

      ],

    );

  }

}



class DashboardGradesList extends ConsumerWidget {

  final CourseModel course;

  const DashboardGradesList({super.key, required this.course});



  @override

  Widget build(BuildContext context, WidgetRef ref) {

    final studentsAsync = ref.watch(classStudentsProvider(course));

    final gradesAsync = ref.watch(gradesProvider);

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

        return ListView.builder(

          padding: const EdgeInsets.all(20),

          itemCount: students.length,

          itemBuilder: (context, index) {

            final student = students[index];

            final grades = gradesAsync.value ?? [];

            final grade =

                grades.where((g) => g.studentUid == student.uid).firstOrNull;



            return StaggeredFadeInSlideY(

              index: index,

              child: Container(

                margin: const EdgeInsets.only(bottom: 16),

                padding: const EdgeInsets.all(16.0),

                decoration: BoxDecoration(

                  color: Colors.white,

                  borderRadius: BorderRadius.circular(16),

                  border: Border.all(color: Colors.grey.shade200),

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

                    Row(

                      children: [

                        CircleAvatar(

                          radius: 16,

                          backgroundColor: const Color(0xFF005A51).withValues(alpha: 0.1),

                          child: const Icon(

                            Icons.person,

                            size: 16,

                            color: Color(0xFF005A51),

                          ),

                        ),

                        const SizedBox(width: 12),

                        Expanded(

                          child: Column(

                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [

                              Text(

                                student.fullNameAr.isNotEmpty

                                    ? student.fullNameAr

                                    : student.fullName,

                                style: const TextStyle(

                                  fontWeight: FontWeight.bold,

                                  fontFamily: 'Cairo',

                                  fontSize: 14,

                                ),

                              ),

                              Text(

                                student.universityId,

                                style: const TextStyle(

                                  color: Colors.grey,

                                  fontSize: 12,

                                  fontFamily: 'Cairo',

                                ),

                              ),

                            ],

                          ),

                        ),

                        Container(

                          padding: const EdgeInsets.symmetric(

                            horizontal: 12,

                            vertical: 6,

                          ),

                          decoration: BoxDecoration(

                            color: const Color(0xFF005A51),

                            borderRadius: BorderRadius.circular(8),

                          ),

                          child: Text(

                            l10n.facultyTotalScorePrefix(

                              (grade?.total ?? 0).toDouble(),

                            ),

                            style: const TextStyle(

                              fontWeight: FontWeight.bold,

                              color: Colors.white,

                              fontFamily: 'Cairo',

                              fontSize: 12,

                            ),

                          ),

                        ),

                      ],

                    ),

                    const SizedBox(height: 16),

                    Form(

                      autovalidateMode: AutovalidateMode.onUserInteraction,

                      child: Row(

                        children: [

                          Expanded(

                            child: TextFormField(

                              initialValue: grade?.midterm.toString() ?? '0',

                              decoration: InputDecoration(

                                labelText: l10n.facultyMidtermLabel,

                                labelStyle: const TextStyle(

                                  fontFamily: 'Cairo',

                                  fontSize: 12,

                                ),

                                border: OutlineInputBorder(

                                  borderRadius: BorderRadius.circular(8),

                                ),

                                contentPadding: const EdgeInsets.symmetric(

                                  horizontal: 12,

                                  vertical: 8,

                                ),

                              ),

                              keyboardType: TextInputType.number,

                              validator: (val) {

                                final v = double.tryParse(val ?? '');

                                if (v == null) return l10n.gradeInvalidNumber;

                                if (v < 0 || v > 40) {

                                  return l10n.gradeMaxMidterm;

                                }

                                return null;

                              },

                              onFieldSubmitted: (val) {

                                final v = double.tryParse(val);

                                if (v == null || v < 0 || v > 40) return;

                                ref

                                    .read(gradesProvider.notifier)

                                    .saveGrade(

                                      course.courseId,

                                      student.uid,

                                      midterm: v,

                                      finalExam: grade?.finalExam,

                                      assignments: grade?.assignments,

                                    );

                              },

                            ),

                          ),

                          const SizedBox(width: 8),

                          Expanded(

                            child: TextFormField(

                              initialValue: grade?.finalExam.toString() ?? '0',

                              decoration: InputDecoration(

                                labelText: l10n.facultyFinalLabel,

                                labelStyle: const TextStyle(

                                  fontFamily: 'Cairo',

                                  fontSize: 12,

                                ),

                                border: OutlineInputBorder(

                                  borderRadius: BorderRadius.circular(8),

                                ),

                                contentPadding: const EdgeInsets.symmetric(

                                  horizontal: 12,

                                  vertical: 8,

                                ),

                              ),

                              keyboardType: TextInputType.number,

                              validator: (val) {

                                final v = double.tryParse(val ?? '');

                                if (v == null) return l10n.gradeInvalidNumber;

                                if (v < 0 || v > 40) {

                                  return l10n.gradeMaxFinal;

                                }

                                return null;

                              },

                              onFieldSubmitted: (val) {

                                final v = double.tryParse(val);

                                if (v == null || v < 0 || v > 40) return;

                                ref

                                    .read(gradesProvider.notifier)

                                    .saveGrade(

                                      course.courseId,

                                      student.uid,

                                      finalExam: v,

                                      midterm: grade?.midterm,

                                      assignments: grade?.assignments,

                                    );

                              },

                            ),

                          ),

                          const SizedBox(width: 8),

                          Expanded(

                            child: TextFormField(

                              initialValue: grade?.assignments.toString() ?? '0',

                              decoration: InputDecoration(

                                labelText: l10n.facultyAssignmentsLabel,

                                labelStyle: const TextStyle(

                                  fontFamily: 'Cairo',

                                  fontSize: 12,

                                ),

                                border: OutlineInputBorder(

                                  borderRadius: BorderRadius.circular(8),

                                ),

                                contentPadding: const EdgeInsets.symmetric(

                                  horizontal: 12,

                                  vertical: 8,

                                ),

                              ),

                              keyboardType: TextInputType.number,

                              validator: (val) {

                                final v = double.tryParse(val ?? '');

                                if (v == null) return l10n.gradeInvalidNumber;

                                if (v < 0 || v > 20) {

                                  return l10n.gradeMaxAssignments;

                                }

                                return null;

                              },

                              onFieldSubmitted: (val) {

                                final v = double.tryParse(val);

                                if (v == null || v < 0 || v > 20) return;

                                ref

                                    .read(gradesProvider.notifier)

                                    .saveGrade(

                                      course.courseId,

                                      student.uid,

                                      assignments: v,

                                      midterm: grade?.midterm,

                                      finalExam: grade?.finalExam,

                                    );

                              },

                            ),

                          ),

                        ],

                      ),

                    ),

                  ],

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