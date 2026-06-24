/// UserModel for the HifdhTracker feature.
library;

import 'package:flutter/foundation.dart';

/// Immutable model representing an authenticated HifdhTracker user.
@immutable
class HifzhUserModel {
  /// Creates a [HifzhUserModel].
  const HifzhUserModel({
    required this.uid,
    required this.email,
    this.displayName = '',
    this.avatarUrl,
    this.totalPagesMemorized = 0,
    this.currentStreak = 0,
    this.createdAt,
  });

  /// Firebase UID.
  final String uid;

  /// User's email address.
  final String email;

  /// Display name (may be empty until profile is completed).
  final String displayName;

  /// Getter alias to displayName for presentation layer compatibility.
  String get name => displayName;

  /// Optional profile photo URL.
  final String? avatarUrl;

  /// Total pages memorized (synced from Firestore).
  final int totalPagesMemorized;

  /// Consecutive days with at least one revision session.
  final int currentStreak;

  /// Account creation timestamp.
  final DateTime? createdAt;

  /// Deserializes from a JSON map (Firestore document).
  factory HifzhUserModel.fromJson(Map<String, dynamic> json) {
    return HifzhUserModel(
      uid: json['uid'] as String? ?? '',
      email: json['email'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String?,
      totalPagesMemorized: (json['totalPagesMemorized'] as num?)?.toInt() ?? 0,
      currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
    );
  }

  /// Serializes to a Firestore-compatible JSON map.
  Map<String, dynamic> toJson() => {
    'uid': uid,
    'email': email,
    'displayName': displayName,
    if (avatarUrl != null) 'avatarUrl': avatarUrl,
    'totalPagesMemorized': totalPagesMemorized,
    'currentStreak': currentStreak,
    if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
  };

  /// Returns a copy with the given fields overridden.
  HifzhUserModel copyWith({
    String? displayName,
    String? avatarUrl,
    int? totalPagesMemorized,
    int? currentStreak,
  }) {
    return HifzhUserModel(
      uid: uid,
      email: email,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      totalPagesMemorized: totalPagesMemorized ?? this.totalPagesMemorized,
      currentStreak: currentStreak ?? this.currentStreak,
      createdAt: createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HifzhUserModel &&
          runtimeType == other.runtimeType &&
          uid == other.uid;

  @override
  int get hashCode => uid.hashCode;

  @override
  String toString() => 'HifzhUserModel(uid: $uid, email: $email)';
}
