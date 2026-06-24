import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_project/core/theme/app_theme.dart';
import 'package:flutter_project/features/auth/data/auth_service.dart';
import 'package:flutter_project/features/requests/data/requests_providers.dart';
import 'package:flutter_project/features/requests/data/student_request_model.dart';
import 'package:flutter_project/features/requests/presentation/pages/new_request_page.dart';
import 'package:flutter_project/features/requests/presentation/pages/request_detail_page.dart';
import 'package:flutter_project/l10n/app_localizations.dart';
import 'package:flutter_project/shared/widgets/uod_shimmer.dart';

class ERequestsPage extends ConsumerWidget {
  const ERequestsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final authAsync = ref.watch(authStateChangesProvider);

    return authAsync.when(
      data: (user) {
        if (user == null) {
          return Scaffold(body: Center(child: Text(l10n.pleaseLogin)));
        }

        final requestsAsync = ref.watch(userRequestsProvider(user.uid));

        return Scaffold(
          appBar: AppBar(
            title: Text(
              l10n.eRequestsTitle,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
          body: requestsAsync.when(
            data: (requests) => _buildBody(context, requests, l10n),
            loading: () => const UodScreenLoading(),
            error: (e, _) => Center(child: Text('${l10n.errorPrefix}$e')),
          ),
        );
      },
      loading: () => const UodScreenLoading(),
      error: (e, _) => Scaffold(body: Center(child: Text(l10n.authError))),
    );
  }

  Widget _buildBody(
    BuildContext context,
    List<StudentRequest> requests,
    AppLocalizations l10n,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildRequestTypesGrid(context, l10n),
          const SizedBox(height: 32),
          _buildSectionTitle(context, l10n.myRequests),
          const SizedBox(height: 16),
          if (requests.isEmpty)
            _buildEmptyState(context, l10n)
          else
            _buildRequestsList(context, requests, l10n),
        ],
      ),
    );
  }

  Widget _buildRequestTypesGrid(BuildContext context, AppLocalizations l10n) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        _buildRequestTypeCard(
          context,
          icon: Icons.school,
          title: l10n.requestTypeGraduationCertificate,
          type: RequestType.graduationCertificate,
          l10n: l10n,
        ),
        _buildRequestTypeCard(
          context,
          icon: Icons.description,
          title: l10n.requestTypeOfficialTranscript,
          type: RequestType.officialTranscript,
          l10n: l10n,
        ),
        _buildRequestTypeCard(
          context,
          icon: Icons.event_busy,
          title: l10n.requestTypeSemesterDeferral,
          type: RequestType.semesterDeferral,
          l10n: l10n,
        ),
        _buildRequestTypeCard(
          context,
          icon: Icons.swap_horiz,
          title: l10n.requestTypeMajorChange,
          type: RequestType.majorChange,
          l10n: l10n,
        ),
      ],
    );
  }

  Widget _buildRequestTypeCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required RequestType type,
    required AppLocalizations l10n,
  }) {
    // جلب الألوان ديناميكياً بناءً على وضع التطبيق (فاتح / داكن)
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // تخصيص ألوان مريحة ومطابقة لكل وضع
    final containerColor = isDarkMode 
        ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
        : theme.colorScheme.primaryContainer;
        
    final iconColor = theme.colorScheme.primary;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewRequestPage(requestType: type),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: containerColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: iconColor, size: 32),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onSurface,
        fontFamily: 'Cairo',
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: AppTheme.outlineVariantColor.withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: Theme.of(
                context,
              ).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noRequestsYet,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
                fontFamily: 'Cairo',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.noRequestsDescription,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontFamily: 'Cairo',
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestsList(
    BuildContext context,
    List<StudentRequest> requests,
    AppLocalizations l10n,
  ) {
    return Column(
      children:
          requests.map((request) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildRequestCard(context, request, l10n),
            );
          }).toList(),
    );
  }

  Widget _buildRequestCard(
    BuildContext context,
    StudentRequest request,
    AppLocalizations l10n,
  ) {
    final statusColor = _getStatusColor(request.status, context);
    final statusText = _getStatusText(request.status, l10n);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RequestDetailPage(request: request),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getRequestTypeText(request.type, l10n),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo',
                      ),
                      textAlign: TextAlign.start,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(request.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontFamily: 'Cairo',
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ],
                ),
              ),
              Chip(
                label: Text(
                  statusText,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                  ),
                ),
                backgroundColor: statusColor.withValues(alpha: 0.2),
                side: BorderSide(color: statusColor),
              ),
            ],
          ),
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

  Color _getStatusColor(RequestStatus status, BuildContext context) {
    switch (status) {
      case RequestStatus.pending:
        return Colors.orange;
      case RequestStatus.approved:
        return Colors.green;
      case RequestStatus.rejected:
        return Colors.red;
      case RequestStatus.readyForPickup:
        return Colors.blue;
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
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}