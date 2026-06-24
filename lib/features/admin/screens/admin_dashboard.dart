// lib/features/admin/screens/admin_dashboard.dart
//
//  Full admin dashboard with:
//  • 4 Firestore-backed stat cards (Students, Faculty, Courses, Departments)
//  • Recent users list with avatars and role chips
//  • Quick-action buttons (Add User, Add Course, Schedule, Report)
//  • RTL Arabic, dark-blue (#1A365D) + gold (#D4AF37) theme
//  • flutter_riverpod state, flutter_animate micro-animations
// ──────────────────────────────────────────────────────────────────────────

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'admin_app_bar.dart';
import 'admin_sidebar.dart';

// ── Palette ────────────────────────────────────────────────────────────────
const _kNavy      = Color(0xFF1A365D);
const _kNavyLight = Color(0xFF2A4A7F);
const _kGold      = Color(0xFFD4AF37);

// ══════════════════════════════════════════════════════════════════════════
//  RIVERPOD PROVIDERS
// ══════════════════════════════════════════════════════════════════════════

/// Equality-key for collection count queries
class _CQ {
  final String col;
  final String? field;
  final String? value;
  const _CQ(this.col, {this.field, this.value});
  @override bool operator ==(Object o) =>
      o is _CQ && o.col == col && o.field == field && o.value == value;
  @override int get hashCode => Object.hash(col, field, value);
}

/// Firestore instance provider
final _fsProvider = Provider<FirebaseFirestore>(
  (_) => FirebaseFirestore.instance,
);

/// Returns aggregate count for a Firestore query
final _countProvider =
    FutureProvider.autoDispose.family<int, _CQ>((ref, q) async {
  Query query = ref.watch(_fsProvider).collection(q.col);
  if (q.field != null && q.value != null) {
    query = query.where(q.field!, isEqualTo: q.value);
  }
  final snap = await query.count().get();
  return snap.count ?? 0;
});

/// Streams the 6 most-recently-created users
final _recentUsersProvider =
    StreamProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
  return ref
      .watch(_fsProvider)
      .collection('users')
      .orderBy('createdAt', descending: true)
      .limit(6)
      .snapshots()
      .map((s) =>
          s.docs.map((d) => <String, dynamic>{'id': d.id, ...d.data()}).toList());
});

// ══════════════════════════════════════════════════════════════════════════
//  MAIN SCREEN
// ══════════════════════════════════════════════════════════════════════════

class AdminDashboard extends ConsumerStatefulWidget {
  const AdminDashboard({super.key});

