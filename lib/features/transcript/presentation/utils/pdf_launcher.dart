import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_project/core/services/error_tracking_service.dart';
import 'package:flutter_project/l10n/app_localizations.dart';

/// Opens transcript PDF URLs in the system browser or PDF viewer.
class PdfLauncher {
  PdfLauncher._();

  static Future<void> launchPdf(String url, BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme) {
      _showError(context, l10n.genericError);
      return;
    }

    try {
      final canLaunch = await canLaunchUrl(uri);
      if (!canLaunch) {
        if (!context.mounted) return;
        _showError(context, l10n.genericError);
        return;
      }

      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && context.mounted) {
        _showError(context, l10n.genericError);
      }
    } catch (e, stackTrace) {
      await ErrorTrackingService.recordError(e, stackTrace, context: '[PdfLauncher] launch failed');
      if (context.mounted) {
        _showError(context, l10n.genericError);
      }
    }
  }

  static void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontFamily: 'Cairo')),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
