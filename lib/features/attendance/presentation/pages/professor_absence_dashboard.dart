// lib/features/attendance/presentation/pages/professor_absence_dashboard.dart
// لوحة تحكم الأستاذ لإدارة أعذار الغياب

import 'package:flutter_project/core/services/error_tracking_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_project/core/theme/app_theme.dart';
import 'package:flutter_project/core/services/notification_service.dart';
import 'package:intl/intl.dart' hide TextDirection;

class ProfessorAbsenceDashboard extends StatefulWidget {
  const ProfessorAbsenceDashboard({super.key});

  @override
  State<ProfessorAbsenceDashboard> createState() =>
      _ProfessorAbsenceDashboardState();
}

class _ProfessorAbsenceDashboardState extends State<ProfessorAbsenceDashboard>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userId = _auth.currentUser?.uid ?? '';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          title: const Text(
            'لوحة تحكم الأعذار',
            style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              labelStyle:
                  const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
              unselectedLabelStyle: const TextStyle(fontFamily: 'Cairo'),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              tabs: [
                Tab(child: _buildTabWithBadge('قيد الانتظار', 'pending', userId)),
                Tab(child: _buildTabWithBadge('مقبولة', 'approved', userId)),
                Tab(child: _buildTabWithBadge('مرفوضة', 'rejected', userId)),
              ],
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _AbsenceExcuseListView(
              status: 'pending',
              firestore: _firestore,
              auth: _auth,
              onStatusChanged: () => setState(() {}),
            ),
            _AbsenceExcuseListView(
              status: 'approved',
              firestore: _firestore,
              auth: _auth,
              onStatusChanged: () => setState(() {}),
            ),
            _AbsenceExcuseListView(
              status: 'rejected',
              firestore: _firestore,
              auth: _auth,
              onStatusChanged: () => setState(() {}),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabWithBadge(String label, String status, String professorId) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('student_requests')
          .where('type', isEqualTo: 'absence_excuse')
          .where('details.professorId', isEqualTo: professorId)
          .where('status', isEqualTo: status)
          .snapshots(),
      builder: (context, snapshot) {
        final count = snapshot.data?.docs.length ?? 0;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label),
            if (count > 0)
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

// â”€â”€ Absence Excuse List View â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _AbsenceExcuseListView extends StatelessWidget {
  final String status;
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final VoidCallback onStatusChanged;

  const _AbsenceExcuseListView({
    required this.status,
    required this.firestore,
    required this.auth,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final professorId = auth.currentUser?.uid ?? '';

    return StreamBuilder<QuerySnapshot>(
      stream: firestore
          .collection('student_requests')
          .where('type', isEqualTo: 'absence_excuse')
          .where('details.professorId', isEqualTo: professorId)
          .where('status', isEqualTo: status)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  status == 'pending'
                      ? Icons.inbox
                      : status == 'approved'
                          ? Icons.check_circle_outline
                          : Icons.block,
                  size: 48,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  status == 'pending'
                      ? 'لا توجد أعذار قيد الانتظار'
                      : status == 'approved'
                          ? 'لا توجد أعذار مقبولة'
                          : 'لا توجد أعذار مرفوضة',
                  style: TextStyle(fontFamily: 'Cairo', color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final data = doc.data() as Map<String, dynamic>;
            final details = data['details'] as Map<String, dynamic>? ?? {};
            return _AbsenceExcuseCard(
              excuseId: doc.id,
              studentName: details['studentName'] ?? 'Unknown',
              courseName: details['course_name'] ?? '',
              absenceDate: (details['absenceDate'] as Timestamp?)?.toDate() ??
                  DateTime.now(),
              reason: details['reason'] ?? '',
              status: status,
              firestore: firestore,
              auth: auth,
              onStatusChanged: onStatusChanged,
              studentId: data['student_id'] ?? data['student_id'] ?? '',
              rejectionReason: data['adminNote'] ?? data['rejectionReason'],
            ).animate().slideY(begin: 0.2).fadeIn();
          },
        );
      },
    );
  }
}

// â”€â”€ Absence Excuse Card â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _AbsenceExcuseCard extends StatefulWidget {
  final String excuseId;
  final String studentName;
  final String courseName;
  final DateTime absenceDate;
  final String reason;
  final String status;
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final VoidCallback onStatusChanged;
  final String studentId;
  final String? rejectionReason;

  const _AbsenceExcuseCard({
    required this.excuseId,
    required this.studentName,
    required this.courseName,
    required this.absenceDate,
    required this.reason,
    required this.status,
    required this.firestore,
    required this.auth,
    required this.onStatusChanged,
    required this.studentId,
    this.rejectionReason,
  });

  @override
  State<_AbsenceExcuseCard> createState() => _AbsenceExcuseCardState();
}

