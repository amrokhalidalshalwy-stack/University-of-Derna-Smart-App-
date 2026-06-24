/// HifdhTracker — Profile & Settings Tab.
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_project/features/hifzh/core/theme/hifzh_theme.dart';
import 'package:flutter_project/features/hifzh/core/constants/hifzh_strings.dart';
import 'package:flutter_project/features/hifzh/core/di/hifzh_injection.dart';
import 'package:flutter_project/features/hifzh/presentation/bloc/auth/auth_cubit.dart';
import 'package:flutter_project/features/hifzh/presentation/bloc/auth/auth_state.dart';
import 'package:flutter_project/features/hifzh/presentation/bloc/quran/quran_state.dart';
import 'package:flutter_project/features/hifzh/domain/models/surah_model.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_project/features/hifzh/core/router/hifzh_router.dart';

/// Profile and settings tab for the authenticated user.
class HifzhProfileTab extends StatelessWidget {
  /// Creates a [HifzhProfileTab].
  const HifzhProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      bloc: getIt<AuthCubit>(),
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          context.go(HifzhRoutes.login);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.all(10),
            child: SizedBox(
              height: 40,
              child: Image.asset(
                'assets/images/university_logo.png',
                fit: BoxFit.contain,
                errorBuilder:
                    (_, e, s) => const Icon(
                      Icons.school_rounded,
                      color: AppColors.onPrimary,
                    ),
              ),
            ),
          ),
          title: Text(
            HifzhStrings.myProfile,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: AppColors.onPrimary),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // ── Avatar + Name ───────────────────────────────────────────
              _ProfileHeader()
                  .animate()
                  .fadeIn(duration: 500.ms)
                  .slideY(begin: 0.06),

              const SizedBox(height: 24),

              // ── Stats Row ───────────────────────────────────────────────
              _StatsRow().animate().fadeIn(delay: 150.ms, duration: 500.ms),

              const SizedBox(height: 24),

              // ── Achievements Section ─────────────────────────────────────
              _SectionHeader(
                title: HifzhStrings.achievements,
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 12),
              _AchievementsGrid().animate().fadeIn(
                delay: 250.ms,
                duration: 500.ms,
              ),

              const SizedBox(height: 24),

              // ── Settings Section ─────────────────────────────────────────
              _SectionHeader(
                title: HifzhStrings.settings,
              ).animate().fadeIn(delay: 300.ms),
              const SizedBox(height: 12),
              _SettingsTile(
                icon: Icons.language_rounded,
                label: 'اللغة',
                trailing: const Text(
                  'العربية',
                  style: TextStyle(fontFamily: 'Cairo'),
                ),
                onTap: () {},
              ).animate().fadeIn(delay: 320.ms),
              _SettingsTile(
                icon: Icons.notifications_outlined,
                label: 'الإشعارات',
                trailing: Switch(
                  value: true,
                  onChanged: (_) {},
                  activeThumbColor: AppColors.secondary,
                ),
                onTap: () {},
              ).animate().fadeIn(delay: 340.ms),
              _SettingsTile(
                icon: Icons.dark_mode_outlined,
                label: 'الوضع الليلي',
                trailing: Switch(
                  value: false,
                  onChanged: (_) {},
                  activeThumbColor: AppColors.secondary,
                ),
                onTap: () {},
              ).animate().fadeIn(delay: 360.ms),
              _SettingsTile(
                icon: Icons.info_outline_rounded,
                label: 'عن التطبيق',
                onTap: () {},
              ).animate().fadeIn(delay: 380.ms),

              const SizedBox(height: 24),

              // ── Sign Out ─────────────────────────────────────────────────
              OutlinedButton.icon(
                key: const Key('hifzh_signout_btn'),
                onPressed: () => getIt<AuthCubit>().signOut(),
                icon: const Icon(Icons.logout_rounded, color: AppColors.error),
                label: Text(
                  HifzhStrings.signOut,
                  style: const TextStyle(color: AppColors.error),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.error),
                ),
              ).animate().fadeIn(delay: 420.ms),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Profile Header ────────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      bloc: getIt<AuthCubit>(),
      builder: (context, state) {
        final user = state is AuthAuthenticated ? state.user : null;
        final parts = (user?.name ?? 'G').split(' ');
        final initials =
            parts.length >= 2
                ? '${parts.first[0]}${parts.last[0]}'.toUpperCase()
                : parts.first[0].toUpperCase();

        return Column(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.primaryGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: const TextStyle(
                        fontSize: 36,
                        color: AppColors.onPrimary,
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Container(
                  decoration: const BoxDecoration(
                    color: AppColors.secondary,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.edit_rounded,
                      color: AppColors.onPrimary,
                      size: 16,
                    ),
                    onPressed: () {},
                    padding: const EdgeInsets.all(6),
                    constraints: const BoxConstraints(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              user?.name ?? 'Guest',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 4),
            Text(
              user?.email ?? '',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
          ],
        );
      },
    );
  }
}

