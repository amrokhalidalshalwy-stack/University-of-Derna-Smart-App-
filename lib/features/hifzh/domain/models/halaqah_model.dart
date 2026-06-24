/// Data models for Halaqah (study circle) community feature.
library;

import 'package:flutter/foundation.dart';

/// Represents the role of a member within a [HalaqahModel].
enum HalaqahRole {
  /// The group creator and primary teacher.
  teacher,

  /// A student member.
  student,
}

/// Parses a [HalaqahRole] from a string.
HalaqahRole halaqahRoleFromJson(String? s) =>
    s == 'teacher' ? HalaqahRole.teacher : HalaqahRole.student;

/// Serializes a [HalaqahRole] to a string.
String halaqahRoleToJson(HalaqahRole r) => r.name;

/// Represents a single member of a [HalaqahModel].
@immutable
class HalaqahMember {
  /// Creates a [HalaqahMember].
  const HalaqahMember({
    required this.uid,
    required this.displayName,
    required this.role,
    required this.joinedAt,
    this.pagesThisWeek = 0,
    this.currentStreak = 0,
    this.totalPagesMemorized = 0,
    this.avatarUrl,
  });

  /// Firebase UID of the member.
  final String uid;

  /// Display name shown in the group.
  final String displayName;

  /// Role within the halaqah.
  final HalaqahRole role;

  /// When this member joined.
  final DateTime joinedAt;

  /// Pages reviewed this calendar week.
  final int pagesThisWeek;

  /// Current consecutive-days revision streak.
  final int currentStreak;

  /// Total pages ever memorized.
  final int totalPagesMemorized;

  /// Optional profile photo URL.
  final String? avatarUrl;

  /// Deserializes from a JSON map.
  factory HalaqahMember.fromJson(Map<String, dynamic> json) {
    return HalaqahMember(
      uid: json['uid'] as String? ?? '',
      displayName: json['displayName'] as String? ?? 'Anonymous',
      role: halaqahRoleFromJson(json['role'] as String?),
      joinedAt:
          DateTime.tryParse(json['joinedAt'] as String? ?? '') ??
          DateTime.now(),
      pagesThisWeek: (json['pagesThisWeek'] as num?)?.toInt() ?? 0,
      currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 0,
      totalPagesMemorized: (json['totalPagesMemorized'] as num?)?.toInt() ?? 0,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  /// Serializes to a JSON map.
  Map<String, dynamic> toJson() => {
    'uid': uid,
    'displayName': displayName,
    'role': halaqahRoleToJson(role),
    'joinedAt': joinedAt.toIso8601String(),
    'pagesThisWeek': pagesThisWeek,
    'currentStreak': currentStreak,
    'totalPagesMemorized': totalPagesMemorized,
    if (avatarUrl != null) 'avatarUrl': avatarUrl,
  };
}

/// Immutable model representing a Halaqah (study circle) group.
@immutable
class HalaqahModel {
  /// Creates a [HalaqahModel].
  const HalaqahModel({
    required this.id,
    required this.name,
    required this.teacherUid,
    required this.createdAt,
    required this.members,
    this.description = '',
    this.inviteCode = '',
    this.isPublic = false,
    this.maxMembers = 10,
  });

  /// Firestore document ID.
  final String id;

  /// Group name shown to members.
  final String name;

  /// UID of the teacher/admin.
  final String teacherUid;

  /// Creation timestamp.
  final DateTime createdAt;

  /// All members (including teacher).
  final List<HalaqahMember> members;

  /// Optional description.
  final String description;

  /// Short invite code for joining.
  final String inviteCode;

  /// Whether this group is publicly discoverable.
  final bool isPublic;

  /// Maximum number of members allowed.
  final int maxMembers;

  /// Total member count.
  int get memberCount => members.length;

  /// Deserializes from a JSON map.
  factory HalaqahModel.fromJson(Map<String, dynamic> json) {
    final membersJson = json['members'] as List<dynamic>? ?? [];
    return HalaqahModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unnamed Halaqah',
      teacherUid: json['teacherUid'] as String? ?? '',
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      members:
          membersJson
              .map((m) => HalaqahMember.fromJson(m as Map<String, dynamic>))
              .toList(),
      description: json['description'] as String? ?? '',
      inviteCode: json['inviteCode'] as String? ?? '',
      isPublic: json['isPublic'] as bool? ?? false,
      maxMembers: (json['maxMembers'] as num?)?.toInt() ?? 10,
    );
  }

  /// Serializes to a JSON map.
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'teacherUid': teacherUid,
    'createdAt': createdAt.toIso8601String(),
    'members': members.map((m) => m.toJson()).toList(),
    'description': description,
    'inviteCode': inviteCode,
    'isPublic': isPublic,
    'maxMembers': maxMembers,
  };

  HalaqahModel copyWith({
    String? id,
    String? name,
    String? teacherUid,
    DateTime? createdAt,
    List<HalaqahMember>? members,
    String? description,
    String? inviteCode,
    bool? isPublic,
    int? maxMembers,
  }) {
    return HalaqahModel(
      id: id ?? this.id,
      name: name ?? this.name,
      teacherUid: teacherUid ?? this.teacherUid,
      createdAt: createdAt ?? this.createdAt,
      members: members ?? this.members,
      description: description ?? this.description,
      inviteCode: inviteCode ?? this.inviteCode,
      isPublic: isPublic ?? this.isPublic,
      maxMembers: maxMembers ?? this.maxMembers,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HalaqahModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
