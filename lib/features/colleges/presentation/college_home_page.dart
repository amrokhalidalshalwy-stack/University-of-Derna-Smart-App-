import 'package:flutter/material.dart';
import 'package:flutter_project/core/colleges/college_registry.dart';
import 'package:flutter_project/l10n/app_localizations.dart';

String? _localizedCampus(CollegeDefinition college, AppLocalizations l10n) {
  final raw = college.campusAr;
  if (raw == null) return null;
  if (raw == 'القبة') return l10n.campusQubbah;
  if (raw == 'درنة') return l10n.campusDerna;
  return raw;
}

class CollegeHomePage extends StatelessWidget {
  const CollegeHomePage({super.key, required this.college});

  final CollegeDefinition college;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    final collegeName = isAr ? college.nameAr : college.nameEn;
    final campusName = _localizedCampus(college, l10n);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: college.backgroundColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(college.icon, size: 48, color: college.primaryColor),
                const SizedBox(height: 12),
                Text(
                  collegeName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: college.primaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isAr ? college.nameEn : college.nameAr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                if (campusName != null) ...[
                  const SizedBox(height: 8),
                  Chip(
                    label: Text(
                      l10n.collegeCampusLabel(campusName),
                      style: const TextStyle(fontFamily: 'Cairo'),
                    ),
                    backgroundColor: Colors.white.withValues(alpha: 0.8),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.collegeWelcomeTitle(collegeName),
            style: theme.textTheme.titleMedium?.copyWith(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.collegeWelcomeSubtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontFamily: 'Cairo',
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
