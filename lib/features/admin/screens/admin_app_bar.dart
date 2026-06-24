// lib/features/admin/screens/admin_app_bar.dart

import 'package:flutter/material.dart';

const _kNavy = Color(0xFF1A365D);
const _kGold = Color(0xFFD4AF37);

class AdminAppBar extends StatelessWidget implements PreferredSizeWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final String title;
  final List<Widget>? extraActions;

  const AdminAppBar({
    super.key,
    required this.scaffoldKey,
    required this.title,
    this.extraActions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: _kNavy,
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F2340), _kNavy],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 26),
        tooltip: 'القائمة',
        onPressed: () => scaffoldKey.currentState?.openDrawer(),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Cairo',
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.3,
        ),
      ),
      actions: [
        // Notification bell
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined,
                  color: Colors.white, size: 24),
              tooltip: 'الإشعارات',
              onPressed: () => _showNotificationsSheet(context),
            ),
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: _kGold,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
        // Search button
        IconButton(
          icon: const Icon(Icons.search_rounded, color: Colors.white, size: 24),
          tooltip: 'بحث',
          onPressed: () => _showSearchDialog(context),
        ),
        if (extraActions != null) ...extraActions!,
        const SizedBox(width: 4),
      ],
    );
  }

  void _showNotificationsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'الإشعارات',
                style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _kNavy),
              ),
              const SizedBox(height: 16),
              const _NotificationItem(
                icon: Icons.person_add_rounded,
                color: Color(0xFF1565C0),
                title: 'طلب تسجيل جديد',
                subtitle: 'تم استلام طلب تسجيل من طالب جديد',
                time: 'منذ 5 دقائق',
              ),
              const _NotificationItem(
                icon: Icons.warning_amber_rounded,
                color: Color(0xFFE65100),
                title: 'تنبيه النظام',
                subtitle: 'يوجد 3 طلبات تسجيل معلّقة تحتاج مراجعة',
                time: 'منذ ساعة',
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('بحث',
              style: TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.bold, color: _kNavy)),
          content: TextField(
            autofocus: true,
            style: const TextStyle(fontFamily: 'Cairo'),
            decoration: InputDecoration(
              hintText: 'ابحث عن مستخدم أو مقرر...',
              hintStyle: TextStyle(fontFamily: 'Cairo', color: Theme.of(context).colorScheme.onSurfaceVariant),
              prefixIcon: const Icon(Icons.search, color: _kNavy),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _kNavy),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _kNavy, width: 1.5),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('إغلاق',
                  style: TextStyle(fontFamily: 'Cairo', color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _kNavy,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => Navigator.pop(ctx),
              child: const Text('بحث',
                  style: TextStyle(fontFamily: 'Cairo', color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String time;

  const _NotificationItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.w600, fontSize: 13)),
                Text(subtitle,
                    style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12, color: Colors.grey.shade600)),
                Text(time,
                    style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11, color: Colors.grey.shade400)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
