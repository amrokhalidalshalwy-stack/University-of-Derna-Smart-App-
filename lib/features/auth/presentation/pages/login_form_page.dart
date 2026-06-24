import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_project/core/theme/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_project/features/auth/data/cached_user_profile_provider.dart';
import 'package:flutter_project/features/auth/presentation/providers/terms_provider.dart';
import 'package:flutter_project/shared/validators/form_validators.dart';
import 'package:flutter_project/l10n/app_localizations.dart';

class LoginFormPage extends ConsumerStatefulWidget {
  final String portalType;
  const LoginFormPage({super.key, this.portalType = 'student'});

  @override
  ConsumerState<LoginFormPage> createState() => _LoginFormPageState();
}

class _LoginFormPageState extends ConsumerState<LoginFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _agreedToTerms = false;
  bool _isLoading = false;
  String? _emailError;
  String? _passwordError;
  String? _authError;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String _mapFirebaseAuthError(FirebaseAuthException e, AppLocalizations l10n) {
    switch (e.code) {
      case 'invalid-email':
        return l10n.invalidEmail;
      case 'too-many-requests':
        return l10n.authErrorTooManyRequests;
      case 'invalid-credential':
        return l10n.authErrorInvalidCredentials;
      case 'user-disabled':
        return l10n.authErrorUserDisabled;
      case 'network-request-failed':
        return l10n.authErrorNetworkFailed;
      default:
        return l10n.authErrorInvalidCredentials;
    }
  }

  bool _validateBeforeSubmit(AppLocalizations l10n) {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    String? emailErr;
    String? passErr;

    if (email.isEmpty) {
      emailErr = l10n.emailRequired;
    } else {
      emailErr = Validators.validateEmail(email, l10n);
    }

    if (password.isEmpty) {
      passErr = l10n.passwordRequired;
    } else if (password.length < 6) {
      passErr = l10n.passwordTooShort;
    }

    setState(() {
      _emailError = emailErr;
      _passwordError = passErr;
      _authError = null;
    });

    return emailErr == null && passErr == null;
  }

  Future<void> _login() async {
    final l10n = AppLocalizations.of(context)!;

    if (!_validateBeforeSubmit(l10n)) return;

    if (widget.portalType != 'admin' &&
        widget.portalType != 'gateway' &&
        !_agreedToTerms) {
      setState(() => _authError = l10n.authErrorTermsRequired);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.authErrorTermsRequired,
            style: const TextStyle(fontFamily: 'Cairo'),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _authError = null;
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      final portalType = widget.portalType;

      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(credential.user!.uid)
              .get();

      if (!doc.exists) {
        await FirebaseAuth.instance.signOut();
        setState(() => _authError = l10n.authErrorUserNotFound);
        return;
      }

      final data = doc.data()!;
      final role = data['role'] as String? ?? 'guest';
      final termsOk = data['terms_accepted'] == true;

      if (!termsOk) {
        await ref
            .read(termsProvider.notifier)
            .accept(uid: credential.user!.uid);
      } else {
        await ref
            .read(termsProvider.notifier)
            .syncFromFirestore(credential.user!.uid);
      }

      if (role != portalType) {
        await FirebaseAuth.instance.signOut();
        setState(() => _authError = l10n.authErrorRoleMismatch);
        return;
      }

      final uid = credential.user?.uid;
      if (uid != null) {
        ref.invalidate(userDataProvider(uid));
      }

      if (mounted) {
        HapticFeedback.mediumImpact();
        switch (role) {
          case 'student':
            context.go('/home');
            break;
          case 'faculty':
            context.go('/faculty/dashboard');
            break;
          case 'admin':
            context.go('/admin/dashboard');
            break;
          default:
            context.go('/home');
        }
      }
    } on FirebaseAuthException catch (e) {
      await FirebaseAuth.instance.signOut();
      final msg = _mapFirebaseAuthError(e, l10n);
      setState(() => _authError = msg);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg, style: const TextStyle(fontFamily: 'Cairo')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      await FirebaseAuth.instance.signOut();
      final msg = l10n.authErrorInvalidCredentials;
      setState(() => _authError = msg);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg, style: const TextStyle(fontFamily: 'Cairo')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isCompact = MediaQuery.sizeOf(context).height < 700;
    final cardVerticalPadding = isCompact ? 24.0 : 40.0;

    // ✅ إضافة isDark لاستخدامه في كامل الصفحة
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      // ✅ إزالة اللون الثابت — الـ Scaffold يأخذ لونه من الثيم تلقائياً
      resizeToAvoidBottomInset: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ✅ الدائرة العلوية — تتكيف مع الثيم
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: isDark ? 0.08 : 0.05),
                shape: BoxShape.circle,
              ),
            ).animate().fadeIn(duration: 1000.ms),
          ),
          // ✅ الدائرة السفلية — تتكيف مع الثيم
          Positioned(
            bottom: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: isDark
                    ? colorScheme.primaryContainer.withValues(alpha: 0.06)
                    : const Color(0xFFE7EEFF),
                shape: BoxShape.circle,
              ),
            ).animate().fadeIn(duration: 1200.ms),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.fromLTRB(24, 12, 24, 24 + bottomInset),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 480),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: cardVerticalPadding,
                            ),
                            decoration: BoxDecoration(
                              // ✅ لون الكارت يتبع الثيم
                              color: colorScheme.surface,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                // ✅ لون الحدود يتبع الثيم
                                color: colorScheme.outlineVariant,
                                width: 0.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isDark
                                      ? Colors.black.withValues(alpha: 0.3)
                                      : AppTheme.primaryColor.withValues(alpha: 0.08),
                                  blurRadius: 25,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // ✅ الشعار داخل دائرة تتكيف مع الثيم
                                  Container(
                                    width: isCompact ? 80 : 100,
                                    height: isCompact ? 80 : 100,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isDark
                                          ? const Color(0xFF1F2937)
                                          : Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    padding: const EdgeInsets.all(10),
                                    child: Image.asset(
                                      'assets/images/university_logo.png',
                                      fit: BoxFit.contain,
                                    ),
                                  ).animate().fadeIn(duration: 600.ms).scale(),
                                  SizedBox(height: isCompact ? 16 : 24),
                                  Text(
                                    l10n.loginTitle,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.headlineSmall?.copyWith(
                                      // ✅ لون العنوان يتبع الثيم
                                      color: colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Cairo',
                                    ),
                                  ).animate().fadeIn(delay: 200.ms),
                                  const SizedBox(height: 8),
                                  Text(
                                    l10n.loginSubtitle,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                      // ✅ لون النص الفرعي يتبع الثيم
                                      color: colorScheme.onSurfaceVariant,
                                      fontFamily: 'Cairo',
                                    ),
                                  ).animate().fadeIn(delay: 300.ms),
                                  SizedBox(height: isCompact ? 20 : 32),
                                  _buildFieldLabel(l10n.email),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: _emailController,
                                    textAlign:
                                        Directionality.of(context) ==
                                                TextDirection.rtl
                                            ? TextAlign.right
                                            : TextAlign.left,
                                    keyboardType: TextInputType.emailAddress,
                                    onChanged: (_) {
                                      if (_emailError != null) {
                                        setState(() => _emailError = null);
                                      }
                                    },
                                    validator:
                                        (v) =>
                                            Validators.validateEmail(v, l10n),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'example@uod.edu.ly',
                                      hintStyle: TextStyle(
                                        color: colorScheme.onPrimaryContainer,
                                      ),
                                      prefixIcon: Icon(
                                        Icons.mail_outline,
                                        color: colorScheme.onPrimaryContainer,
                                      ),
                                      // ✅ حقل الإيميل يبقى بلون primaryColor (كحلي) في الوضعين — مقصود للتصميم
                                      fillColor: AppTheme.primaryColor,
                                      filled: true,
                                      errorText: _emailError,
                                      errorStyle: const TextStyle(
                                        fontFamily: 'Cairo',
                                        color: Color(0xFFDC3545),
                                      ),
                                    ),
                                  ).animate().fadeIn(delay: 400.ms),
                                  const SizedBox(height: 20),
                                  _buildFieldLabel(l10n.password),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: _passwordController,
                                    obscureText: _obscurePassword,
                                    onChanged: (_) {
                                      if (_passwordError != null) {
                                        setState(() => _passwordError = null);
                                      }
                                    },
                                    validator:
                                        (v) => Validators.validatePassword(
                                          v,
                                          l10n,
                                        ),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: '••••••••',
                                      hintStyle: TextStyle(
                                        color: colorScheme.onPrimaryContainer,
                                      ),
                                      prefixIcon: Icon(
                                        Icons.lock_outline,
                                        color: colorScheme.onPrimaryContainer,
                                      ),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                          color: colorScheme.onPrimaryContainer,
                                        ),
                                        onPressed:
                                            () => setState(
                                              () =>
                                                  _obscurePassword =
                                                      !_obscurePassword,
                                            ),
                                      ),
                                      // ✅ حقل الباسورد يبقى بلون primaryColor (كحلي) في الوضعين — مقصود للتصميم
                                      fillColor: AppTheme.primaryColor,
                                      filled: true,
                                      errorText: _passwordError,
                                      errorStyle: const TextStyle(
                                        fontFamily: 'Cairo',
                                        color: Color(0xFFDC3545),
                                      ),
                                    ),
                                  ).animate().fadeIn(delay: 500.ms),
                                  if (_authError != null) ...[
                                    const SizedBox(height: 12),
                                    Text(
                                      _authError!,
                                      style: const TextStyle(
                                        color: Color(0xFFDC3545),
                                        fontFamily: 'Cairo',
                                        fontSize: 13,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                  SizedBox(height: isCompact ? 12 : 16),
                                  _buildTermsAndForgotRow(l10n),
                                  const SizedBox(height: 24),
                                  Container(
                                    height: 56,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          AppTheme.primaryColor,
                                          AppTheme.primaryContainer,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: ElevatedButton(
                                      onPressed:
                                          (!_isLoading &&
                                                  (widget.portalType ==
                                                          'admin' ||
                                                      widget.portalType ==
                                                          'gateway' ||
                                                      _agreedToTerms))
                                              ? () {
                                                HapticFeedback.lightImpact();
                                                _login();
                                              }
                                              : null,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                      ),
                                      child:
                                          _isLoading
                                              ? Shimmer.fromColors(
                                                baseColor: Colors.white24,
                                                highlightColor: Colors.white70,
                                                child: const SizedBox(
                                                  width: 28,
                                                  height: 28,
                                                  child: DecoratedBox(
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      shape: BoxShape.circle,
                                                    ),
                                                  ),
                                                ),
                                              )
                                              : Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  const Icon(Icons.login),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    l10n.loginButton,
                                                    style: const TextStyle(
                                                      fontFamily: 'Cairo',
                                                    ),
                                                  ),
                                                ],
                                              ),
                                    ),
                                  ),
                                  const SizedBox(height: 32),
                                  // 🔥 إخفاء زر إنشاء حساب للأدمن
                                  if (widget.portalType != 'admin' &&
                                      widget.portalType != 'gateway')
                                    Wrap(
                                      alignment: WrapAlignment.center,
                                      children: [
                                        TextButton(
                                          onPressed:
                                              () => context.go(
                                                '/signup?portalType=${widget.portalType}',
                                              ),
                                          child: Text(
                                            l10n.createAccount,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Cairo',
                                            ),
                                          ),
                                        ),
                                        Text(
                                          l10n.noAccount,
                                          // ✅ لون النص يتبع الثيم
                                          style: TextStyle(
                                            fontFamily: 'Cairo',
                                            color: colorScheme.onSurface,
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildSecureFooter(l10n),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 🔥 إخفاء زر "نسيت كلمة السر" ومربع الشروط للأدمن وبوابة الدخول
  Widget _buildTermsAndForgotRow(AppLocalizations l10n) {
    if (widget.portalType == 'admin' || widget.portalType == 'gateway') {
      return const SizedBox.shrink();
    }

    final forgotButton = TextButton(
      onPressed: () => context.push('/forgot-password'),
      child: Text(
        l10n.forgotPassword,
        style: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
      ),
    );

    // ✅ لون نص الشروط يتبع الثيم
    final colorScheme = Theme.of(context).colorScheme;
    final termsControl = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
          value: _agreedToTerms,
          onChanged: (v) => setState(() => _agreedToTerms = v ?? false),
        ),
        Flexible(
          child: Text(
            l10n.agreeToTerms,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12,
              color: colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 360) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: forgotButton,
              ),
              termsControl,
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: forgotButton),
            Flexible(child: termsControl),
          ],
        );
      },
    );
  }

  Widget _buildSecureFooter(AppLocalizations l10n) {
    // ✅ ألوان الفوتر تتبع الثيم
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.verified_user_outlined,
          size: 16,
          color: colorScheme.outline,
        ),
        const SizedBox(width: 8),
        Text(
          l10n.secureSystem,
          style: TextStyle(
            fontSize: 12,
            color: colorScheme.outline.withValues(alpha: 0.7),
            fontFamily: 'Cairo',
          ),
        ),
      ],
    );
  }

  Widget _buildFieldLabel(String label) {
    // ✅ لون تسميات الحقول يتبع الثيم
    final colorScheme = Theme.of(context).colorScheme;
    return Align(
      alignment:
          Directionality.of(context) == TextDirection.rtl
              ? Alignment.centerRight
              : Alignment.centerLeft,
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
          fontFamily: 'Cairo',
        ),
      ),
    );
  }
}