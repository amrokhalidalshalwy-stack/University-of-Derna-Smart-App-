// verification_queue_page.dart — admin approval/rejection interface
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_project/features/admin/data/admin_service.dart';
import 'package:flutter_project/core/constants/app_roles.dart';
import 'package:flutter_project/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

class VerificationQueuePage extends ConsumerStatefulWidget {
  const VerificationQueuePage({super.key});
  @override
  ConsumerState<VerificationQueuePage> createState() => _VQPageState();
}

class _VQPageState extends ConsumerState<VerificationQueuePage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  static const _tabFilters = [
    'all',
    'pending_final_approval',
    'under_review',
    'requires_additional',
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final stream = ref.watch(registrationsStreamProvider);

    final tabLabels = [
      l10n.verifQueueTabAll,
      l10n.verifQueueTabPending,
      l10n.verifQueueTabUnderReview,
      l10n.verifQueueTabRequiresInfo,
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF001835),
        title: Text(
          l10n.verifQueueTitle,
          style: const TextStyle(
            fontFamily: 'Cairo',
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => context.go('/admin/dashboard'),
        ),
        bottom: TabBar(
          controller: _tabs,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: const Color(0xFFFED65B),
          labelStyle: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
          tabs: tabLabels.map((l) => Tab(text: l)).toList(),
        ),
      ),
      body: stream.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (e, _) => Center(
              child: Text(
                '${l10n.genericError}: $e',
                style: const TextStyle(fontFamily: 'Cairo'),
              ),
            ),
        data: (all) {
          return TabBarView(
            controller: _tabs,
            children: List.generate(4, (i) {
              final filter = _tabFilters[i];
              final list =
                  filter == 'all'
                      ? all
                      : all.where((r) => r['status'] == filter).toList();
              if (list.isEmpty) return _emptyState(l10n);
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: list.length,
                itemBuilder: (_, j) => _ApplicationCard(data: list[j]),
              );
            }),
          );
        },
      ),
    );
  }

  Widget _emptyState(AppLocalizations l10n) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.inbox_rounded,
          size: 64,
          color: const Color(0xFF74777F).withValues(alpha: 0.4),
        ),
        const SizedBox(height: 12),
        Text(
          l10n.verifQueueEmpty,
          style: const TextStyle(fontFamily: 'Cairo', color: Color(0xFF74777F)),
        ),
      ],
    ),
  );
}

// ── Application Card ──────────────────────────────────────────────────────────
class _ApplicationCard extends ConsumerStatefulWidget {
  final Map<String, dynamic> data;
  const _ApplicationCard({required this.data});
  @override
  ConsumerState<_ApplicationCard> createState() => _AppCardState();
}

