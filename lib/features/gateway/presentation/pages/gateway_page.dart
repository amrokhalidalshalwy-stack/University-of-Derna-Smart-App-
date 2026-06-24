// ═══════════════════════════════════════════════════════════════════════════
// gateway_page.dart
// بوابة جامعة درنة الذكية — Smart Gateway Portal
//
// Entry point for role selection: Student, Faculty, Admin, Guest.
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_project/l10n/app_localizations.dart';
import 'package:flutter_project/core/services/audio_service.dart';

enum _PortalKind { student, faculty, admin }

// ─── Portal data model ───────────────────────────────────────────────────────
class _PortalInfo {
  final String title;
  final String description;
  final IconData icon;
  final Color iconColor;
  // ✅ تم حذف bgColor الثابت — سيتم حسابه ديناميكياً بناءً على الثيم
  final bool available;
  final _PortalKind portalKind;

  const _PortalInfo({
    required this.title,
    required this.description,
    required this.icon,
    required this.iconColor,
    required this.available,
    required this.portalKind,
  });
}

List<_PortalInfo> _portalsFor(AppLocalizations l10n) => [
  _PortalInfo(
    title: l10n.studentPortal,
    description: l10n.studentPortalDesc,
    icon: Icons.school_rounded,
    iconColor: const Color(0xFF0F6CBD),
    available: true,
    portalKind: _PortalKind.student,
  ),
  _PortalInfo(
    title: l10n.facultyPortal,
    description: l10n.facultyPortalDesc,
    icon: Icons.account_balance_rounded,
    iconColor: const Color(0xFF00A694),
    available: true,
    portalKind: _PortalKind.faculty,
  ),
  _PortalInfo(
    title: l10n.adminPortal,
    description: l10n.adminPortalDesc,
    icon: Icons.admin_panel_settings_rounded,
    iconColor: const Color(0xFF8B3DFF),
    available: true,
    portalKind: _PortalKind.admin,
  ),
];

