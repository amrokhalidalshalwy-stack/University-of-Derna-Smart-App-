/// HifdhTracker — Shell (Bottom Navigation Host).
library;

import 'package:flutter/material.dart';
import 'package:flutter_project/features/hifzh/core/theme/hifzh_theme.dart';
import 'package:flutter_project/features/hifzh/core/constants/hifzh_strings.dart';
import 'package:flutter_project/features/hifzh/core/router/hifzh_router.dart';
import 'package:go_router/go_router.dart';

/// The persistent scaffold with a bottom [NavigationBar] that hosts all tabs.
class HifzhShellPage extends StatelessWidget {
  /// Creates a [HifzhShellPage].
  const HifzhShellPage({super.key, required this.child});

  /// The currently active tab's widget, provided by GoRouter's [ShellRoute].
  final Widget child;

  // Tab destinations and their associated routes.
  static const _tabs = [
    (
      label: HifzhStrings.todayTab,
      icon: Icons.wb_sunny_outlined,
      activeIcon: Icons.wb_sunny_rounded,
      route: HifzhRoutes.home,
      path: '/hifzh/today',
    ),
    (
      label: HifzhStrings.mushafTab,
      icon: Icons.menu_book_outlined,
      activeIcon: Icons.menu_book_rounded,
      route: HifzhRoutes.mushaf,
      path: '/hifzh/mushaf',
    ),
    (
      label: HifzhStrings.halaqahTab,
      icon: Icons.people_outline_rounded,
      activeIcon: Icons.people_rounded,
      route: HifzhRoutes.halaqah,
      path: '/hifzh/halaqah',
    ),
    (
      label: HifzhStrings.profileTab,
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      route: HifzhRoutes.profile,
      path: '/hifzh/profile',
    ),
  ];

  int _selectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    for (var i = 0; i < _tabs.length; i++) {
      if (location.startsWith(_tabs[i].path)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _selectedIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: (i) => context.goNamed(_tabs[i].route),
          selectedItemColor: AppColors.secondary,
          unselectedItemColor: AppColors.textHint,
          selectedLabelStyle: const TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 11,
          ),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          items:
              _tabs
                  .map(
                    (t) => BottomNavigationBarItem(
                      icon: Icon(t.icon),
                      activeIcon: Icon(t.activeIcon),
                      label: t.label,
                    ),
                  )
                  .toList(),
        ),
      ),
    );
  }
}
