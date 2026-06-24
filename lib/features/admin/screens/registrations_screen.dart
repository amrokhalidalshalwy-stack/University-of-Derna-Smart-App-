// lib/features/admin/screens/registrations_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RegistrationsScreen extends StatefulWidget {
  const RegistrationsScreen({super.key});

  @override
  State<RegistrationsScreen> createState() => _RegistrationsScreenState();
}

class _RegistrationsScreenState extends State<RegistrationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('طلبات التسجيل'),
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            indicatorColor: Colors.white,
            tabs: const [
              Tab(text: 'الكل'),
              Tab(text: 'معلّقة'),
              Tab(text: 'مقبولة'),
              Tab(text: 'مرفوضة'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _RegistrationList(filterStatus: null),
            _RegistrationList(filterStatus: 'pending'),
            _RegistrationList(filterStatus: 'approved'),
            _RegistrationList(filterStatus: 'rejected'),
          ],
        ),
      ),
    );
  }
}

class _RegistrationList extends StatelessWidget {
  final String? filterStatus;
  const _RegistrationList({this.filterStatus});

  Color _statusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'under_review':
        return Colors.blue;
      default:
        return Colors.orange;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'approved':
        return 'مقبول';
      case 'rejected':
        return 'مرفوض';
      case 'under_review':
        return 'قيد المراجعة';
      case 'pending':
        return 'معلق';
      default:
        return status;
    }
  }

  Future<void> _updateStatus(
    BuildContext context,
    String uid,
    String status,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('registrations')
          .doc(uid)
          .update({
            'status': status,
            'reviewedAt': FieldValue.serverTimestamp(),
          });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              status == 'approved' ? 'تم قبول الطلب ✓' : 'تم رفض الطلب',
            ),
            backgroundColor: status == 'approved' ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Query query = FirebaseFirestore.instance
        .collection('registrations')
        .orderBy('submittedAt', descending: true);
    if (filterStatus != null) {
      if (filterStatus == 'pending') {
        // Include all pending statuses
        query = query.where('status', whereIn: [
          'pending_final_approval',
          'under_review',
          'requires_additional',
        ]);
      } else {
        query = query.where('status', isEqualTo: filterStatus);
      }
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
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
                Icon(
                  Icons.inbox_outlined,
                  size: 64,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 12),
                Text(
                  'لا توجد طلبات',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: docs.length,
          itemBuilder: (context, i) {
            final d = docs[i].data() as Map<String, dynamic>;
            final uid = docs[i].id;
            final status = d['status'] as String? ?? 'pending';
            final color = _statusColor(status);

            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ExpansionTile(
                leading: CircleAvatar(
                  backgroundColor: color.withValues(alpha: 0.15),
                  child: Icon(Icons.person, color: color),
                ),
                title: Text(
                  d['fullNameAr'] ?? '--',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Row(
                  children: [
                    Expanded(
                      child: Text(
                        d['role'] == 'faculty' 
                            ? (d['college'] ?? '--') 
                            : (d['faculty'] ?? '--'),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _statusLabel(status),
                        style: TextStyle(
                          color: color,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(),
                        _infoRow(context, Icons.phone, 'الهاتف', d['phone']),
                        _infoRow(context, Icons.email, 'البريد', d['email']),
                        _infoRow(
                          context,
                          Icons.business,
                          'القسم',
                          d['role'] == 'faculty' ? d['specialization'] : d['department'],
                        ),
                        if (d['role'] == 'student')
                          _infoRow(
                            context,
                            Icons.grade,
                            'معدل الثانوية',
                            d['secondaryGpa']?.toString(),
                          ),
                        if (d['role'] == 'faculty') ...[
                          _infoRow(
                            context,
                            Icons.school,
                            'الدرجة الأكاديمية',
                            d['academicDegree'],
                          ),
                          _infoRow(
                            context,
                            Icons.work,
                            'المسمى الوظيفي',
                            d['academicTitle'],
                          ),
                        ],
                        if (d['submittedAt'] != null)
                          _infoRow(
                            context,
                            Icons.calendar_today,
                            'تاريخ التقديم',
                            _formatTimestamp(d['submittedAt']),
                          ),
                        const SizedBox(height: 12),

                        // أزرار الإجراءات
                        if (status == 'pending' ||
                            status == 'under_review') ...[
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.check, size: 18),
                                  label: const Text('قبول'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                  ),
                                  onPressed:
                                      () => _updateStatus(
                                        context,
                                        uid,
                                        'approved',
                                      ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.visibility, size: 18),
                                  label: const Text('مراجعة'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                  ),
                                  onPressed:
                                      () => _updateStatus(
                                        context,
                                        uid,
                                        'under_review',
                                      ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.close, size: 18),
                                  label: const Text('رفض'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  onPressed:
                                      () => _updateStatus(
                                        context,
                                        uid,
                                        'rejected',
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
                          Row(
                            children: [
                              Icon(
                                status == 'approved'
                                    ? Icons.check_circle
                                    : Icons.cancel,
                                color: color,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                status == 'approved'
                                    ? 'تم قبول هذا الطلب'
                                    : 'تم رفض هذا الطلب',
                                style: TextStyle(color: color, fontSize: 13),
                              ),
                              const Spacer(),
                              TextButton(
                                onPressed:
                                    () =>
                                        _updateStatus(context, uid, 'pending'),
                                child: const Text('إعادة تعيين'),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _infoRow(
    BuildContext context,
    IconData icon,
    String label,
    String? value,
  ) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icon, size: 15, color: Colors.grey),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  String _formatTimestamp(dynamic ts) {
    if (ts is Timestamp) {
      final d = ts.toDate();
      return '${d.day}/${d.month}/${d.year}';
    }
    return '--';
  }
}
