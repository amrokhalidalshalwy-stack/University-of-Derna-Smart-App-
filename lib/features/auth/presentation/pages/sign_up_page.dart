// ═══════════════════════════════════════════════════════════════════════════
// sign_up_page.dart
// ═══════════════════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_project/features/auth/presentation/providers/registration_provider.dart';
import 'package:flutter_project/features/auth/presentation/widgets/step_progress_bar.dart';
import 'package:flutter_project/features/auth/presentation/widgets/registration_step1.dart';
import 'package:flutter_project/features/auth/presentation/widgets/registration_step2.dart';
import 'package:flutter_project/features/auth/presentation/widgets/registration_steps_3_4.dart';
import 'package:flutter_project/core/constants/app_roles.dart';
import 'package:flutter_project/l10n/app_localizations.dart';

class SignUpPage extends ConsumerStatefulWidget {
  final String portalType;
  const SignUpPage({super.key, this.portalType = 'student'});

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  final _pageCtrl = PageController();
  final _formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
  ];
  int _visualStep = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.portalType == 'admin') {
        context.go('/login-form?portalType=admin');
        return;
      }
      ref.read(registrationProvider.notifier).setPortalType(widget.portalType);
    });
  }

  List<String> get _stepLabels {
    final l10n = AppLocalizations.of(context)!;
    return [
      l10n.authStepPersonalInfo,
      l10n.authStepAcademicInfo,
      l10n.authStepAccountSetup,
      l10n.authStepReview,
    ];
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    FocusScope.of(context).unfocus();
    final step = _visualStep;

    if (step < 3) {
      if (step == 0 && ref.read(registrationProvider).dateOfBirth == null) {
        _showError(AppLocalizations.of(context)!.authErrorDateOfBirthRequired);
        return;
      }
      if (step < _formKeys.length) {
        final currentFormKey = _formKeys[step];
        if (currentFormKey.currentState == null) return;
        if (!currentFormKey.currentState!.validate()) return;
      }
    }

    if (step == 3) {
      await _submit();
      return;
    }

    setState(() => _visualStep++);

    await _pageCtrl.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );

    if (!mounted) return;
    ref.read(registrationProvider.notifier).nextStep();
  }

  Future<void> _back() async {
    FocusScope.of(context).unfocus();
    if (_visualStep == 0) return;

    setState(() => _visualStep--);

    await _pageCtrl.previousPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );

    if (!mounted) return;
    ref.read(registrationProvider.notifier).previousStep();
  }

  Future<void> _submit() async {
    final state = ref.read(registrationProvider);
    if (!state.isSubmitEnabled) {
      _showError(AppLocalizations.of(context)!.authErrorTermsRequired);
      return;
    }
    await ref.read(registrationProvider.notifier).submit();
    final newState = ref.read(registrationProvider);
    if (!mounted) return;
    if (newState.result != null) {
      HapticFeedback.mediumImpact();
      _showSuccessDialog(
        newState.result!.preliminaryScore,
        newState.result!.status,
      );
    } else if (newState.errorMessage != null) {
      _showError(newState.errorMessage!);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontFamily: 'Cairo')),
        backgroundColor: const Color(0xFFDC3545),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showSuccessDialog(int score, RegistrationStatus status) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Color(0xFF28A745), size: 28),
            const SizedBox(width: 8),
            Text(
              AppLocalizations.of(context)!.authRegistrationSuccess,
              style: const TextStyle(fontFamily: 'Cairo', fontSize: 16),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${AppLocalizations.of(context)!.authRegistrationScorePrefix} $score / 100',
              style: const TextStyle(fontFamily: 'Cairo', fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              '${AppLocalizations.of(context)!.authRegistrationStatus} ${status.labelAr}',
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context)!.authRegistrationFinalDecision,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13,
                color: Color(0xFF43474E),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF001835),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              ref.read(registrationProvider.notifier).reset();
              context.go(
                '/pending',
                extra: {
                  'status': status.value,
                },
              );
            },
            child: Text(
              AppLocalizations.of(context)!.ok,
              style: const TextStyle(fontFamily: 'Cairo', color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
@override
Widget build(BuildContext context) {
  final state = ref.watch(registrationProvider);

  return Scaffold(
    backgroundColor: const Color(0xFFF7F9FB),
    appBar: AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: _visualStep > 0
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              onPressed: _back,
            )
          : IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: () => context.go('/gateway'),
            ),
      title: Text(
        AppLocalizations.of(context)!.signUpTitle,
        style: const TextStyle(
          fontFamily: 'Cairo',
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Color(0xFF001835),
        ),
      ),
      centerTitle: true,
    ),
    body: Column(
      children: [
        // ← شريط المراحل هنا في body مباشرة
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
          child: StepProgressBar(
            currentStep: _visualStep,
            totalSteps: 4,
            labels: _stepLabels,
          ),
        ),
        if (state.errorMessage != null)
          Container(
            width: double.infinity,
            color: const Color(0xFFDC3545).withValues(alpha: 0.1),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              state.errorMessage!,
              style: const TextStyle(
                fontFamily: 'Cairo',
                color: Color(0xFFDC3545),
                fontSize: 13,
              ),
            ),
          ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return ClipRect(
                child: SizedBox(
                  height: constraints.maxHeight,
                  child: PageView.builder(
                    controller: _pageCtrl,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 4,
                    itemBuilder: (context, index) {
                      switch (index) {
                        case 0:
                          return _StepWrapper(child: RegistrationStep1(formKey: _formKeys[0]));
                        case 1:
                          return _StepWrapper(child: RegistrationStep2(formKey: _formKeys[1]));
                        case 2:
                          return _StepWrapper(child: RegistrationStep3(formKey: _formKeys[2]));
                        case 3:
                          return _StepWrapper(
                            child: _visualStep >= 3
                                ? const RegistrationStep4()
                                : const SizedBox.shrink(),
                          );
                        default:
                          return const SizedBox.shrink();
                      }
                    },
                  ),
                ),
              );
            },
          ),
        ),
        _buildNavBar(state),
      ],
    ),
  );
}
  Widget _buildNavBar(RegistrationFormState state) {
    final isLast = _visualStep == 3;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SizedBox(
        height: 52,
        child: ElevatedButton(
          onPressed: (state.isLoading || (isLast && !state.isSubmitEnabled))
              ? null
              : _next,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF001835),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: state.isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isLast
                          ? AppLocalizations.of(context)!.authSubmitRequest
                          : AppLocalizations.of(context)!.authStepNext,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      isLast ? Icons.send_rounded : Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ── Step content wrapper ─────────────────────────────────────────────────────
class _StepWrapper extends StatelessWidget {
  final Widget child;
  const _StepWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: constraints.maxWidth,
              maxWidth: constraints.maxWidth,
              minHeight: 0,
              maxHeight: double.infinity,
            ),
            child: child,
          ),
        );
      },
    );
  }
}
