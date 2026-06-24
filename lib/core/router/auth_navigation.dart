import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_project/core/constants/app_roles.dart';
import 'package:flutter_project/core/providers/user_role_provider.dart';

/// Default landing route per [UserRole] (from Firestore `users/{uid}.role`).
String homePathForRole(UserRole role) {
  switch (role) {
    case UserRole.admin:
      return '/admin/dashboard';
    case UserRole.faculty:
      return '/faculty/dashboard';
    case UserRole.guest:
      return '/colleges';
    case UserRole.student:
      return '/home';
  }
}

/// After sign-in, wait for role snapshot then navigate (students may go to `/pending`).
Future<void> navigateAfterLogin(BuildContext context, WidgetRef ref) async {
  UserRoleInfo? info;
  for (var attempt = 0; attempt < 30; attempt++) {
    info = ref.read(userRoleInfoProvider).value;
    if (info != null) break;
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }

  if (!context.mounted) return;

  if (info != null &&
      info.role == UserRole.student &&
      (info.status.isPending || info.status.isBlocked)) {
    context.go(
      '/pending',
      extra: {
        'status': info.status.value,
        if (info.rejectionReason != null)
          'rejectionReason': info.rejectionReason,
      },
    );
    return;
  }

  context.go(homePathForRole(info?.role ?? UserRole.student));
}
