/// Update memorization status use case.
library;

import 'package:flutter_project/features/hifzh/core/errors/hifzh_failures.dart';
import 'package:flutter_project/features/hifzh/data/repositories/quran_repository.dart';
import 'package:flutter_project/features/hifzh/domain/models/surah_model.dart';

/// Updates the memorization [status] for a given Surah.
class UpdateMemorizationStatusUseCase {
  const UpdateMemorizationStatusUseCase(this._repository);
  final QuranRepository _repository;

  Future<HifzhResult<void>> call({
    required int surahId,
    required MemorizationStatus status,
  }) => _repository.updateMemorizationStatus(surahId, status);
}
