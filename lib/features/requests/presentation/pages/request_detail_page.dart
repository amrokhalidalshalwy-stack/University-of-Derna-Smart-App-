import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_project/core/theme/app_theme.dart';
import 'package:flutter_project/features/requests/data/requests_providers.dart';
import 'package:flutter_project/features/requests/data/student_request_model.dart';
import 'package:flutter_project/l10n/app_localizations.dart';

class RequestDetailPage extends ConsumerWidget {
  final StudentRequest request;

  const RequestDetailPage({super.key, required this.request});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.requestDetails,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildRequestInfoCard(context, request, l10n),
            const SizedBox(height: 24),
            _buildTimeline(context, request, l10n),
            const SizedBox(height: 24),
            if (request.status == RequestStatus.rejected &&
                request.adminNote != null &&
                request.adminNote!.isNotEmpty)
              _buildAdminNoteCard(context, request.adminNote!, l10n),
            const SizedBox(height: 24),
            if (request.status == RequestStatus.pending)
              _buildCancelButton(context, request, l10n, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestInfoCard(
    BuildContext context,
    StudentRequest request,
    AppLocalizations l10n,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getRequestTypeText(request.type, l10n),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
                color: AppTheme.primaryColor,
              ),
              textAlign: TextAlign.start,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              context,
              l10n.requestTimeline,
              _formatDate(request.createdAt),
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              context,
              l10n.requestStatusPending,
              _getStatusText(request.status, l10n),
            ),
            const SizedBox(height: 16),
            _buildDetailsSection(context, request, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontFamily: 'Cairo',
            ),
            textAlign: TextAlign.start,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              fontFamily: 'Cairo',
            ),
            textAlign: TextAlign.start,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsSection(
    BuildContext context,
    StudentRequest request,
    AppLocalizations l10n,
  ) {
    final details = request.details;
    if (details.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const SizedBox(height: 12),
        Text(
          'Details',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Cairo',
          ),
          textAlign: TextAlign.start,
        ),
        const SizedBox(height: 12),
        ...details.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildInfoRow(
              context,
              _formatDetailKey(entry.key, l10n),
              entry.value.toString(),
            ),
          );
        }),
      ],
    );
  }

  String _formatDetailKey(String key, AppLocalizations l10n) {
    switch (key) {
      case 'notes':
        return l10n.optionalNotes;
      case 'numberOfCopies':
        return l10n.numberOfCopies;
      case 'language':
        return l10n.language;
      case 'semester':
        return l10n.semesterToDefer;
      case 'reason':
        return l10n.reasonForRequest;
      case 'newMajor':
        return l10n.newMajor;
      default:
        return key;
    }
  }

  Widget _buildTimeline(
    BuildContext context,
    StudentRequest request,
    AppLocalizations l10n,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.requestTimeline,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
              ),
              textAlign: TextAlign.start,
            ),
            const SizedBox(height: 20),
            _buildTimelineStep(
              context,
              title: l10n.timelineSubmitted,
              isCompleted: true,
              isCurrent: false,
              isFirst: true,
            ),
            _buildTimelineStep(
              context,
              title: l10n.timelineReview,
              isCompleted: request.status != RequestStatus.pending,
              isCurrent: request.status == RequestStatus.pending,
            ),
            _buildTimelineStep(
              context,
              title: l10n.timelineDecision,
              isCompleted:
                  request.status == RequestStatus.approved ||
                  request.status == RequestStatus.rejected,
              isCurrent: false,
            ),
            if (request.status == RequestStatus.approved ||
                request.status == RequestStatus.readyForPickup)
              _buildTimelineStep(
                context,
                title: l10n.timelineReady,
                isCompleted: request.status == RequestStatus.readyForPickup,
                isCurrent: request.status == RequestStatus.approved,
                isLast: true,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineStep(
    BuildContext context, {
    required String title,
    required bool isCompleted,
    required bool isCurrent,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    isCompleted
                        ? Colors.green
                        : isCurrent
                        ? AppTheme.primaryColor
                        : Colors.grey.withValues(alpha: 0.3),
                border: Border.all(
                  color:
                      isCompleted
                          ? Colors.green
                          : isCurrent
                          ? AppTheme.primaryColor
                          : Colors.grey.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child:
                  isCompleted
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color:
                    isCompleted
                        ? Colors.green
                        : Colors.grey.withValues(alpha: 0.3),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                color:
                    isCompleted || isCurrent
                        ? Theme.of(context).colorScheme.onSurface
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                fontFamily: 'Cairo',
              ),
              textAlign: TextAlign.start,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAdminNoteCard(
    BuildContext context,
    String adminNote,
    AppLocalizations l10n,
  ) {
    return Card(
      elevation: 2,
      color: Colors.red.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Colors.red),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning, color: Colors.red),
                const SizedBox(width: 8),
                Text(
                  l10n.adminNote,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                    color: Colors.red,
                  ),
                  textAlign: TextAlign.start,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              adminNote,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface,
                fontFamily: 'Cairo',
                height: 1.5,
              ),
              textAlign: TextAlign.start,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCancelButton(
    BuildContext context,
    StudentRequest request,
    AppLocalizations l10n,
    WidgetRef ref,
  ) {
    return ElevatedButton.icon(
      onPressed: () {
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Text(l10n.cancelRequest),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.cancelRequestConfirm),
                    const SizedBox(height: 8),
                    Text(
                      l10n.cancelRequestWarning,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l10n.cancel),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        final repository = ref.read(requestsRepositoryProvider);
                        await repository.cancelRequest(request.id);
                        if (context.mounted) {
                          Navigator.pop(context);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.requestCancelled),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${l10n.requestFailed}: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(l10n.cancelRequest),
                  ),
                ],
              ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      icon: const Icon(Icons.cancel),
      label: Text(
        l10n.cancelRequest,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontFamily: 'Cairo',
        ),
      ),
    );
  }

  String _getRequestTypeText(RequestType type, AppLocalizations l10n) {
    switch (type) {
      case RequestType.graduationCertificate:
        return l10n.requestTypeGraduationCertificate;
      case RequestType.officialTranscript:
        return l10n.requestTypeOfficialTranscript;
      case RequestType.semesterDeferral:
        return l10n.requestTypeSemesterDeferral;
      case RequestType.majorChange:
        return l10n.requestTypeMajorChange;
    }
  }

  String _getStatusText(RequestStatus status, AppLocalizations l10n) {
    switch (status) {
      case RequestStatus.pending:
        return l10n.requestStatusPending;
      case RequestStatus.approved:
        return l10n.requestStatusApproved;
      case RequestStatus.rejected:
        return l10n.requestStatusRejected;
      case RequestStatus.readyForPickup:
        return l10n.requestStatusReadyForPickup;
    }
  }

  String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
