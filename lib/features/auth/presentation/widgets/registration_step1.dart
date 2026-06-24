// Step 1 — Personal Information (widget for multi-step registration)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_project/features/auth/presentation/providers/registration_provider.dart';
import 'package:flutter_project/core/constants/university_data.dart';
import 'package:flutter_project/l10n/app_localizations.dart';
import 'package:flutter_project/shared/validators/name_validators.dart';

class RegistrationStep1 extends ConsumerWidget {
  final GlobalKey<FormState> formKey;
  const RegistrationStep1({super.key, required this.formKey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(registrationProvider.notifier);
    final state = ref.watch(registrationProvider);
    final l10n = AppLocalizations.of(context)!;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _field(
            label: l10n.authFullNameArabic,
            hint: l10n.authHintFullNameArabic,
            icon: Icons.person_outline,
            initialValue: state.fullNameAr,
            onChanged: notifier.updateFullNameAr,
            inputFormatters: NameValidators.arabicInputFormatters(),
            validator: (v) => NameValidators.validateArabicName(v, l10n),
          ),
          const SizedBox(height: 16),
          _field(
            label: l10n.authFullNameEnglish,
            hint: l10n.authHintFullNameEnglish,
            icon: Icons.person_outline,
            initialValue: state.fullNameEn,
            onChanged: notifier.updateFullNameEn,
            inputFormatters: NameValidators.englishInputFormatters(),
            validator: (v) => NameValidators.validateEnglishName(v, l10n),
          ),
          const SizedBox(height: 16),
          _field(
            label: l10n.email,
            hint: l10n.authLoginEmailHint,
            icon: Icons.email_outlined,
            initialValue: state.email,
            keyboardType: TextInputType.emailAddress,
            onChanged: notifier.updateEmail,
            validator: (v) {
              final String val = v?.toString().trim() ?? '';
              if (val.isEmpty) {
                return l10n.emailRequired;
              }
              if (!RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$').hasMatch(val)) {
                return l10n.invalidEmail;
              }
              if (state.isFaculty &&
                  !val.toLowerCase().endsWith('@uod.edu.ly')) {
                return 'البريد الإلكتروني للجامعة يجب أن ينتهي بـ @uod.edu.ly';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _field(
            label: l10n.authPhoneNumber,
            hint: l10n.authHintPhone,
            icon: Icons.phone_outlined,
            initialValue: state.phone,
            keyboardType: TextInputType.phone,
            onChanged: notifier.updatePhone,
            validator: (v) {
              final String val = v?.toString().trim() ?? '';
              if (val.isEmpty) {
                return l10n.authErrorPhoneFormat;
              }
              if (!RegExp(r'^(091|092|093|094)\d{7}$').hasMatch(val)) {
                return 'رقم الهاتف يجب أن يتكون من 10 أرقام ويبدأ بـ 091/092/093/094';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _field(
            label: l10n.authNationalId,
            hint: l10n.authHintNationalId,
            icon: Icons.badge_outlined,
            initialValue: state.nationalId,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(12),
            ],
            onChanged: notifier.updateNationalId,
            validator: (v) {
              final String val = v?.toString().trim() ?? '';
              if (val.isEmpty) {
                return l10n.authErrorNationalIdRequired;
              }
              if (val.length != 12) {
                return l10n.authErrorNationalIdFormat;
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          // Date of Birth picker (المعدل باستخدام InputDecorator لعرض الخطأ القياسي)
          _DatePickerField(
            label: l10n.authDateOfBirth,
            errorText: l10n.authErrorDateOfBirthRequired,
            value: state.dateOfBirth,
            onChanged: notifier.updateDateOfBirth,
          ),
          const SizedBox(height: 16),
          // Gender dropdown
          _DropdownField<String>(
            label: l10n.authGender,
            value: state.gender.isEmpty ? null : state.gender,
            hint: Text(
              l10n.authGender,
              style: const TextStyle(
                fontFamily: 'Cairo',
                color: Color(0xFF74777F),
              ),
            ),
            items: UniversityData.genderValues,
            itemLabel:
                (v) => UniversityData.genderLabel(v, isArabic: isAr),
            onChanged: (v) {
              if (v != null) notifier.updateGender(v);
            },
            validator: (v) {
              final String val = v?.toString().trim() ?? '';
              if (val.isEmpty) {
                return l10n.authErrorGenderRequired;
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _field({
    required String label,
    required String hint,
    required IconData icon,
    required String initialValue,
    required ValueChanged<String> onChanged,
    FormFieldValidator<String>? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: Color(0xFF001835),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          initialValue: initialValue,
          onChanged: onChanged,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 20),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }
}

class _DatePickerField extends FormField<DateTime> {
  final DateTime? value;

  _DatePickerField({
    required String label,
    required String errorText,
    required this.value,
    required ValueChanged<DateTime> onChanged,
  }) : super(
          initialValue: value,
          validator: (v) => v == null ? errorText : null,
          builder: (FormFieldState<DateTime> field) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Color(0xFF001835),
                  ),
                ),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: field.context,
                      initialDate: field.value ?? DateTime(2000),
                      firstDate: DateTime(1950),
                      lastDate: DateTime.now().subtract(
                        const Duration(days: 365 * 17),
                      ),
                      helpText: AppLocalizations.of(field.context)!.authSelectDateOfBirth,
                    );

                    if (picked != null) {
                      field.didChange(picked);
                      onChanged(picked);
                    }
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.calendar_today_outlined,
                        size: 20,
                        color: Color(0xFF74777F),
                      ),
                      errorText: field.errorText, // يسند نص الخطأ مباشرة لنظام الماتيريال الأساسي
                      errorStyle: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12,
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    child: Text(
                      field.value != null
                          ? '${field.value!.day}/${field.value!.month}/${field.value!.year}'
                          : AppLocalizations.of(field.context)!.authSelectDateOfBirth,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        color: field.value != null
                            ? const Color(0xFF001835)
                            : const Color(0xFF74777F),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );

  @override
  FormFieldState<DateTime> createState() => _DatePickerFieldState();
}

class _DatePickerFieldState extends FormFieldState<DateTime> {}

class _DropdownField<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<T> items;
  final String Function(T) itemLabel;
  final ValueChanged<T?> onChanged;
  final FormFieldValidator<T>? validator;
  final Widget? hint;
  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    this.validator,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: Color(0xFF001835),
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<T>(
          value: value,
          onChanged: onChanged,
          validator: validator,
          hint: hint,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          items: items
              .map(
                (item) => DropdownMenuItem<T>(
                  value: item,
                  child: Text(
                    itemLabel(item),
                    style: const TextStyle(fontFamily: 'Cairo'),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
