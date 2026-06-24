import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_project/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_project/core/utils/pagination_helper.dart';

class SystemLogsPage extends StatefulWidget {
  const SystemLogsPage({super.key});

  @override
  State<SystemLogsPage> createState() => _SystemLogsPageState();
}

class _SystemLogsPageState extends State<SystemLogsPage> {
  late PaginationHelper<Map<String, dynamic>> _pagination;
  final _scrollController = ScrollController();
  bool _isInitialLoad = true;

  @override
  void initState() {
    super.initState();
    _initQuery();
    _scrollController.addListener(_onScroll);
  }

  void _initQuery() {
    _pagination = PaginationHelper<Map<String, dynamic>>(
      baseQuery: FirebaseFirestore.instance
          .collection('activityLogs')
          .orderBy('timestamp', descending: true),
      fromDoc: (doc) => doc.data()!,
      pageSize: 20,
    );
    _loadInitial();
  }

  Future<void> _loadInitial() async {
    await _pagination.loadNextPage();
    if (mounted) setState(() => _isInitialLoad = false);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (_pagination.hasMore && !_pagination.isLoading) {
        _pagination.loadNextPage().then((_) {
          if (mounted) setState(() {});
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFF070B14), // Deep tech dark
      appBar: AppBar(
        backgroundColor: const Color(0xFF070B14),
        elevation: 0,
        title: Text(
          l10n.systemLogsTitle,
          style: const TextStyle(
            fontFamily: 'Cairo',
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF8B3DFF)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => context.go('/admin/dashboard'),
        ),
      ),
      body: Stack(
        children: [
          // High-Tech Grid Background
          Positioned.fill(child: CustomPaint(painter: _GridPainter())),

          Builder(
            builder: (context) {
              if (_isInitialLoad) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF8B3DFF)),
                );
              }

              final docs = _pagination.items;
              if (docs.isEmpty) {
                return const Center(
                  child: Text(
                    'لا توجد سجلات نشاط حتى الآن',
                    style: TextStyle(fontFamily: 'Cairo', color: Colors.white70),
                  ),
                );
              }

              return ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                itemCount: docs.length + (_pagination.hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == docs.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(color: Color(0xFF8B3DFF)),
                      ),
                    );
                  }
                  final logData = docs[index];
                  return _ActivityLogCard(log: logData);
                },
              );
            },
          ),
        ],
      ),
    );
  }
}


class _ActivityLogCard extends StatefulWidget {
  final Map<String, dynamic> log;
  const _ActivityLogCard({required this.log});

  @override
  State<_ActivityLogCard> createState() => _ActivityLogCardState();
}

class _ActivityLogCardState extends State<_ActivityLogCard> {
  String _adminEmail = '';
  String _targetUser = '';
  bool _loading = true;

  bool _fetchStarted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_fetchStarted) {
      _fetchStarted = true;
      _fetchDetails(context);
    }
  }

  Future<void> _fetchDetails(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final adminUid = widget.log['adminUid'] as String?;
    final targetUid = widget.log['targetUid'] as String?;

    String resolvedAdmin = adminUid ?? l10n.systemLogsSystem;
    String resolvedTarget = targetUid ?? l10n.notApplicable;

    try {
      if (adminUid != null && adminUid.isNotEmpty) {
        final adminDoc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(adminUid)
                .get();
        if (adminDoc.exists) {
          resolvedAdmin = adminDoc.data()?['email'] as String? ?? adminUid;
        }
      }

      if (targetUid != null && targetUid.isNotEmpty) {
        final targetDoc =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(targetUid)
                .get();
        if (targetDoc.exists) {
          final data = targetDoc.data()!;
          resolvedTarget =
              data['fullNameAr'] as String? ??
              data['fullName'] as String? ??
              data['email'] as String? ??
              targetUid;
        }
      }
    } catch (_) {
      // Fallback to UIDs in case of any database read failures
    }

    if (mounted) {
      setState(() {
        _adminEmail = resolvedAdmin;
        _targetUser = resolvedTarget;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final log = widget.log;
    final action = log['action'] as String? ?? '';
    final detail = log['detail'] as String? ?? '';
    final timestamp = log['timestamp'];

    Color statusColor;
    IconData statusIcon;

    if (action == 'approved') {
      statusColor = const Color(0xFF00FF88);
      statusIcon = Icons.check_circle_rounded;
    } else if (action == 'rejected') {
      statusColor = const Color(0xFFFF3366);
      statusIcon = Icons.cancel_rounded;
    } else {
      statusColor = const Color(0xFF00E5FF);
      statusIcon = Icons.info_rounded;
    }

    String formattedTime = '';
    if (timestamp is Timestamp) {
      formattedTime = DateFormat(
        'yyyy-MM-dd HH:mm:ss',
      ).format(timestamp.toDate());
    } else if (timestamp != null) {
      formattedTime = timestamp.toString();
    }

    String displayAction;
    if (action == 'approved') {
      displayAction = l10n.systemLogsActionApproved;
    } else if (action == 'rejected') {
      displayAction = l10n.systemLogsActionRejected;
    } else {
      displayAction = action.isEmpty ? l10n.systemLogsActionOther : action;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withValues(alpha: 0.2), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(statusIcon, color: statusColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      displayAction,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: statusColor,
                      ),
                    ),
                    Text(
                      formattedTime,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white38,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${l10n.systemLogsAdmin}: ${_loading ? "..." : _adminEmail}',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${l10n.systemLogsTarget}: ${_loading ? "..." : _targetUser}',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
                if (detail.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.02),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${l10n.systemLogsDetails}: $detail',
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11,
                        color: Colors.white54,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = const Color(0xFF00E5FF).withValues(alpha: 0.02)
          ..strokeWidth = 1.0;

    for (double i = 0; i < size.width; i += 30) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += 30) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
