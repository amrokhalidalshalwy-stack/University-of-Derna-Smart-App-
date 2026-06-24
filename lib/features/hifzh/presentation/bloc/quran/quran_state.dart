/// Quran Cubit state definitions.
library;

import 'package:flutter_project/features/hifzh/domain/models/surah_model.dart';

/// Base class for all Quran browse states.
sealed class QuranState {
  const QuranState();
}

/// Initial state before any load.
final class QuranInitial extends QuranState {
  const QuranInitial();
}

/// Surahs loading from local storage.
final class QuranLoading extends QuranState {
  const QuranLoading();
}

/// Surahs loaded successfully.
final class QuranLoaded extends QuranState {
  const QuranLoaded(this.surahs, {this.filter});

  /// The full (or filtered) list of Surahs to display.
  final List<SurahModel> surahs;

  /// Active status filter, or null for "all".
  final MemorizationStatus? filter;
}

/// Loading or filtering failed.
final class QuranError extends QuranState {
  const QuranError(this.message);
  final String message;
}
