/// Auth Cubit — manages authentication state for HifdhTracker.
library;

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_project/features/hifzh/core/errors/hifzh_failures.dart';
import 'package:flutter_project/features/hifzh/domain/usecases/sign_in_use_case.dart';
import 'package:flutter_project/features/hifzh/domain/usecases/register_use_case.dart';
import 'package:flutter_project/features/hifzh/domain/usecases/sign_out_use_case.dart';
import 'package:flutter_project/features/hifzh/data/repositories/auth_repository.dart';
import 'auth_state.dart';

/// Cubit that manages all authentication transitions for HifdhTracker.
class AuthCubit extends Cubit<AuthState> {
  /// Creates an [AuthCubit].
  AuthCubit({
    required SignInUseCase signInUseCase,
    required RegisterUseCase registerUseCase,
    required SignOutUseCase signOutUseCase,
    required HifzhAuthRepository repository,
  }) : _signIn = signInUseCase,
       _register = registerUseCase,
       _signOut = signOutUseCase,
       _repository = repository,
       super(const AuthInitial());

  final SignInUseCase _signIn;
  final RegisterUseCase _register;
  final SignOutUseCase _signOut;
  final HifzhAuthRepository _repository;
  StreamSubscription? _sub;

  /// Checks the current auth state from the stream (called on app start).
  void checkAuthStatus() {
    _sub = _repository.authStateChanges.listen((user) {
      if (isClosed) return;
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(const AuthUnauthenticated());
      }
    });
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }

  /// Attempts to sign in with [email] and [password].
  Future<void> signIn({required String email, required String password}) async {
    emit(const AuthLoading());
    final result = await _signIn(email: email, password: password);
    result.fold(
      (user) => emit(AuthAuthenticated(user)),
      (failure) => emit(AuthError(_failureMessage(failure))),
    );
  }

  /// Registers a new account. Validates that passwords match before calling.
  Future<void> register({
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    if (password != confirmPassword) {
      emit(const AuthError('كلمتا المرور غير متطابقتين'));
      return;
    }
    emit(const AuthLoading());
    final result = await _register(email: email, password: password);
    result.fold(
      (user) => emit(AuthAuthenticated(user)),
      (failure) => emit(AuthError(_failureMessage(failure))),
    );
  }

  /// Signs the current user out.
  Future<void> signOut() async {
    emit(const AuthLoading());
    final result = await _signOut();
    result.fold(
      (_) => emit(const AuthUnauthenticated()),
      (failure) => emit(AuthError(_failureMessage(failure))),
    );
  }

  /// Sends a password-reset email to [email].
  Future<void> sendPasswordReset({required String email}) async {
    await _repository.sendPasswordResetEmail(email);
  }

  /// Signs in with Google (stub for now).
  Future<void> signInWithGoogle() async {
    emit(const AuthLoading());
    // Simulate Google sign in delay
    await Future.delayed(const Duration(seconds: 1));
    emit(
      const AuthError('Google Sign-In is not yet implemented on the server'),
    );
  }

  String _failureMessage(HifzhFailure failure) => failure.message;
}
