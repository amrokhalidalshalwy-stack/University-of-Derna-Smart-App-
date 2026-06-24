/// Halaqah Cubit.
library;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_project/features/hifzh/data/repositories/halaqah_repository.dart';
import 'package:flutter_project/features/hifzh/domain/usecases/get_leaderboard_use_case.dart';
import 'halaqah_state.dart';

/// Cubit managing the Halaqah (study circle) tab.
class HalaqahCubit extends Cubit<HalaqahState> {
  HalaqahCubit({
    required HalaqahRepository repository,
    required GetLeaderboardUseCase getLeaderboard,
    required JoinHalaqahUseCase joinHalaqah,
  }) : _repository = repository,
       _getLeaderboard = getLeaderboard,
       _joinHalaqah = joinHalaqah,
       super(const HalaqahInitial());

  final HalaqahRepository _repository;
  final GetLeaderboardUseCase _getLeaderboard;
  final JoinHalaqahUseCase _joinHalaqah;

  Future<void> loadHalaqahs() async {
    emit(const HalaqahLoading());
    final result = await _repository.getUserHalaqahs();
    result.fold(
      (halaqahs) => emit(HalaqahLoaded(halaqahs)),
      (failure) => emit(HalaqahError(failure.message)),
    );
  }

  Future<void> loadHalaqah(String id) async {
    emit(const HalaqahLoading());
    final result = await _repository.getUserHalaqahs();
    result.fold((halaqahs) {
      try {
        final halaqah = halaqahs.firstWhere((h) => h.id == id);
        emit(HalaqahLoaded([halaqah]));
      } catch (_) {
        emit(const HalaqahError('الحلقة غير موجودة'));
      }
    }, (failure) => emit(HalaqahError(failure.message)));
  }

  Future<void> joinHalaqah(String inviteCode) async {
    emit(const HalaqahLoading());
    final result = await _joinHalaqah(inviteCode);
    result.fold(
      (_) => loadHalaqahs(),
      (failure) => emit(HalaqahError(failure.message)),
    );
  }

  Future<void> refreshLeaderboard(String halaqahId) async {
    final current = state;
    final result = await _getLeaderboard(halaqahId);
    result.fold((board) {
      if (current is HalaqahLoaded) {
        emit(HalaqahLoaded(current.halaqahs, leaderboard: board));
      }
    }, (failure) => emit(HalaqahError(failure.message)));
  }
}
