// ═══════════════════════════════════════════════════════════════════════════
// Step 2 — Academic Information (Student OR Faculty variant) - FIXED GLITCH
// ═══════════════════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_project/features/auth/presentation/providers/registration_provider.dart';
import 'package:flutter_project/core/constants/university_data.dart';
import 'package:flutter_project/l10n/app_localizations.dart';

class RegistrationStep2 extends ConsumerWidget {
  final GlobalKey<FormState> formKey;
  const RegistrationStep2({super.key, required this.formKey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(registrationProvider.notifier);
    final state = ref.watch(registrationProvider);
    final l10n = AppLocalizations.of(context)!;

    // تصفية وعرض الواجهة بناءً على نوع الحساب المختار
    if (state.isFaculty) {
      return _buildFacultyForm(context, ref, notifier, state, l10n);
    } else {
      return _buildStudentForm(context, ref, notifier, state, l10n);
    }
  }

  Widget _buildStudentForm(
    BuildContext context,
    WidgetRef ref,
    RegistrationNotifier notifier,
    RegistrationFormState state,
    AppLocalizations l10n,
  ) {
    // جلب التخصصات بحماية كاملة في حال كانت الكلية فارغة
    final depts = state.faculty.isEmpty
        ? <String>[]
        : UniversityData.specializationsFor(state.faculty);

    final currentYear = DateTime.now().year;
    final years = List.generate(7, (i) => currentYear + i);

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min, // حماية لحجم الارتفاع
        children: [
          // Faculty
          _label(l10n.authCollege),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: state.faculty.isNotEmpty ? state.faculty : null,
            decoration: _deco(),
            validator: (v) {
              final String val = v?.toString().trim() ?? '';
              if (val.isEmpty) {
                return l10n.authErrorCollegeRequired;
              }
              return null;
            },
            items: UniversityData.faculties
                .map(
                  (f) => DropdownMenuItem(
                    value: f.nameAr,
                    child: Text(
                      f.nameAr,
                      style: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
                    ),
                  ),
                )
                .toList(),
            onChanged: (v) {
              if (v != null && v.toString().trim().isNotEmpty) {
                notifier.updateFaculty(v);
              }
            },
          ),
          const SizedBox(height: 16),
          
          // Department
          _label(l10n.authDepartment),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            // حماية لمنع الخطأ الأحمر عند تحديث الكلية بشكل مفاجئ
            value: (state.department.isNotEmpty && depts.contains(state.department))
                ? state.department
                : null,
            decoration: _deco(),
            validator: (v) {
              final String val = v?.toString().trim() ?? '';
              if (val.isEmpty) {
                return l10n.authErrorDepartmentRequired;
              }
              return null;
            },
            items: depts
                .map(
                  (d) => DropdownMenuItem(
                    value: d,
                    child: Text(
                      d,
                      style: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
                    ),
                  ),
                )
                .toList(),
            onChanged: depts.isEmpty
                ? null
                : (v) {
                    if (v != null && v.toString().trim().isNotEmpty) notifier.updateDepartment(v);
                  },
            hint: Text(
              depts.isEmpty
                  ? l10n.authHintSelectCollegeFirst
                  : l10n.authHintSelectDepartment,
              style: const TextStyle(
                fontFamily: 'Cairo',
                color: Color(0xFF74777F),
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Semester
          _label(l10n.authSemester),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: state.semester.isNotEmpty ? state.semester : null,
            decoration: _deco(),
            validator: (v) {
              final String val = v?.toString().trim() ?? '';
              if (val.isEmpty) {
                return l10n.authErrorSemesterRequired;
              }
              return null;
            },
            items: UniversityData.semesters
                .map(
                  (s) => DropdownMenuItem(
                    value: s,
                    child: Text(
                      s,
                      style: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
                    ),
                  ),
                )
                .toList(),
            onChanged: (v) {
              if (v != null && v.toString().trim().isNotEmpty) notifier.updateSemester(v);
            },
          ),
          const SizedBox(height: 16),
          
          // Expected graduation year
          _label(l10n.authExpectedGraduationYear),
          const SizedBox(height: 6),
          DropdownButtonFormField<int>(
            value: years.contains(state.graduationYear) ? state.graduationYear : years.first,
            decoration: _deco(),
            items: years
                .map(
                  (y) => DropdownMenuItem(
                    value: y,
                    child: Text(
                      y.toString(),
                      style: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
                    ),
                  ),
                )
                .toList(),
            onChanged: (v) {
              if (v != null) notifier.updateGraduationYear(v);
            },
          ),
          const SizedBox(height: 16),
          
          // Secondary school GPA
          _label(l10n.authSecondaryGpa),
          const SizedBox(height: 6),
          TextFormField(
            initialValue: state.secondaryGpa > 0 ? state.secondaryGpa.toString() : '',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: _deco().copyWith(
              hintText: l10n.authHintSecondaryGpa,
              hintStyle: const TextStyle(fontSize: 13, fontFamily: 'Cairo'),
              suffixText: '%',
            ),
            validator: (v) {
              final String val = v?.toString().trim() ?? '';
              if (val.isEmpty) {
                return l10n.authErrorSecondaryGpaRequired;
              }
              final d = double.tryParse(val);
              if (d == null || d < 0 || d > 100) {
                return l10n.authErrorSecondaryGpaRange;
              }
              return null;
            },
            onChanged: (v) {
              final d = double.tryParse(v);
              if (d != null) notifier.updateSecondaryGpa(d);
            },
          ),
          const SizedBox(height: 16),
          
          // Certificate type
          _label(l10n.authCertificateType),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: state.certificateType.isNotEmpty ? state.certificateType : null,
            decoration: _deco(),
            validator: (v) {
              final String val = v?.toString().trim() ?? '';
              if (val.isEmpty) {
                return l10n.authErrorCertificateRequired;
              }
              return null;
            },
            items: UniversityData.certificateTypes
                .map(
                  (c) => DropdownMenuItem(
                    value: c,
                    child: Text(
                      c,
                      style: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
                    ),
                  ),
                )
                .toList(),
            onChanged: (v) {
              if (v != null && v.toString().trim().isNotEmpty) notifier.updateCertificateType(v);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFacultyForm(
    BuildContext context,
    WidgetRef ref,
    RegistrationNotifier notifier,
    RegistrationFormState state,
    AppLocalizations l10n,
  ) {
    final specs = state.college.isEmpty
        ? <String>[]
        : UniversityData.specializationsFor(state.college);
    final depts = state.college.isEmpty
        ? <String>[]
        : UniversityData.departmentsFor(state.college);

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Academic Degree
          _label('الدرجة الأكاديمية'),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: state.academicDegree.isNotEmpty ? state.academicDegree : null,
            decoration: _deco(),
            validator: (v) {
              final String val = v?.toString().trim() ?? '';
              if (val.isEmpty) {
                return 'الدرجة الأكاديمية مطلوبة';
              }
              return null;
            },
            items: ['دكتوراه', 'ماجستير', 'بكالوريوس']
                .map(
                  (d) => DropdownMenuItem(
                    value: d,
                    child: Text(d, style: const TextStyle(fontFamily: 'Cairo', fontSize: 13)),
                  ),
                )
                .toList(),
            onChanged: (v) {
              if (v != null && v.toString().trim().isNotEmpty) notifier.updateAcademicDegree(v);
            },
          ),
          const SizedBox(height: 16),
          
          // Academic Title
          _label('المسمى الوظيفي'),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: state.academicTitle.isNotEmpty ? state.academicTitle : null,
            decoration: _deco(),
            validator: (v) {
              final String val = v?.toString().trim() ?? '';
              if (val.isEmpty) {
                return 'المسمى الوظيفي مطلوب';
              }
              return null;
            },
            items: ['أستاذ', 'أستاذ مساعد', 'محاضر', 'مدرس']
                .map(
                  (t) => DropdownMenuItem(
                    value: t,
                    child: Text(t, style: const TextStyle(fontFamily: 'Cairo', fontSize: 13)),
                  ),
                )
                .toList(),
            onChanged: (v) {
              if (v != null && v.toString().trim().isNotEmpty) notifier.updateAcademicTitle(v);
            },
          ),
          const SizedBox(height: 16),
          
          // Specialization
          _label('التخصص'),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: (state.specialization.isNotEmpty && specs.contains(state.specialization))
                ? state.specialization
                : null,
            decoration: _deco(),
            validator: (v) {
              final String val = v?.toString().trim() ?? '';
              if (val.isEmpty) {
                return 'التخصص مطلوب';
              }
              return null;
            },
            items: specs
                .map(
                  (s) => DropdownMenuItem(
                    value: s,
                    child: Text(s, style: const TextStyle(fontFamily: 'Cairo', fontSize: 13)),
                  ),
                )
                .toList(),
            onChanged: specs.isEmpty
                ? null
                : (v) {
                    if (v != null && v.toString().trim().isNotEmpty) notifier.updateSpecialization(v);
                  },
            hint: Text(
              specs.isEmpty ? 'اختر الكلية أولاً' : 'اختر التخصص',
              style: const TextStyle(fontFamily: 'Cairo', color: Color(0xFF74777F), fontSize: 13),
            ),
          ),
          const SizedBox(height: 16),
          
          // College / Department
          _label('الالتحاق بالكلية'),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: state.college.isNotEmpty ? state.college : null,
            decoration: _deco(),
            validator: (v) {
              final String val = v?.toString().trim() ?? '';
              if (val.isEmpty) {
                return 'الكلية مطلوبة';
              }
              return null;
            },
            items: UniversityData.faculties
                .map(
                  (f) => DropdownMenuItem(
                    value: f.nameAr,
                    child: Text(f.nameAr, style: const TextStyle(fontFamily: 'Cairo', fontSize: 13)),
                  ),
                )
                .toList(),
            onChanged: (v) {
              if (v != null && v.toString().trim().isNotEmpty) {
                notifier.updateCollege(v);
              }
            },
          ),
          const SizedBox(height: 16),
          
          // Department
          _label('القسم الأكاديمي'),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: (state.department.isNotEmpty && depts.contains(state.department))
                ? state.department
                : null,
            decoration: _deco(),
            validator: (v) {
              final String val = v?.toString().trim() ?? '';
              if (val.isEmpty) {
                return 'القسم مطلوب';
              }
              return null;
            },
            items: depts
                .map(
                  (d) => DropdownMenuItem(
                    value: d,
                    child: Text(d, style: const TextStyle(fontFamily: 'Cairo', fontSize: 13)),
                  ),
                )
                .toList(),
            onChanged: depts.isEmpty
                ? null
                : (v) {
                    if (v != null && v.toString().trim().isNotEmpty) notifier.updateDepartment(v);
                  },
            hint: Text(
              depts.isEmpty ? 'اختر الكلية أولاً' : 'اختر القسم',
              style: const TextStyle(fontFamily: 'Cairo', color: Color(0xFF74777F), fontSize: 13),
            ),
          ),
          const SizedBox(height: 16),
          