  @override
  ConsumerState<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends ConsumerState<AdminDashboard> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: const Color(0xFFF0F4F8),
        drawer: const AdminSidebar(),
        appBar: AdminAppBar(
          scaffoldKey: _scaffoldKey,
          title: 'لوحة التحكم',
        ),
        body: RefreshIndicator(
          color: _kGold,
          backgroundColor: _kNavy,
          onRefresh: () async {
            ref.invalidate(_countProvider);
            ref.invalidate(_recentUsersProvider);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Welcome banner
                _WelcomeBanner(),

                const SizedBox(height: 24),

                // 2. Stat cards
                const _SectionTitle(title: 'نظرة عامة'),
                const SizedBox(height: 12),
                const _StatsGrid(),

                const SizedBox(height: 28),

                // 3. Quick actions
                const _SectionTitle(title: 'إجراءات سريعة'),
                const SizedBox(height: 12),
                _QuickActions(),

                const SizedBox(height: 28),

                // 4. Recent users
                const _SectionTitle(title: 'آخر المستخدمين'),
                const SizedBox(height: 12),
                const _RecentUsersList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  WELCOME BANNER
// ══════════════════════════════════════════════════════════════════════════
class _WelcomeBanner extends StatelessWidget {
  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'صباح الخير 🌅';
    if (h < 17) return 'مساء الخير ☀️';
    return 'مساء النور 🌙';
  }

  String get _date {
    final n = DateTime.now();
    const m = ['','يناير','فبراير','مارس','أبريل','مايو','يونيو',
                'يوليو','أغسطس','سبتمبر','أكتوبر','نوفمبر','ديسمبر'];
    const d = ['','الاثنين','الثلاثاء','الأربعاء','الخميس','الجمعة','السبت','الأحد'];
    return '${d[n.weekday]}  ${n.day} ${m[n.month]} ${n.year}';
  }

  @override
  Widget build(BuildContext context) {
    final adminName =
        FirebaseAuth.instance.currentUser?.displayName ?? 'المسؤول';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_kNavy, _kNavyLight],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _kNavy.withValues(alpha: 0.45),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Gold-ringed avatar
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _kGold.withValues(alpha: 0.15),
              border: Border.all(color: _kGold, width: 2.5),
              boxShadow: [
                BoxShadow(
                    color: _kGold.withValues(alpha: 0.3),
                    blurRadius: 10,
                    spreadRadius: 1)
              ],
            ),
            child: const Icon(Icons.admin_panel_settings_rounded,
                color: _kGold, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_greeting,
                    style: const TextStyle(
                        fontFamily: 'Cairo',
                        color: _kGold,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
                Text(adminName,
                    style: const TextStyle(
                        fontFamily: 'Cairo',
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded,
                        color: Colors.white38, size: 12),
                    const SizedBox(width: 4),
                    Text(_date,
                        style: TextStyle(
                            fontFamily: 'Cairo',
                            color: Theme.of(context).colorScheme.onPrimaryContainer, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
          // University icon
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.account_balance_rounded,
                color: Colors.white38, size: 24),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.08);
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  SECTION TITLE
// ══════════════════════════════════════════════════════════════════════════
class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4, height: 20,
          decoration: BoxDecoration(
              color: _kGold, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 10),
        Text(title,
            style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: _kNavy)),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  STATS GRID  (2×2)
// ══════════════════════════════════════════════════════════════════════════
class _StatsGrid extends ConsumerWidget {
  const _StatsGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cards = [
      _CardCfg(
        label: 'الطلاب',
        icon: Icons.school_rounded,
        color: const Color(0xFF1565C0),
        query: const _CQ('users', field: 'role', value: 'student'),
      ),
      _CardCfg(
        label: 'أعضاء الهيئة',
        icon: Icons.person_rounded,
        color: const Color(0xFF6A1B9A),
        query: const _CQ('users', field: 'role', value: 'faculty'),
      ),
      _CardCfg(
        label: 'المقررات',
        icon: Icons.menu_book_rounded,
        color: const Color(0xFF00695C),
        query: const _CQ('courses'),
      ),
      _CardCfg(
        label: 'الأقسام',
        icon: Icons.account_balance_rounded,
        color: const Color(0xFFE65100),
        query: const _CQ('faculties'),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cards.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.55,
      ),
      itemBuilder: (_, i) => _StatCard(
        cfg: cards[i],
        count: ref.watch(_countProvider(cards[i].query)),
      ).animate(delay: (i * 90).ms).fadeIn(duration: 450.ms).slideY(begin: 0.2),
    );
  }
}

class _CardCfg {
  final String label;
  final IconData icon;
  final Color color;
  final _CQ query;
  const _CardCfg(
      {required this.label,
      required this.icon,
      required this.color,
      required this.query});
}

class _StatCard extends StatelessWidget {
  final _CardCfg cfg;
  final AsyncValue<int> count;
  const _StatCard({required this.cfg, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: cfg.color.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: cfg.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(cfg.icon, color: cfg.color, size: 20),
              ),
              count.when(
                data: (n) => Text('$n',
                    style: TextStyle(
                        fontFamily: 'Lexend',
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: cfg.color)),
                loading: () => SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: cfg.color)),
                error: (e, _) => Text('--',
                    style: TextStyle(
                        color: cfg.color,
                        fontSize: 22,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          Text(cfg.label,
              style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
//  QUICK ACTIONS  (1 row × 4)
// ══════════════════════════════════════════════════════════════════════════
class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final items = [
      _AcfG(
        label: 'إدارة\nالمستخدمين',
        icon: Icons.people_rounded,
        color: const Color(0xFF1565C0),
        onTap: () => context.push('/admin/users'),
      ),
      _AcfG(
        label: 'إضافة\nمقرر',
        icon: Icons.library_add_rounded,
        color: const Color(0xFF00695C),
        onTap: () => context.push('/admin/courses'),
      ),
      _AcfG(
        label: 'الجدول\nالدراسي',
        icon: Icons.calendar_month_rounded,
        color: const Color(0xFF6A1B9A),
        onTap: () => context.push('/admin/settings'),
      ),
      _AcfG(
        label: 'التقارير',
        icon: Icons.bar_chart_rounded,
        color: const Color(0xFFE65100),
        onTap: () => context.push('/admin/reports'),
      ),
    ];

    return Row(
      children: List.generate(items.length, (i) {
        final a = items[i];
        return Expanded(
          child: GestureDetector(
            onTap: a.onTap,
            child: Container(
              margin: EdgeInsets.only(right: i < items.length - 1 ? 10 : 0),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
              decoration: BoxDecoration(
                color: a.color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border:
                    Border.all(color: a.color.withValues(alpha: 0.22), width: 1),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: a.color,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                            color: a.color.withValues(alpha: 0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 3)),
                      ],
                    ),
                    child: Icon(a.icon, color: Colors.white, size: 20),
                  ),
                  const SizedBox(height: 8),
                  Text(a.label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: a.color,
                          height: 1.3)),
                ],
              ),
            ),
          )
              .animate(delay: (i * 65).ms)
              .fadeIn(duration: 400.ms)
              .scale(begin: const Offset(0.88, 0.88)),
        );
      }),
    );
  }

}

