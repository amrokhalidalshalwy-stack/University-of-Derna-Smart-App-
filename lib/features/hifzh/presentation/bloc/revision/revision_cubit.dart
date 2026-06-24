/// Revision Cubit — manages the daily SM-2 review session.
library;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_project/features/hifzh/domain/usecases/get_due_sessions_use_case.dart';
import 'package:flutter_project/features/hifzh/domain/usecases/apply_revision_review_use_case.dart';
import 'package:flutter_project/features/hifzh/domain/models/revision_session_model.dart';
import 'revision_state.dart';

/// Cubit driving the today-review flow.
class RevisionCubit extends Cubit<RevisionState> {
  RevisionCubit({
    required GetDueSessionsUseCase getDueSessions,
    required ApplyRevisionReviewUseCase applyReview,
  }) : _getDueSessions = getDueSessions,
       _applyReview = applyReview,
       super(const RevisionInitial());

  final GetDueSessionsUseCase _getDueSessions;
  final ApplyRevisionReviewUseCase _applyReview;

  /// Loads today's due sessions.
  Future<void> loadDueSessions() async {
    emit(const RevisionLoading());
    final result = await _getDueSessions();
    result.fold(
      (sessions) => emit(RevisionReady(sessions)),
      (failure) => emit(RevisionError(failure.message)),
    );
  }

  /// Submits a SM-2 quality rating for a given session and refreshes.
  Future<void> submitReview({
    required RevisionSessionModel session,
    required int quality,
  }) async {
    final result = await _applyReview(session: session, quality: quality);
    result.fold(
      (_) => loadDueSessions(),
      (failure) => emit(RevisionError(failure.message)),
    );
  }
}