class _AbsenceExcuseCardState extends State<_AbsenceExcuseCard> {
  bool _isProcessing = false;

  Future<void> _approveExcuse() async {
    setState(() => _isProcessing = true);
    try {
      // Update excuse status
      await widget.firestore
          .collection('student_requests')
          .doc(widget.excuseId)
          .update({
        'status': 'approved',
        'updatedAt': FieldValue.serverTimestamp(),
        'details.reviewedAt': FieldValue.serverTimestamp(),
      });

      // Send notification to student
      await _sendNotificationToStudent('approved', null);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'تم قبول العذر بنجاح',
              style: TextStyle(fontFamily: 'Cairo'),
            ),
            backgroundColor: Colors.green,
          ),
        );
        widget.onStatusChanged();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'خطأ: $e',
              style: const TextStyle(fontFamily: 'Cairo'),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _rejectExcuse() async {
    final reason = await _showRejectDialog();
    if (reason == null) return;

    setState(() => _isProcessing = true);
    try {
      // Update excuse status
      await widget.firestore
          .collection('student_requests')
          .doc(widget.excuseId)
          .update({
        'status': 'rejected',
        'adminNote': reason,
        'updatedAt': FieldValue.serverTimestamp(),
        'details.reviewedAt': FieldValue.serverTimestamp(),
      });

      // Send notification to student
      await _sendNotificationToStudent('rejected', reason);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'تم رفض العذر',
              style: TextStyle(fontFamily: 'Cairo'),
            ),
            backgroundColor: Colors.orange,
          ),
        );
        widget.onStatusChanged();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'خطأ: $e',
              style: const TextStyle(fontFamily: 'Cairo'),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _sendNotificationToStudent(
    String decision,
    String? rejectionReason,
  ) async {
    try {
      // Get student FCM token
      final userDoc =
          await widget.firestore.collection('users').doc(widget.studentId).get();
      final userData = userDoc.data();
      final fcmToken = userData?['fcmToken'] as String?;

      if (fcmToken != null && fcmToken.isNotEmpty) {
        await NotificationService().sendAbsenceExcuseNotification(
          studentFcmToken: fcmToken,
          studentName: widget.studentName,
          studentId: widget.studentId,
          decision: decision,
          courseName: widget.courseName,
          rejectionReason: rejectionReason,
        );
      }
    } catch (e, stackTrace) {
      ErrorTrackingService.recordError(e, stackTrace, context: 'Error sending notification');
    }
  }

  Future<String?> _showRejectDialog() {
    return showDialog<String>(
      context: context,
      builder: (context) => _RejectAbsenceDialog(excuseId: widget.excuseId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                  child: Text(
                    widget.studentName.substring(0, 1),
                    style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.studentName,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.courseName,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'التاريخ: ${DateFormat('yyyy-MM-dd').format(widget.absenceDate)}',
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'السبب: ${widget.reason}',
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            if (widget.rejectionReason != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'سبب الرفض: ${widget.rejectionReason}',
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
            if (widget.status == 'pending')
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _isProcessing ? null : _rejectExcuse,
                      icon: const Icon(Icons.close, size: 16),
                      label: const Text(
                        'رفض',
                        style: TextStyle(fontFamily: 'Cairo', fontSize: 12),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _isProcessing ? null : _approveExcuse,
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text(
                        'قبول',
                        style: TextStyle(fontFamily: 'Cairo', fontSize: 12),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// â”€â”€ Reject Dialog â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _RejectAbsenceDialog extends StatefulWidget {
  final String excuseId;

  const _RejectAbsenceDialog({required this.excuseId});

  @override
  State<_RejectAbsenceDialog> createState() => _RejectAbsenceDialogState();
}

class _RejectAbsenceDialogState extends State<_RejectAbsenceDialog> {
  final _reasonCtrl = TextEditingController();

  @override
  void dispose() {
    _reasonCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        title: const Text(
          'تأكيد رفض العذر',
          style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'يرجى إدخال سبب الرفض:',
              style: TextStyle(fontFamily: 'Cairo', fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _reasonCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'أدخل سبب الرفض...',
                hintStyle: TextStyle(fontFamily: 'Cairo', color: Theme.of(context).colorScheme.onSurfaceVariant),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppTheme.primaryColor),
                ),
              ),
              style: const TextStyle(fontFamily: 'Cairo'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'إلغاء',
              style: TextStyle(fontFamily: 'Cairo', color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (_reasonCtrl.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'يرجى إدخال سبب الرفض',
                      style: TextStyle(fontFamily: 'Cairo'),
                    ),
                  ),
                );
                return;
              }
              Navigator.pop(context, _reasonCtrl.text);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text(
              'تأكيد الرفض',
              style: TextStyle(fontFamily: 'Cairo', color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

