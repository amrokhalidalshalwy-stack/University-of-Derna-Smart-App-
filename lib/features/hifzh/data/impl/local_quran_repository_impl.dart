/// Local implementation of [QuranRepository] using SharedPreferences + bundled JSON.
library;

import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_project/features/hifzh/core/errors/hifzh_failures.dart';
import 'package:flutter_project/features/hifzh/data/repositories/quran_repository.dart';
import 'package:flutter_project/features/hifzh/domain/models/surah_model.dart';
import 'package:flutter_project/features/hifzh/domain/models/revision_session_model.dart';

/// Prefs keys.
const _kStatusPrefix = 'hifzh_status_';
const _kSessionPrefix = 'hifzh_session_';
const _kSessionIds = 'hifzh_session_ids';

/// Concrete [QuranRepository] backed by bundled JSON + SharedPreferences.
///
/// Surah metadata comes from `assets/data/surahs.json`.
/// User progress (memorization status, revision sessions) is persisted
/// locally in [SharedPreferences].
class LocalQuranRepositoryImpl implements QuranRepository {
  LocalQuranRepositoryImpl(this._prefs);

  final SharedPreferences _prefs;

  // ── Surah operations ──────────────────────────────────────────────────────

  @override
  Future<HifzhResult<List<SurahModel>>> getAllSurahs() async {
    try {
      final raw = await rootBundle.loadString('assets/data/surahs.json');
      final List<dynamic> jsonList = json.decode(raw) as List<dynamic>;

      final surahs =
          jsonList.map((e) {
            final map = e as Map<String, dynamic>;
            final id = (map['id'] as num).toInt();
            final statusStr = _prefs.getString('$_kStatusPrefix$id');
            final status = memorizationStatusFromJson(statusStr);
            final memorizedAyahs =
                _prefs.getInt('${_kStatusPrefix}ayahs_$id') ?? 0;

            return SurahModel(
              number: id,
              nameArabic: map['nameAr'] as String? ?? '',
              nameEnglish: map['name'] as String? ?? '',
              nameTransliteration: map['name'] as String? ?? '',
              ayahCount: (map['totalVerses'] as num?)?.toInt() ?? 0,
              revelationType: map['type'] as String? ?? 'Meccan',
              juzStart: (map['juz'] as num?)?.toInt() ?? 1,
              pageStart: (map['page'] as num?)?.toInt() ?? 1,
              status: status,
              memorizedAyahs: memorizedAyahs,
            );
          }).toList();

      return HifzhSuccess(surahs);
    } catch (e) {
      return HifzhError(CacheFailure('فشل تحميل بيانات القرآن: $e'));
    }
  }

  @override
  Future<HifzhResult<SurahModel>> getSurahById(int id) async {
    final result = await getAllSurahs();
    return result.fold((surahs) {
      try {
        final surah = surahs.firstWhere((s) => s.number == id);
        return HifzhSuccess(surah);
      } catch (_) {
        return HifzhError(CacheFailure('السورة رقم $id غير موجودة'));
      }
    }, HifzhError.new);
  }

  @override
  Future<HifzhResult<void>> updateMemorizationStatus(
    int surahId,
    MemorizationStatus status,
  ) async {
    try {
      await _prefs.setString(
        '$_kStatusPrefix$surahId',
        memorizationStatusToJson(status),
      );
      return const HifzhSuccess(null);
    } catch (e) {
      return HifzhError(CacheFailure('فشل حفظ الحالة: $e'));
    }
  }

  // ── Revision sessions ─────────────────────────────────────────────────────

  @override
  Future<HifzhResult<List<RevisionSessionModel>>> getDueSessions() async {
    try {
      final ids = _prefs.getStringList(_kSessionIds) ?? [];
      final now = DateTime.now();
      final sessions = <RevisionSessionModel>[];

      for (final id in ids) {
        final raw = _prefs.getString('$_kSessionPrefix$id');
        if (raw == null) continue;
        final map = json.decode(raw) as Map<String, dynamic>;
        final session = RevisionSessionModel.fromJson(map);
        if (session.nextReviewDate.isBefore(now.add(const Duration(days: 1)))) {
          sessions.add(session);
        }
      }

      return HifzhSuccess(sessions);
    } catch (e) {
      return HifzhError(CacheFailure('فشل تحميل جلسات المراجعة: $e'));
    }
  }

  @override
  Future<HifzhResult<void>> saveRevisionSession(
    RevisionSessionModel session,
  ) async {
    try {
      final ids = _prefs.getStringList(_kSessionIds) ?? [];
      if (!ids.contains(session.id)) {
        ids.add(session.id);
        await _prefs.setStringList(_kSessionIds, ids);
      }
      await _prefs.setString(
        '$_kSessionPrefix${session.id}',
        json.encode(session.toJson()),
      );
      return const HifzhSuccess(null);
    } catch (e) {
      return HifzhError(CacheFailure('فشل حفظ الجلسة: $e'));
    }
  }
}
