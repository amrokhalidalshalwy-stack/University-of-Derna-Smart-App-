// user_role_provider.dart — reads current user's role+status from Firestore
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_project/features/auth/data/auth_service.dart';
import 'package:flutter_project/core/constants/app_roles.dart';

class UserRoleInfo {
  final UserRole role;
  final RegistrationStatus status;
  final String? rejectionReason;
  const UserRoleInfo({
    required this.role,
    required this.status,
    this.rejectionReason,
  });
}

/// Watches auth state and fetches role+status from Firestore when logged in.
final userRoleInfoProvider = StreamProvider<UserRoleInfo?>((ref) {
  final authStream = ref.watch(authStateChangesProvider);
  return authStream.when(
    data: (user) {
      if (user == null) return Stream.value(null);
      final firestore = ref.read(firestoreProvider);
      return firestore.collection('users').doc(user.uid).snapshots().map((
        snap,
      ) {
        if (!snap.exists) return null;
        final data = snap.data()!;
        return UserRoleInfo(
          role: UserRole.fromString(data['role'] as String?),
          status: RegistrationStatus.fromString(data['status'] as String?),
          rejectionReason: data['rejectionReason'] as String?,
        );
      });
    },
    loading: () => Stream.value(null),
    error: (err, stack) => Stream.value(null),
  );
});
