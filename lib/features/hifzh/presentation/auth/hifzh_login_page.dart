/// HifdhTracker — Login & Registration Screen.
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_project/features/hifzh/core/theme/hifzh_theme.dart';
import 'package:flutter_project/features/hifzh/core/constants/hifzh_strings.dart';
import 'package:flutter_project/features/hifzh/core/router/hifzh_router.dart';
import 'package:flutter_project/features/hifzh/core/di/hifzh_injection.dart';
import 'package:flutter_project/features/hifzh/presentation/bloc/auth/auth_cubit.dart';
import 'package:flutter_project/features/hifzh/presentation/bloc/auth/auth_state.dart';

/// The combined login & registration screen for HifdhTracker.
class HifzhLoginPage extends StatefulWidget {
  /// Creates a [HifzhLoginPage].
  const HifzhLoginPage({super.key});

  @override
  State<HifzhLoginPage> createState() => _HifzhLoginPageState();
}

class _HifzhLoginPageState extends State<HifzhLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isRegisterMode = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return HifzhStrings.emailRequired;
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value.trim())) return HifzhStrings.emailInvalid;
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return HifzhStrings.passwordRequired;
    if (value.length < 8) return HifzhStrings.passwordTooShort;
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return HifzhStrings.passwordRequired;
    if (value != _passwordController.text) {
      return HifzhStrings.passwordsDoNotMatch;
    }
    return null;
  }

  void _submit(BuildContext context) {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final cubit = context.read<AuthCubit>();
    if (_isRegisterMode) {
      cubit.register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
      );
    } else {
      cubit.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    }
  }

  void _signInWithGoogle(BuildContext context) {
    context.read<AuthCubit>().signInWithGoogle();
  }

  void _toggleMode() {
    setState(() {
      _isRegisterMode = !_isRegisterMode;
      _formKey.currentState?.reset();
      _emailController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();
    });
  }

  void _forgotPassword() {
    showDialog<void>(
      context: context,
      builder:
          (_) =>
              _ForgotPasswordDialog(initialEmail: _emailController.text.trim()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return BlocProvider(
      create:
          (_) => HifzhInjection.instance.createAuthCubit()..checkAuthStatus(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthAuthenticated) {
              context.goNamed(HifzhRoutes.home);
            } else if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    state.message,
                    textDirection: TextDirection.rtl,
                  ),
                  backgroundColor: Colors.red.shade800,
                ),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is AuthLoading;
            return Stack(
              children: [
                // ── Decorative header background ──────────────────────────────
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: size.height * 0.28,
                    decoration: const BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(40),
                        bottomRight: Radius.circular(40),
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: 24,
                          top: 24,
                          child: Icon(
                            Icons.auto_awesome,
                            color: AppColors.accentGold.withValues(alpha: 0.25),
                            size: 80,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 500.ms),
                ),

                // ── Scrollable form ───────────────────────────────────────────
                SafeArea(
                  child: IgnorePointer(
                    ignoring: isLoading,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          const SizedBox(height: 24),

                          // University logo — height: 40, leading slot
                          Row(
                            children: [
                              SizedBox(
                                height: 40,
                                child: Image.asset(
                                  'assets/images/university_logo.png',
                                  fit: BoxFit.contain,
                                  errorBuilder:
                                      (_, e, s) => const Icon(
                                        Icons.school_rounded,
                                        color: AppColors.onPrimary,
                                        size: 40,
                                      ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'حافظ | HifdhTracker',
                                style: Theme.of(
                                  context,
                                ).textTheme.titleMedium?.copyWith(
                                  color: AppColors.onPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ).animate().fadeIn(duration: 600.ms),

                          SizedBox(height: size.height * 0.07),

                          // ── Auth card ─────────────────────────────────────────
                          Container(
                                padding: const EdgeInsets.all(28),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(
                                        alpha: 0.08,
                                      ),
                                      blurRadius: 24,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Text(
                                        _isRegisterMode
                                            ? HifzhStrings.registerTitle
                                            : HifzhStrings.loginTitle,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.headlineMedium?.copyWith(
                                          color: AppColors.primary,
                                        ),
                                        textDirection: TextDirection.rtl,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        _isRegisterMode
                                            ? 'أنشئ حسابك لتبدأ رحلة الحفظ'
                                            : 'سجّل دخولك للمتابعة من حيث توقفت',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium?.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                        textDirection: TextDirection.rtl,
                                      ),
                                      const SizedBox(height: 28),

                                      // Email
                                      TextFormField(
                                        key: const Key('hifzh_email_field'),
                                        controller: _emailController,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        textDirection: TextDirection.ltr,
                                        validator: _validateEmail,
                                        decoration: const InputDecoration(
                                          labelText: HifzhStrings.emailLabel,
                                          hintText: HifzhStrings.emailHint,
                                          prefixIcon: Icon(
                                            Icons.email_outlined,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),

                                      // Password
                                      TextFormField(
                                        key: const Key('hifzh_password_field'),
                                        controller: _passwordController,
                                        obscureText: _obscurePassword,
                                        validator: _validatePassword,
                                        decoration: InputDecoration(
                                          labelText: HifzhStrings.passwordLabel,
                                          hintText: HifzhStrings.passwordHint,
                                          prefixIcon: const Icon(
                                            Icons.lock_outline_rounded,
                                          ),
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              _obscurePassword
                                                  ? Icons.visibility_outlined
                                                  : Icons
                                                      .visibility_off_outlined,
                                            ),
                                            onPressed:
                                                () => setState(
                                                  () =>
                                                      _obscurePassword =
                                                          !_obscurePassword,
                                                ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),

                                      // Confirm Password (register only)
                                      AnimatedSize(
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        curve: Curves.easeInOut,
                                        child:
                                            _isRegisterMode
                                                ? Column(
                                                  children: [
                                                    TextFormField(
                                                      key: const Key(
                                                        'hifzh_confirm_pw_field',
                                                      ),
                                                      controller:
                                                          _confirmPasswordController,
                                                      obscureText:
                                                          _obscureConfirmPassword,
                                                      validator:
                                                          _validateConfirmPassword,
                                                      decoration: InputDecoration(
                                                        labelText:
                                                            HifzhStrings
                                                                .confirmPasswordLabel,
                                                        hintText:
                                                            HifzhStrings
                                                                .passwordHint,
                                                        prefixIcon: const Icon(
                                                          Icons
                                                              .lock_person_outlined,
                                                        ),
                                                        suffixIcon: IconButton(
                                                          icon: Icon(
                                                            _obscureConfirmPassword
                                                                ? Icons
                                                                    .visibility_outlined
                                                                : Icons
                                                                    .visibility_off_outlined,
                                                          ),
                                                          onPressed:
                                                              () => setState(
                                                                () =>
                                                                    _obscureConfirmPassword =
                                                                        !_obscureConfirmPassword,
                                                              ),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 16),
                                                  ],
                                                )
                                                : const SizedBox.shrink(),
                                      ),

                                      // Forgot Password (login only)
                                      if (!_isRegisterMode)
                                        Align(
                                          alignment:
                                              AlignmentDirectional.centerEnd,
                                          child: TextButton(
                                            onPressed: _forgotPassword,
                                            child: Text(
                                              HifzhStrings.forgotPassword,
                                              style: Theme.of(
                                                context,
                                              ).textTheme.bodySmall?.copyWith(
                                                color: AppColors.secondary,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                      const SizedBox(height: 8),

                                      // Submit button
                                      ElevatedButton(
                                        key: const Key('hifzh_submit_btn'),
                                        onPressed:
                                            isLoading
                                                ? null
                                                : () => _submit(context),
                                        child:
                                            isLoading
                                                ? const SizedBox(
                                                  height: 20,
                                                  width: 20,
                                                  child:
                                                      CircularProgressIndicator(
                                                        strokeWidth: 2.5,
                                                        color:
                                                            AppColors.onPrimary,
                                                      ),
                                                )
                                                : Text(
                                                  _isRegisterMode
                                                      ? HifzhStrings
                                                          .registerButton
                                                      : HifzhStrings
                                                          .loginButton,
                                                ),
                                      ),
                                      const SizedBox(height: 20),

                                      // OR divider
                                      Row(
                                        children: [
                                          const Expanded(child: Divider()),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                            ),
                                            child: Text(
                                              HifzhStrings.orDivider,
                                              style: Theme.of(
                                                context,
                                              ).textTheme.bodySmall?.copyWith(
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                          ),
                                          const Expanded(child: Divider()),
                                        ],
                                      ),
                                      const SizedBox(height: 16),

                                      // Google Sign-In
                                      OutlinedButton.icon(
                                        key: const Key('hifzh_google_btn'),
                                        onPressed:
                                            isLoading
                                                ? null
                                                : () =>
                                                    _signInWithGoogle(context),
                                        icon: const Icon(
                                          Icons.g_mobiledata_rounded,
                                          size: 24,
                                        ),
                                        label: Text(
                                          HifzhStrings.continueWithGoogle,
                                        ),
                                      ),
                                      const SizedBox(height: 20),

                                      // Mode toggle
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            _isRegisterMode
                                                ? HifzhStrings.hasAccount
                                                : HifzhStrings.noAccount,
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodySmall?.copyWith(
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: _toggleMode,
                                            child: Text(
                                              _isRegisterMode
                                                  ? HifzhStrings.signInLink
                                                  : HifzhStrings.signUpLink,
                                              style: Theme.of(
                                                context,
                                              ).textTheme.bodySmall?.copyWith(
                                                color: AppColors.secondary,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .animate()
                              .fadeIn(delay: 300.ms, duration: 500.ms)
                              .slideY(
                                begin: 0.05,
                                delay: 300.ms,
                                curve: Curves.easeOut,
                              ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (isLoading)
                  Container(
                    color: Colors.black.withValues(alpha: 0.1),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ── Forgot Password Dialog ────────────────────────────────────────────────────

/// Modal dialog for sending a password-reset email.
class _ForgotPasswordDialog extends StatefulWidget {
  const _ForgotPasswordDialog({this.initialEmail = ''});
  final String initialEmail;

  @override
  State<_ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<_ForgotPasswordDialog> {
  late final TextEditingController _ctrl;
  bool _sent = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final email = _ctrl.text.trim();
    if (email.isEmpty) return;
    setState(() => _loading = true);
    try {
      await context.read<AuthCubit>().sendPasswordReset(email: email);
      if (mounted) setState(() => _sent = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        'استعادة كلمة المرور',
        style: Theme.of(context).textTheme.titleLarge,
        textDirection: TextDirection.rtl,
      ),
      content:
          _sent
              ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.mark_email_read_outlined,
                    size: 48,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'تم إرسال رابط إعادة التعيين إلى بريدك الإلكتروني.',
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              )
              : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'أدخل بريدك الإلكتروني لتلقي رابط إعادة تعيين كلمة المرور.',
                    textDirection: TextDirection.rtl,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _ctrl,
                    keyboardType: TextInputType.emailAddress,
                    textDirection: TextDirection.ltr,
                    decoration: const InputDecoration(
                      labelText: HifzhStrings.emailLabel,
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                  ),
                ],
              ),
      actions:
          _sent
              ? [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(HifzhStrings.confirm),
                ),
              ]
              : [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(HifzhStrings.cancel),
                ),
                ElevatedButton(
                  onPressed: _loading ? null : _send,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(100, 44),
                  ),
                  child:
                      _loading
                          ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.onPrimary,
                            ),
                          )
                          : const Text('إرسال'),
                ),
              ],
    );
  }
}
