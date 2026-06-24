import 'package:flutter/material.dart';
import 'package:flutter_project/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

/// Support hub — Batch 10.
class SupportHubPage extends StatelessWidget {
  const SupportHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.supportTitle,
          style: const TextStyle(fontFamily: 'Cairo'),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FilledButton.icon(
              onPressed: () => context.push('/support'),
              icon: const Icon(Icons.confirmation_number_outlined),
              label: Text(
                l10n.supportTicketButton,
                style: const TextStyle(fontFamily: 'Cairo'),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => context.push('/report-issue'),
              icon: const Icon(Icons.bug_report_outlined),
              label: Text(
                l10n.reportProblemButton,
                style: const TextStyle(fontFamily: 'Cairo'),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.push('/help'),
              child: Text(
                l10n.helpCenterTitle,
                style: const TextStyle(fontFamily: 'Cairo'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
