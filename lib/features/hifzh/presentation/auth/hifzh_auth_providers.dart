/// Auth providers for HifdhTracker (stub implementation).
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Auth state for HifdhTracker.
class HifzhAuthState {
  const HifzhAuthState({this.isAuthenticated = false, this.uid});
  final bool isAuthenticated;
  final String? uid;
}

/// Notifier that manages HifdhTracker authentication.
class HifzhAuthNotifier extends AsyncNotifier<HifzhAuthState> {
  @override
  Future<HifzhAuthState> build() async {
    return const HifzhAuthState();
  }

  /// Signs in with email and password.
  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncValue.loading();
    await Future.delayed(const Duration(seconds: 1));
    state = const AsyncValue.data(
      HifzhAuthState(isAuthenticated: true, uid: 'stub_uid'),
    );
  }

  /// Registers a new account.
  Future<void> register({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    await Future.delayed(const Duration(seconds: 1));
    state = const AsyncValue.data(
      HifzhAuthState(isAuthenticated: true, uid: 'stub_uid'),
    );
  }

  /// Signs in with Google (stub).
  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    await Future.delayed(const Duration(seconds: 1));
    state = const AsyncValue.data(
      HifzhAuthState(isAuthenticated: true, uid: 'google_uid'),
    );
  }

  /// Sends a password reset email (stub).
  Future<void> sendPasswordReset({required String email}) async {
    await Future.delayed(const Duration(milliseconds: 800));
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    state = const AsyncValue.data(HifzhAuthState());
  }
}

/// Provider for the HifdhTracker auth notifier.
final hifzhAuthNotifierProvider =
    AsyncNotifierProvider<HifzhAuthNotifier, HifzhAuthState>(
      HifzhAuthNotifier.new,
    );
