/// Revision Cubit state definitions.
library;

import 'package:flutter_project/features/hifzh/domain/models/revision_session_model.dart';

sealed class RevisionState {
  const RevisionState();
}

final class RevisionInitial extends RevisionState {
  const RevisionInitial();
}

final class RevisionLoading extends RevisionState {
  const RevisionLoading();
}

/// Sessions loaded; [sessions] may be empty (nothing due today).
final class RevisionReady extends RevisionState {
  const RevisionReady(this.sessions);
  final List<RevisionSessionModel> sessions;
}

/// All due sessions have been reviewed.
final class RevisionComplete extends RevisionState {
  const RevisionComplete();
}

final class RevisionError extends RevisionState {
  const RevisionError(this.message);
  final String message;
}
