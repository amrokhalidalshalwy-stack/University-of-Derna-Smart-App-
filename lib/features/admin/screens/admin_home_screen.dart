// lib/features/admin/screens/admin_home_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'registrations_screen.dart';
import 'admin_users_screen.dart';
import 'admin_faculties_screen.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          title: const Text('لوحة الإدارة'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'تسجيل الخروج',
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('تسجيل الخروج'),
                    content: const Text('هل تريد تسجيل الخروج؟'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('إلغاء')),
                      ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('خروج')),
                    ],
                  ),
                );
                if (confirm == true) {
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/login', (_) => false);
                  }
                }
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── بطاقة الترحيب ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primary, Color(0xFF2E7D32)],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.white24,
                      child: Icon(Icons.admin_panel_settings,
                          color: Colors.white, size: 30),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('لوحة الإدارة',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                        const Text('جامعة درنة',
                            style: TextStyle(
                                color: Colors.white70, fontSize: 13)),
                        Text(
                          _todayDate(),
                          style: const TextStyle(
                              color: Colors.white60, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── الإحصائيات ──
              const Text('الإحصائيات',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'الطلاب',
                      collection: 'users',
                      filterField: 'role',
                      filterValue: 'student',
                      icon: Icons.school_outlined,
                      color: const Color(0xFF1565C0),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatCard(
                      label: 'أعضاء التدريس',
                      collection: 'users',
                      filterField: 'role',
                      filterValue: 'faculty',
                      icon: Icons.person_outlined,
                      color: const Color(0xFF6A1B9A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'طلبات التسجيل',
                      collection: 'registrations',
                      icon: Icons.app_registration,
                      color: const Color(0xFFE65100),
                      filterField: 'status',
                      filterValue: 'pending',
                      labelSuffix: 'معلّقة',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatCard(
                      label: 'الكليات',
                      collection: 'faculties',
                      icon: Icons.account_balance_outlined,
                      color: const Color(0xFF00695C),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ── الإجراءات ──
              const Text('الإجراءات',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              _ActionTile(
                context: context,
                title: 'طلبات التسجيل',
                subtitle: 'مراجعة وقبول ورفض الطلبات الواردة',
                icon: Icons.app_registration,
                iconColor: const Color(0xFFE65100),
                screen: const RegistrationsScreen(),
                badge: FutureBuilder<AggregateQuerySnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('registrations')
                      .where('status', isEqualTo: 'pending')
                      .count()
                      .get(),
                  builder: (_, s) {
                    if (s.connectionState == ConnectionState.waiting) {
                      return const SizedBox.shrink();
                    }
                    final n = s.data?.count ?? 0;
                    return n > 0
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(10)),
                            child: Text('$n',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold)),
                          )
                        : const SizedBox.shrink();
                  },
                ),
              ),

              _ActionTile(
                context: context,
                title: 'إدارة المستخدمين',
                subtitle: 'عرض وتعديل بيانات الطلاب وأعضاء التدريس',
                icon: Icons.manage_accounts,
                iconColor: const Color(0xFF1565C0),
                screen: const AdminUsersScreen(),
              ),

              _ActionTile(
                context: context,
                title: 'إدارة الكليات والأقسام',
                subtitle: 'إضافة وتعديل الكليات والتخصصات',
                icon: Icons.account_balance,
                iconColor: const Color(0xFF00695C),
                screen: const AdminFacultiesScreen(),
              ),

              _ActionTile(
                context: context,
                title: 'سجل النشاطات',
                subtitle: 'متابعة جميع العمليات في النظام',
                icon: Icons.history,
                iconColor: const Color(0xFF6A1B9A),
                screen: null,
              ),

              _ActionTile(
                context: context,
                title: 'الإشعارات والإعلانات',
                subtitle: 'إرسال إشعارات لمجموعات المستخدمين',
                icon: Icons.campaign_outlined,
                iconColor: const Color(0xFFE65100),
                screen: null,
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  String _todayDate() {
    final now = DateTime.now();
    const months = [
      '', 'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];
    return '${now.day} ${months[now.month]} ${now.year}';
  }
}

// ── بطاقة إحصائية ──
class _StatCard extends StatelessWidget {
  final String label;
  final String collection;
  final IconData icon;
  final Color color;
  final String? filterField;
  final String? filterValue;
  final String? labelSuffix;

  const _StatCard({
    required this.label,
    required this.collection,
    required this.icon,
    required this.color,
    this.filterField,
    this.filterValue,
    this.labelSuffix,
  });

  @override
  Widget build(BuildContext context) {
    Query query = FirebaseFirestore.instance.collection(collection);
    if (filterField != null && filterValue != null) {
      query = query.where(filterField!, isEqualTo: filterValue);
    }

    return FutureBuilder<AggregateQuerySnapshot>(
      future: query.count().get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(child: Padding(padding: EdgeInsets.all(14), child: Center(child: CircularProgressIndicator())));
        }
        final count = snapshot.data?.count ?? 0;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(icon, color: color, size: 24),
                    Text(
                      '$count',
                      style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: color),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(label,
                    style: const TextStyle(
                        color: Colors.grey, fontSize: 13)),
                if (labelSuffix != null)
                  Text(labelSuffix!,
                      style: TextStyle(
                          color: color,
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── بلاطة إجراء ──
class _ActionTile extends StatelessWidget {
  final BuildContext context;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Widget? screen;
  final Widget? badge;

  const _ActionTile({
    required this.context,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.screen,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        title: Row(
          children: [
            Expanded(
                child: Text(title,
                    style:
                        const TextStyle(fontWeight: FontWeight.w600))),
            if (badge != null) badge!,
          ],
        ),
        subtitle: Text(subtitle,
            style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
        trailing: Icon(
          screen != null
              ? Icons.arrow_forward_ios
              : Icons.lock_outline,
          size: 15,
          color: screen != null ? Colors.grey : Colors.grey.shade300,
        ),
        onTap: screen != null
            ? () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => screen!))
            : null,
      ),
    );
  }
}
