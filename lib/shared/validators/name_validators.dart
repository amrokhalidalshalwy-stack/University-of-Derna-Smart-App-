import 'package:flutter/services.dart';
import 'package:flutter_project/l10n/app_localizations.dart';

final RegExp arabicNamePattern = RegExp(
  r'^[\u0600-\u065F\u066A-\u06EF\u06FA-\u06FF\s\-\.]+$',
);

final RegExp englishNamePattern = RegExp(r"^[A-Za-z\s\-\.\']+$");

final RegExp arabicNameInputPattern = RegExp(
  r'[\u0600-\u065F\u066A-\u06EF\u06FA-\u06FF\s\-\.]',
);

final RegExp englishNameInputPattern = RegExp(r"[A-Za-z\s\-\.\']");

class NameValidators {
  NameValidators._();

  static List<TextInputFormatter> arabicInputFormatters() => [
    FilteringTextInputFormatter.allow(arabicNameInputPattern),
  ];

  static List<TextInputFormatter> englishInputFormatters() => [
    FilteringTextInputFormatter.allow(englishNameInputPattern),
  ];

  static String? validateArabicName(String? value, AppLocalizations l10n) {
    final String val = value?.toString().trim() ?? '';
    if (val.isEmpty) {
      return l10n.authErrorNameArabicRequired;
    }
    if (!arabicNamePattern.hasMatch(val)) {
      return l10n.authErrorNameArabicOnly;
    }
    return null;
  }

  static String? validateEnglishName(String? value, AppLocalizations l10n) {
    final String val = value?.toString().trim() ?? '';
    if (val.isEmpty) {
      return l10n.authErrorNameEnglishRequired;
    }
    if (!englishNamePattern.hasMatch(val)) {
      return l10n.authErrorNameEnglishOnly;
    }
    return null;
  }
}
