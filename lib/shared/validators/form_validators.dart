import 'package:flutter_project/l10n/app_localizations.dart';

/// Merged validators for the entire application.
/// Localized error messages using AppLocalizations.
class Validators {
  // Check Email
  static String? validateEmail(String? value, AppLocalizations l10n) {
    if (value == null || value.isEmpty) return l10n.emailRequired;
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$').hasMatch(value)) {
      return l10n.invalidEmail;
    }
    return null;
  }

  // Check Password
  static String? validatePassword(String? value, AppLocalizations l10n) {
    if (value == null || value.isEmpty) return l10n.passwordRequired;
    if (value.length < 6) return l10n.passwordTooShort;
    return null;
  }

  // Check Username
  static String? validateUsername(String? value, AppLocalizations l10n) {
    if (value == null || value.isEmpty) return l10n.usernameRequired;
    if (value.length < 3) return l10n.usernameTooShort;
    return null;
  }

  // Check Registration Number (8 or 9 digits)
  static String? validateRegistrationNumber(
    String? value,
    AppLocalizations l10n,
  ) {
    if (value == null || value.isEmpty) return l10n.registrationNumberRequired;
    if (!RegExp(r'^\d{8,9}$').hasMatch(value)) {
      return l10n.invalidRegistrationNumber;
    }
    return null;
  }

  // Check Confirm Password
  static String? validateConfirmPassword(
    String? value,
    String password,
    AppLocalizations l10n,
  ) {
    if (value == null || value.isEmpty) return l10n.confirmPasswordRequired;
    if (value != password) return l10n.passwordsDoNotMatch;
    return null;
  }
}
