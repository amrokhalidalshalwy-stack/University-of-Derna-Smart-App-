/// Data model representing a single Surah (chapter) of the Holy Quran.
library;

import 'package:flutter/foundation.dart';

/// The memorization status of a single Quran page or Surah.
enum MemorizationStatus {
  /// Not yet started.
  notStarted,

  /// Currently being memorized.
  inProgress,

  /// Memorized but needs regular revision.
  memorized,

  /// Fully mastered — passed teacher review.
  mastered,
}

/// Converts a [MemorizationStatus] to its string key for JSON storage.
String memorizationStatusToJson(MemorizationStatus s) => s.name;

/// Parses a [MemorizationStatus] from a JSON string.
MemorizationStatus memorizationStatusFromJson(String? s) =>
    MemorizationStatus.values.firstWhere(
      (e) => e.name == s,
      orElse: () => MemorizationStatus.notStarted,
    );

/// Immutable data model for a Surah (chapter) of the Holy Quran.
@immutable
class SurahModel {
  /// Creates a [SurahModel].
  const SurahModel({
    required this.number,
    required this.nameArabic,
    required this.nameEnglish,
    required this.nameTransliteration,
    required this.ayahCount,
    required this.revelationType,
    required this.juzStart,
    required this.pageStart,
    this.status = MemorizationStatus.notStarted,
    this.memorizedAyahs = 0,
  });

  /// Surah number (1–114).
  final int number;

  /// Arabic name (e.g. الفاتحة).
  final String nameArabic;

  /// English meaning (e.g. "The Opening").
  final String nameEnglish;

  /// Romanized transliteration (e.g. "Al-Fatihah").
  final String nameTransliteration;

  /// Total number of Ayahs in this Surah.
  final int ayahCount;

  /// Whether this Surah was revealed in Mecca or Medina.
  final String revelationType;

  /// Juz' number where this Surah starts.
  final int juzStart;

  /// Mushaf page number where this Surah starts.
  final int pageStart;

  /// The user's current memorization status for this entire Surah.
  final MemorizationStatus status;

  /// Number of Ayahs the user has memorized so far.
  final int memorizedAyahs;

  /// Percentage progress (0.0 – 1.0).
  double get progressPercent =>
      ayahCount == 0 ? 0 : (memorizedAyahs / ayahCount).clamp(0.0, 1.0);

  /// Deserializes a [SurahModel] from a JSON map.
  factory SurahModel.fromJson(Map<String, dynamic> json) {
    return SurahModel(
      number: (json['number'] as num).toInt(),
      nameArabic: json['nameArabic'] as String? ?? '',
      nameEnglish: json['nameEnglish'] as String? ?? '',
      nameTransliteration: json['nameTransliteration'] as String? ?? '',
      ayahCount: (json['ayahCount'] as num?)?.toInt() ?? 0,
      revelationType: json['revelationType'] as String? ?? 'Meccan',
      juzStart: (json['juzStart'] as num?)?.toInt() ?? 1,
      pageStart: (json['pageStart'] as num?)?.toInt() ?? 1,
      status: memorizationStatusFromJson(json['status'] as String?),
      memorizedAyahs: (json['memorizedAyahs'] as num?)?.toInt() ?? 0,
    );
  }

  /// Serializes this model to a JSON map.
  Map<String, dynamic> toJson() => {
    'number': number,
    'nameArabic': nameArabic,
    'nameEnglish': nameEnglish,
    'nameTransliteration': nameTransliteration,
    'ayahCount': ayahCount,
    'revelationType': revelationType,
    'juzStart': juzStart,
    'pageStart': pageStart,
    'status': memorizationStatusToJson(status),
    'memorizedAyahs': memorizedAyahs,
  };

  /// Returns a copy of this model with the given fields replaced.
  SurahModel copyWith({MemorizationStatus? status, int? memorizedAyahs}) {
    return SurahModel(
      number: number,
      nameArabic: nameArabic,
      nameEnglish: nameEnglish,
      nameTransliteration: nameTransliteration,
      ayahCount: ayahCount,
      revelationType: revelationType,
      juzStart: juzStart,
      pageStart: pageStart,
      status: status ?? this.status,
      memorizedAyahs: memorizedAyahs ?? this.memorizedAyahs,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SurahModel &&
          runtimeType == other.runtimeType &&
          number == other.number;

  @override
  int get hashCode => number.hashCode;

  @override
  String toString() =>
      'SurahModel(number: $number, name: $nameTransliteration, ayahs: $ayahCount)';
}
