import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_project/features/auth/data/auth_service.dart';
import 'package:flutter_project/features/auth/data/cached_user_profile_provider.dart';
import 'package:flutter_project/l10n/app_localizations.dart';
import 'package:flutter_project/features/faculty/presentation/utils/faculty_assignments_navigation.dart';

class FacultyDrawer extends ConsumerWidget {
  const FacultyDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(authStateChangesProvider).value;
    final userDataAsync = ref.watch(userDataProvider(user?.uid ?? ''));

    final drawerBackgroundColor = const Color(0xFF132220);
    final textColor = const Color(0xFFE8E8E8);
    final iconColor = const Color(0xFFE8E8E8);

    return Drawer(
      backgroundColor: drawerBackgroundColor,
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: const [
                  Color(0xFF132220),
                  Color(0xFF1A2E2C),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: const Color(0xFF1A2E2C),
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: const Color(0xFF10B981),
                    ),
                  ),
                  const SizedBox(height: 12),
                  userDataAsync.when(
                    data: (profile) {
                      final fullName =
                          profile?['fullName'] as String? ?? l10n.facultyMember;
                      return Text(
                        fullName,
                        style: const TextStyle(
                          color: Color(0xFFE8E8E8),
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      );
                    },
                    loading:
                        () => const CircularProgressIndicator(
                          color: Color(0xFF10B981),
                        ),
                    error:
                        (_, _) => const Text(
                          'Error',
                          style: TextStyle(color: Color(0xFFE8E8E8)),
                        ),
                  ),
                ],
              ),
            ),
          ),
          _DrawerItem(
            icon: Icons.person_outline,
            title: l10n.profileTitle,
            iconColor: iconColor,
            textColor: textColor,
            onTap: () {
              context.pop();
              context.push('/faculty/profile');
            },
          ),
          _DrawerItem(
            icon: Icons.calendar_month_outlined,
            title: l10n.scheduleTitle,
            iconColor: iconColor,
            textColor: textColor,
            onTap: () {
              context.pop();
              context.push('/faculty/schedule');
            },
          ),
          _DrawerItem(
            icon: Icons.fact_check_outlined,
            title: l10n.attendanceSheetTitle,
            iconColor: iconColor,
            textColor: textColor,
            onTap: () {
              context.pop();
              context.push('/faculty/attendance');
            },
          ),
          _DrawerItem(
            icon: Icons.group_outlined,
            title: l10n.studentsTitle,
            iconColor: iconColor,
            textColor: textColor,
            onTap: () {
              context.pop();
              context.push('/faculty/students');
            },
          ),
          _DrawerItem(
            icon: Icons.assignment_outlined,
            title: l10n.assignmentsTitle,
            iconColor: iconColor,
            textColor: textColor,
            onTap: () {
              context.pop();
              openFacultyAssignments(context, ref);
            },
          ),
          _DrawerItem(
            icon: Icons.bar_chart_outlined,
            title: l10n.reportsTitle,
            iconColor: iconColor,
            textColor: textColor,
            onTap: () {
              context.pop();
              context.push('/faculty/reports');
            },
          ),
          Divider(
            color: const Color(0xFF10B981).withValues(alpha: 0.3),
          ),
          _DrawerItem(
            icon: Icons.settings_outlined,
            title: l10n.settingsTitle,
            iconColor: iconColor,
            textColor: textColor,
            onTap: () {
              context.pop();
              context.push('/faculty/settings');
            },
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color iconColor;
  final Color textColor;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.iconColor,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final splashColor = const Color(0x1A10B981);

    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'Cairo',
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
      onTap: onTap,
      splashColor: splashColor,
    );
  }
}
