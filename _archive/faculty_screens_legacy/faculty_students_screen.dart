// lib/features/faculty/screens/faculty_students_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class FacultyStudentsScreen extends StatefulWidget {
  const FacultyStudentsScreen({super.key});

  @override
  State<FacultyStudentsScreen> createState() => _FacultyStudentsScreenState();
}

class _FacultyStudentsScreenState extends State<FacultyStudentsScreen> {
  String? _selectedCourseId;
  String? _selectedCourseName;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('قائمة الطلاب')),
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
                if (courses.isNotEmpty)
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(12),
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'اختر المادة',
                        prefixIcon: Icon(Icons.book_outlined),
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                      initialValue: _selectedCourseId,
                      items:
                          courses.map((c) {
                            String id = '--';
                            String name = '--';
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
                  ),

                // ── بحث ──
                if (_selectedCourseId != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'بحث بالاسم أو الرقم...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 12,
                        ),
                        suffixIcon:
                            _searchQuery.isNotEmpty
                                ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                )
                                : null,
                      ),
                      onChanged: (v) => setState(() => _searchQuery = v.trim()),
                    ),
                  ),

                // ── قائمة الطلاب ──
                Expanded(
                  child:
                      _selectedCourseId == null
                          ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.touch_app,
                                  size: 60,
                                  color: Colors.grey.shade300,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'اختر مادة لعرض طلابها',
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
                              var docs = snapshot.data?.docs ?? [];

                              // تصفية البحث
                              if (_searchQuery.isNotEmpty) {
                                docs =
                                    docs.where((d) {
                                      final data =
                                          d.data() as Map<String, dynamic>;
                                      final name =
                                          data['student_name']?.toString() ??
                                          '';
                                      final sid =
                                          data['student_id']?.toString() ?? '';
                                      return name.contains(_searchQuery) ||
                                          sid.contains(_searchQuery);
                                    }).toList();
                              }

                              if (docs.isEmpty) {
                                return Center(
                                  child: Text(
                                    'لا يوجد طلاب مسجّلون',
                                    style: TextStyle(
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                );
                              }

                              return Column(
                                children: [
                                  // رأس القائمة
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    color: AppTheme.primary.withValues(
                                      alpha: 0.05,
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          'إجمالي الطلاب: ${docs.length}',
                                          style: const TextStyle(
                                            color: AppTheme.primary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          _selectedCourseName ?? '',
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: ListView.builder(
                                      padding: const EdgeInsets.all(12),
                                      itemCount: docs.length,
                                      itemBuilder: (context, i) {
                                        final d =
                                            docs[i].data()
                                                as Map<String, dynamic>;
                                        final studentName =
                                            d['student_name'] as String? ??
                                            '--';
                                        final studentId =
                                            d['student_id'] as String? ?? '--';
                                        final grade =
                                            d['grade']?.toString() ?? '--';
                                        final gradeVal =
                                            double.tryParse(grade) ?? -1;

                                        Color gradeColor = Colors.grey;
                                        if (gradeVal >= 90) {
                                          gradeColor = Colors.green;
                                        } else if (gradeVal >= 75) {
                                          gradeColor = AppTheme.primary;
                                        } else if (gradeVal >= 60) {
                                          gradeColor = Colors.orange;
                                        } else if (gradeVal >= 0) {
                                          gradeColor = Colors.red;
                                        }

                                        return Card(
                                          margin: const EdgeInsets.only(
                                            bottom: 8,
                                          ),
                                          child: ListTile(
                                            leading: CircleAvatar(
                                              backgroundColor: AppTheme.primary
                                                  .withValues(alpha: 0.1),
                                              child: Text(
                                                '${i + 1}',
                                                style: const TextStyle(
                                                  color: AppTheme.primary,
                                                  fontWeight: FontWeight.bold,
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
                                              'رقم الطالب: $studentId',
                                            ),
                                            trailing:
                                                grade != '--'
                                                    ? Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 10,
                                                            vertical: 4,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: gradeColor
                                                            .withValues(
                                                              alpha: 0.1,
                                                            ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              10,
                                                            ),
                                                      ),
                                                      child: Text(
                                                        grade,
                                                        style: TextStyle(
                                                          color: gradeColor,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    )
                                                    : null,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
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
}
