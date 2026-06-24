/// Sign-in use case.
library;

import 'package:flutter_project/features/hifzh/core/errors/hifzh_failures.dart';
import 'package:flutter_project/features/hifzh/data/repositories/auth_repository.dart';
import 'package:flutter_project/features/hifzh/domain/models/user_model.dart';

/// Authenticates an existing user with [email] and [password].
class SignInUseCase {
  /// Creates a [SignInUseCase].
  const SignInUseCase(this._repository);

  final HifzhAuthRepository _repository;

  /// Executes the sign-in operation.
  Future<HifzhResult<HifzhUserModel>> call({
    required String email,
    required String password,
  }) => _repository.signInWithEmail(email, password);
}
