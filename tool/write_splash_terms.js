var fs = require("fs");
var splash = `import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_project/features/auth/presentation/providers/terms_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), _navigateNext);
  }

  void _navigateNext() {
    if (!mounted) return;
    final termsAccepted = ref.read(termsProvider);
    if (termsAccepted) {
      context.go('/gateway');
    } else {
      context.go('/terms');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B4F8C),
      body: Center(
        child: Image.asset(
          'assets/images/university_logo.png',
          width: 160,
          height: 160,
        )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .scale(
              begin: const Offset(0.92, 0.92),
              end: const Offset(1.08, 1.08),
              duration: 1200.ms,
              curve: Curves.easeInOut,
            )
            .fadeIn(duration: 600.ms),
      ),
    );
  }
}
`;
fs.writeFileSync("lib/features/splash/splash_screen.dart", splash);
var terms = `import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_project/features/auth/presentation/providers/terms_provider.dart';
import 'package:flutter_project/l10n/app_localizations.dart';

class TermsPermissionsPage extends ConsumerStatefulWidget {
  const TermsPermissionsPage({super.key});

  @override
  ConsumerState<TermsPermissionsPage> createState() =>
      _TermsPermissionsPageState();
}

class _TermsPermissionsPageState extends ConsumerState<TermsPermissionsPage> {
  bool _checked = false;
  bool _saving = false;

  Future<void> _continue() async {
    if (!_checked) return;
    setState(() => _saving = true);
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      await ref.read(termsProvider.notifier).accept(uid: uid);
      if (!mounted) return;
      context.go('/gateway');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFF1B4F8C),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: Text(
          l10n.termsOfService,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.authTermsAndConditions,
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF001835),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.legalAgreement,
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 14,
                            height: 1.6,
                            color: Color(0xFF43474E),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              CheckboxListTile(
                value: _checked,
                onChanged: (v) => setState(() => _checked = v ?? false),
                title: Text(
                  l10n.agreeToTerms,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: const Color(0xFFFED65B),
                checkColor: const Color(0xFF001835),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: (_checked && !_saving) ? _continue : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFED65B),
                    foregroundColor: const Color(0xFF001835),
                    disabledBackgroundColor: Colors.white24,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          l10n.termsContinue,
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
`;
fs.writeFileSync("lib/features/auth/presentation/widgets/terms_permissions_page.dart", terms);
console.log("ok");
