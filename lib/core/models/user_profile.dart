import 'package:cloud_firestore/cloud_firestore.dart';

/// Cached user profile for `users/{uid}` (Firestore) ⇄ `cached_users` (SQLite) ⇄ UI.
class UserProfile {
  const UserProfile({
    required this.uid,
    required this.fullName,
    required this.universityId,
    required this.email,
    required this.gpa,
    required this.completedHours,
    required this.major,
    this.profilePhotoUrl,
    this.createdAtMs,
    required this.updatedAtMs,
    required this.syncedAtMs,
    // DUSPS new fields
    this.role = 'student',
    this.status = 'approved',
    this.phone = '',
    this.fullNameAr = '',
    this.fullNameEn = '',
    // Core identity fields (KYC)
    this.nationalId = '',
    this.dateOfBirth,
    this.gender = '',
  });

  final String uid;
  final String fullName;
  final String universityId;
  final String email;
  final String gpa;
  final String completedHours;
  final String major;
  final String? profilePhotoUrl;
  final int? createdAtMs;
  final int updatedAtMs;
  final int syncedAtMs;

  // DUSPS new fields
  final String role;
  final String status;
  final String phone;
  final String fullNameAr;
  final String fullNameEn;

  // Core identity fields (KYC)
  final String nationalId;
  final DateTime? dateOfBirth;
  final String gender;

  static String _stringField(Map<String, dynamic> data, String key) {
    final v = data[key];
    if (v == null) return '';
    if (v is String) return v.trim();
    if (v is num) return v.toString();
    if (v is Timestamp) return v.toDate().toIso8601String();
    return v.toString();
  }

  factory UserProfile.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return UserProfile.fromFirestoreMap(doc.id, data);
  }

  factory UserProfile.fromFirestoreMap(String uid, Map<String, dynamic> data) {
    String? pickPhoto() {
      for (final key in ['profilePhotoUrl', 'photoUrl', 'profileImageUrl']) {
        final s = _stringField(data, key);
        if (s.isNotEmpty) return s;
      }
      return null;
    }

    DateTime? pickDateOfBirth() {
      final dob = data['dateOfBirth'];
      if (dob == null) return null;
      if (dob is DateTime) return dob;
      if (dob is Timestamp) return dob.toDate();
      return null;
    }

    return UserProfile(
      uid: uid,
      fullName: _stringField(data, 'fullName'),
      universityId: _stringField(data, 'universityId'),
      email: _stringField(data, 'email'),
      gpa: _stringField(data, 'gpa'),
      completedHours: _stringField(data, 'completedHours'),
      major: _stringField(data, 'major'),
      profilePhotoUrl: pickPhoto(),
      createdAtMs: _timestampToMs(data['createdAt']),
      updatedAtMs: DateTime.now().millisecondsSinceEpoch,
      syncedAtMs: DateTime.now().millisecondsSinceEpoch,
      // DUSPS new fields
      role:
          _stringField(data, 'role').isEmpty
              ? 'student'
              : _stringField(data, 'role'),
      status:
          _stringField(data, 'status').isEmpty
              ? 'approved'
              : _stringField(data, 'status'),
      phone: _stringField(data, 'phone'),
      fullNameAr: _stringField(data, 'fullNameAr'),
      fullNameEn: _stringField(data, 'fullNameEn'),
      // Core identity fields (KYC)
      nationalId: _stringField(data, 'nationalId'),
      dateOfBirth: pickDateOfBirth(),
      gender: _stringField(data, 'gender'),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'fullName': fullName,
      'universityId': universityId,
      'email': email,
      'gpa': gpa,
      'completedHours': completedHours,
      'major': major,
      'role': role,
      'status': status,
      'phone': phone,
      'fullNameAr': fullNameAr,
      'fullNameEn': fullNameEn,
      // Core identity fields (KYC)
      'nationalId': nationalId,
      if (dateOfBirth != null)
        'dateOfBirth': Timestamp.fromDate(dateOfBirth!),
      'gender': gender,
      if (profilePhotoUrl != null && profilePhotoUrl!.isNotEmpty)
        'profilePhotoUrl': profilePhotoUrl,
      if (createdAtMs != null)
        'createdAt': Timestamp.fromMillisecondsSinceEpoch(createdAtMs!),
    };
  }

  factory UserProfile.fromSqliteMap(Map<String, Object?> row) {
    final url = row['profile_photo_url'] as String?;
    return UserProfile(
      uid: row['uid']! as String,
      fullName: row['full_name'] as String? ?? '',
      universityId: row['university_id'] as String? ?? '',
      email: row['email'] as String? ?? '',
      gpa: row['gpa'] as String? ?? '',
      completedHours: row['completed_hours'] as String? ?? '',
      major: row['major'] as String? ?? '',
      profilePhotoUrl: (url != null && url.isNotEmpty) ? url : null,
      createdAtMs: row['created_at'] as int?,
      updatedAtMs: row['updated_at'] as int? ?? 0,
      syncedAtMs: row['synced_at'] as int? ?? 0,
    );
  }

  Map<String, Object?> toSqliteMap() {
    return {
      'uid': uid,
      'full_name': fullName,
      'university_id': universityId,
      'email': email,
      'gpa': gpa,
      'completed_hours': completedHours,
      'major': major,
      'profile_photo_url': profilePhotoUrl ?? '',
      'created_at': createdAtMs,
      'updated_at': updatedAtMs,
      'synced_at': syncedAtMs,
    };
  }

  UserProfile copyWith({
    int? updatedAtMs,
    int? syncedAtMs,
    String? nationalId,
    DateTime? dateOfBirth,
    String? gender,
  }) {
    return UserProfile(
      uid: uid,
      fullName: fullName,
      universityId: universityId,
      email: email,
      gpa: gpa,
      completedHours: completedHours,
      major: major,
      profilePhotoUrl: profilePhotoUrl,
      createdAtMs: createdAtMs,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      syncedAtMs: syncedAtMs ?? this.syncedAtMs,
      role: role,
      status: status,
      phone: phone,
      fullNameAr: fullNameAr,
      fullNameEn: fullNameEn,
      // Core identity fields (KYC)
      nationalId: nationalId ?? this.nationalId,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
    );
  }

  static int? _timestampToMs(dynamic value) {
    if (value is Timestamp) return value.millisecondsSinceEpoch;
    return null;
  }

  Map<String, dynamic> toUserDataMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'universityId': universityId,
      'gpa': gpa,
      'completedHours': completedHours,
      'major': major,
      'role': role,
      'status': status,
      'phone': phone,
      'fullNameAr': fullNameAr,
      'fullNameEn': fullNameEn,
      if (profilePhotoUrl != null) 'profilePhotoUrl': profilePhotoUrl,
    };
  }
}