// ✅ دالة مساعدة: تُرجع لون خلفية الأيقونة بحسب الثيم
Color _portalBgColor(_PortalKind kind, bool isDark) {
  switch (kind) {
    case _PortalKind.student:
      return isDark ? const Color(0xFF1A2744) : const Color(0xFFEBF4FF);
    case _PortalKind.faculty:
      return isDark ? const Color(0xFF0D2B28) : const Color(0xFFE8F8F5);
    case _PortalKind.admin:
      return isDark
          ? const Color(0xFF8B3DFF).withValues(alpha: 0.1)
          : const Color(0xFFF3EBFF);
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// GatewayPage
// ═══════════════════════════════════════════════════════════════════════════
class GatewayPage extends StatefulWidget {
  const GatewayPage({super.key});

  @override
  State<GatewayPage> createState() => _GatewayPageState();
}

class _GatewayPageState extends State<GatewayPage>
    with TickerProviderStateMixin {
  // ── Animation controllers ─────────────────────────────────────────────────
  late final AnimationController _logoFloatCtrl;
  late final AnimationController _orbCtrl;
  late final AnimationController _cardsCtrl;

  // ── Derived animations ────────────────────────────────────────────────────
  late final Animation<double> _logoFloat;
  late final Animation<double> _orbScale;

  // Per-card entrance animations (fade + slide)
  late final List<Animation<double>> _cardOpacity;
  late final List<Animation<Offset>> _cardSlide;

  @override
  void initState() {
    super.initState();

    AudioService()
        .initialize()
        .then((_) {
          debugPrint('🎵 [GatewayPage] Audio service initialized');
        })
        .catchError((e) {
          debugPrint('❌ [GatewayPage] Failed to initialize audio service: $e');
        });

    _logoFloatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    _logoFloat = Tween<double>(
      begin: -6.0,
      end: 6.0,
    ).animate(CurvedAnimation(parent: _logoFloatCtrl, curve: Curves.easeInOut));

    _orbCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat(reverse: true);

    _orbScale = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _orbCtrl, curve: Curves.easeInOut));

    _cardsCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();

    _cardOpacity = List.generate(3, (i) {
      final start = i * 0.2;
      final end = start + 0.5;
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _cardsCtrl,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      );
    });

    _cardSlide = List.generate(3, (i) {
      final start = i * 0.2;
      final end = start + 0.5;
      return Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _cardsCtrl,
          curve: Interval(start, end, curve: Curves.easeOutCubic),
        ),
      );
    });
  }

  @override
  void dispose() {
    _logoFloatCtrl.dispose();
    _orbCtrl.dispose();
    _cardsCtrl.dispose();
    AudioService().dispose();
    super.dispose();
  }

  void _onPortalTap(int index) async {
    HapticFeedback.mediumImpact();
    if (!mounted) return;
    final roles = ['student', 'faculty', 'admin'];
    context.push('/login?role=${roles[index]}');
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final l10n = AppLocalizations.of(context)!;
    final portals = _portalsFor(l10n);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // ✅ لون الخلفية يتبع الثيم بدلاً من اللون الثابت
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          _buildBackground(size, isDark),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              child: Column(
                children: [
                  _buildHeader(l10n, isDark),
                  const SizedBox(height: 36),
                  _buildPortalCards(portals, l10n),
                  const SizedBox(height: 28),
                  _buildGuestButton(l10n, isDark),
                  const SizedBox(height: 40),
                  _buildFooter(isDark),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Animated background orbs ─────────────────────────────────────────────
  Widget _buildBackground(Size size, bool isDark) {
    return AnimatedBuilder(
      animation: _orbScale,
      builder: (context, child) {
        return Stack(
          children: [
            Positioned(
              top: -size.width * 0.25,
              left: -size.width * 0.25,
              child: Transform.scale(
                scale: _orbScale.value,
                child: Container(
                  width: size.width * 0.7,
                  height: size.width * 0.7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        // ✅ شدة الـ orbs تتكيف مع الثيم
                        const Color(
                          0xFF0F2D52,
                        ).withValues(alpha: isDark ? 0.12 : 0.07),
                        const Color(0xFF0F2D52).withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -size.width * 0.3,
              right: -size.width * 0.3,
              child: Transform.scale(
                scale: 2.0 - _orbScale.value,
                child: Container(
                  width: size.width * 0.8,
                  height: size.width * 0.8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(
                          0xFF00A694,
                        ).withValues(alpha: isDark ? 0.12 : 0.08),
                        const Color(0xFF00A694).withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: size.height * 0.35,
              right: -size.width * 0.12,
              child: Container(
                width: size.width * 0.35,
                height: size.width * 0.35,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(
                        0xFFFED65B,
                      ).withValues(alpha: isDark ? 0.08 : 0.06),
                      const Color(0xFFFED65B).withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader(AppLocalizations l10n, bool isDark) {
    return Column(
      children: [
        const SizedBox(height: 8),

        AnimatedBuilder(
          animation: _logoFloat,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _logoFloat.value),
              child: child,
            );
          },
          child: Container(
            // ✅ تكبير الحجم وتعديل الـ padding لتعديل حجم الشعار في الوضع الداكن
            width: isDark ? 140 : 110,
            height: isDark ? 140 : 110,
            decoration: BoxDecoration(
              color: isDark ? Colors.transparent : Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(
                    0xFF001835,
                  ).withValues(alpha: isDark ? 0.4 : 0.12),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: const Color(
                    0xFF00A694,
                  ).withValues(alpha: isDark ? 0.12 : 0.08),
                  blurRadius: 40,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            padding: EdgeInsets.all(isDark ? 2 : 18),
            child: Image.asset(
              isDark
                  ? 'images/university_logo_dark.png' // 👈 قمنا بحذف كلمة assets/ الأولى
                  : 'images/university_logo.png', // 👈 قمنا بحذف كلمة assets/ الأولى
              fit: BoxFit.contain,
            ),
          ),
        ), // القوس الخاص بإغلاق الـ AnimatedBuilder

        const SizedBox(height: 2),

        // Badge — لونه ثابت (مقصود للهوية البصرية)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFFED65B),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Text(
            l10n.gatewayUniversityBadge,
            style: const TextStyle(
              color: Color(0xFF745C00),
              fontWeight: FontWeight.bold,
              fontSize: 12,
              fontFamily: 'Cairo',
            ),
          ),
        ),

        const SizedBox(height: 16),

        Text(
          l10n.gatewayMainTitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
            fontFamily: 'Cairo',
            height: 1.3,
          ),
        ),

        const SizedBox(height: 10),

        Text(
          l10n.gatewaySubtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color:
                isDark
                    ? Colors.white60
                    : const Color(0xFF001835).withValues(alpha: 0.7),
            fontFamily: 'Cairo',
            height: 1.5,
          ),
        ),
      ],
    );
  }

  // ── Portal cards ──────────────────────────────────────────────────────────
  Widget _buildPortalCards(List<_PortalInfo> portals, AppLocalizations l10n) {
    return Column(
      children: List.generate(portals.length, (i) {
        return Padding(
          padding: EdgeInsets.only(bottom: i < portals.length - 1 ? 16 : 0),
          child: FadeTransition(
            opacity: _cardOpacity[i],
            child: SlideTransition(
              position: _cardSlide[i],
              child: _PortalCard(
                info: portals[i],
                l10n: l10n,
                onTap: () => _onPortalTap(i),
              ),
            ),
          ),
        );
      }),
    );
  }

  // ✅ تم إضافة isDark للمعامل
  Widget _buildGuestButton(AppLocalizations l10n, bool isDark) {
    return FadeTransition(
      opacity: _cardOpacity[2],
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Divider(
                  color: const Color(0xFF74777F).withValues(alpha: 0.25),
                  thickness: 1,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  l10n.guestPortalDivider,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    color: const Color(0xFF74777F).withValues(alpha: 0.6),
                    fontSize: 13,
                  ),
                ),
              ),
              Expanded(
                child: Divider(
                  color: const Color(0xFF74777F).withValues(alpha: 0.25),
                  thickness: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          OutlinedButton.icon(
            onPressed: () => context.go('/guest'),
            style: OutlinedButton.styleFrom(
              // ✅ لون الزر يتبع الثيم
              foregroundColor:
                  isDark ? const Color(0xFFFFD54F) : const Color(0xFF735C00),
              side: BorderSide(
                color: const Color(
                  0xFFFED65B,
                ).withValues(alpha: isDark ? 0.5 : 0.7),
                width: 1.5,
              ),
              // ✅ خلفية زر الضيف تتكيف مع الثيم
              backgroundColor:
                  isDark
                      ? const Color(0xFF2A2000).withValues(alpha: 0.6)
                      : const Color(0xFFFFF8E1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            ),
            icon: const Icon(Icons.person_outline_rounded, size: 20),
            label: Text(
              l10n.guestPortalEnter,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Footer ────────────────────────────────────────────────────────────────
  Widget _buildFooter(bool isDark) {
    final linkStyle = TextStyle(
      fontFamily: 'Cairo',
      fontSize: 11,
      // ✅ لون روابط الفوتر يتبع الثيم
      color: isDark ? Colors.white38 : const Color(0xFF74777F),
    );

    return Column(
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 20,
          runSpacing: 8,
          children: [
            GestureDetector(
              onTap: () {},
              child: Text('الرئيسية', style: linkStyle),
            ),
            GestureDetector(
              onTap: () {},
              child: Text('سياسة الخصوصية', style: linkStyle),
            ),
            GestureDetector(
              onTap: () {},
              child: Text('شروط الخدمة', style: linkStyle),
            ),
            GestureDetector(
              onTap: () {},
              child: Text('الدعم الفني', style: linkStyle),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          '© 2026 جامعة درنة - جميع الحقوق محفوظة',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 10,
            color:
                isDark
                    ? Colors.white24
                    : const Color(0xFF001835).withValues(alpha: 0.4),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// _PortalCard
// ═══════════════════════════════════════════════════════════════════════════
class _PortalCard extends StatefulWidget {
  final _PortalInfo info;
  final AppLocalizations l10n;
  final VoidCallback onTap;

  const _PortalCard({
    required this.info,
    required this.l10n,
    required this.onTap,
  });

  @override
  State<_PortalCard> createState() => _PortalCardState();
}

class _PortalCardState extends State<_PortalCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  late final Animation<double> _pressScale;
  late final Animation<double> _pressShadow;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _pressScale = Tween<double>(
      begin: 1.0,
      end: 0.967,
    ).animate(CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut));
    _pressShadow = Tween<double>(
      begin: 1.0,
      end: 0.5,
    ).animate(CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final info = widget.info;
    final l10n = widget.l10n;
    final isFaculty = info.portalKind == _PortalKind.faculty;
    final isAdmin = info.portalKind == _PortalKind.admin;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ✅ لون خلفية الكارت يتكيف مع الثيم
    final cardBgColor =
        isAdmin
            ? const Color(0xFF0F1423)
            : isDark
            ? const Color(0xFF152238)
            : (isFaculty ? const Color(0xFFFAFAFA) : Colors.white);

    // ✅ لون خلفية الأيقونة يتكيف مع الثيم
    final iconBgColor =
        isAdmin
            ? const Color(0xFF8B3DFF).withValues(alpha: 0.1)
            : (isFaculty
                ? Theme.of(context).colorScheme.primary
                : _portalBgColor(info.portalKind, isDark));

    final ctaLabel = switch (info.portalKind) {
      _PortalKind.student => l10n.portalEnterStudent,
      _PortalKind.faculty => l10n.portalEnterFaculty,
      _PortalKind.admin => l10n.portalEnterAdmin,
    };

    return GestureDetector(
      onTapDown: (_) => _pressCtrl.forward(),
      onTapUp: (_) {
        _pressCtrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _pressCtrl.reverse(),
      child: AnimatedBuilder(
        animation: _pressCtrl,
        builder: (context, child) {
          return Transform.scale(
            scale: _pressScale.value,
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: cardBgColor,
                borderRadius: BorderRadius.circular(
                  isFaculty ? 12 : (isAdmin ? 24 : 20),
                ),
                border: Border.all(
                  color:
                      isAdmin
                          ? const Color(0xFF8B3DFF).withValues(alpha: 0.3)
                          : (isFaculty
                              ? const Color(0xFF00A694).withValues(alpha: 0.2)
                              : info.iconColor.withValues(
                                alpha: isDark ? 0.2 : 0.12,
                              )),
                  width: isAdmin ? 1.5 : 1.0,
                ),
                boxShadow: [
                  if (isAdmin)
                    BoxShadow(
                      color: const Color(
                        0xFF8B3DFF,
                      ).withValues(alpha: 0.15 * _pressShadow.value),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    )
                  else if (isFaculty)
                    BoxShadow(
                      color: const Color(
                        0xFF001835,
                      ).withValues(alpha: 0.05 * _pressShadow.value),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    )
                  else
                    BoxShadow(
                      color: info.iconColor.withValues(
                        alpha: 0.08 * _pressShadow.value,
                      ),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                ],
              ),
              child: Stack(
                children: [
                  if (isAdmin)
                    Positioned.fill(
                      child: Opacity(
                            opacity: 0.05,
                            child: CustomPaint(painter: _MiniGridPainter()),
                          )
                          .animate(onPlay: (c) => c.repeat(reverse: true))
                          .fadeIn(duration: 2.seconds),
                    ),
                  if (isFaculty)
                    Positioned(
                      right: -20,
                      top: -20,
                      child: Icon(
                        Icons.account_balance_rounded,
                        size: 100,
                        color: const Color(0xFF00A694).withValues(alpha: 0.03),
                      ),
                    ),
                  child!,
                ],
              ),
            ),
          );
        },
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isAdmin ? 24 : 20,
            vertical: isAdmin ? 24 : 20,
          ),
          child: Row(
            children: [
              // Icon container
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(
                    isAdmin ? 12 : (isFaculty ? 100 : 16),
                  ),
                  boxShadow:
                      isAdmin
                          ? [
                            BoxShadow(
                              color: const Color(
                                0xFF8B3DFF,
                              ).withValues(alpha: 0.3),
                              blurRadius: 10,
                            ),
                          ]
                          : null,
                ),
                child: Icon(info.icon, color: info.iconColor, size: 28)
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .shimmer(
                      duration: isAdmin ? 2.seconds : 3.seconds,
                      color: Colors.white,
                    ),
              ),

              const SizedBox(width: 16),

              // Text section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      info.title,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: isAdmin ? 18 : 17,
                        fontWeight: FontWeight.bold,
                        // ✅ لون عنوان الكارت يتكيف
                        color:
                            isAdmin
                                ? Colors.white
                                : Theme.of(context).colorScheme.primary,
                        letterSpacing: isAdmin ? 1.0 : 0.0,
                      ),
                      textAlign: TextAlign.start,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      info.description,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12,
                        // ✅ لون وصف الكارت يتكيف
                        color:
                            isAdmin
                                ? Colors.white70
                                : isDark
                                ? Colors.white60
                                : const Color(0xFF4B5563),
                        height: 1.4,
                      ),
                      textAlign: TextAlign.start,
                    ),
                    const SizedBox(height: 16),

                    // CTA button
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isAdmin
                                ? const Color(0xFF8B3DFF).withValues(alpha: 0.2)
                                : (isFaculty
                                    ? Colors.transparent
                                    // ✅ خلفية زر CTA تتكيف مع الثيم
                                    : _portalBgColor(info.portalKind, isDark)),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          color:
                              isAdmin
                                  ? const Color(
                                    0xFF00E5FF,
                                  ).withValues(alpha: 0.5)
                                  : (isFaculty
                                      ? const Color(0xFF00A694)
                                      : info.iconColor.withValues(alpha: 0.25)),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            ctaLabel,
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color:
                                  isAdmin
                                      ? const Color(0xFF00E5FF)
                                      : (isFaculty
                                          ? const Color(0xFF00A694)
                                          : info.iconColor),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            isAdmin
                                ? Icons.arrow_forward_rounded
                                : Icons.arrow_back_ios_new_rounded,
                            size: 11,
                            color:
                                isAdmin
                                    ? const Color(0xFF00E5FF)
                                    : (isFaculty
                                        ? const Color(0xFF00A694)
                                        : info.iconColor),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              if (!info.available)
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Icon(
                    Icons.lock_outline_rounded,
                    size: 18,
                    color: const Color(0xFF74777F).withValues(alpha: 0.5),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = const Color(0xFF00E5FF)
          ..strokeWidth = 0.5;

    for (double i = 0; i < size.width; i += 10) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += 10) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
