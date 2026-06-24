import 'package:flutter_project/l10n/app_localizations.dart';

/// Maps Firestore Arabic major names to localized display strings.
String localizedMajor(String? major, AppLocalizations l10n) {
  final value = major?.trim();
  if (value == null || value.isEmpty) {
    return l10n.unspecifiedMajor;
  }

  if (l10n.localeName.startsWith('ar')) {
    return value;
  }

  final enByAr = <String, String Function(AppLocalizations)>{
    'هندسة البرمجيات': (l) => l.softwareEngineering,
    'هندسة البرمجيات ': (l) => l.softwareEngineering,
  };

  final localized = enByAr[value];
  if (localized != null) {
    return localized(l10n);
  }

  return value;
}

/// Localized course title from Firestore `nameAr` / `nameEn`.
String localizedCourseName({
  required String nameAr,
  required String nameEn,
  required AppLocalizations l10n,
}) {
  if (l10n.localeName.startsWith('ar')) {
    return nameAr.isNotEmpty ? nameAr : nameEn;
  }
  if (nameEn.isNotEmpty) return nameEn;
  return nameAr;
}
