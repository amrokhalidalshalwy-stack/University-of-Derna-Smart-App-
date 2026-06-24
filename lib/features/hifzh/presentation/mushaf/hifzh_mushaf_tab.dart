/// HifdhTracker — Mushaf (Quran Browser) Tab.
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_project/features/hifzh/core/theme/hifzh_theme.dart';
import 'package:flutter_project/features/hifzh/core/constants/hifzh_strings.dart';
import 'package:flutter_project/features/hifzh/domain/models/surah_model.dart';
import 'package:flutter_project/features/hifzh/core/di/hifzh_injection.dart';
import 'package:flutter_project/features/hifzh/presentation/bloc/quran/quran_cubit.dart';
import 'package:flutter_project/features/hifzh/presentation/bloc/quran/quran_state.dart';

/// Mushaf browser tab — shows all 114 Surahs with memorization status.
class HifzhMushafTab extends StatefulWidget {
  /// Creates a [HifzhMushafTab].
  const HifzhMushafTab({super.key, this.initialSurah});

  /// If provided, the tab will open this Surah's detail view immediately.
  final int? initialSurah;

  @override
  State<HifzhMushafTab> createState() => _HifzhMushafTabState();
}

class _HifzhMushafTabState extends State<HifzhMushafTab> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _filter = 'all'; // 'all' | 'meccan' | 'medinan'

  late final QuranCubit _quranCubit;

  @override
  void initState() {
    super.initState();
    _quranCubit = HifzhInjection.instance.createQuranCubit()..loadSurahs();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _quranCubit.close();
    super.dispose();
  }

  Color _statusColor(MemorizationStatus s) {
    switch (s) {
      case MemorizationStatus.mastered:
        return AppColors.statusMastered;
      case MemorizationStatus.memorized:
        return AppColors.statusMemorized;
      case MemorizationStatus.inProgress:
        return AppColors.statusInProgress;
      case MemorizationStatus.notStarted:
        return AppColors.statusNotStarted;
    }
  }

  String _statusLabel(MemorizationStatus s) {
    switch (s) {
      case MemorizationStatus.mastered:
        return HifzhStrings.statusMastered;
      case MemorizationStatus.memorized:
        return HifzhStrings.statusMemorized;
      case MemorizationStatus.inProgress:
        return HifzhStrings.statusInProgress;
      case MemorizationStatus.notStarted:
        return HifzhStrings.statusNotStarted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _quranCubit,
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
            HifzhStrings.mushafTab,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: AppColors.onPrimary),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) {
                  _quranCubit.searchSurahs(v);
                },
                textDirection: TextDirection.rtl,
                style: const TextStyle(color: AppColors.onPrimary),
                decoration: InputDecoration(
                  hintText: HifzhStrings.searchSurah,
                  hintStyle: TextStyle(
                    color: AppColors.onPrimary.withValues(alpha: 0.5),
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: AppColors.onPrimary.withValues(alpha: 0.7),
                  ),
                  filled: true,
                  fillColor: AppColors.onPrimary.withValues(alpha: 0.12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            // ── Filter Chips ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  _FilterChip(
                    label: HifzhStrings.allSurahs,
                    selected: _filter == 'all',
                    onTap: () => setState(() => _filter = 'all'),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: HifzhStrings.meccan,
                    selected: _filter == 'meccan',
                    onTap: () => setState(() => _filter = 'meccan'),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: HifzhStrings.medinan,
                    selected: _filter == 'medinan',
                    onTap: () => setState(() => _filter = 'medinan'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Surah List ──────────────────────────────────────────────────
            Expanded(
              child: BlocBuilder<QuranCubit, QuranState>(
                builder: (context, state) {
                  if (state is QuranLoading || state is QuranInitial) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is QuranError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            state.message,
                            style: const TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => _quranCubit.loadSurahs(),
                            child: const Text('إعادة المحاولة'),
                          ),
                        ],
                      ),
                    );
                  } else if (state is QuranLoaded) {
                    // Apply local filter on top of Cubit state if necessary
                    final surahs =
                        state.surahs.where((s) {
                          final matchesFilter =
                              _filter == 'all' ||
                              (_filter == 'meccan' &&
                                  s.revelationType == 'Meccan') ||
                              (_filter == 'medinan' &&
                                  s.revelationType == 'Medinan');
                          return matchesFilter;
                        }).toList();

                    if (surahs.isEmpty) {
                      return const Center(child: Text('لا توجد سور مطابقة'));
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      itemCount: surahs.length,
                      itemBuilder: (context, index) {
                        final surah = surahs[index];
                        return _SurahListTile(
                          surah: surah,
                          statusColor: _statusColor(surah.status),
                          statusLabel: _statusLabel(surah.status),
                          index: index,
                        );
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Filter Chip ───────────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppColors.secondary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.secondary : AppColors.textHint,
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: selected ? AppColors.onPrimary : AppColors.textSecondary,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

// ── Surah List Tile ───────────────────────────────────────────────────────────

class _SurahListTile extends StatelessWidget {
  const _SurahListTile({
    required this.surah,
    required this.statusColor,
    required this.statusLabel,
    required this.index,
  });
  final SurahModel surah;
  final Color statusColor;
  final String statusLabel;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.onSurface.withValues(alpha: 0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Surah number circle
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.accentGoldLight,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${surah.number}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.accentGold,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Names
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        surah.nameArabic,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                        textDirection: TextDirection.rtl,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${surah.nameTransliteration} • ${surah.ayahCount} ${HifzhStrings.ayahs} • ${surah.revelationType == "Meccan" ? HifzhStrings.meccan : HifzhStrings.medinan}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Progress bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: surah.progressPercent,
                          minHeight: 5,
                          backgroundColor: statusColor.withValues(alpha: 0.15),
                          valueColor: AlwaysStoppedAnimation(statusColor),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                // Status badge with PopupMenu
                PopupMenuButton<MemorizationStatus>(
                  onSelected: (status) {
                    context.read<QuranCubit>().updateStatus(
                      surah.number,
                      status,
                    );
                  },
                  itemBuilder:
                      (context) =>
                          MemorizationStatus.values
                              .map(
                                (status) => PopupMenuItem(
                                  value: status,
                                  child: Text(
                                    status == MemorizationStatus.mastered
                                        ? HifzhStrings.statusMastered
                                        : status == MemorizationStatus.memorized
                                        ? HifzhStrings.statusMemorized
                                        : status ==
                                            MemorizationStatus.inProgress
                                        ? HifzhStrings.statusInProgress
                                        : HifzhStrings.statusNotStarted,
                                  ),
                                ),
                              )
                              .toList(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          statusLabel,
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_drop_down,
                          color: statusColor,
                          size: 14,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: (index * 40).ms).slideY(begin: 0.04);
  }
}
