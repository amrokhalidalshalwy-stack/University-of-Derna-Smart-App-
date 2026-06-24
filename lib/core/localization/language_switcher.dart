import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_project/l10n/app_localizations.dart';
import 'package:flutter_project/core/localization/locale_provider.dart';

class LanguageSwitcher extends ConsumerWidget {
  const LanguageSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final notifier = ref.read(localeProvider.notifier);
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';

    return PopupMenuButton<String>(
      icon: const Icon(Icons.language_outlined),
      tooltip: l10n.language,
      onSelected: (code) => notifier.setLocale(Locale(code)),
      itemBuilder:
          (_) => [
            PopupMenuItem(
              value: 'ar',
              child: Row(
                children: [
                  if (isArabic) const Icon(Icons.check, size: 16),
                  const SizedBox(width: 8),
                  Text(l10n.arabic),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'en',
              child: Row(
                children: [
                  if (!isArabic) const Icon(Icons.check, size: 16),
                  const SizedBox(width: 8),
                  Text(l10n.english),
                ],
              ),
            ),
          ],
    );
  }
}
