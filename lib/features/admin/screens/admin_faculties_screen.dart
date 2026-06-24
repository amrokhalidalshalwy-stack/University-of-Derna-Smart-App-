// lib/features/admin/screens/admin_faculties_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class AdminFacultiesScreen extends StatelessWidget {
  const AdminFacultiesScreen({super.key});

  Future<void> _addFaculty(BuildContext context) async {
    final nameController = TextEditingController();
    final deanController = TextEditingController();
    await showDialog(
      context: context,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('إضافة كلية جديدة'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'اسم الكلية',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: deanController,
                decoration: const InputDecoration(
                  labelText: 'اسم العميد',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty) return;
                await FirebaseFirestore.instance
                    .collection('faculties')
                    .add({
                  'name': nameController.text.trim(),
                  'dean': deanController.text.trim(),
                  'departments': [],
                  'createdAt': FieldValue.serverTimestamp(),
                });
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('إضافة'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addDepartment(
      BuildContext context, String facultyId) async {
    final deptController = TextEditingController();
    await showDialog(
      context: context,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('إضافة قسم'),
          content: TextField(
            controller: deptController,
            decoration: const InputDecoration(
              labelText: 'اسم القسم',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () async {
                if (deptController.text.trim().isEmpty) return;
                await FirebaseFirestore.instance
                    .collection('faculties')
                    .doc(facultyId)
                    .update({
                  'departments':
                      FieldValue.arrayUnion([deptController.text.trim()])
                });
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('إضافة'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('إدارة الكليات والأقسام')),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: AppTheme.primary,
          onPressed: () => _addFaculty(context),
          icon: const Icon(Icons.add, color: Colors.white),
          label:
              const Text('كلية جديدة', style: TextStyle(color: Colors.white)),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('faculties')
              .orderBy('name')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final docs = snapshot.data?.docs ?? [];
            if (docs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.account_balance,
                        size: 64, color: Colors.grey.shade300),
                    const SizedBox(height: 12),
                    Text('لا توجد كليات مسجّلة',
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: () => _addFaculty(context),
                      icon: const Icon(Icons.add),
                      label: const Text('أضف كلية'),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
              itemCount: docs.length,
              itemBuilder: (context, i) {
                final d = docs[i].data() as Map<String, dynamic>;
                final departments =
                    (d['departments'] as List<dynamic>?) ?? [];
                final facultyId = docs[i].id;

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ExpansionTile(
                    leading: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.account_balance,
                          color: AppTheme.primary, size: 22),
                    ),
                    title: Text(d['name'] as String? ?? '--',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: d['dean'] != null && d['dean'] != ''
                        ? Text('العميد: ${d['dean']}',
                            style: const TextStyle(fontSize: 12))
                        : null,
                    trailing: Text('${departments.length} قسم',
                        style: const TextStyle(
                            color: AppTheme.primary, fontSize: 12)),
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Divider(),
                            const Text('الأقسام:',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                    fontSize: 13)),
                            const SizedBox(height: 8),
                            if (departments.isEmpty)
                              Text('لا توجد أقسام بعد',
                                  style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant))
                            else
                              Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                children: departments.map((dept) {
                                  return Chip(
                                    label: Text(dept.toString(),
                                        style: const TextStyle(
                                            fontSize: 12)),
                                    backgroundColor: AppTheme.primary
                                        .withValues(alpha: 0.08),
                                    side: BorderSide(
                                        color: AppTheme.primary
                                            .withValues(alpha: 0.3)),
                                    deleteIcon: const Icon(Icons.close,
                                        size: 14),
                                    onDeleted: () async {
                                      await FirebaseFirestore.instance
                                          .collection('faculties')
                                          .doc(facultyId)
                                          .update({
                                        'departments':
                                            FieldValue.arrayRemove(
                                                [dept])
                                      });
                                    },
                                  );
                                }).toList(),
                              ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    icon: const Icon(Icons.add, size: 16),
                                    label: const Text('إضافة قسم'),
                                    onPressed: () => _addDepartment(
                                        context, facultyId),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      color: Colors.red),
                                  tooltip: 'حذف الكلية',
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        title: const Text('تأكيد الحذف'),
                                        content: const Text(
                                            'هل تريد حذف هذه الكلية؟'),
                                        actions: [
                                          TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(
                                                      context, false),
                                              child: const Text('إلغاء')),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.red),
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                            child: const Text('حذف'),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirm == true) {
                                      await FirebaseFirestore.instance
                                          .collection('faculties')
                                          .doc(facultyId)
                                          .delete();
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
