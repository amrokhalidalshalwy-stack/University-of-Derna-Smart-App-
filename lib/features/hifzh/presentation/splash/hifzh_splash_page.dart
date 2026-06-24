/// HifdhTracker — Splash / Onboarding Screen.
///
/// Displayed on first launch with animated Arabic calligraphy,
/// university logo, and a 3-step onboarding [PageView].
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_project/features/hifzh/core/theme/hifzh_theme.dart';
import 'package:flutter_project/features/hifzh/core/constants/hifzh_strings.dart';
import 'package:flutter_project/features/hifzh/core/router/hifzh_router.dart';

/// The splash and onboarding entry point for the HifdhTracker feature.
class HifzhSplashPage extends StatefulWidget {
  /// Creates a [HifzhSplashPage].
  const HifzhSplashPage({super.key});

  @override
  State<HifzhSplashPage> createState() => _HifzhSplashPageState();
}

class _HifzhSplashPageState extends State<HifzhSplashPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const List<_OnboardingData> _pages = [
    _OnboardingData(
      icon: Icons.auto_awesome_rounded,
      title: HifzhStrings.onboarding1Title,
      body: HifzhStrings.onboarding1Body,
    ),
    _OnboardingData(
      icon: Icons.grid_view_rounded,
      title: HifzhStrings.onboarding2Title,
      body: HifzhStrings.onboarding2Body,
    ),
    _OnboardingData(
      icon: Icons.people_alt_rounded,
      title: HifzhStrings.onboarding3Title,
      body: HifzhStrings.onboarding3Body,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      context.goNamed(HifzhRoutes.login);
    }
  }

  void _onSkip() => context.goNamed(HifzhRoutes.login);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Column(
          children: [
            // ── University Logo & App Name ────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
              child: Row(
                children: [
                  // University logo — consistent with all other screens.
                  SizedBox(
                    height: 40,
                    child: Image.asset(
                      'assets/images/university_logo.png',
                      fit: BoxFit.contain,
                      errorBuilder:
                          (_, e, s) => const Icon(
                            Icons.school_rounded,
                            color: AppColors.accentGold,
                            size: 40,
                          ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'حافظ',
                          style: Theme.of(
                            context,
                          ).textTheme.headlineLarge?.copyWith(
                            color: AppColors.onPrimary,
                            fontFamily: 'Amiri',
                          ),
                        ),
                        Text(
                          HifzhStrings.tagline,
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            color: AppColors.onPrimary.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Skip button
                  TextButton(
                    onPressed: _onSkip,
                    child: Text(
                      HifzhStrings.skip,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.accentGold,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn(duration: 800.ms),
            ),

            // ── Hero Calligraphy Art ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: _CalligraphyHero()
                  .animate()
                  .fadeIn(delay: 400.ms, duration: 800.ms)
                  .scale(
                    begin: const Offset(0.85, 0.85),
                    delay: 400.ms,
                    duration: 600.ms,
                    curve: Curves.easeOutBack,
                  ),
            ),

            // ── Onboarding PageView ───────────────────────────────────────
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _pages.length,
                itemBuilder:
                    (context, i) => _OnboardingCard(data: _pages[i], index: i),
              ),
            ),

            // ── Page Indicators + CTA ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Column(
                children: [
                  // Dot indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == i ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color:
                              _currentPage == i
                                  ? AppColors.accentGold
                                  : AppColors.onPrimary.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // CTA Button
                  ElevatedButton(
                    onPressed: _onNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      _currentPage == _pages.length - 1
                          ? HifzhStrings.getStarted
                          : 'التالي',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Hero Calligraphy Widget ───────────────────────────────────────────────────

/// Decorative Arabic calligraphy hero with a glowing ring effect.
class _CalligraphyHero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              AppColors.secondary.withValues(alpha: 0.15),
              AppColors.primary,
            ],
          ),
          border: Border.all(
            color: AppColors.accentGold.withValues(alpha: 0.5),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondary.withValues(alpha: 0.3),
              blurRadius: 40,
              spreadRadius: 10,
            ),
          ],
        ),
        child: const Center(
          child: Text(
            'بِسۡمِ ٱللَّهِ\nٱلرَّحۡمَـٰنِ ٱلرَّحِيمِ',
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 20,
              color: AppColors.onPrimary,
              fontWeight: FontWeight.bold,
              height: 1.8,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Onboarding Card ───────────────────────────────────────────────────────────

/// A single onboarding page with icon, title, and description.
class _OnboardingCard extends StatelessWidget {
  const _OnboardingCard({required this.data, required this.index});

  final _OnboardingData data;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.accentGold.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(data.icon, size: 48, color: AppColors.accentGold),
              )
              .animate(key: ValueKey(index))
              .scale(duration: 400.ms, curve: Curves.easeOutBack),
          const SizedBox(height: 24),
          Text(
            data.title,
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppColors.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ).animate(key: ValueKey('t$index')).fadeIn(delay: 200.ms),
          const SizedBox(height: 12),
          Text(
            data.body,
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.onPrimary.withValues(alpha: 0.75),
              height: 1.6,
            ),
          ).animate(key: ValueKey('b$index')).fadeIn(delay: 300.ms),
        ],
      ),
    );
  }
}

/// Data class for a single onboarding page.
class _OnboardingData {
  const _OnboardingData({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;
}
