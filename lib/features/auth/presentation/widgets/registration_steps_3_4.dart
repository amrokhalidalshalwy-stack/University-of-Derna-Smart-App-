// Step 3 — Credentials  |  Step 4 — Review & Submit
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_project/core/constants/university_data.dart';
import 'package:flutter_project/features/auth/presentation/providers/registration_provider.dart';
import 'package:flutter_project/features/auth/presentation/widgets/password_strength_meter.dart';
import 'package:flutter_project/l10n/app_localizations.dart';

// ── Step 3: Credentials ───────────────────────────────────────────────────────
class RegistrationStep3 extends ConsumerStatefulWidget {
  final GlobalKey<FormState> formKey;
  const RegistrationStep3({super.key, required this.formKey});
  @override
  ConsumerState<RegistrationStep3> createState() => _Step3State();
}

class _Step3State extends ConsumerState<RegistrationStep3> {
  bool _obscure = true;
  bool _obscureConfirm = true;
  final _confirmCtrl = TextEditingController();

  @override
  void dispose() {
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(registrationProvider.notifier);
    final state = ref.watch(registrationProvider);
    final l10n = AppLocalizations.of(context)!;

    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.password,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: Color(0xFF001835),
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            obscureText: _obscure,
            onChanged: notifier.updatePassword,
            validator: (v) {
              final String val = v?.toString().trim() ?? '';
              if (val.isEmpty || val.length < 8) {
                return l10n.authErrorPasswordLength;
              }
              return null;
            },
            decoration: InputDecoration(
              hintText: '••••••••',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
          ),
          PasswordStrengthMeter(password: state.password),
          const SizedBox(height: 16),
          Text(
            l10n.authConfirmPassword,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: Color(0xFF001835),
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _confirmCtrl,
            obscureText: _obscureConfirm,
            validator: (v) {
              final String val = v?.toString().trim() ?? '';
              if (val.isEmpty) {
                return l10n.authErrorPasswordMismatch;
              }
              if (val != state.password) return l10n.authErrorPasswordMismatch;
              return null;
            },
            decoration: InputDecoration(
              hintText: '••••••••',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirm
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed:
                    () => setState(() => _obscureConfirm = !_obscureConfirm),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Step 4: Review & Agreements ───────────────────────────────────────────────
class RegistrationStep4 extends ConsumerWidget {
  const RegistrationStep4({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(registrationProvider.notifier);
    final state = ref.watch(registrationProvider);
    final l10n = AppLocalizations.of(context)!;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFEBF4FF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF0F6CBD).withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // تأمين الـ Column الداخلي
            children: [
              Text(
                l10n.authReviewData,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Color(0xFF001835),
                ),
              ),
              const Divider(height: 20),
              _row(l10n.authLabelFullNameArabic, state.fullNameAr),
              _row(l10n.authLabelFullNameEnglish, state.fullNameEn),
              _reviewField(
                l10n.authLabelEmail,
                state.email,
                'البريد',
                state.errorMessage,
                notifier.updateEmail,
                false,
                true,
              ),
              _reviewField(
                l10n.authLabelPhone,
                state.phone,
                'الهاتف',
                state.errorMessage,
                notifier.updatePhone,
                true,
                false,
              ),
              _reviewField(
                l10n.authLabelNationalId,
                state.nationalId,
                'الهوية',
                state.errorMessage,
                notifier.updateNationalId,
                false,
                false,
              ),
              _row(
                l10n.authLabelGender,
                state.gender.isEmpty
                    ? ''
                    : UniversityData.genderLabel(
                      state.gender,
                      isArabic: isAr,
                    ),
              ),
              if (!state.isFaculty) ...[
                _row(l10n.authLabelCollege, state.faculty),
                _row(l10n.authLabelDepartment, state.department),
                _row(l10n.authLabelSemester, state.semester),
                _row(
                  l10n.authLabelGraduationYear,
                  state.graduationYear.toString(),
                ),
                _row(l10n.authLabelGpa, '${state.secondaryGpa}%'),
                _row(l10n.authLabelCertificateType, state.certificateType),
              ],
              if (state.isFaculty) ...[
                _row('الدرجة الأكاديمية', state.academicDegree),
                _row('المسمى الوظيفي', state.academicTitle),
                _row('التخصص الأكاديمي', state.specialization),
                _row('الكلية', state.college),
                _row(
                  'تاريخ التعيين',
                  state.employmentDate != null
                      ? '${state.employmentDate!.year}-${state.employmentDate!.month.toString().padLeft(2, '0')}-${state.employmentDate!.day.toString().padLeft(2, '0')}'
                      : 'غير محدد',
                ),
                _row('معدل نجاح الطلاب', '${state.studentPassRate}%'),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),
        CheckboxListTile(
          value: state.agreedToTerms,
          onChanged: (_) => notifier.toggleTerms(),
          title: Text(
            l10n.authAgreeToTermsOfService,
            style: const TextStyle(fontFamily: 'Cairo', fontSize: 14),
          ),
          controlAffinity: ListTileControlAffinity.leading,
          activeColor: const Color(0xFF001835),
        ),
        CheckboxListTile(
          value: state.agreedToPrivacy,
          onChanged: (_) => notifier.togglePrivacy(),
          title: Text(
            l10n.authAgreeToPrivacyPolicy,
            style: const TextStyle(fontFamily: 'Cairo', fontSize: 14),
          ),
          controlAffinity: ListTileControlAffinity.leading,
          activeColor: const Color(0xFF001835),
        ),
      ],
    );
  }

  Widget _reviewField(
    String label,
    String value,
    String errorKeyword,
    String? currentError,
    ValueChanged<String> onChanged,
    bool isPhone,
    bool isEmail,
  ) {
    bool hasConflict =
        currentError != null && currentError.isNotEmpty && currentError.contains(errorKeyword);
    if (!hasConflict) return _row(label, value);

    // حماية بناء حقل الخطأ التفاعلي منعاً للـ الـ Overflow اللانهائي
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: Color(0xFFDC3545),
            ),
          ),
          const SizedBox(height: 4),
          TextFormField(
            initialValue: value,
            onChanged: onChanged,
            keyboardType:
                isPhone
                    ? TextInputType.phone
                    : (isEmail ? TextInputType.emailAddress : TextInputType.text),
            style: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              // استبدال الـ errorText بـ helperText أو تصفية العرض لمنع تمدد المحاذاة برقم فلكي
              helperText: 'يرجى تصحيح المدخلات أعلاه',
              helperStyle: const TextStyle(color: Color(0xFFDC3545), fontSize: 11, fontFamily: 'Cairo'),
              border: OutlineInputBorder(
                borderSide: const BorderSide(color: Color(0xFFDC3545)),
                borderRadius: BorderRadius.circular(8),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Color(0xFFDC3545)),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: Color(0xFF43474E),
            ),
          ),
          Expanded(
            child: Text(
              value ?? '',
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12,
                color: Color(0xFF001835),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
