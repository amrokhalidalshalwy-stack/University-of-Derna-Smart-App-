import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_project/features/auth/data/auth_service.dart';
import 'package:flutter_project/features/auth/data/cached_user_profile_provider.dart';
import 'package:flutter_project/features/transcript/presentation/pages/transcript_screen.dart';
import 'package:flutter_project/l10n/app_localizations.dart';

/// Resolves the logged-in student's ID and opens [TranscriptScreen].
class TranscriptRoutePage extends ConsumerWidget {
  const TranscriptRoutePage({super.key, this.semester});

  final String? semester;

  static const _defaultSemester = '2024-2025-Fall';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final authAsync = ref.watch(authStateChangesProvider);

    return authAsync.when(
      data: (user) {
        if (user == null) {
          return Scaffold(
            body: Center(
              child: Text(
                l10n.pleaseLogin,
                style: const TextStyle(fontFamily: 'Cairo'),
              ),
            ),
          );
        }

        final profileAsync = ref.watch(userDataProvider(user.uid));
        return profileAsync.when(
          data: (data) {
            final universityId = data?['universityId'] as String? ?? '';
            final studentId =
                universityId.isNotEmpty ? universityId : user.uid;
            final gpa = data?['gpa'] as String?;
            return TranscriptScreen(
              studentId: studentId,
              semester: semester ?? _defaultSemester,
              gpa: gpa,
            );
          },
          loading:
              () => Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(
                        l10n.transcriptLoadingMessage,
                        style: const TextStyle(fontFamily: 'Cairo'),
                      ),
                    ],
                  ),
                ),
              ),
          error:
              (_, _) => TranscriptScreen(
                studentId: user.uid,
                semester: semester ?? _defaultSemester,
              ),
        );
      },
      loading:
          () => Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    l10n.transcriptLoadingMessage,
                    style: const TextStyle(fontFamily: 'Cairo'),
                  ),
                ],
              ),
            ),
          ),
      error:
          (_, _) => Scaffold(
            body: Center(
              child: Text(
                l10n.pleaseLogin,
                style: const TextStyle(fontFamily: 'Cairo'),
              ),
            ),
          ),
    );
  }
}
