/// Quran Cubit — manages Surah list and memorization status updates.
library;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_project/features/hifzh/domain/models/surah_model.dart';
import 'package:flutter_project/features/hifzh/domain/usecases/get_all_surahs_use_case.dart';
import 'package:flutter_project/features/hifzh/domain/usecases/update_memorization_status_use_case.dart';
import 'quran_state.dart';

/// Cubit managing the Mushaf browser tab and memorization status.
class QuranCubit extends Cubit<QuranState> {
  QuranCubit({
    required GetAllSurahsUseCase getAllSurahs,
    required UpdateMemorizationStatusUseCase updateStatus,
  }) : _getAllSurahs = getAllSurahs,
       _updateStatus = updateStatus,
       super(const QuranInitial());

  final GetAllSurahsUseCase _getAllSurahs;
  final UpdateMemorizationStatusUseCase _updateStatus;

  /// All surahs from the last successful load (for client-side filtering).
  List<SurahModel> _allSurahs = [];

  /// Loads all 114 Surahs from local storage.
  Future<void> loadSurahs() async {
    emit(const QuranLoading());
    final result = await _getAllSurahs();
    result.fold((surahs) {
      _allSurahs = surahs;
      emit(QuranLoaded(surahs));
    }, (failure) => emit(QuranError(failure.message)));
  }

  /// Filters the displayed list by [status] (client-side — no I/O).
  void filterByStatus(MemorizationStatus? status) {
    if (_allSurahs.isEmpty) return;
    final filtered =
        status == null
            ? _allSurahs
            : _allSurahs.where((s) => s.status == status).toList();
    emit(QuranLoaded(filtered, filter: status));
  }

  /// Performs a client-side text search — no new state class needed.
  void searchSurahs(String query) {
    if (_allSurahs.isEmpty) return;
    final q = query.trim().toLowerCase();
    final filtered =
        q.isEmpty
            ? _allSurahs
            : _allSurahs
                .where(
                  (s) =>
                      s.nameArabic.contains(query) ||
                      s.nameTransliteration.toLowerCase().contains(q),
                )
                .toList();
    final current = state;
    final activeFilter = current is QuranLoaded ? current.filter : null;
    emit(QuranLoaded(filtered, filter: activeFilter));
  }

  /// Persists a status change and refreshes the list.
  Future<void> updateStatus(int surahId, MemorizationStatus status) async {
    final result = await _updateStatus(surahId: surahId, status: status);
    result.fold(
      (_) => loadSurahs(),
      (failure) => emit(QuranError(failure.message)),
    );
  }
}
