import 'package:flutter/material.dart';
import 'package:flutter_project/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

/// Help center hub — Batch 10.
class HelpCenterPage extends StatelessWidget {
  const HelpCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.helpCenterTitle,
          style: const TextStyle(fontFamily: 'Cairo'),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _HelpTile(
            icon: Icons.quiz_outlined,
            label: l10n.faqTitle,
            onTap: () => context.push('/faq'),
          ),
          _HelpTile(
            icon: Icons.support_agent_outlined,
            label: l10n.supportTitle,
            onTap: () => context.push('/support'),
          ),
          _HelpTile(
            icon: Icons.contact_mail_outlined,
            label: l10n.contactUsTitle,
            onTap: () => context.push('/contact'),
          ),
          _HelpTile(
            icon: Icons.report_problem_outlined,
            label: l10n.reportProblemButton,
            onTap: () => context.push('/report-issue'),
          ),
        ],
      ),
    );
  }
}

class _HelpTile extends StatelessWidget {
  const _HelpTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon),
        title: Text(label, style: const TextStyle(fontFamily: 'Cairo')),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}
