import 'package:flutter_project/core/services/error_tracking_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_project/core/models/app_notification.dart';
import 'package:flutter_project/core/providers/app_providers.dart';
import 'package:flutter_project/core/theme/app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_project/features/auth/data/auth_service.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_project/shared/widgets/empty_state_widget.dart';
import 'package:flutter_project/shared/widgets/uod_shimmer.dart';
import 'package:flutter_project/l10n/app_localizations.dart';

enum _NotificationFilter { all, alerts, announcements }

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  _NotificationFilter _filter = _NotificationFilter.all;

  List<AppNotification> _filtered(List<AppNotification> items) {
    final uniqueItems = <String, AppNotification>{};
    for (final item in items) {
      uniqueItems[item.id] = item;
    }
    final deduplicated = uniqueItems.values.toList();

    return switch (_filter) {
      _NotificationFilter.all => deduplicated,
      _NotificationFilter.alerts => deduplicated.where(_isAlert).toList(),
      _NotificationFilter.announcements =>
        deduplicated.where(_isAnnouncement).toList(),
    };
  }

  bool _isAlert(AppNotification n) {
    final c = n.category?.toLowerCase() ?? '';
    return c.contains('alert') || c.contains('تنبيه');
  }

  bool _isAnnouncement(AppNotification n) {
    final c = n.category?.toLowerCase() ?? '';
    return c.contains('announcement') ||
        c.contains('إعلان') ||
        c.contains('news');
  }

  Future<void> _markRead(String uid, AppNotification notification) async {
    if (notification.isRead) return;
    try {
      final firestore = FirebaseFirestore.instance;
      final now = DateTime.now().millisecondsSinceEpoch;
      if (notification.id.startsWith('global_')) {
        await firestore
            .collection('users')
            .doc(uid)
            .collection('notification_reads')
            .doc(notification.id)
            .set({'read': true, 'readAt': now});
        return;
      }
      await firestore
          .collection('users')
          .doc(uid)
          .collection('notifications')
          .doc(notification.id)
          .update({
            'read': true,
            'isRead': true,
            'is_read': true,
            'updatedAt': now,
          });
    } catch (e, stackTrace) {
      ErrorTrackingService.recordError(e, stackTrace, context: 'Error marking notification read');
    }
  }

  Future<void> _markAllRead(String uid) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final qs = await firestore
          .collection('users')
          .doc(uid)
          .collection('notifications')
          .get();

      final batch = firestore.batch();
      final now = DateTime.now().millisecondsSinceEpoch;
      for (final doc in qs.docs) {
        final data = doc.data();
        final isRead =
            data['is_read'] as bool? ??
            data['read'] as bool? ??
            data['isRead'] as bool? ??
            false;
        if (!isRead) {
          batch.update(doc.reference, {
            'read': true,
            'isRead': true,
            'is_read': true,
            'updatedAt': now,
          });
        }
      }
      await batch.commit();
    } catch (e, stackTrace) {
      ErrorTrackingService.recordError(e, stackTrace, context: 'Error marking all read');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to mark all as read')),
        );
      }
    }
  }

  Future<void> _delete(String uid, String id) async {
    if (id.startsWith('global_')) return;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('notifications')
          .doc(id)
          .delete();
    } catch (e, stackTrace) {
      ErrorTrackingService.recordError(e, stackTrace, context: 'Error deleting notification');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete notification')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authStateChangesProvider);
    final l10n = AppLocalizations.of(context)!;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notificationsTitle),
        centerTitle: true,
        actions: [
          auth.when(
            data:
                (user) =>
                    user == null
                        ? const SizedBox.shrink()
                        : TextButton(
                          onPressed: () => _markAllRead(user.uid),
                          child: Text(
                            l10n.notificationsMarkAllReadButton,
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 13,
                            ),
                          ),
                        ),
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),
          IconButton(
            tooltip: l10n.notificationSettingsButton,
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: SegmentedButton<_NotificationFilter>(
              segments: [
                ButtonSegment(
                  value: _NotificationFilter.all,
                  label: Text(
                    l10n.notificationsTitle,
                    style: const TextStyle(fontFamily: 'Cairo', fontSize: 12),
                  ),
                ),
                ButtonSegment(
                  value: _NotificationFilter.alerts,
                  label: Text(
                    l10n.alertsTitle,
                    style: const TextStyle(fontFamily: 'Cairo', fontSize: 12),
                  ),
                ),
                ButtonSegment(
                  value: _NotificationFilter.announcements,
                  label: Text(
                    l10n.announcementsTitle,
                    style: const TextStyle(fontFamily: 'Cairo', fontSize: 12),
                  ),
                ),
              ],
              selected: {_filter},
              onSelectionChanged: (set) {
                setState(() => _filter = set.first);
              },
            ),
          ),
          Expanded(
            child: auth.when(
              data: (user) {
                if (user == null) {
                  return Center(child: Text(l10n.pleaseLogin));
                }
                final listAsync = ref.watch(
                  notificationListProvider(user.uid),
                );
                return listAsync.when(
                  data: (items) {
                    // ✅ لا mock data — إذا كانت القائمة فارغة، نعرض الحالة الفارغة الحقيقية
                    final filtered = _filtered(items);
                    if (filtered.isEmpty) {
                      return RefreshIndicator(
                        onRefresh: () async {
                          ref.invalidate(notificationListProvider(user.uid));
                        },
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(24),
                          children: [
                            EmptyStateWidget(
                              icon: Icons.notifications_none_rounded,
                              title: l10n.notificationsEmptyMessage,
                              subtitle: l10n.pullToRefreshSync,
                              actionLabel: l10n.refreshAction,
                              onAction:
                                  () => ref.invalidate(
                                    notificationListProvider(user.uid),
                                  ),
                            ),
                          ],
                        ),
                      );
                    }
                    return RefreshIndicator(
                      onRefresh: () async {
                        ref.invalidate(notificationListProvider(user.uid));
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final n = filtered[index];
                          return _NotificationTile(
                            notification: n,
                            l10n: l10n,
                            isAr: isAr,
                            onTap: () => _markRead(user.uid, n),
                            onDelete: () => _delete(user.uid, n.id),
                          ).animate().fadeIn(delay: (index * 40).ms).slideX(
                            begin: isAr ? 0.05 : -0.05,
                          );
                        },
                      ),
                    );
                  },
                  loading: () => const UodScreenLoading(),
                  error:
                      (e, _) => Center(child: Text('${l10n.errorPrefix}$e')),
                );
              },
              loading: () => const UodScreenLoading(),
              error: (e, _) => Center(child: Text('${l10n.errorPrefix}$e')),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.notification,
    required this.l10n,
    required this.isAr,
    required this.onTap,
    required this.onDelete,
  });

  final AppNotification notification;
  final AppLocalizations l10n;
  final bool isAr;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final n = notification;
    final title = n.title.isEmpty ? l10n.notificationDefault : n.title;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              n.isRead
                  ? theme.dividerColor.withValues(alpha: 0.3)
                  : AppTheme.tertiaryColor.withValues(alpha: 0.5),
          width: n.isRead ? 0.5 : 1.2,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(16),
        title: Row(
          children: [
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.start,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
            ),
            if (!n.isRead) ...[
              const SizedBox(width: 8),
              Chip(
                label: Text(
                  l10n.notificationNewBadge,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                backgroundColor: AppTheme.tertiaryColor.withValues(alpha: 0.15),
              ),
            ],
          ],
        ),
        subtitle: Column(
          crossAxisAlignment:
              isAr ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              n.body,
              textAlign: TextAlign.start,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 14,
                fontFamily: 'Cairo',
              ),
            ),
            if (n.createdAtMs != null) ...[
              const SizedBox(height: 6),
              Text(
                _timeAgoLabel(l10n, n.createdAtMs!),
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 12,
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ],
        ),
        trailing:
            n.id.startsWith('global_')
                ? null
                : IconButton(
                  tooltip: l10n.notificationDeleteButton,
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    color: theme.colorScheme.error,
                  ),
                  onPressed: onDelete,
                ),
      ),
    );
  }

  String _timeAgoLabel(AppLocalizations l10n, int createdAtMs) {
    final diff = DateTime.now().difference(
      DateTime.fromMillisecondsSinceEpoch(createdAtMs),
    );
    final String time;
    if (diff.inMinutes < 60) {
      time = '${diff.inMinutes.clamp(1, 59)}m';
    } else if (diff.inHours < 24) {
      time = '${diff.inHours}h';
    } else {
      time = '${diff.inDays}d';
    }
    return l10n.notificationTimeAgo(time);
  }
}
