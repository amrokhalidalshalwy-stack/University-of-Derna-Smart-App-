// lib/features/faculty/screens/faculty_grades_entry_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/service_providers.dart';
import '../../../core/services/professor_validator.dart';

class FacultyGradesEntryScreen extends ConsumerStatefulWidget {
  final ProfessorValidator? validator;
  const FacultyGradesEntryScreen({super.key, this.validator});

  @override
  ConsumerState<FacultyGradesEntryScreen> createState() =>
      _FacultyGradesEntryScreenState();
}

class _FacultyGradesEntryScreenState
    extends ConsumerState<FacultyGradesEntryScreen> {
  String? _selectedCourseId;
  String? _selectedCourseName;
  bool _saving = false;
  late final ProfessorValidator _validator = widget.validator ?? ProfessorValidator();

  // تحويل الدرجة إلى حرف
  String _gradeToLetter(double g) {
    if (g >= 90) return 'A+';
    if (g >= 85) return 'A';
    if (g >= 80) return 'B+';
    if (g >= 75) return 'B';
    if (g >= 70) return 'C+';
    if (g >= 65) return 'C';
    if (g >= 60) return 'D+';
    if (g >= 50) return 'D';
    return 'F';
  }

  Future<void> _saveGrade(
    String docId,
    String studentUid,
    String studentName,
    String studentNumber,
    String grade,
  ) async {
    if (_saving) return;

    if (_selectedCourseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء اختيار المادة أولاً'),
          backgroundColor: Color(0xFFBA1A1A),
        ),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      final validation = await _validator.validateGradeEntry(
        courseId: _selectedCourseId!,
        studentId: studentUid,
      );

      if (!validation.isValid) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ ${validation.errorMessage}'),
              backgroundColor: const Color(0xFFBA1A1A),
            ),
          );
        }
        return; // ← الثغرة كانت هنا: return بدون finally يُجمّد _saving
      }

      final service = ref.read(integrationServiceProvider);
      final gradeValue = double.tryParse(grade) ?? 0.0;

      await service.saveStudentGrades(
        courseId: _selectedCourseId ?? 'unknown',
        courseName: _selectedCourseName ?? 'غير محدد',
        professorId: FirebaseAuth.instance.currentUser!.uid,
        professorName: 'عضو هيئة التدريس',
        semester: 'الفصل الثاني 2025-2026',
        academicYear: '2025-2026',
        studentId: studentUid,
        studentName: studentName,
        studentNumber: studentNumber,
        courseworkScore: null,
        midtermScore: null,
        finalScore: gradeValue,
        maxCoursework: 20,
        maxMidterm: 30,
        maxFinal: 50,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ تم رصد الدرجة بنجاح'),
            backgroundColor: Color(0xFF00A694),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ حدث خطأ: ${e.toString()}'),
            backgroundColor: const Color(0xFFBA1A1A),
          ),
        );
      }
    } finally {
      // ✅ الإصلاح: _saving يُعاد دائماً لـ false في جميع الحالات
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('إدخال الدرجات')),
        body: StreamBuilder<DocumentSnapshot>(
          stream:
              FirebaseFirestore.instance
                  .collection('faculty_records')
                  .doc(uid)
                  .snapshots(),
          builder: (context, snap) {
            final rec = snap.data?.data() as Map<String, dynamic>? ?? {};
            final courses = rec['courses'] as List<dynamic>? ?? [];

            return Column(
              children: [
                // ── اختيار المادة ──
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'اختر المادة الدراسية',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.book_outlined),
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                        ),
                        initialValue: _selectedCourseId,
                        hint: const Text('-- اختر المادة --'),
                        items:
                            courses.map((c) {
                              String id;
                              String name;
                              if (c is Map) {
                                id = c['id']?.toString() ?? c.toString();
                                name = c['name']?.toString() ?? id;
                              } else {
                                id = c.toString();
                                name = c.toString();
                              }
                              return DropdownMenuItem(
                                value: id,
                                child: Text(name),
                                onTap:
                                    () => setState(
                                      () => _selectedCourseName = name,
                                    ),
                              );
                            }).toList(),
                        onChanged: (v) => setState(() => _selectedCourseId = v),
                      ),
                    ],
                  ),
                ),

                if (_selectedCourseId != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    color: AppTheme.primary.withValues(alpha: 0.05),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: AppTheme.primary,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'انقر على الدرجة لتعديلها — $_selectedCourseName',
                          style: const TextStyle(
                            color: AppTheme.primary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                // ── قائمة الطلاب والدرجات ──
                Expanded(
                  child:
                      _selectedCourseId == null
                          ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.edit_note,
                                  size: 64,
                                  color: Colors.grey.shade300,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'اختر مادة لبدء إدخال الدرجات',
                                  style: TextStyle(
                                    color:
                                        Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          )
                          : StreamBuilder<QuerySnapshot>(
                            stream:
                                FirebaseFirestore.instance
                                    .collection('academic_records')
                                    .where(
                                      'course_id',
                                      isEqualTo: _selectedCourseId,
                                    )
                                    .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              final docs = snapshot.data?.docs ?? [];
                              if (docs.isEmpty) {
                                return Center(
                                  child: Text(
                                    'لا يوجد طلاب مسجّلون في هذه المادة',
                                    style: TextStyle(
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                );
                              }

                              return ListView.builder(
                                padding: const EdgeInsets.all(12),
                                itemCount: docs.length,
                                itemBuilder: (context, i) {
                                  final doc = docs[i];
                                  final d = doc.data() as Map<String, dynamic>;
                                  final studentName =
                                      d['student_name'] as String? ?? '--';
                                  final currentGrade =
                                      d['grade']?.toString() ?? '';
                                  final gradeVal =
                                      double.tryParse(currentGrade) ?? -1;
                                  final letter =
                                      gradeVal >= 0
                                          ? _gradeToLetter(gradeVal)
                                          : '--';

                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: AppTheme.primary
                                            .withValues(alpha: 0.1),
                                        child: Text(
                                          '${i + 1}',
                                          style: const TextStyle(
                                            color: AppTheme.primary,
                                          ),
                                        ),
                                      ),
                                      title: Text(
                                        studentName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      subtitle: Text(
                                        d['student_id'] as String? ?? '',
                                      ),
                                      trailing: GestureDetector(
                                        onTap:
                                            () => _showGradeDialog(
                                              context,
                                              doc.id,
                                              d['student_uid'] as String? ?? '',
                                              d['student_id'] as String? ?? '',
                                              currentGrade,
                                              studentName,
                                            ),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                currentGrade.isEmpty
                                                    ? Colors.grey.shade100
                                                    : AppTheme.primary
                                                        .withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            border: Border.all(
                                              color:
                                                  currentGrade.isEmpty
                                                      ? Colors.grey.shade300
                                                      : AppTheme.primary
                                                          .withValues(
                                                            alpha: 0.3,
                                                          ),
                                            ),
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                currentGrade.isEmpty
                                                    ? 'إدخال'
                                                    : currentGrade,
                                                style: TextStyle(
                                                  color:
                                                      currentGrade.isEmpty
                                                          ? Colors.grey
                                                          : AppTheme.primary,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15,
                                                ),
                                              ),
                                              if (currentGrade.isNotEmpty)
                                                Text(
                                                  letter,
                                                  style: const TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 11,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showGradeDialog(
    BuildContext context,
    String docId,
    String studentUid,
    String studentNumber,
    String currentGrade,
    String studentName,
  ) {
    final controller = TextEditingController(text: currentGrade);
    showDialog(
      context: context,
      builder:
          (_) => Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              title: Text(
                'درجة: $studentName',
                style: const TextStyle(fontSize: 16),
              ),
              content: TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'الدرجة (0 - 100)',
                  border: OutlineInputBorder(),
                  suffixText: '/100',
                ),
                autofocus: true,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('إلغاء'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final val = double.tryParse(controller.text);
                    if (val == null || val < 0 || val > 100) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('أدخل درجة صحيحة بين 0 و 100'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    Navigator.pop(context);
                    _saveGrade(
                      docId,
                      studentUid,
                      studentName,
                      studentNumber,
                      controller.text.trim(),
                    );
                  },
                  child: const Text('حفظ'),
                ),
              ],
            ),
          ),
    );
  }
}
