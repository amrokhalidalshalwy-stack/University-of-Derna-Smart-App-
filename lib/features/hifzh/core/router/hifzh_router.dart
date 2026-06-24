/// GoRouter configuration for the HifdhTracker feature module.
///
/// All named routes are defined here. The router is exposed as a Riverpod
/// [Provider] so it can be injected into [MaterialApp.router].
library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_project/features/hifzh/core/di/hifzh_injection.dart';
import 'package:flutter_project/features/hifzh/presentation/bloc/auth/auth_cubit.dart';
import 'package:flutter_project/features/hifzh/presentation/bloc/auth/auth_state.dart';
import 'package:flutter_project/features/hifzh/presentation/splash/hifzh_splash_page.dart';
import 'package:flutter_project/features/hifzh/presentation/auth/hifzh_login_page.dart';
import 'package:flutter_project/features/hifzh/presentation/shell/hifzh_shell_page.dart';
import 'package:flutter_project/features/hifzh/presentation/home/hifzh_home_tab.dart';
import 'package:flutter_project/features/hifzh/presentation/mushaf/hifzh_mushaf_tab.dart';
import 'package:flutter_project/features/hifzh/presentation/halaqah/hifzh_halaqah_tab.dart';
import 'package:flutter_project/features/hifzh/presentation/profile/hifzh_profile_tab.dart';

// ── Route Name Constants ────────────────────────────────────────────────────

/// All named route identifiers for HifdhTracker.
abstract final class HifzhRoutes {
  /// Animated splash / loading screen.
  static const String splash = '/hifzh/splash';

  /// Login & registration screen.
  static const String login = '/hifzh/login';

  /// Main shell (bottom nav host).
  static const String shell = '/hifzh';

  /// Today's revision tab.
  static const String home = '/hifzh/today';

  /// Mushaf browser tab.
  static const String mushaf = '/hifzh/mushaf';

  /// Surah detail / page viewer.
  static const String surahDetail = '/hifzh/mushaf/surah/:surahNumber';

  /// Halaqah (study circle) tab.
  static const String halaqah = '/hifzh/halaqah';

  /// Profile & settings tab.
  static const String profile = '/hifzh/profile';

  /// Page not found route.
  static const String notFound = '/404';
}

// ── Route Path Constants ─────────────────────────────────────────────────────

/// All URL path segments for HifdhTracker screens.
abstract final class HifzhPaths {
  static const String splash = '/hifzh/splash';
  static const String login = '/hifzh/login';
  static const String shell = '/hifzh';
  static const String home = 'today';
  static const String mushaf = 'mushaf';
  static const String surahDetail = 'mushaf/surah/:surahNumber';
  static const String halaqah = 'halaqah';
  static const String profile = 'profile';
}

// ── Router Provider ──────────────────────────────────────────────────────────

/// Provides the [GoRouter] instance for the HifdhTracker feature.
final hifzhRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    debugLogDiagnostics: true,
    initialLocation: HifzhPaths.splash,
    redirect: (context, state) {
      final authCubit = getIt<AuthCubit>();
      final isAuthenticated = authCubit.state is AuthAuthenticated;
      final isOnLogin =
          state.matchedLocation == HifzhRoutes.login ||
          state.matchedLocation == HifzhRoutes.splash;

      if (!isAuthenticated && !isOnLogin) return HifzhRoutes.login;
      if (isAuthenticated && isOnLogin) return HifzhRoutes.home;
      return null;
    },
    refreshListenable: GoRouterRefreshStream(getIt<AuthCubit>().stream),
    errorBuilder:
        (context, state) => Scaffold(
          appBar: AppBar(title: const Text('Page Not Found')),
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Route not found: ${state.uri}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.go(HifzhRoutes.home),
                  child: const Text('Go Home'),
                ),
              ],
            ),
          ),
        ),
    routes: [
      // ── Splash ─────────────────────────────────────────────────────────
      GoRoute(
        path: HifzhPaths.splash,
        name: HifzhRoutes.splash,
        pageBuilder:
            (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const HifzhSplashPage(),
              transitionsBuilder: _fadeTransition,
            ),
      ),

      // ── Login ──────────────────────────────────────────────────────────
      GoRoute(
        path: HifzhPaths.login,
        name: HifzhRoutes.login,
        pageBuilder:
            (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const HifzhLoginPage(),
              transitionsBuilder: _slideUpTransition,
            ),
      ),

      // ── Main Shell (Bottom Nav) ────────────────────────────────────────
      ShellRoute(
        builder: (context, state, child) {
          return HifzhShellPage(child: child);
        },
        routes: [
          GoRoute(
            path: '${HifzhPaths.shell}/${HifzhPaths.home}',
            name: HifzhRoutes.home,
            builder: (context, state) => const HifzhHomeTab(),
          ),
          GoRoute(
            path: '${HifzhPaths.shell}/${HifzhPaths.mushaf}',
            name: HifzhRoutes.mushaf,
            builder: (context, state) => const HifzhMushafTab(),
            routes: [
              GoRoute(
                path: 'surah/:surahNumber',
                name: HifzhRoutes.surahDetail,
                builder: (context, state) {
                  final surahNumber =
                      int.tryParse(
                        state.pathParameters['surahNumber'] ?? '1',
                      ) ??
                      1;
                  return HifzhMushafTab(initialSurah: surahNumber);
                },
              ),
            ],
          ),
          GoRoute(
            path: '${HifzhPaths.shell}/${HifzhPaths.halaqah}',
            name: HifzhRoutes.halaqah,
            builder: (context, state) => const HifzhHalaqahTab(),
          ),
          GoRoute(
            path: '${HifzhPaths.shell}/${HifzhPaths.profile}',
            name: HifzhRoutes.profile,
            builder: (context, state) => const HifzhProfileTab(),
          ),
        ],
      ),

      // ── 404 Route ──────────────────────────────────────────────────────
      GoRoute(
        path: HifzhRoutes.notFound,
        name: HifzhRoutes.notFound,
        builder:
            (context, state) => Scaffold(
              appBar: AppBar(title: const Text('Page Not Found')),
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text('Route not found: ${state.uri}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.go(HifzhRoutes.home),
                      child: const Text('Go Home'),
                    ),
                  ],
                ),
              ),
            ),
      ),
    ],
  );
});

// ── Transition Builders ──────────────────────────────────────────────────────

/// Smooth fade transition used for splash screen.
Widget _fadeTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return FadeTransition(opacity: animation, child: child);
}

/// Slide-up transition used for auth screens.
Widget _slideUpTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return SlideTransition(
    position: animation.drive(
      Tween(
        begin: const Offset(0, 0.08),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeOutCubic)),
    ),
    child: FadeTransition(opacity: animation, child: child),
  );
}

// ── GoRouter Refresh Stream ──────────────────────────────────────────────────

/// Standard GoRouter stream adapter to listen to auth state changes.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _sub = stream.listen((_) => notifyListeners());
  }
  late final StreamSubscription<dynamic> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
