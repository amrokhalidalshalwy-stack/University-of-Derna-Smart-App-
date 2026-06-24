import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter_project/shared/widgets/animated_widgets.dart';
import 'package:flutter_project/core/providers/service_providers.dart';
import 'package:flutter_project/l10n/app_localizations.dart';

class FacultyExcusesPage extends ConsumerWidget {
  const FacultyExcusesPage({super.key});

  Future<void> _updateStatus(
    BuildContext context,
    WidgetRef ref,
    String requestId,
    String studentId,
    String courseId,
    String newStatus,
  ) async {
    try {
      final service = ref.read(integrationServiceProvider);
      final reviewerId = FirebaseAuth.instance.currentUser!.uid;
      final l10n = AppLocalizations.of(context)!;
      final reviewerName = l10n.excusesFacultyMember;

      await service.reviewAbsenceExcuse(
        requestId: requestId,
        reviewerId: reviewerId,
        reviewerName: reviewerName,
        newStatus: newStatus,
        reviewNotes: null,
        studentId: studentId,
        courseId: courseId,
      );

      if (context.mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newStatus == 'approved' ? l10n.excusesApproved : l10n.excusesRejected,
              style: const TextStyle(fontFamily: 'Cairo'),
            ),
            backgroundColor: newStatus == 'approved' ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.excusesErrorOccurred(e.toString()),
              style: const TextStyle(fontFamily: 'Cairo'),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appBarColor =
        isDark ? const Color(0xFF0D2420) : const Color(0xFF00A694);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            l10n.excusesTitle,
            style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: appBarColor,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => context.pop(),
          ),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream:
              FirebaseFirestore.instance
                  .collection('student_requests')
                  .where('type', isEqualTo: 'absence_excuse')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
          builder: (context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  l10n.excusesErrorOccurred(snapshot.error.toString()),
                  style: const TextStyle(fontFamily: 'Cairo'),
                ),
              );
            }

            final docs = snapshot.data?.docs ?? [];
            if (docs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inbox_rounded,
                      size: 80,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.excusesNoExcuses,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final doc = docs[index];
                final data = doc.data() as Map<String, dynamic>;
                final details = data['details'] as Map<String, dynamic>? ?? {};
                final reason = details['reason'] ?? l10n.excusesWithoutReason;
                final status = data['status'] ?? 'pending';
                final attachmentUrl = details['attachmentUrl'];
                final courseName = details['course_name'] ?? l10n.unspecifiedMajor;
                final studentId = data['student_id'] ?? data['student_id'] ?? '';
                final courseId = details['course_id'] ?? '';
                final requestId = doc.id;

                String statusText = l10n.excusesStatusSubmitted;
                if (status == 'approved') statusText = l10n.statusApproved;
                if (status == 'rejected') statusText = l10n.statusRejected;

                Color statusColor = Colors.orange;
                if (status == 'approved') statusColor = Colors.green;
                if (status == 'rejected') statusColor = Colors.red;

                return StaggeredFadeInSlideY(
                  index: index,
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                courseName,
                                style: const TextStyle(
                                  fontFamily: 'Cairo',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: statusColor),
                                ),
                                child: Text(
                                  statusText,
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    color: statusColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(),
                          Text(
                            '${l10n.excusesReasonLabel}: $reason',
                            style: const TextStyle(fontFamily: 'Cairo'),
                          ),
                          const SizedBox(height: 16),
                          if (attachmentUrl != null) ...[
                            OutlinedButton.icon(
                              onPressed: () async {
                                final uri = Uri.parse(attachmentUrl);
                                if (await canLaunchUrl(uri)) {
                                  await launchUrl(uri);
                                }
                              },
                              icon: const Icon(Icons.attachment_rounded),
                              label: Text(
                                l10n.excusesViewAttachment,
                                style: const TextStyle(fontFamily: 'Cairo'),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          if (status == 'pending')
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed:
                                        () => _updateStatus(
                                          context,
                                          ref,
                                          requestId,
                                          studentId,
                                          courseId,
                                          'approved',
                                        ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: Text(
                                      l10n.verifQueueApprove,
                                      style: const TextStyle(fontFamily: 'Cairo'),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed:
                                        () => _updateStatus(
                                          context,
                                          ref,
                                          requestId,
                                          studentId,
                                          courseId,
                                          'rejected',
                                        ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: Text(
                                      l10n.verifQueueReject,
                                      style: const TextStyle(fontFamily: 'Cairo'),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
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
