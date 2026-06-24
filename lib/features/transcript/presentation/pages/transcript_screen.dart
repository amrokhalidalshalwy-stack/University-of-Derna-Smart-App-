import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_project/core/theme/app_theme.dart';
import 'package:flutter_project/features/transcript/di/transcript_module.dart';
import 'package:flutter_project/features/transcript/presentation/providers/transcript_provider.dart';
import 'package:flutter_project/features/transcript/presentation/utils/pdf_launcher.dart';
import 'package:flutter_project/l10n/app_localizations.dart';

/// Semester transcript / report screen (PDF via n8n + offline cache).
class TranscriptScreen extends StatefulWidget {
  const TranscriptScreen({
    super.key,
    required this.studentId,
    required this.semester,
    this.gpa,
  });

  final String studentId;
  final String semester;
  final String? gpa;

  @override
  State<TranscriptScreen> createState() => _TranscriptScreenState();
}

class _TranscriptScreenState extends State<TranscriptScreen> {
  late final TranscriptProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = TranscriptModule.createProvider();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider.fetchTranscript(widget.studentId, widget.semester);
    });
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ChangeNotifierProvider<TranscriptProvider>.value(
      value: _provider,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: Text(
            l10n.transcriptTitle,
            style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          actions: [
            IconButton(
              tooltip: l10n.transcriptRefreshButton,
              onPressed: () {
                _provider.requestForceRefresh();
                _provider.fetchTranscript(widget.studentId, widget.semester);
              },
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.transcriptSemesterLabel(widget.semester),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 15,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.transcriptStudentIdLabel(widget.studentId),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              if (widget.gpa != null && widget.gpa!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  l10n.transcriptGpaLabel(widget.gpa!),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Expanded(
                child: _TranscriptBody(
                  studentId: widget.studentId,
                  semester: widget.semester,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TranscriptBody extends StatelessWidget {
  const _TranscriptBody({required this.studentId, required this.semester});

  final String studentId;
  final String semester;

  @override
  Widget build(BuildContext context) {
    return Consumer<TranscriptProvider>(
      builder: (context, provider, _) {
        switch (provider.currentState) {
          case TranscriptState.idle:
          case TranscriptState.loading:
            return _LoadingView(
              message:
                  provider.isGenerating
                      ? AppLocalizations.of(context)!.transcriptGeneratingMessage
                      : AppLocalizations.of(context)!.transcriptLoadingMessage,
            );
          case TranscriptState.success:
            return _SuccessView(
              pdfUrl: provider.pdfUrl!,
              isOfflineWarning: provider.isOfflineWarning,
            );
          case TranscriptState.error:
            return _ErrorView(
              message: _resolveErrorMessage(context, provider),
              onRetry: () => provider.fetchTranscript(studentId, semester),
            );
        }
      },
    );
  }

  String _resolveErrorMessage(BuildContext context, TranscriptProvider provider) {
    final l10n = AppLocalizations.of(context)!;
    final raw = provider.errorMessage;
    if (raw == null || raw.isEmpty) {
      return l10n.transcriptNoDataMessage;
    }
    switch (raw) {
      case TranscriptErrorKeys.noData:
        return l10n.transcriptNoDataMessage;
      case TranscriptErrorKeys.noCache:
        return l10n.transcriptNoCacheMessage;
      case TranscriptErrorKeys.generic:
        return l10n.genericError;
      default:
        return raw;
    }
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(fontFamily: 'Cairo', fontSize: 15),
          ),
        ],
      ),
    );
  }
}

class _SuccessView extends StatelessWidget {
  const _SuccessView({required this.pdfUrl, required this.isOfflineWarning});

  final String pdfUrl;
  final bool isOfflineWarning;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isOfflineWarning) ...[
          Material(
            color: Colors.amber.shade100,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Icon(Icons.wifi_off_rounded, color: Colors.amber.shade900),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.transcriptOfflineBanner,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 13,
                        color: Colors.amber.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
        Icon(
          Icons.picture_as_pdf_rounded,
          size: 72,
          color: AppTheme.primaryColor.withValues(alpha: 0.85),
        ),
        const SizedBox(height: 32),
        ElevatedButton.icon(
          onPressed: () => PdfLauncher.launchPdf(pdfUrl, context),
          icon: const Icon(Icons.open_in_new_rounded),
          label: Text(
            l10n.transcriptOpenPdfButton,
            style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => PdfLauncher.launchPdf(pdfUrl, context),
          icon: const Icon(Icons.download_rounded),
          label: Text(
            l10n.transcriptDownloadButton,
            style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.primaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, size: 56, color: Colors.red.shade400),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontFamily: 'Cairo', fontSize: 15),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: Text(
              l10n.transcriptRetryButton,
              style: const TextStyle(fontFamily: 'Cairo'),
            ),
          ),
        ],
      ),
    );
  }
}
