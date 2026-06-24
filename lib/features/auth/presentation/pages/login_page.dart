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
import 'package:flutter_project/shared/validators/form_validators.dart';
import 'package:flutter_project/l10n/app_localizations.dart';

class LoginPage extends ConsumerStatefulWidget {
  final String? role;
  const LoginPage({super.key, this.role});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _isLoading = false;

  bool _obscurePassword = true;

  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login(AppLocalizations l10n) async {
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      final portalType = widget.role ?? 'student';

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
        throw Exception('user_not_found');
      }

      final role = doc.data()?['role'] as String? ?? 'guest';
      final status = doc.data()?['status'] as String? ?? 'pending_final_approval';

      if (role != portalType) {
        await FirebaseAuth.instance.signOut();
        throw Exception('role_mismatch');
      }

      if (status != 'approved') {
        await FirebaseAuth.instance.signOut();
        throw Exception('account_not_approved');
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

      if (mounted) {
        setState(() {
          final code = e.code;
          final isAr = Localizations.localeOf(context).languageCode == 'ar';

          switch (code) {
            case 'invalid-email':
            case 'user-not-found':
            case 'wrong-password':
            case 'invalid-credential':
              _passwordError =
                  isAr
                      ? 'البريد الإلكتروني أو كلمة المرور غير صحيحة'
                      : 'Incorrect email or password';
              break;

            case 'too-many-requests':
              _passwordError =
                  isAr
                      ? 'تم حظر المحاولات مؤقتاً لكثرة الأخطاء. يرجى المحاولة لاحقاً'
                      : 'Too many unsuccessful attempts. Please try again later.';
              break;

            case 'user-disabled':
              _emailError =
                  isAr
                      ? 'هذا الحساب تم تعطيله، يرجى مراسلة الدعم'
                      : 'This account has been disabled. Please contact support.';
              break;

            case 'network-request-failed':
              _emailError =
                  isAr
                      ? 'تحقق من اتصالك بالإنترنت'
                      : 'Check your internet connection';
              break;

            default:
              _passwordError =
                  isAr
                      ? 'حدث خطأ أثناء تسجيل الدخول، يرجى المحاولة لاحقاً'
                      : 'An error occurred during login. Please try again later.';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          final isAr = Localizations.localeOf(context).languageCode == 'ar';
          final err = e.toString();

          if (err.contains('role_mismatch')) {
            _emailError =
                isAr
                    ? 'ليس لديك صلاحية الدخول لهذه البوابة'
                    : 'You are not authorized for this portal';
          } else if (err.contains('account_not_approved')) {
            _emailError =
                isAr
                    ? 'الحساب تحت المراجعة أو تم رفضه'
                    : 'Account is under review or has been rejected';
          } else if (err.contains('user_not_found')) {
            _passwordError =
                isAr
                    ? 'البريد الإلكتروني أو كلمة المرور غير صحيحة'
                    : 'Incorrect email or password';
          } else {
            _passwordError =
                isAr
                    ? 'حدث خطأ، حاول مجدداً'
                    : 'An error occurred, please try again';
          }
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final isFaculty = widget.role == 'faculty';
    final isAdmin = widget.role == 'admin';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ── خلفية الصفحة ──────────────────────────────────────────────────────
    final Color? scaffoldBg =
        isAdmin
            ? const Color(0xFF070B14)
            : isFaculty
            ? (isDark ? const Color(0xFF071A18) : const Color(0xFFF0FAFA))
            : (isDark ? const Color(0xFF0A0E1A) : null);

    // ── دوائر الخلفية ─────────────────────────────────────────────────────
    final bgCircle1 =
        isAdmin
            ? const Color(0xFF8B3DFF).withValues(alpha: 0.2)
            : isFaculty
            ? const Color(0xFF00A694).withValues(alpha: isDark ? 0.18 : 0.1)
            : AppTheme.primaryContainer.withValues(alpha: isDark ? 0.12 : 0.05);

    final bgCircle2 =
        isAdmin
            ? const Color(0xFF00E5FF).withValues(alpha: 0.15)
            : isFaculty
            ? (isDark ? const Color(0xFF0D2B28) : const Color(0xFFE8F8F5))
            : (isDark ? const Color(0xFF1A2744) : const Color(0xFFE7EEFF));

    // ── لون الكارت ────────────────────────────────────────────────────────
    final cardColor =
        isAdmin
            ? const Color(0xFF0F1423)
            : isFaculty
            ? (isDark ? const Color(0xFF0D2420) : Colors.white)
            : (isDark ? const Color(0xFF111827) : Colors.white);

    // ── حدود الكارت ───────────────────────────────────────────────────────
    final cardBorder =
        isAdmin
            ? const Color(0xFF8B3DFF).withValues(alpha: 0.5)
            : isFaculty
            ? const Color(0xFF00A694).withValues(alpha: isDark ? 0.5 : 0.3)
            : (isDark
                ? AppTheme.primaryColor.withValues(alpha: 0.3)
                : AppTheme.outlineVariantColor);

    // ── ألوان النصوص ──────────────────────────────────────────────────────
    final titleColor =
        isAdmin
            ? Colors.white
            : isFaculty
            ? (isDark ? const Color(0xFF4DFFD6) : const Color(0xFF001835))
            : (isDark ? Colors.white : AppTheme.primaryColor);

    final subtitleColor =
        isAdmin
            ? Colors.white70
            : (isDark ? Colors.white60 : AppTheme.onSurfaceVariantColor);

    final labelColor =
        isAdmin
            ? Colors.white
            : (isDark ? Colors.white70 : AppTheme.onSurfaceColor);

    // ── لون حقول الإدخال ──────────────────────────────────────────────────
    final fieldBgColor =
        isAdmin
            ? const Color(0xFF1E2536)
            : isFaculty
            ? (isDark ? const Color(0xFF0A3330) : const Color(0xFF00695C))
            : (isDark ? const Color(0xFF1E3A5F) : AppTheme.primaryColor);

    // ── تدرج زر الدخول ────────────────────────────────────────────────────
    final btnGradColors =
        isAdmin
            ? [const Color(0xFF8B3DFF), const Color(0xFF00E5FF)]
            : isFaculty
            ? (isDark
                ? [const Color(0xFF00695C), const Color(0xFF4DFFD6)]
                : [const Color(0xFF001835), const Color(0xFF00A694)])
            : (isDark
                ? [const Color(0xFF1565C0), const Color(0xFF42A5F5)]
                : [AppTheme.primaryColor, AppTheme.primaryContainer]);

    // ── ظل الكارت ─────────────────────────────────────────────────────────
    final cardShadowColor =
        isAdmin
            ? const Color(0xFF8B3DFF).withValues(alpha: 0.15)
            : isFaculty
            ? const Color(0xFF00A694).withValues(alpha: isDark ? 0.2 : 0.08)
            : AppTheme.primaryColor.withValues(alpha: isDark ? 0.2 : 0.08);

    final displayTitle =
        isAdmin
            ? l10n.authLoginAdminTitle
            : (isFaculty ? l10n.authLoginFacultyTitle : l10n.authWelcomeTitle);
    final displaySubtitle =
        isAdmin
            ? l10n.authLoginAdminSubtitle
            : (isFaculty
                ? l10n.authLoginFacultySubtitle
                : l10n.authWelcomeSubtitle);

    final viewHeight = MediaQuery.sizeOf(context).height;
    final isCompact = viewHeight < 700;
    final cardVerticalPadding = isCompact ? 24.0 : 40.0;

    return Scaffold(
      backgroundColor: scaffoldBg,
      resizeToAvoidBottomInset: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── دائرة الخلفية العلوية ────────────────────────────────────────
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: bgCircle1,
                shape: BoxShape.circle,
              ),
            ).animate().fadeIn(duration: 1000.ms),
          ),
          // ── دائرة الخلفية السفلية ────────────────────────────────────────
          Positioned(
            bottom: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: bgCircle2,
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
                  padding: EdgeInsetsDirectional.fromSTEB(
                    24,
                    12,
                    24,
                    24 + bottomInset,
                  ),
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
                              color: cardColor,
                              borderRadius: BorderRadius.circular(
                                isAdmin ? 32 : 24,
                              ),
                              border: Border.all(
                                color: cardBorder,
                                width: isAdmin ? 1 : 0.8,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: cardShadowColor,
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
                                  // ── الشعار / الأيقونة ─────────────────────
                                  if (isAdmin)
                                    Icon(
                                      Icons.admin_panel_settings_rounded,
                                      size: isCompact ? 64 : 80,
                                      color: const Color(0xFF00E5FF),
                                    ).animate().shimmer(
                                      duration: 2.seconds,
                                      color: Colors.white,
                                    )
                                  else if (isFaculty)
                                    // ✅ شعار faculty مع دعم الوضع الداكن
                                    Container(
                                      padding: EdgeInsets.all(isDark ? 0 : 12),
                                      decoration: BoxDecoration(
                                        color:
                                            isDark
                                                ? Colors.transparent
                                                : const Color(
                                                  0xFF00A694,
                                                ).withValues(alpha: 0.08),
                                        shape: BoxShape.circle,
                                        border:
                                            isDark
                                                ? Border.all(
                                                  color: const Color(
                                                    0xFF00A694,
                                                  ).withValues(alpha: 0.4),
                                                  width: 1.5,
                                                )
                                                : null,
                                      ),
                                      child: Image.asset(
                                        isDark
                                            ? 'assets/images/university_logo_dark.png'
                                            : 'assets/images/university_logo.png',
                                        width: isCompact ? 70 : 90,
                                        height: isCompact ? 70 : 90,
                                        fit: BoxFit.contain,
                                      ),
                                    ).animate().fadeIn(duration: 600.ms).scale()
                                  else
                                    // ✅ شعار student مع دعم الوضع الداكن
                                    Image.asset(
                                      isDark
                                          ? 'assets/images/university_logo_dark.png'
                                          : 'assets/images/university_logo.png',
                                      width: isCompact ? 100 : 120,
                                      height: isCompact ? 100 : 120,
                                      fit: BoxFit.contain,
                                    ).animate().fadeIn(duration: 600.ms).scale(),

                                  SizedBox(height: isCompact ? 16 : 24),

                                  // ── العنوان ───────────────────────────────
                                  Text(
                                        displayTitle,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.headlineSmall?.copyWith(
                                          color: titleColor,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Cairo',
                                        ),
                                      )
                                      .animate()
                                      .fadeIn(delay: 200.ms)
                                      .slideY(begin: 0.1),
                                  const SizedBox(height: 8),
                                  Text(
                                    displaySubtitle,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: subtitleColor,
                                      fontFamily: 'Cairo',
                                    ),
                                  ).animate().fadeIn(delay: 300.ms),
                                  SizedBox(height: isCompact ? 20 : 32),

                                  // ── حقل البريد الإلكتروني ─────────────────
                                  _buildFieldLabel(l10n.email, labelColor),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                        controller: _emailController,
                                        textAlign:
                                            Directionality.of(context) ==
                                                    TextDirection.rtl
                                                ? TextAlign.right
                                                : TextAlign.left,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        validator:
                                            (v) => Validators.validateEmail(
                                              v,
                                              l10n,
                                            ),
                                        onChanged: (_) {
                                          if (_emailError != null) {
                                            setState(() => _emailError = null);
                                          }
                                        },
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                        cursorColor: Colors.white,
                                        decoration: InputDecoration(
                                          hintText: l10n.authLoginEmailHint,
                                          hintStyle: const TextStyle(
                                            color: Colors.white60,
                                          ),
                                          prefixIcon: const Icon(
                                            Icons.mail_outline,
                                            color: Colors.white70,
                                          ),
                                          fillColor: fieldBgColor,
                                          filled: true,
                                          errorText: _emailError,
                                          errorStyle: TextStyle(
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.error,
                                            fontSize: 12,
                                            fontFamily: 'Cairo',
                                          ),
                                        ),
                                      )
                                      .animate()
                                      .fadeIn(delay: 400.ms)
                                      .slideX(begin: 0.1),

                                  const SizedBox(height: 20),

                                  // ── حقل كلمة المرور ───────────────────────
                                  _buildFieldLabel(l10n.password, labelColor),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                        controller: _passwordController,
                                        obscureText: _obscurePassword,
                                        validator:
                                            (v) => Validators.validatePassword(
                                              v,
                                              l10n,
                                            ),
                                        onChanged: (_) {
                                          if (_passwordError != null) {
                                            setState(
                                              () => _passwordError = null,
                                            );
                                          }
                                        },
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                        cursorColor: Colors.white,
                                        decoration: InputDecoration(
                                          hintText: '••••••••',
                                          hintStyle: const TextStyle(
                                            color: Colors.white60,
                                          ),
                                          prefixIcon: const Icon(
                                            Icons.lock_outline,
                                            color: Colors.white70,
                                          ),
                                          fillColor: fieldBgColor,
                                          filled: true,
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              _obscurePassword
                                                  ? Icons.visibility_off
                                                  : Icons.visibility,
                                              color: Colors.white70,
                                              size: 20,
                                            ),
                                            onPressed:
                                                () => setState(
                                                  () =>
                                                      _obscurePassword =
                                                          !_obscurePassword,
                                                ),
                                          ),
                                          errorText: _passwordError,
                                          errorStyle: TextStyle(
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.error,
                                            fontSize: 12,
                                            fontFamily: 'Cairo',
                                          ),
                                        ),
                                      )
                                      .animate()
                                      .fadeIn(delay: 500.ms)
                                      .slideX(begin: 0.1),