          // Date of Employment
          _label('تاريخ التعيين'),
          const SizedBox(height: 6),
          InkWell(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: state.employmentDate ?? DateTime.now(),
                firstDate: DateTime(1970),
                lastDate: DateTime.now(),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: Color(0xFF001835),
                        onPrimary: Colors.white,
                        onSurface: Color(0xFF001835),
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (date != null) {
                notifier.updateEmploymentDate(date);
              }
            },
            child: InputDecorator(
              decoration: _deco().copyWith(
                prefixIcon: const Icon(Icons.calendar_today_outlined, size: 20),
              ),
              child: Text(
                state.employmentDate == null
                    ? 'اختر تاريخ التعيين'
                    : '${state.employmentDate!.year}-${state.employmentDate!.month.toString().padLeft(2, '0')}-${state.employmentDate!.day.toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13,
                  color: state.employmentDate == null ? const Color(0xFF74777F) : const Color(0xFF001835),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Student Pass Rate
          _label('معدل نجاح الطلاب (%)'),
          const SizedBox(height: 6),
          TextFormField(
            initialValue: state.studentPassRate > 0 ? state.studentPassRate.toString() : '',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: _deco().copyWith(
              hintText: 'أدخل معدل نجاح الطلاب',
              hintStyle: const TextStyle(fontSize: 13, fontFamily: 'Cairo'),
              suffixText: '%',
              prefixIcon: const Icon(Icons.percent_outlined, size: 20),
            ),
            validator: (v) {
              final String val = v?.toString().trim() ?? '';
              if (val.isEmpty) {
                return 'معدل نجاح الطلاب مطلوب';
              }
              final d = double.tryParse(val);
              if (d == null || d < 0 || d > 100) {
                return 'الرجاء إدخال نسبة مئوية صحيحة (0-100)';
              }
              return null;
            },
            onChanged: (v) {
              final d = double.tryParse(v);
              if (d != null) notifier.updateStudentPassRate(d);
            },
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: const TextStyle(
          fontFamily: 'Cairo',
          fontWeight: FontWeight.w600,
          fontSize: 13,
          color: Color(0xFF001835),
        ),
      );

  InputDecoration _deco() => InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      );
}