// ── Stats Row ─────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final quranState = HifzhInjection.instance.createQuranCubit().state;
    int pagesMemorized = 0;
    if (quranState is QuranLoaded) {
      pagesMemorized = quranState.surahs
          .where((s) => s.status == MemorizationStatus.memorized || s.status == MemorizationStatus.mastered)
          .length;
    }

    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('hifzh_progress').doc(uid).snapshots(),
      builder: (context, snapshot) {
        int streak = 0;
        int weeklyGoal = 5;

        if (snapshot.connectionState == ConnectionState.active || snapshot.hasData) {
          if (snapshot.hasData && snapshot.data!.exists) {
            final data = snapshot.data!.data() as Map<String, dynamic>;
            streak = data['streak'] as int? ?? 0;
            weeklyGoal = data['weekly_goal'] as int? ?? 5;
          }
        }

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.onSurface.withValues(alpha: 0.06)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatItem(value: '$pagesMemorized', label: HifzhStrings.pagesMemorized),
              _Divider(),
              _StatItem(value: '$streak', label: HifzhStrings.streakLabel),
              _Divider(),
              _StatItem(value: '$weeklyGoal', label: HifzhStrings.weeklyGoal),
            ],
          ),
        );
      },
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AppColors.secondary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          textDirection: TextDirection.rtl,
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: 1,
      color: AppColors.onSurface.withValues(alpha: 0.08),
    );
  }
}

// ── Achievements Grid ─────────────────────────────────────────────────────────

class _AchievementsGrid extends StatelessWidget {
  static const _badges = [
    (icon: Icons.military_tech_rounded, label: 'أول سبع آيات', earned: true),
    (
      icon: Icons.workspace_premium_rounded,
      label: 'حافظ الفاتحة',
      earned: true,
    ),
    (
      icon: Icons.local_fire_department_rounded,
      label: '7 أيام متتالية',
      earned: true,
    ),
    (icon: Icons.star_rounded, label: 'حافظ جزء عم', earned: false),
    (icon: Icons.verified_rounded, label: 'إتقان الإخلاص', earned: true),
    (icon: Icons.emoji_events_rounded, label: 'المتصدر', earned: false),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: _badges.length,
      itemBuilder: (context, i) {
        final badge = _badges[i];
        return _BadgeTile(
          icon: badge.icon,
          label: badge.label,
          earned: badge.earned,
        );
      },
    );
  }
}

class _BadgeTile extends StatelessWidget {
  const _BadgeTile({
    required this.icon,
    required this.label,
    required this.earned,
  });
  final IconData icon;
  final String label;
  final bool earned;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: earned ? AppColors.accentGoldLight : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              earned
                  ? AppColors.accentGold.withValues(alpha: 0.4)
                  : AppColors.onSurface.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 36,
            color: earned ? AppColors.accentGold : AppColors.textHint,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              label,
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: earned ? AppColors.onSurface : AppColors.textHint,
                fontWeight: earned ? FontWeight.w600 : FontWeight.normal,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section Header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        textDirection: TextDirection.rtl,
      ),
    );
  }
}

// ── Settings Tile ─────────────────────────────────────────────────────────────

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.label,
    this.trailing,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.onSurface.withValues(alpha: 0.06)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryLight.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        title: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
          textDirection: TextDirection.rtl,
        ),
        trailing:
            trailing ??
            const Icon(Icons.chevron_right_rounded, color: AppColors.textHint),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
