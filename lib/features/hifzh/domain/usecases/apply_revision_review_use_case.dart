/// Apply revision review use case — core SM-2 logic entry point.
library;

import 'package:flutter_project/features/hifzh/core/errors/hifzh_failures.dart';
import 'package:flutter_project/features/hifzh/data/repositories/quran_repository.dart';
import 'package:flutter_project/features/hifzh/domain/models/revision_session_model.dart';

/// Applies the SM-2 algorithm to a session and persists the updated state.
///
/// [quality] must be 0–5:
///   5 = perfect recall, 4 = correct with slight hesitation,
///   3 = correct with effort, 2 = incorrect easy recall,
///   1 = incorrect hard recall, 0 = complete blackout.
class ApplyRevisionReviewUseCase {
  const ApplyRevisionReviewUseCase(this._repository);
  final QuranRepository _repository;

  Future<HifzhResult<RevisionSessionModel>> call({
    required RevisionSessionModel session,
    required int quality,
  }) async {
    if (quality < 0 || quality > 5) {
      return HifzhError(
        ValidationFailure('quality', 'يجب أن تكون الجودة بين 0 و 5'),
      );
    }
    final updated = session.applyReview(quality);
    final saveResult = await _repository.saveRevisionSession(updated);
    return saveResult.fold((_) => HifzhSuccess(updated), HifzhError.new);
  }
}
