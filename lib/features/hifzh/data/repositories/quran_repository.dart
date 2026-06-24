/// Abstract repository contract for Quran data.
library;

import 'package:flutter_project/features/hifzh/core/errors/hifzh_failures.dart';
import 'package:flutter_project/features/hifzh/domain/models/surah_model.dart';
import 'package:flutter_project/features/hifzh/domain/models/revision_session_model.dart';

/// Defines all Quran data operations available to the domain layer.
abstract interface class QuranRepository {
  /// Returns all 114 Surahs, optionally with user's memorization status.
  Future<HifzhResult<List<SurahModel>>> getAllSurahs();

  /// Returns a single Surah by its number (1–114).
  Future<HifzhResult<SurahModel>> getSurahById(int id);

  /// Persists the user's [status] for a given Surah.
  Future<HifzhResult<void>> updateMemorizationStatus(
    int surahId,
    MemorizationStatus status,
  );

  /// Returns all revision sessions that are due today or overdue.
  Future<HifzhResult<List<RevisionSessionModel>>> getDueSessions();

  /// Persists an updated [RevisionSessionModel] after a review.
  Future<HifzhResult<void>> saveRevisionSession(RevisionSessionModel session);
}
