import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_project/core/app_keys.dart';
import 'package:flutter_project/core/network/connection_surface_notifier.dart';
import 'package:flutter_project/core/theme/app_theme.dart';

/// Listens to [connectionSurfaceProvider] and shows subtle SnackBars globally.
class AppSyncListener extends ConsumerWidget {
  const AppSyncListener({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(connectionSurfaceProvider, (prev, next) {
      final messenger = rootScaffoldMessengerKey.currentState;
      if (messenger == null) return;

      switch (next) {
        case ConnectionSurface.normal:
          break;
        case ConnectionSurface.offlineDevice:
          messenger.hideCurrentSnackBar();
          messenger.showSnackBar(
            SnackBar(
              content: const Text(
                'وضع بدون اتصال — البيانات من الذاكرة المحلية',
              ),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 4),
              backgroundColor: AppTheme.primaryContainer,
            ),
          );
          break;
        case ConnectionSurface.syncDegraded:
          messenger.hideCurrentSnackBar();
          messenger.showSnackBar(
            SnackBar(
              content: const Text(
                'تعذر المزامنة مع الخادم — عرض البيانات المحفوظة',
              ),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: 'حسناً',
                textColor: AppTheme.secondaryContainer,
                onPressed:
                    () =>
                        ref
                            .read(connectionSurfaceProvider.notifier)
                            .acknowledge(),
              ),
              backgroundColor: AppTheme.secondaryColor,
            ),
          );
          break;
      }
    });

    // The AppSyncListener itself doesn't need to show a loading indicator
    // as it's a listener. The MaterialApp.router builder handles the child being null.
    return child;
  }
}
