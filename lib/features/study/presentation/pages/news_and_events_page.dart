import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_project/core/theme/app_theme.dart';
import 'package:flutter_project/l10n/app_localizations.dart';

class NewsAndEventsPage extends StatelessWidget {
  const NewsAndEventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.departmentNewsTitle,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildNewsCard(
            context,
            icon: Icons.science,
            title: l10n.newsResearchTitle,
            description: l10n.newsResearchDescription,
            date: l10n.newsResearchDate,
            l10n: l10n,
          ).animate().fadeIn().slideX(begin: -0.1),
          const SizedBox(height: 16),
          _buildNewsCard(
            context,
            icon: Icons.psychology,
            title: l10n.newsAiSeminarTitle,
            description: l10n.newsAiSeminarDescription,
            date: l10n.newsAiSeminarDate,
            l10n: l10n,
          ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.1),
          const SizedBox(height: 16),
          _buildNewsCard(
            context,
            icon: Icons.event_note,
            title: l10n.newsExamsTitle,
            description: l10n.newsExamsDescription,
            date: l10n.newsExamsDate,
            l10n: l10n,
          ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1),
        ],
      ),
    );
  }

  Widget _buildNewsCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required String date,
    required AppLocalizations l10n,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo',
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    textAlign: TextAlign.start,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontFamily: 'Cairo',
                      height: 1.5,
                    ),
                    textAlign: TextAlign.start,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        date,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                          fontFamily: 'Cairo',
                        ),
                        textAlign: TextAlign.start,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
