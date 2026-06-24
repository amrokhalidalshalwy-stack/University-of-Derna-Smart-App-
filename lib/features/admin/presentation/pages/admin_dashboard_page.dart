import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import 'package:flutter_project/features/admin/data/admin_service.dart';
import 'package:flutter_project/features/auth/data/auth_service.dart';
import 'package:flutter_project/l10n/app_localizations.dart';

class AdminDashboardPage extends ConsumerWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stream = ref.watch(registrationsStreamProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFF070B14), // خلفية داكنة تقنية
      drawer: _buildDrawer(context, ref),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          l10n.adminControlCenter,
          style: const TextStyle(
            fontFamily: 'Cairo',
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF8B3DFF)),
        actions: [
          RepaintBoundary(
            child: IconButton(
              icon: const Icon(
                Icons.security_rounded,
                color: Color(0xFF00E5FF),
              ),
              onPressed: () {},
            )
                .animate(onPlay: (controller) => controller.repeat(reverse: true))
                .fadeOut(duration: 1.seconds, curve: Curves.easeInOut)
                .fadeIn(),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // شبكة الخلفية التقنية (Grid)
          Positioned.fill(child: CustomPaint(painter: _GridPainter())),
          
          // إضاءات النيون الخلفية الجمالية (Ambient Orbs)
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF8B3DFF).withValues(alpha: 0.15),
                boxShadow: const [
                  BoxShadow(color: Color(0xFF8B3DFF), blurRadius: 100),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF00E5FF).withValues(alpha: 0.1),
                boxShadow: const [
                  BoxShadow(color: Color(0xFF00E5FF), blurRadius: 100),
                ],
              ),
            ),
          ),
          
          // المحتوى الرئيسي
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: stream.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF8B3DFF),
                  ),
                ),
                error: (e, _) => Center(
                  child: Text(
                    '${l10n.adminDashboardErrorText}: $e',
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      color: Colors.redAccent,
                    ),
                  ),
                ),
                data: (regs) {
                  final pending = regs
                      .where((r) => [
                            'pending_final_approval',
                            'under_review',
                            'requires_additional',
                          ].contains(r['status']))
                      .length;
                  final approved = regs.where((r) => r['status'] == 'approved').length;
                  final rejected = regs
                      .where((r) => [
                            'rejected',
                            'auto_rejected',
                          ].contains(r['status']))
                      .length;
                  final total = regs.length;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // هيدر حالة النظام
                      _GlassContainer(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            const RepaintBoundary(
                              child: Icon(
                                Icons.admin_panel_settings,
                                color: Color(0xFF00E5FF),
                                size: 40,
                              ),
                            ).animate().shimmer(duration: 2.seconds),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.adminDashboardStatusSafe,
                                    style: const TextStyle(
                                      fontFamily: 'Cairo',
                                      color: Color(0xFF00E5FF),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    l10n.adminDashboardWelcome,
                                    style: const TextStyle(
                                      fontFamily: 'Cairo',
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            RepaintBoundary(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00E5FF).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: const Color(0xFF00E5FF).withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Text(
                                  l10n.adminDashboardSystemOnline,
                                  style: const TextStyle(
                                    color: Color(0xFF00E5FF),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                              )
                                  .animate(onPlay: (c) => c.repeat(reverse: true))
                                  .fade(duration: 1.seconds),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1),

                      const SizedBox(height: 24),
                      Text(
                        l10n.adminDashboardLiveAnalysis,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // شبكة الـ KPIs الإحصائية
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 1.2,
                        children: [
                          _NeonKpiCard(
                            title: l10n.adminDashboardTotalRecords,
                            value: '$total',
                            icon: Icons.data_usage_rounded,
                            color: const Color(0xFF00E5FF),
                            delay: 100,
                          ),
                          _NeonKpiCard(
                            title: l10n.adminDashboardPendingReqs,
                            value: '$pending',
                            icon: Icons.pending_actions_rounded,
                            color: const Color(0xFFFFC107),
                            badge: pending > 0,
                            delay: 200,
                          ),
                          _NeonKpiCard(
                            title: l10n.adminDashboardApproved,
                            value: '$approved',
                            icon: Icons.verified_user_rounded,
                            color: const Color(0xFF00FF88),
                            delay: 300,
                          ),
                          _NeonKpiCard(
                            title: l10n.adminDashboardRejected, // تم تعديلها هنا وإصلاحها
                            value: '$rejected',
                            icon: Icons.gpp_bad_rounded,
                            color: const Color(0xFFFF3366),
                            delay: 400,
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),
                      Text(
                        l10n.adminDashboardQuickActions,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // أزرار العمليات السريعة
                      _TechAction(
                        icon: Icons.shield_rounded,
                        label: l10n.adminDashboardVerifQueue,
                        badge: pending,
                        color: const Color(0xFF8B3DFF),
                        delay: 100,
                        onTap: () => context.go('/admin/verifications'),
                      ),
                      const SizedBox(height: 12),
                      _TechAction(
                        icon: Icons.hub_rounded,
                        label: l10n.adminDashboardUserMgmt,
                        color: const Color(0xFF00E5FF),
                        delay: 200,
                        onTap: () => context.go('/admin/users'),
                      ),
                      const SizedBox(height: 12),
                      _TechAction(
                        icon: Icons.memory_rounded,
                        label: l10n.adminDashboardSystemLogs,
                        color: const Color(0xFF00FF88),
                        delay: 300,
                        onTap: () => context.pushNamed('admin_logs'),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Drawer(
      backgroundColor: const Color(0xFF070B14).withValues(alpha: 0.9),
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFF8B3DFF), width: 2),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const RepaintBoundary(
                  child: Icon(
                    Icons.admin_panel_settings,
                    color: Color(0xFF8B3DFF),
                    size: 50,
                  ),
                ).animate().shimmer(
                      color: const Color(0xFF8B3DFF),
                      duration: 2.seconds,
                    ),
                const SizedBox(height: 12),
                Text(
                  l10n.adminDashboardDrawerTitle,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(
              Icons.dashboard_rounded,
              color: Color(0xFF00E5FF),
            ),
            title: Text(
              l10n.adminDashboardDrawerDashboard,
              style: const TextStyle(fontFamily: 'Cairo', color: Colors.white),
            ),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(
              Icons.verified_user_rounded,
              color: Colors.white70,
            ),
            title: Text(
              l10n.adminDashboardDrawerRegistrations,
              style: const TextStyle(fontFamily: 'Cairo', color: Colors.white70),
            ),
            onTap: () {
              Navigator.pop(context);
              context.go('/admin/verifications');
            },
          ),
          const Spacer(),
          const Divider(color: Colors.white24),
          ListTile(
            leading: const Icon(
              Icons.power_settings_new_rounded,
              color: Color(0xFFFF3366),
            ),
            title: Text(
              l10n.adminDashboardDrawerEndSession,
              style: const TextStyle(fontFamily: 'Cairo', color: Color(0xFFFF3366)),
            ),
            onTap: () async {
              await ref.read(authServiceProvider).signOut();
              if (context.mounted) context.go('/gateway');
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final double alpha;
  const _GlassContainer({
    required this.child,
    required this.padding,
    this.alpha = 0.1,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: alpha),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _NeonKpiCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color color;
  final bool badge;
  final int delay;
  const _NeonKpiCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.badge = false,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return _GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RepaintBoundary(
                child: Icon(icon, color: color, size: 28)
                    .animate(onPlay: (controller) => controller.repeat())
                    .shimmer(duration: 3.seconds, color: Colors.white),
              ),
              if (badge)
                RepaintBoundary(
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF3366),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFFFF3366),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .fade(duration: 500.ms),
                ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                  color: Colors.white,
                  shadows: [Shadow(color: color, blurRadius: 10)],
                ),
              ),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms, delay: delay.ms).scale(begin: const Offset(0.9, 0.9));
  }
}

class _TechAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final int badge;
  final int delay;
  final VoidCallback onTap;
  const _TechAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.badge = 0,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: _GlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        alpha: 0.05,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withValues(alpha: 0.3)),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
            if (badge > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF3366),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(color: Color(0xFFFF3366), blurRadius: 8),
                  ],
                ),
                child: Text(
                  '$badge',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: Colors.white38,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms, delay: delay.ms).slideX(begin: 0.1);
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00E5FF).withValues(alpha: 0.03)
      ..strokeWidth = 1.0;

    for (double i = 0; i < size.width; i += 30) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += 30) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
