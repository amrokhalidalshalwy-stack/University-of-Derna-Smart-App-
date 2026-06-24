/// Register use case.
library;

import 'package:flutter_project/features/hifzh/core/errors/hifzh_failures.dart';
import 'package:flutter_project/features/hifzh/data/repositories/auth_repository.dart';
import 'package:flutter_project/features/hifzh/domain/models/user_model.dart';

/// Creates a new user account with [email] and [password].
class RegisterUseCase {
  /// Creates a [RegisterUseCase].
  const RegisterUseCase(this._repository);

  final HifzhAuthRepository _repository;

  /// Executes the registration operation.
  Future<HifzhResult<HifzhUserModel>> call({
    required String email,
    required String password,
  }) => _repository.registerWithEmail(email, password);
}
