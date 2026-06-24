/// HifdhTracker — Halaqah (Study Circle) Tab.
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_project/features/hifzh/core/theme/hifzh_theme.dart';
import 'package:flutter_project/features/hifzh/core/constants/hifzh_strings.dart';
import 'package:flutter_project/features/hifzh/domain/models/halaqah_model.dart';
import 'package:flutter_project/features/hifzh/core/di/hifzh_injection.dart';
import 'package:flutter_project/features/hifzh/presentation/bloc/halaqah/halaqah_cubit.dart';
import 'package:flutter_project/features/hifzh/presentation/bloc/halaqah/halaqah_state.dart';

// ── Main Widget ───────────────────────────────────────────────────────────────

/// Halaqah (study circle) tab — shows group info and leaderboard.
class HifzhHalaqahTab extends StatefulWidget {
  /// Creates a [HifzhHalaqahTab].
  const HifzhHalaqahTab({super.key});

  @override
  State<HifzhHalaqahTab> createState() => _HifzhHalaqahTabState();
}

class _HifzhHalaqahTabState extends State<HifzhHalaqahTab> {
  late final HalaqahCubit _halaqahCubit;

  @override
  void initState() {
    super.initState();
    _halaqahCubit =
        HifzhInjection.instance.createHalaqahCubit()
          ..loadHalaqah('stub_halaqah_1');
  }

  @override
  void dispose() {
    _halaqahCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _halaqahCubit,
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
            HifzhStrings.halaqahTab,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: AppColors.onPrimary),
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.add_circle_outline_rounded,
                color: AppColors.onPrimary,
              ),
              onPressed: () => _showJoinDialog(context),
              tooltip: HifzhStrings.joinHalaqah,
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Leaderboard List ──────────────────────────────────────────
              BlocBuilder<HalaqahCubit, HalaqahState>(
                builder: (context, state) {
                  if (state is HalaqahLoading || state is HalaqahInitial) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is HalaqahError) {
                    return Center(
                      child: Column(
                        children: [
                          Text(
                            state.message,
                            style: const TextStyle(color: Colors.red),
                          ),
                          ElevatedButton(
                            onPressed:
                                () =>
                                    _halaqahCubit.loadHalaqah('stub_halaqah_1'),
                            child: const Text('إعادة المحاولة'),
                          ),
                        ],
                      ),
                    );
                  } else if (state is HalaqahLoaded) {
                    final students =
                        state.halaqah.members
                            .where((m) => m.role == HalaqahRole.student)
                            .toList()
                          ..sort(
                            (a, b) =>
                                b.pagesThisWeek.compareTo(a.pagesThisWeek),
                          );

                    return Column(
                      children: [
                        _HalaqahInfoCard(halaqah: state.halaqah)
                            .animate()
                            .fadeIn(duration: 500.ms)
                            .slideY(begin: 0.06),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            const Icon(
                              Icons.emoji_events_rounded,
                              color: AppColors.accentGold,
                              size: 22,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              HifzhStrings.leaderboard,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        ).animate().fadeIn(delay: 150.ms),
                        const SizedBox(height: 12),
                        ...students.asMap().entries.map(
                          (e) => _LeaderboardTile(
                            member: e.value,
                            rank: e.key + 1,
                            index: e.key,
                          ),
                        ),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _showJoinDialog(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog<void>(
      context: context,
      builder:
          (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              HifzhStrings.joinHalaqah,
              style: Theme.of(context).textTheme.titleLarge,
              textDirection: TextDirection.rtl,
            ),
            content: TextFormField(
              controller: ctrl,
              textDirection: TextDirection.ltr,
              decoration: InputDecoration(
                labelText: HifzhStrings.enterInviteCode,
                prefixIcon: const Icon(Icons.vpn_key_outlined),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(HifzhStrings.cancel),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('جاري الانضمام بالرمز: ${ctrl.text}'),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(100, 44),
                ),
                child: const Text(HifzhStrings.confirm),
              ),
            ],
          ),
    );
  }
}

// ── Halaqah Info Card ─────────────────────────────────────────────────────────

class _HalaqahInfoCard extends StatelessWidget {
  const _HalaqahInfoCard({required this.halaqah});
  final HalaqahModel halaqah;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.people_rounded,
                color: AppColors.accentGold,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  halaqah.name,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(color: AppColors.onPrimary),
                  textDirection: TextDirection.rtl,
                ),
              ),
            ],
          ),
          if (halaqah.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              halaqah.description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.onPrimary.withValues(alpha: 0.75),
              ),
              textDirection: TextDirection.rtl,
            ),
          ],
          const SizedBox(height: 16),
          // Stats Row
          Row(
            children: [
              _InfoBadge(
                icon: Icons.people_alt_outlined,
                label: '${halaqah.memberCount} ${HifzhStrings.memberCount}',
              ),
              const SizedBox(width: 10),
              _InfoBadge(
                icon: Icons.vpn_key_outlined,
                label: halaqah.inviteCode,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  const _InfoBadge({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.onPrimary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.accentGold, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Leaderboard Tile ──────────────────────────────────────────────────────────

class _LeaderboardTile extends StatelessWidget {
  const _LeaderboardTile({
    required this.member,
    required this.rank,
    required this.index,
  });
  final HalaqahMember member;
  final int rank;
  final int index;

  Color _rankColor(BuildContext context) {
    switch (rank) {
      case 1:
        return AppColors.accentGold;
      case 2:
        return Theme.of(context).colorScheme.onSurfaceVariant;
      case 3:
        return Theme.of(context).colorScheme.tertiary;
      default:
        return AppColors.textHint;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: rank == 1 ? AppColors.accentGoldLight : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              rank == 1
                  ? AppColors.accentGold.withValues(alpha: 0.3)
                  : AppColors.onSurface.withValues(alpha: 0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Rank badge
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _rankColor(context).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$rank',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: _rankColor(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: Text(
              member.displayName.isNotEmpty ? member.displayName[0] : '؟',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Name + streak
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.displayName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textDirection: TextDirection.rtl,
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.local_fire_department_rounded,
                      size: 14,
                      color: AppColors.accentGold,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '${member.currentStreak} ${HifzhStrings.streakLabel}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Pages this week
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${member.pagesThisWeek}',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                HifzhStrings.pagesThisWeek,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                ),
                textDirection: TextDirection.rtl,
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: (200 + index * 70).ms).slideX(begin: 0.04);
  }
}
