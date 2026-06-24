/// Data model for a single spaced-repetition revision session entry.
library;

import 'package:flutter/foundation.dart';

/// Represents the SM-2 spaced repetition state for one Quran page.
///
/// The SM-2 algorithm schedules reviews based on:
/// - [easeFactor]: how easy the item is (≥ 1.3).
/// - [intervalDays]: days until next review.
/// - [repetitions]: how many times reviewed correctly in a row.
@immutable
class RevisionSessionModel {
  /// Creates a [RevisionSessionModel].
  const RevisionSessionModel({
    required this.id,
    required this.userUid,
    required this.pageNumber,
    required this.surahNumber,
    required this.nextReviewDate,
    required this.easeFactor,
    required this.intervalDays,
    required this.repetitions,
    required this.lastReviewDate,
    this.qualityRating = 0,
  });

  /// Unique document ID (Firestore or local).
  final String id;

  /// Firebase UID of the owner.
  final String userUid;

  /// Mushaf page number (1–604).
  final int pageNumber;

  /// Surah number for display grouping.
  final int surahNumber;

  /// The next date this page should be reviewed.
  final DateTime nextReviewDate;

  /// SM-2 ease factor — starts at 2.5, min 1.3.
  final double easeFactor;

  /// Days until next review (computed by SM-2).
  final int intervalDays;

  /// Consecutive correct repetitions.
  final int repetitions;

  /// Date of the last review.
  final DateTime lastReviewDate;

  /// User's self-rated quality (0–5) from the last review.
  final int qualityRating;

  /// Whether this page is due for review today or earlier.
  bool get isDueToday =>
      nextReviewDate.isBefore(DateTime.now().add(const Duration(days: 1)));

  /// Deserializes from a Firestore/JSON map.
  factory RevisionSessionModel.fromJson(Map<String, dynamic> json) {
    return RevisionSessionModel(
      id: json['id'] as String? ?? '',
      userUid: json['userUid'] as String? ?? '',
      pageNumber: (json['pageNumber'] as num).toInt(),
      surahNumber: (json['surahNumber'] as num?)?.toInt() ?? 1,
      nextReviewDate: _parseDate(json['nextReviewDate']),
      lastReviewDate: _parseDate(json['lastReviewDate']),
      easeFactor: (json['easeFactor'] as num?)?.toDouble() ?? 2.5,
      intervalDays: (json['intervalDays'] as num?)?.toInt() ?? 1,
      repetitions: (json['repetitions'] as num?)?.toInt() ?? 0,
      qualityRating: (json['qualityRating'] as num?)?.toInt() ?? 0,
    );
  }

  /// Serializes to a JSON map.
  Map<String, dynamic> toJson() => {
    'id': id,
    'userUid': userUid,
    'pageNumber': pageNumber,
    'surahNumber': surahNumber,
    'nextReviewDate': nextReviewDate.toIso8601String(),
    'lastReviewDate': lastReviewDate.toIso8601String(),
    'easeFactor': easeFactor,
    'intervalDays': intervalDays,
    'repetitions': repetitions,
    'qualityRating': qualityRating,
  };

  static DateTime _parseDate(dynamic value) {
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  /// Returns a new [RevisionSessionModel] after applying SM-2 algorithm.
  ///
  /// [quality] must be 0–5 where:
  ///   5 = perfect, 4 = good, 3 = correct with effort,
  ///   2 = incorrect but easy recall, 1 = incorrect hard recall, 0 = blackout
  RevisionSessionModel applyReview(int quality) {
    assert(quality >= 0 && quality <= 5, 'Quality must be 0–5');

    final clampedQuality = quality.clamp(0, 5);
    int newRepetitions;
    int newIntervalDays;
    double newEaseFactor;

    if (clampedQuality < 3) {
      // Failed recall — restart
      newRepetitions = 0;
      newIntervalDays = 1;
      newEaseFactor = easeFactor;
    } else {
      // Correct recall
      newRepetitions = repetitions + 1;
      if (repetitions == 0) {
        newIntervalDays = 1;
      } else if (repetitions == 1) {
        newIntervalDays = 6;
      } else {
        newIntervalDays = (intervalDays * easeFactor).round();
      }
      // Update ease factor
      newEaseFactor =
          easeFactor +
          (0.1 - (5 - clampedQuality) * (0.08 + (5 - clampedQuality) * 0.02));
      if (newEaseFactor < 1.3) newEaseFactor = 1.3;
    }

    final now = DateTime.now();
    return RevisionSessionModel(
      id: id,
      userUid: userUid,
      pageNumber: pageNumber,
      surahNumber: surahNumber,
      nextReviewDate: now.add(Duration(days: newIntervalDays)),
      lastReviewDate: now,
      easeFactor: newEaseFactor,
      intervalDays: newIntervalDays,
      repetitions: newRepetitions,
      qualityRating: clampedQuality,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RevisionSessionModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
