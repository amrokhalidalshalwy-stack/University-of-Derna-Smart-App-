/// Halaqah use cases.
library;

import 'package:flutter_project/features/hifzh/core/errors/hifzh_failures.dart';
import 'package:flutter_project/features/hifzh/data/repositories/halaqah_repository.dart';
import 'package:flutter_project/features/hifzh/domain/models/halaqah_model.dart';

/// Returns the sorted leaderboard for a given Halaqah.
class GetLeaderboardUseCase {
  const GetLeaderboardUseCase(this._repository);
  final HalaqahRepository _repository;

  Future<HifzhResult<List<HalaqahMember>>> call(String halaqahId) =>
      _repository.getLeaderboard(halaqahId);
}

/// Joins a Halaqah using an invite code.
class JoinHalaqahUseCase {
  const JoinHalaqahUseCase(this._repository);
  final HalaqahRepository _repository;

  Future<HifzhResult<HalaqahModel>> call(String inviteCode) =>
      _repository.joinHalaqah(inviteCode);
}
