import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_project/core/colleges/college_registry.dart';
import 'package:flutter_project/l10n/app_localizations.dart';

/// Shell for `/colleges/:slug/*` — applies per-college theme and tab navigation.
class CollegeShellPage extends StatelessWidget {
  const CollegeShellPage({
    super.key,
    required this.college,
    required this.child,
  });

  final CollegeDefinition college;
  final Widget child;

  int _tabIndexForPath(String path) {
    if (path.endsWith('/news')) return 1;
    if (path.endsWith('/departments')) return 2;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final path = GoRouterState.of(context).uri.path;
    final selectedIndex = _tabIndexForPath(path);
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: college.primaryColor,
          brightness: Theme.of(context).brightness,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed:
                () => context.canPop() ? context.pop() : context.go('/gateway'),
          ),
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(college.icon, size: 22),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  isAr ? college.nameAr : college.nameEn,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          centerTitle: true,
        ),
        body: child,
        bottomNavigationBar: NavigationBar(
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
          height: 72,
          selectedIndex: selectedIndex,
          onDestinationSelected: (index) {
            final segment = switch (index) {
              1 => 'news',
              2 => 'departments',
              _ => 'home',
            };
            context.go('/colleges/${college.slug}/$segment');
          },
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home),
              label: l10n.homeTitle,
            ),
            NavigationDestination(
              icon: const Icon(Icons.newspaper_outlined),
              selectedIcon: const Icon(Icons.newspaper),
              label: l10n.collegeNews,
            ),
            NavigationDestination(
              icon: const Icon(Icons.account_tree_outlined),
              selectedIcon: const Icon(Icons.account_tree),
              label: l10n.collegeDepartments,
            ),
          ],
        ),
      ),
    );
  }
}
