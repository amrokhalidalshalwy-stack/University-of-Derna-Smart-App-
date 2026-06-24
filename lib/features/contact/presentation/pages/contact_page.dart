import 'package:flutter/material.dart';
import 'package:flutter_project/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

/// Contact us — Batch 10.
class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  static const _supportEmail = 'support@uod.edu.ly';
  static const _supportPhone = '+218910000000';

  Future<void> _launch(Uri uri) async {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.contactUsTitle,
          style: const TextStyle(fontFamily: 'Cairo'),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              leading: const Icon(Icons.email_outlined),
              title: Text(
                l10n.supportEmailLabel,
                style: const TextStyle(fontFamily: 'Cairo'),
              ),
              subtitle: Text(
                _supportEmail,
                style: const TextStyle(fontFamily: 'Cairo'),
              ),
              onTap: () => _launch(Uri.parse('mailto:$_supportEmail')),
            ),
            ListTile(
              leading: const Icon(Icons.phone_outlined),
              title: Text(
                l10n.supportPhoneLabel,
                style: const TextStyle(fontFamily: 'Cairo'),
              ),
              subtitle: Text(
                _supportPhone,
                style: const TextStyle(fontFamily: 'Cairo'),
              ),
              onTap: () => _launch(Uri.parse('tel:$_supportPhone')),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => context.push('/support'),
              icon: const Icon(Icons.confirmation_number_outlined),
              label: Text(
                l10n.supportTicketButton,
                style: const TextStyle(fontFamily: 'Cairo'),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => Navigator.maybePop(context),
              child: Text(
                l10n.cancelButton,
                style: const TextStyle(fontFamily: 'Cairo'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
