/// Sign-out use case.
library;

import 'package:flutter_project/features/hifzh/core/errors/hifzh_failures.dart';
import 'package:flutter_project/features/hifzh/data/repositories/auth_repository.dart';

/// Signs the current user out of HifdhTracker.
class SignOutUseCase {
  /// Creates a [SignOutUseCase].
  const SignOutUseCase(this._repository);

  final HifzhAuthRepository _repository;

  /// Executes sign-out.
  Future<HifzhResult<void>> call() => _repository.signOut();
}
