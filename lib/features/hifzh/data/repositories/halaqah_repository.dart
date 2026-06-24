/// Abstract repository contract for Halaqah (study circles).
library;

import 'package:flutter_project/features/hifzh/core/errors/hifzh_failures.dart';
import 'package:flutter_project/features/hifzh/domain/models/halaqah_model.dart';

/// Defines all Halaqah operations available to the domain layer.
abstract interface class HalaqahRepository {
  /// Returns all Halaqahs the current user belongs to.
  Future<HifzhResult<List<HalaqahModel>>> getUserHalaqahs();

  /// Joins a Halaqah using a short [inviteCode].
  Future<HifzhResult<HalaqahModel>> joinHalaqah(String inviteCode);

  /// Creates a new Halaqah with the given [name].
  Future<HifzhResult<HalaqahModel>> createHalaqah(String name);

  /// Returns the leaderboard members for [halaqahId], sorted by pagesThisWeek.
  Future<HifzhResult<List<HalaqahMember>>> getLeaderboard(String halaqahId);
}
