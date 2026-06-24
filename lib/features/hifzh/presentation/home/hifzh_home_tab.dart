library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_project/features/hifzh/core/theme/hifzh_theme.dart';
import 'package:flutter_project/features/hifzh/core/constants/hifzh_strings.dart';
import 'package:flutter_project/features/hifzh/core/router/hifzh_router.dart';
import 'package:flutter_project/features/hifzh/core/di/hifzh_injection.dart';
import 'package:flutter_project/features/hifzh/domain/models/revision_session_model.dart';
import 'package:flutter_project/features/hifzh/domain/models/surah_model.dart';
import 'package:flutter_project/features/hifzh/presentation/bloc/revision/revision_cubit.dart';
import 'package:flutter_project/features/hifzh/presentation/bloc/revision/revision_state.dart';
import 'package:flutter_project/features/hifzh/presentation/bloc/quran/quran_state.dart';

class HifzhHomeTab extends StatefulWidget {
  const HifzhHomeTab({super.key});

  @override
  State<HifzhHomeTab> createState() => _HifzhHomeTabState();
}

class _HifzhHomeTabState extends State<HifzhHomeTab>
    with SingleTickerProviderStateMixin {
  late final RevisionCubit _revisionCubit;
  late final AnimationController _shimmerCtrl;

  @override
  void initState() {
    super.initState();
    _revisionCubit =
        HifzhInjection.instance.createRevisionCubit()..loadDueSessions();
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _revisionCubit.close();
    _shimmerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quranState = HifzhInjection.instance.createQuranCubit().state;
    int pagesMemorized = 0;
    if (quranState is QuranLoaded) {
      pagesMemorized =
          quranState.surahs
              .where(
                (s) =>
                    s.status == MemorizationStatus.memorized ||
                    s.status == MemorizationStatus.mastered,
              )
              .length;
    }

    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return StreamBuilder<DocumentSnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('hifzh_progress')
              .doc(uid)
              .snapshots(),
      builder: (context, snapshot) {
        int streak = 0;
        int weeklyPages = 0;
        int weeklyGoal = 5;

        if (snapshot.connectionState == ConnectionState.active ||
            snapshot.hasData) {
          if (!snapshot.hasData || !snapshot.data!.exists) {
            if (uid.isNotEmpty) {
              FirebaseFirestore.instance
                  .collection('hifzh_progress')
                  .doc(uid)
                  .set({
                    'uid': uid,
                    'streak': 0,
                    'weekly_pages': 0,
                    'weekly_goal': 5,
                    'total_pages': 0,
                    'last_session': FieldValue.serverTimestamp(),
                    'updated_at': FieldValue.serverTimestamp(),
                  }, SetOptions(merge: true));
            }
          } else {
            final data = snapshot.data!.data() as Map<String, dynamic>;
            streak = data['streak'] as int? ?? 0;
            weeklyPages = data['weekly_pages'] as int? ?? 0;
            weeklyGoal = data['weekly_goal'] as int? ?? 5;
          }
        }

        return BlocProvider.value(
          value: _revisionCubit,
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
                HifzhStrings.todayTab,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: AppColors.onPrimary),
              ),
              actions: [
                IconButton(
                  icon: const Icon(
                    Icons.notifications_none_rounded,
                    color: AppColors.onPrimary,
                  ),
                  onPressed: () {},
                ),
              ],
            ),
            body: RefreshIndicator(
              color: AppColors.secondary,
              onRefresh: () async => _revisionCubit.loadDueSessions(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _GreetingCard(
                      streak: streak,
                      pagesMemorized: pagesMemorized,
                    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.08),
                    const SizedBox(height: 20),
                    _WeeklyProgressCard(
                      weeklyPages: weeklyPages,
                      weeklyGoal: weeklyGoal,
                    ).animate().fadeIn(delay: 150.ms, duration: 500.ms),
                    const SizedBox(height: 24),
                    Text(
                      HifzhStrings.dueTodayTitle,
                      style: Theme.of(context).textTheme.titleLarge,
                      textDirection: TextDirection.rtl,
                    ).animate().fadeIn(delay: 200.ms),
                    const SizedBox(height: 12),
                    BlocBuilder<RevisionCubit, RevisionState>(
                      builder: (context, state) {
                        if (state is RevisionLoading ||
                            state is RevisionInitial) {
                          return Column(
                            children: List.generate(
                              3,
                              (index) => FadeTransition(
                                opacity: Tween<double>(
                                  begin: 0.4,
                                  end: 1.0,
                                ).animate(_shimmerCtrl),
                                child: Container(
                                  height: 80,
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: AppColors.onSurface.withValues(
                                        alpha: 0.06,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        } else if (state is RevisionReady) {
                          final due =
                              state.sessions
                                  .where((s) => s.isDueToday)
                                  .toList();
                          if (due.isEmpty) {
                            return _EmptyReviewState().animate().fadeIn(
                              delay: 250.ms,
                            );
                          }
                          return Column(
                            children:
                                due
                                    .asMap()
                                    .entries
                                    .map(
                                      (e) => _RevisionSessionCard(
                                            session: e.value,
                                            index: e.key,
                                          )
                                          .animate()
                                          .fadeIn(delay: (250 + e.key * 80).ms)
                                          .slideX(begin: 0.04),
                                    )
                                    .toList(),
                          );
                        } else if (state is RevisionComplete) {
                          return _EmptyReviewState().animate().fadeIn(
                            delay: 250.ms,
                          );
                        } else if (state is RevisionError) {
                          return Center(
                            child: Column(
                              children: [
                                Text(
                                  state.message,
                                  style: const TextStyle(color: Colors.red),
                                ),
                                ElevatedButton(
                                  onPressed:
                                      () => _revisionCubit.loadDueSessions(),
                                  child: const Text('إعادة المحاولة'),
                                ),
                              ],
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ); // ← نهاية StreamBuilder builder
      },
    ); // ← نهاية StreamBuilder
  } // ← نهاية build
} // ← نهاية _HifzhHomeTabState

// ── Greeting Card ─────────────────────────────────────────────────────────────

class _GreetingCard extends StatelessWidget {
  const _GreetingCard({required this.streak, required this.pagesMemorized});

  final int streak;
  final int pagesMemorized;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      HifzhStrings.todayGreeting,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(color: AppColors.onPrimary),
                      textDirection: TextDirection.rtl,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      HifzhStrings.todaySubtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.onPrimary.withValues(alpha: 0.75),
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.accentGold.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.accentGold,
                  size: 32,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _StatChip(
                value: '$streak',
                label: HifzhStrings.streakLabel,
                icon: Icons.local_fire_department_rounded,
                color: AppColors.accentGold,
              ),
              const SizedBox(width: 12),
              _StatChip(
                value: '$pagesMemorized',
                label: HifzhStrings.pagesMemorized,
                icon: Icons.menu_book_rounded,
                color: AppColors.secondary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.onPrimary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.onPrimary.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Weekly Progress Card ──────────────────────────────────────────────────────

class _WeeklyProgressCard extends StatelessWidget {
  const _WeeklyProgressCard({
    required this.weeklyPages,
    required this.weeklyGoal,
  });

  final int weeklyPages;
  final int weeklyGoal;

  @override
  Widget build(BuildContext context) {
    final progress = weeklyGoal == 0 ? 0.0 : weeklyPages / weeklyGoal;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                HifzhStrings.weeklyProgress,
                style: Theme.of(context).textTheme.titleMedium,
                textDirection: TextDirection.rtl,
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.secondaryLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$weeklyPages / $weeklyGoal ${HifzhStrings.pagesMemorized}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: AppColors.secondaryLight,
              valueColor: const AlwaysStoppedAnimation(AppColors.secondary),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(progress * 100).toStringAsFixed(0)}% من الهدف الأسبوعي',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            textDirection: TextDirection.rtl,
          ),
        ],
      ),
    );
  }
}

// ── Revision Session Card ─────────────────────────────────────────────────────

class _RevisionSessionCard extends StatelessWidget {
  const _RevisionSessionCard({required this.session, required this.index});

  final RevisionSessionModel session;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.onSurface.withValues(alpha: 0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            context.go('${HifzhRoutes.home}/revision/${session.id}');
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color:
                        session.easeFactor >= 2.5
                            ? AppColors.statusMastered
                            : session.easeFactor >= 1.8
                            ? AppColors.statusMemorized
                            : AppColors.statusNotStarted,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      '${session.pageNumber}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'صفحة ${session.pageNumber} — سورة ${session.surahNumber}',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                        textDirection: TextDirection.rtl,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.repeat_rounded,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${session.repetitions} مراجعات • معامل السهولة '
                            '${session.easeFactor.toStringAsFixed(1)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'ابدأ',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────

class _EmptyReviewState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.secondaryLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.check_circle_outline_rounded,
            size: 64,
            color: AppColors.secondary,
          ),
          const SizedBox(height: 16),
          Text(
            HifzhStrings.noReviewsDue,
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.secondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
