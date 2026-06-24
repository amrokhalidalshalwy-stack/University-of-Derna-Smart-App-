// lib/features/admin/screens/admin_users_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إدارة المستخدمين'),
          bottom: TabBar(
            controller: _tabController,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            indicatorColor: Colors.white,
            tabs: const [
              Tab(text: 'الكل'),
              Tab(text: 'الطلاب'),
              Tab(text: 'هيئة التدريس'),
            ],
          ),
        ),
        body: Column(
          children: [
            // ── بحث ──
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'بحث بالاسم أو البريد...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 12,
                  ),
                  suffixIcon:
                      _searchQuery.isNotEmpty
                          ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                          : null,
                ),
                onChanged: (v) => setState(() => _searchQuery = v.trim()),
              ),
            ),

            // ── القوائم ──
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _UserList(roleFilter: null, searchQuery: _searchQuery),
                  _UserList(roleFilter: 'student', searchQuery: _searchQuery),
                  _UserList(roleFilter: 'faculty', searchQuery: _searchQuery),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserList extends StatelessWidget {
  final String? roleFilter;
  final String searchQuery;

  const _UserList({this.roleFilter, required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    Query query = FirebaseFirestore.instance.collection('users');
    if (roleFilter != null) {
      query = query.where('role', isEqualTo: roleFilter);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        var docs = snapshot.data?.docs ?? [];

        // تصفية البحث
        if (searchQuery.isNotEmpty) {
          docs =
              docs.where((d) {
                final data = d.data() as Map<String, dynamic>;
                final name = data['fullNameAr']?.toString() ?? '';
                final email = data['email']?.toString() ?? '';
                return name.contains(searchQuery) ||
                    email.contains(searchQuery);
              }).toList();
        }

        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.people_outline,
                  size: 60,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 12),
                Text(
                  'لا يوجد مستخدمون',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: docs.length,
          itemBuilder: (context, i) {
            final d = docs[i].data() as Map<String, dynamic>;
            final role = d['role'] as String? ?? 'student';
            final name = d['fullNameAr'] as String? ?? '--';

            Color roleColor;
            IconData roleIcon;
            String roleLabel;
            switch (role) {
              case 'admin':
                roleColor = Colors.red;
                roleIcon = Icons.admin_panel_settings;
                roleLabel = 'مدير';
                break;
              case 'faculty':
                roleColor = const Color(0xFF6A1B9A);
                roleIcon = Icons.person;
                roleLabel = 'عضو تدريس';
                break;
              default:
                roleColor = AppTheme.primary;
                roleIcon = Icons.school;
                roleLabel = 'طالب';
            }

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: roleColor.withValues(alpha: 0.1),
                  child: Icon(roleIcon, color: roleColor, size: 22),
                ),
                title: Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  d['email'] as String? ?? '',
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: roleColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        roleLabel,
                        style: TextStyle(
                          color: roleColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      d['faculty'] as String? ?? '',
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
                onTap: () => _showUserDetails(context, d, docs[i].id),
              ),
            );
          },
        );
      },
    );
  }

  void _showUserDetails(
    BuildContext context,
    Map<String, dynamic> d,
    String uid,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (_) => Directionality(
            textDirection: TextDirection.rtl,
            child: DraggableScrollableSheet(
              initialChildSize: 0.6,
              maxChildSize: 0.9,
              minChildSize: 0.4,
              expand: false,
              builder:
                  (_, controller) => ListView(
                    controller: controller,
                    padding: const EdgeInsets.all(20),
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
                      Center(
                        child: CircleAvatar(
                          radius: 36,
                          backgroundColor: AppTheme.primary.withValues(
                            alpha: 0.1,
                          ),
                          child: Text(
                            (d['fullNameAr'] as String? ?? 'م').isNotEmpty
                                ? (d['fullNameAr'] as String)[0]
                                : 'م',
                            style: const TextStyle(
                              fontSize: 28,
                              color: AppTheme.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: Text(
                          d['fullNameAr'] as String? ?? '--',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Center(
                        child: Text(
                          d['email'] as String? ?? '--',
                          style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      const Divider(height: 28),
                      _detailRow(context, 'الكلية', d['faculty']),
                      _detailRow(
                        context,
                        'القسم / التخصص',
                        d['major'] ?? d['department'],
                      ),
                      _detailRow(context, 'الهاتف', d['phone']),
                      _detailRow(context, 'الدور', d['role']),
                      _detailRow(context, 'المعدل', d['gpa']),
                      _detailRow(
                        context,
                        'الساعات المكتملة',
                        d['completedHours'],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
            ),
          ),
    );
  }

  Widget _detailRow(BuildContext context, String label, dynamic value) {
    if (value == null || value.toString().isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.toString(),
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
