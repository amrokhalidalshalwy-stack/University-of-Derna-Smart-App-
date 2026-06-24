/// Halaqah Cubit states.
library;

import 'package:flutter_project/features/hifzh/domain/models/halaqah_model.dart';

sealed class HalaqahState {
  const HalaqahState();
}

final class HalaqahInitial extends HalaqahState {
  const HalaqahInitial();
}

final class HalaqahLoading extends HalaqahState {
  const HalaqahLoading();
}

final class HalaqahLoaded extends HalaqahState {
  const HalaqahLoaded(this.halaqahs, {this.leaderboard = const []});
  final List<HalaqahModel> halaqahs;
  final List<HalaqahMember> leaderboard;

  HalaqahModel get halaqah => halaqahs.first;
}

final class HalaqahError extends HalaqahState {
  const HalaqahError(this.message);
  final String message;
}
