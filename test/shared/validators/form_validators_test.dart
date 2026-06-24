import 'package:flutter_project/l10n/app_localizations_en.dart';
import 'package:flutter_project/shared/validators/form_validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppLocalizationsEn l10n;

  setUp(() {
    l10n = AppLocalizationsEn();
  });

  group('FormValidators Tests', () {
    test('validateEmail succeeds for valid email (Happy Path)', () {
      final result = Validators.validateEmail('test@uod.edu.ly', l10n);
      expect(result, isNull);
    });

    test('validateEmail fails for invalid email format (Failure Path)', () {
      final result = Validators.validateEmail('invalid-email', l10n);
      expect(result, l10n.invalidEmail);
    });

    test('validatePassword fails when too short (Failure Path)', () {
      final result = Validators.validatePassword('12345', l10n);
      expect(result, l10n.passwordTooShort);
    });

    test('validateRegistrationNumber succeeds for 8 or 9 digits (Happy Path)', () {
      expect(Validators.validateRegistrationNumber('12345678', l10n), isNull);
      expect(Validators.validateRegistrationNumber('123456789', l10n), isNull);
    });
  });
}
