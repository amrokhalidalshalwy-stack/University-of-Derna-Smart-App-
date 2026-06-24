import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_project/core/preferences/app_preferences.dart';

const String _kLanguageCodeKey = 'language_code';
const String _kLegacyLocaleKey = 'locale_code';

class UodLocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final saved = prefs.getString(_kLanguageCodeKey) ??
        prefs.getString(_kLegacyLocaleKey);
    if (saved == null || saved == 'system') {
      return _resolveDeviceLocale();
    }
    return Locale(saved);
  }

  Locale _resolveDeviceLocale() {
    final deviceCode =
        WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    if (deviceCode == 'en') return const Locale('en');
    return const Locale('ar');
  }

  Future<void> setLocale(Locale locale) async {
    final prefs = ref.read(sharedPreferencesProvider);
    state = locale;
    await prefs.setString(_kLanguageCodeKey, locale.languageCode);
    await prefs.remove(_kLegacyLocaleKey);
  }

  /// Follow device language (re-resolves on next app launch).
  Future<void> setSystemLocale() async {
    final prefs = ref.read(sharedPreferencesProvider);
    final resolved = _resolveDeviceLocale();
    state = resolved;
    await prefs.setString(_kLanguageCodeKey, 'system');
    await prefs.remove(_kLegacyLocaleKey);
  }

  bool get isArabic => state.languageCode == 'ar';
}

final localeProvider = NotifierProvider<UodLocaleNotifier, Locale>(
  UodLocaleNotifier.new,
);