class _AcfG {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _AcfG(
      {required this.label,
      required this.icon,
      required this.color,
      required this.onTap});
}

// ══════════════════════════════════════════════════════════════════════════
//  RECENT USERS LIST
// ══════════════════════════════════════════════════════════════════════════
class _RecentUsersList extends ConsumerWidget {
  const _RecentUsersList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_recentUsersProvider);
    return async.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator(color: _kNavy)),
      ),
      error: (e, _) => Center(
          child: Text('تعذّر تحميل البيانات',
              style:  TextStyle(fontFamily: 'Cairo', color: Colors.red))),
      data: (users) {
        if (users.isEmpty) {
          return Center(
              child: Padding(
            padding: EdgeInsets.all(24),
            child: Text('لا يوجد مستخدمون بعد',
                style: TextStyle(fontFamily: 'Cairo', color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ));
        }
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: users.length,
            separatorBuilder: (context, index) => Divider(
                height: 1, indent: 72, color: Colors.grey.shade100),
            itemBuilder: (_, i) => _UserTile(user: users[i], index: i),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
//  Single user tile
// ─────────────────────────────────────────────
class _UserTile extends StatelessWidget {
  final Map<String, dynamic> user;
  final int index;
  const _UserTile({required this.user, required this.index});

  /// Returns (label, color) for a role
  (String, Color) _roleInfo(String role) {
    switch (role) {
      case 'admin':
        return ('مدير', _kNavy);
      case 'faculty':
        return ('تدريس', const Color(0xFF6A1B9A));
      case 'student':
        return ('طالب', const Color(0xFF1565C0));
      default:
        return ('ضيف', Colors.grey);
    }
  }

  @override
  Widget build(BuildContext context) {
    final name  = (user['name'] ?? user['displayName'] ?? 'مستخدم') as String;
    final role  = (user['role']  ?? 'guest') as String;
    final email = (user['email'] ?? '') as String;
    final initial = name.isNotEmpty ? name[0] : '؟';
    final (roleLabel, roleColor) = _roleInfo(role);

    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: CircleAvatar(
        radius: 22,
        backgroundColor: roleColor.withValues(alpha: 0.14),
        child: Text(initial,
            style: TextStyle(
                fontFamily: 'Cairo',
                color: roleColor,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
      ),
      title: Text(name,
          style: const TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: _kNavy)),
      subtitle: Text(email,
          style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 11, color: Colors.grey.shade500),
          overflow: TextOverflow.ellipsis),
      trailing: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: roleColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(roleLabel,
            style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: roleColor)),
      ),
    )
        .animate(delay: (index * 55).ms)
        .fadeIn(duration: 400.ms)
        .slideX(begin: 0.1);
  }
}