class _AppCardState extends ConsumerState<_ApplicationCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final d = widget.data;
    final status = RegistrationStatus.fromString(d['status']);
    final score = (d['preliminaryScore'] as num?)?.toInt() ?? 0;
    final scoreColor =
        score >= 75
            ? const Color(0xFF28A745)
            : score >= 50
            ? const Color(0xFFFFC107)
            : const Color(0xFFDC3545);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header row
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  // Score badge
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: scoreColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: scoreColor.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '$score',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: scoreColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          d['fullNameAr'] ?? '',
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color(0xFF001835),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${d['faculty'] ?? ''} — ${d['department'] ?? ''}',
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 11,
                            color: Color(0xFF43474E),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: scoreColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(
                            status.labelAr,
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 10,
                              color: scoreColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: const Color(0xFF74777F),
                  ),
                ],
              ),
            ),
          ),
          // Expanded detail
          if (_expanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _infoRow(l10n.verifQueueFieldNameEn, d['fullNameEn'] ?? ''),
                  _infoRow(l10n.verifQueueFieldEmail, d['email'] ?? ''),
                  _infoRow(l10n.verifQueueFieldPhone, d['phone'] ?? ''),
                  _infoRow(
                    l10n.verifQueueFieldNationalId,
                    d['nationalId'] ?? '',
                  ),
                  _infoRow(l10n.verifQueueFieldGender, d['gender'] ?? ''),
                  _infoRow(l10n.verifQueueFieldSemester, d['semester'] ?? ''),
                  _infoRow(
                    l10n.verifQueueFieldGpa,
                    '${d['secondaryGpa'] ?? 0}%',
                  ),
                  _infoRow(
                    l10n.verifQueueFieldGraduationYear,
                    '${d['expectedGraduationYear'] ?? ''}',
                  ),
                  const SizedBox(height: 12),
                  // Action buttons
                  if (status.isPending ||
                      status == RegistrationStatus.underReview ||
                      status == RegistrationStatus.requiresAdditional)
                    Row(
                      children: [
                        Expanded(
                          child: _actionBtn(
                            l10n.verifQueueApprove,
                            const Color(0xFF28A745),
                            Icons.check_rounded,
                            () => _approve(d['id'] ?? d['uid'] ?? '', l10n),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _actionBtn(
                            l10n.verifQueueReject,
                            const Color(0xFFDC3545),
                            Icons.close_rounded,
                            () =>
                                _rejectDialog(d['id'] ?? d['uid'] ?? '', l10n),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(String label, String val) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.w600,
            fontSize: 12,
            color: Color(0xFF43474E),
          ),
        ),
        Expanded(
          child: Text(
            val,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12,
              color: Color(0xFF001835),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _actionBtn(
    String label,
    Color color,
    IconData icon,
    VoidCallback onTap,
  ) => ElevatedButton.icon(
    style: ElevatedButton.styleFrom(
      backgroundColor: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.symmetric(vertical: 10),
    ),
    onPressed: onTap,
    icon: Icon(icon, size: 16, color: Colors.white),
    label: Text(
      label,
      style: const TextStyle(
        fontFamily: 'Cairo',
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    ),
  );

  Future<void> _approve(String uid, AppLocalizations l10n) async {
    final confirm = await _confirm(l10n.verifQueueApproveMsg, l10n);
    if (!confirm || !mounted) return;
    try {
      await ref.read(adminServiceProvider).approveStudent(uid: uid);
      if (mounted) {
        _snack(l10n.verifQueueApproveSuccess, const Color(0xFF28A745));
      }
    } catch (e) {
      if (mounted) {
        _snack('${l10n.verifQueueErrorAction}: $e', const Color(0xFFDC3545));
      }
    }
  }

  Future<void> _rejectDialog(String uid, AppLocalizations l10n) async {
    String? selectedReason;
    String? customReason;
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (_) => StatefulBuilder(
            builder:
                (ctx, setS) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  title: Text(
                    l10n.verifQueueRejectReason,
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                        ),
                        hint: Text(
                          l10n.verifQueueRejectReasonHint,
                          style: const TextStyle(fontFamily: 'Cairo'),
                        ),
                        items:
                            RejectionReasons.options
                                .map(
                                  (r) => DropdownMenuItem(
                                    value: r,
                                    child: Text(
                                      r,
                                      style: const TextStyle(
                                        fontFamily: 'Cairo',
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                        onChanged: (v) => setS(() => selectedReason = v),
                      ),
                      if (selectedReason == l10n.verifQueueOtherReason) ...[
                        const SizedBox(height: 10),
                        TextField(
                          onChanged: (v) => customReason = v,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            hintText: l10n.verifQueueRejectCustomHint,
                            hintStyle: const TextStyle(fontFamily: 'Cairo'),
                          ),
                        ),
                      ],
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: Text(
                        l10n.cancel,
                        style: const TextStyle(fontFamily: 'Cairo'),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDC3545),
                      ),
                      onPressed:
                          selectedReason == null
                              ? null
                              : () => Navigator.pop(ctx, true),
                      child: Text(
                        l10n.verifQueueRejectConfirm,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
          ),
    );
    if (confirmed != true || !mounted) return;
    final reason =
        selectedReason == l10n.verifQueueOtherReason
            ? (customReason ?? l10n.verifQueueOtherReason)
            : (selectedReason ?? '');
    try {
      await ref
          .read(adminServiceProvider)
          .rejectStudent(uid: uid, reason: reason);
      if (mounted) {
        _snack(l10n.verifQueueRejectSuccess, const Color(0xFFDC3545));
      }
    } catch (e) {
      if (mounted) {
        _snack('${l10n.verifQueueErrorAction}: $e', const Color(0xFFDC3545));
      }
    }
  }

  Future<bool> _confirm(String msg, AppLocalizations l10n) async {
    return await showDialog<bool>(
          context: context,
          builder:
              (_) => AlertDialog(
                title: Text(
                  l10n.verifQueueConfirmTitle,
                  style: const TextStyle(fontFamily: 'Cairo'),
                ),
                content: Text(msg, style: const TextStyle(fontFamily: 'Cairo')),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(
                      l10n.cancel,
                      style: const TextStyle(fontFamily: 'Cairo'),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: Text(
                      l10n.verifQueueYes,
                      style: const TextStyle(fontFamily: 'Cairo'),
                    ),
                  ),
                ],
              ),
        ) ??
        false;
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontFamily: 'Cairo')),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
