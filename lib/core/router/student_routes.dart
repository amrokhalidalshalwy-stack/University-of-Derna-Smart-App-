import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

import 'package:flutter_project/features/requests/presentation/pages/e_requests_page.dart';

List<RouteBase> buildStudentAndSharedRoutes(
  Ref ref,
  GlobalKey<NavigatorState> rootNavigatorKey,
) {
  return [
    GoRoute(
      path: '/e-requests',
      name: 'e-requests',
      parentNavigatorKey: rootNavigatorKey,
      builder: (context, state) => const ERequestsPage(),
    ),
  ];
}
