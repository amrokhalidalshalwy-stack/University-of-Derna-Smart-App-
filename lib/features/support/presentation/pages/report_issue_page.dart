import 'package:flutter/material.dart';
import 'package:flutter_project/l10n/app_localizations.dart';

/// Report a problem — Batch 10 localized.
class ReportIssuePage extends StatefulWidget {
  const ReportIssuePage({super.key});

  @override
  State<ReportIssuePage> createState() => _ReportIssuePageState();
}

class _ReportIssuePageState extends State<ReportIssuePage> {
  final _formKey = GlobalKey<FormState>();
  final _issueController = TextEditingController();

  @override
  void dispose() {
    _issueController.dispose();
    super.dispose();
  }

  void _submitIssue() {
    if (_formKey.currentState!.validate()) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.supportSent)));
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.reportProblemButton,
          style: const TextStyle(fontFamily: 'Cairo'),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.supportMessage,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontFamily: 'Cairo',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _issueController,
                maxLines: 6,
                decoration: InputDecoration(
                  hintText: l10n.supportMessage,
                  hintStyle: const TextStyle(fontFamily: 'Cairo'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.supportMessageRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitIssue,
                child: Text(
                  l10n.reportProblemButton,
                  style: const TextStyle(fontFamily: 'Cairo'),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.maybePop(context),
                child: Text(
                  l10n.cancelButton,
                  style: const TextStyle(fontFamily: 'Cairo'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