                                  SizedBox(height: isCompact ? 12 : 16),
                                  _buildTermsAndForgotRow(
                                    l10n,
                                    subtitleColor,
                                  ).animate().fadeIn(delay: 600.ms),
                                  const SizedBox(height: 24),

                                  // ── زر الدخول ─────────────────────────────
                                  Container(
                                        height: 56,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: btnGradColors,
                                            begin:
                                                AlignmentDirectional
                                                    .centerStart,
                                            end: AlignmentDirectional.centerEnd,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: btnGradColors.first
                                                  .withValues(alpha: 0.35),
                                              blurRadius: 12,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: ElevatedButton(
                                          onPressed:
                                              _isLoading
                                                  ? null
                                                  : ((widget.role == 'admin' ||
                                                          widget.role ==
                                                              'gateway' ||
                                                          _rememberMe)
                                                      ? () {
                                                        HapticFeedback.lightImpact();
                                                        _login(l10n);
                                                      }
                                                      : null),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.transparent,
                                            shadowColor: Colors.transparent,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                          ),
                                          child:
                                              _isLoading
                                                  ? Shimmer.fromColors(
                                                    baseColor: Colors.white24,
                                                    highlightColor:
                                                        Colors.white70,
                                                    child: const SizedBox(
                                                      width: 28,
                                                      height: 28,
                                                      child: DecoratedBox(
                                                        decoration:
                                                            BoxDecoration(
                                                              color:
                                                                  Colors.white,
                                                              shape:
                                                                  BoxShape
                                                                      .circle,
                                                            ),
                                                      ),
                                                    ),
                                                  )
                                                  : Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      const Icon(
                                                        Icons.login,
                                                        color: Colors.white,
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        l10n.loginButton,
                                                        style: const TextStyle(
                                                          fontFamily: 'Cairo',
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                        ),
                                      )
                                      .animate()
                                      .slideY(begin: 0.1, delay: 700.ms)
                                      .fadeIn(delay: 700.ms),

                                  const SizedBox(height: 32),

                                  // ── رابط إنشاء حساب ───────────────────────
                                  if (widget.role != 'admin' &&
                                      widget.role != 'gateway')
                                    Wrap(
                                      alignment: WrapAlignment.center,
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      spacing: 4,
                                      runSpacing: 4,
                                      children: [
                                        TextButton(
                                          onPressed:
                                              () => context.go(
                                                '/signup?portalType=${widget.role ?? 'student'}',
                                              ),
                                          style: TextButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            minimumSize: Size.zero,
                                            tapTargetSize:
                                                MaterialTapTargetSize
                                                    .shrinkWrap,
                                            foregroundColor:
                                                isFaculty && isDark
                                                    ? const Color(0xFF4DFFD6)
                                                    : null,
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
                                          style: TextStyle(
                                            fontFamily: 'Cairo',
                                            color: subtitleColor,
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
                        _buildSecureFooter(l10n, subtitleColor),
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

  Widget _buildTermsAndForgotRow(AppLocalizations l10n, Color subtitleColor) {
    if (widget.role == 'admin' || widget.role == 'gateway') {
      return const SizedBox.shrink();
    }

    final forgotButton = TextButton(
      onPressed: () => context.push('/forgot-password'),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        l10n.forgotPassword,
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 13,
          color: subtitleColor,
        ),
      ),
    );

    final termsControl = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
          value: _rememberMe,
          onChanged: (v) => setState(() => _rememberMe = v ?? false),
          side: BorderSide(color: subtitleColor),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        ),
        Flexible(
          child: Text(
            l10n.agreeToTerms,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13,
              color: subtitleColor,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
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
            Expanded(
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: forgotButton,
              ),
            ),
            Flexible(child: termsControl),
          ],
        );
      },
    );
  }

  Widget _buildSecureFooter(AppLocalizations l10n, Color subtitleColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.verified_user_outlined,
          size: 16,
          color: subtitleColor.withValues(alpha: 0.7),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            l10n.secureSystem,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: subtitleColor.withValues(alpha: 0.6),
              fontFamily: 'Cairo',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFieldLabel(String label, Color color) {
    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: color,
          fontFamily: 'Cairo',
        ),
      ),
    );
  }
}
