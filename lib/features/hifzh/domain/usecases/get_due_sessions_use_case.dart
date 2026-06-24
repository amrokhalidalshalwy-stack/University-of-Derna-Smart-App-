/// Get due revision sessions use case.
library;

import 'package:flutter_project/features/hifzh/core/errors/hifzh_failures.dart';
import 'package:flutter_project/features/hifzh/data/repositories/quran_repository.dart';
import 'package:flutter_project/features/hifzh/domain/models/revision_session_model.dart';

/// Returns all revision sessions that are due today or overdue.
class GetDueSessionsUseCase {
  const GetDueSessionsUseCase(this._repository);
  final QuranRepository _repository;

  Future<HifzhResult<List<RevisionSessionModel>>> call() =>
      _repository.getDueSessions();
}
