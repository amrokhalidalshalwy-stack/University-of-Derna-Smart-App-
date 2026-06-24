import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotification {
  const AppNotification({
    required this.id,
    required this.userUid,
    required this.title,
    required this.body,
    this.category,
    required this.isRead,
    this.createdAtMs,
    required this.updatedAtMs,
  });

  final String id;
  final String userUid;
  final String title;
  final String body;
  final String? category;
  final bool isRead;
  final int? createdAtMs;
  final int updatedAtMs;

  factory AppNotification.fromFirestore(
    String userUid,
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return AppNotification.fromFirestoreMap(userUid, doc.id, data);
  }

  factory AppNotification.fromFirestoreMap(
    String userUid,
    String id,
    Map<String, dynamic> data,
  ) {
    return AppNotification(
      id: id,
      userUid: userUid,
      title: data['title'] as String? ?? '',
      body: data['body'] as String? ?? data['message'] as String? ?? '',
      category: data['category'] as String? ?? data['type'] as String?,
      isRead:
          data['is_read'] as bool? ??
          data['read'] as bool? ??
          data['isRead'] as bool? ??
          false,
      createdAtMs: _timestampToMs(
        data['createdAt'] ?? data['created_at'] ?? data['timestamp'],
      ),
      updatedAtMs: _timestampToMs(
            data['updatedAt'] ?? data['updated_at'],
          ) ??
          DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Global broadcast notifications from the top-level `notifications` collection.
  factory AppNotification.fromGlobalFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return AppNotification.fromFirestoreMap('', 'global_${doc.id}', data);
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'body': body,
      if (category != null) 'category': category,
      'read': isRead,
      if (createdAtMs != null)
        'createdAt': Timestamp.fromMillisecondsSinceEpoch(createdAtMs!),
    };
  }

  factory AppNotification.fromSqliteMap(Map<String, Object?> row) {
    return AppNotification(
      id: row['id']! as String,
      userUid: row['user_uid']! as String,
      title: row['title'] as String? ?? '',
      body: row['body'] as String? ?? '',
      category: row['category'] as String?,
      isRead: (row['is_read'] as int? ?? 0) != 0,
      createdAtMs: row['created_at'] as int?,
      updatedAtMs: row['updated_at'] as int? ?? 0,
    );
  }

  Map<String, Object?> toSqliteMap() {
    return {
      'id': id,
      'user_uid': userUid,
      'title': title,
      'body': body,
      'category': category,
      'is_read': isRead ? 1 : 0,
      'created_at': createdAtMs,
      'updated_at': updatedAtMs,
    };
  }

  static int? _timestampToMs(dynamic value) {
    if (value is Timestamp) return value.millisecondsSinceEpoch;
    if (value is int) return value;
    return null;
  }
}
