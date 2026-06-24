/// Abstract repository contract for HifdhTracker authentication.
library;

import 'package:flutter_project/features/hifzh/core/errors/hifzh_failures.dart';
import 'package:flutter_project/features/hifzh/domain/models/user_model.dart';

/// Defines the authentication operations available to the domain layer.
///
/// Concrete implementations (Firebase, stub, etc.) satisfy this contract
/// without leaking implementation details into use-cases or cubits.
abstract interface class HifzhAuthRepository {
  /// Signs in an existing user with [email] and [password].
  Future<HifzhResult<HifzhUserModel>> signInWithEmail(
    String email,
    String password,
  );

  /// Creates a new account with [email] and [password].
  Future<HifzhResult<HifzhUserModel>> registerWithEmail(
    String email,
    String password,
  );

  /// Signs the current user out.
  Future<HifzhResult<void>> signOut();

  /// Sends a password-reset email to [email].
  Future<HifzhResult<void>> sendPasswordResetEmail(String email);

  /// Emits the current user on subscription and whenever auth state changes.
  /// Emits `null` when the user signs out.
  Stream<HifzhUserModel?> get authStateChanges;
}
