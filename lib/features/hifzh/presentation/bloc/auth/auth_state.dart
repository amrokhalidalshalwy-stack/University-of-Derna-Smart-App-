/// Auth Cubit state definitions.
library;

import 'package:flutter_project/features/hifzh/domain/models/user_model.dart';

/// Base class for all authentication states.
sealed class AuthState {
  const AuthState();
}

/// Initial state before any auth check.
final class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Auth operation in progress.
final class AuthLoading extends AuthState {
  const AuthLoading();
}

/// User is signed in with a valid session.
final class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.user);
  final HifzhUserModel user;
}

/// User is not signed in (or just signed out).
final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// An auth operation failed.
final class AuthError extends AuthState {
  const AuthError(this.message);
  final String message;
}
