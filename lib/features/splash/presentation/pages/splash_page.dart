import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_project/core/widgets/glass_card.dart';
import 'package:flutter_project/l10n/app_localizations.dart';
import 'package:flutter_project/core/services/audio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_project/core/preferences/app_preferences.dart';
import 'package:flutter_project/core/localization/locale_provider.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final themeMode = ref.watch(themeModeNotifierProvider);
    final locale = ref.watch(localeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRtl = locale.languageCode == 'ar';

    final bgColor = isDark ? const Color(0xFF0D1B2A) : const Color(0xFFF7F9FB);
    final btnBg = isDark ? const Color(0xFF1E3A5F) : const Color(0xFF001835);
    final btnFg = Colors.white;
    final btnBorder = isDark ? const Color(0xFF3A6491) : const Color(0xFF0F2D52);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // خلفية ديناميكية
          Positioned.fill(child: Container(color: bgColor)),

          Positioned(
            top: -100,
            left: -100,
            child: Container(
                  width: 400,
                  height: 400,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F2D52).withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                  ),
                )
                .animate()
                .fadeIn(duration: 1000.ms)
                .scale(begin: const Offset(0.8, 0.8)),
          ),

          Positioned(
            bottom: -100,
            right: -100,
            child: Container(
                  width: 400,
                  height: 400,
                  decoration: BoxDecoration(
                    color: const Color(0xFF79F7E3).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                )
                .animate()
                .fadeIn(duration: 1200.ms)
                .scale(begin: const Offset(0.7, 0.7)),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
                child: Column(
                  children: [
                    // ── تعديل جزئية الحاوية لتدعم شعار الوضع الداكن بذكاء ──
                    Container(
                      // تكبير أبعاد الحاوية وتصفير الـ padding في الوضع الداكن ليتمدد الشعار المفرغ بشكل ممتاز
                      width: isDark ? 210 : 180,
                      height: isDark ? 210 : 180,
                      decoration: BoxDecoration(
                        // خلفية شفافة بالكامل في الـ Dark Mode ليظهر الشعار مفرغاً وأنيقاً
                        color: isDark ? Colors.transparent : Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: isDark 
                                ? Colors.black.withValues(alpha: 0.25)
                                : Colors.black.withValues(alpha: 0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.all(isDark ? 0 : 20),
                      child: Image.asset(
                        // تبديل مسار الشعار تلقائياً بناءً على الثيم الحالي
                        isDark
                            ? 'assets/images/university_logo_dark.png'
                            : 'assets/images/university_logo.png',
                        fit: BoxFit.contain,
                      ),
                    ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.2),

                    const SizedBox(height: 32),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFED65B),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        l10n.appWelcomeTag,
                        style: const TextStyle(
                          color: Color(0xFF745C00),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ).animate().fadeIn(delay: 400.ms),

                    const SizedBox(height: 48),

                    GlassCard(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.format_quote,
                            size: 60,
                            color: Color(0x1A000000),
                          ),

                          Text(
                            l10n.appMotto,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF001835),
                              fontFamily: 'Cairo',
                            ),
                          ).animate().fadeIn(delay: 600.ms),

                          const SizedBox(height: 24),

                          Text(
                            l10n.appWelcomeBody,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF374151),
                              height: 1.6,
                            ),
                          ).animate().fadeIn(delay: 800.ms),

                          const SizedBox(height: 40),

                          ElevatedButton(
                                onPressed: () async {
                                  await AudioService().playStartupSound();
                                  if (!context.mounted) return;
                                  context.go('/gateway');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF001835),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 20,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        l10n.openHorizons,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Icon(
                                      Directionality.of(context) ==
                                              TextDirection.rtl
                                          ? Icons.arrow_back
                                          : Icons.arrow_forward,
                                    ),
                                  ],
                                ),
                              )
                              .animate()
                              .fadeIn(delay: 1000.ms)
                              .scale(delay: 1000.ms),

                          const SizedBox(height: 36),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 4,
                                    height: 22,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFED65B),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    l10n.universityStats,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          isDark
                                              ? Colors.white
                                              : const Color(0xFFFED65B),
                                      fontFamily: 'Cairo',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              Row(
                                children: [
                                  _buildStatCard(
                                    icon: Icons.school_rounded,
                                    number: '7,452+',
                                    label: l10n.studentsCount,
                                    iconColor: const Color(0xFF0F6CBD),
                                    bgColor: const Color(0xFFEBF4FF),
                                  ),
                                  const SizedBox(width: 10),
                                  _buildStatCard(
                                    icon: Icons.account_balance_rounded,
                                    number: '17',
                                    label: l10n.collegesCount,
                                    iconColor: const Color(0xFF0A7A55),
                                    bgColor: const Color(0xFFE8F8F2),
                                  ),
                                  const SizedBox(width: 10),
                                  _buildStatCard(
                                    icon: Icons.groups_rounded,
                                    number: '791+',
                                    label: l10n.facultyCount,
                                    iconColor: const Color(0xFF8B3DFF),
                                    bgColor: const Color(0xFFF3EBFF),
                                  ),
                                ],
                              ),
                            ],
                          ).animate().fadeIn(delay: 1200.ms).slideY(begin: 0.2),
                        ],
                      ),
                    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1),
                  ],
                ),
              ),
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        l10n.privacy,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        l10n.termsOfService,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.rightsReserved,
                    style: TextStyle(
                      fontSize: 10,
                      color: const Color(0xFF001835).withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(delay: 1500.ms),

          Positioned(
            top: 16,
            right: isRtl ? null : 16,
            left: isRtl ? 16 : null,
            child: SafeArea(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── زر اللغة ──
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      final currentLocale = locale.languageCode;
                      final newLocale = currentLocale == 'ar' ? 'en' : 'ar';
                      ref
                          .read(localeProvider.notifier)
                          .setLocale(Locale(newLocale));
                    },
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: btnBg,
                        shape: BoxShape.circle,
                        border: Border.all(color: btnBorder, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          locale.languageCode == 'ar' ? 'EN' : 'ع',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: btnFg,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // ── زر الثيم ──
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      final newMode = switch (themeMode) {
                        ThemeMode.light => ThemeMode.dark,
                        ThemeMode.dark => ThemeMode.light,
                        ThemeMode.system => ThemeMode.dark,
                      };
                      ref
                          .read(themeModeNotifierProvider.notifier)
                          .setThemeMode(newMode);
                    },
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: btnBg,
                        shape: BoxShape.circle,
                        border: Border.all(color: btnBorder, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 280),
                          transitionBuilder: (child, animation) {
                            return RotationTransition(
                              turns: animation,
                              child: ScaleTransition(
                                scale: animation,
                                child: child,
                              ),
                            );
                          },
                          child: Icon(
                            isDark
                                ? Icons.light_mode_outlined
                                : Icons.dark_mode_outlined,
                            key: ValueKey(themeMode),
                            size: 20,
                            color: btnFg,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn(
                delay: 200.ms,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String number,
    required String label,
    required Color iconColor,
    required Color bgColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: iconColor.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border.all(
            color: iconColor.withValues(alpha: 0.12),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(height: 12),
            Text(
              number,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: iconColor,
                fontFamily: 'Cairo',
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF6B7280),
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
