/// Get all surahs use case.
library;

import 'package:flutter_project/features/hifzh/core/errors/hifzh_failures.dart';
import 'package:flutter_project/features/hifzh/data/repositories/quran_repository.dart';
import 'package:flutter_project/features/hifzh/domain/models/surah_model.dart';

/// Loads all 114 Surahs with the user's current memorization status.
class GetAllSurahsUseCase {
  /// Creates a [GetAllSurahsUseCase].
  const GetAllSurahsUseCase(this._repository);

  final QuranRepository _repository;

  /// Returns all Surahs.
  Future<HifzhResult<List<SurahModel>>> call() => _repository.getAllSurahs();
}
