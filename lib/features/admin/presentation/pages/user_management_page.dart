import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_project/core/constants/app_roles.dart';
import 'package:flutter_project/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

class UserManagementPage extends ConsumerWidget {
  const UserManagementPage({super.key});

  Color _roleColor(UserRole role) {
    switch (role) {
      case UserRole.admin: return Colors.red.shade100;
      case UserRole.faculty: return Colors.green.shade100;
      case UserRole.student: return Colors.blue.shade100;
      default: return Colors.grey.shade200;
    }
  }

  Future<void> _showRoleDialog(
    BuildContext context,
    String uid,
    UserRole currentRole,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final selected = await showDialog<UserRole>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(l10n.changeRoleTitle,
          style: const TextStyle(fontFamily: 'Cairo')),
        children: UserRole.values
          .where((r) => r != UserRole.guest)
          .map((r) => SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, r),
            child: Row(
              children: [
                if (r == currentRole)
                  const Icon(Icons.check, size: 16),
                const SizedBox(width: 8),
                Text(r.value,
                  style: const TextStyle(fontFamily: 'Cairo')),
              ],
            ),
          ))
          .toList(),
      ),
    );

    if (selected == null || selected == currentRole) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .update({'role': selected.value});
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.userManagementTitle,
          style: const TextStyle(fontFamily: 'Cairo'),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => context.go('/admin/dashboard'),
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('${l10n.errorPrefix}${snapshot.error}'));
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return Center(child: Text(l10n.noUsersFound));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final data = docs[index].data();
              final role = UserRole.fromString(data['role'] as String?);
              final name =
                  data['fullName'] as String? ??
                  data['email'] as String? ??
                  docs[index].id;

              return ListTile(
                title: Text(
                  name,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  '${l10n.roleLabel}: ${role.value} · ${data['email'] ?? ''}',
                  style: const TextStyle(fontFamily: 'Cairo', fontSize: 12),
                ),
                trailing: GestureDetector(
                  onTap: () => _showRoleDialog(context, docs[index].id, role),
                  child: Chip(
                    label: Text(role.value, style: const TextStyle(fontSize: 11)),
                    backgroundColor: _roleColor(role),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
