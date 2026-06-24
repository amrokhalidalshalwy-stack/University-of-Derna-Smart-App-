import 'package:cloud_firestore/cloud_firestore.dart';

class FeeRecord {
  const FeeRecord({
    required this.id,
    required this.userUid,
    required this.title,
    required this.amount,
    required this.currency,
    this.dueDate,
    required this.status,
    this.academicYear,
    required this.updatedAtMs,
  });

  final String id;
  final String userUid;
  final String title;
  final String amount;
  final String currency;
  final String? dueDate;
  final String status;
  final String? academicYear;
  final int updatedAtMs;

  factory FeeRecord.fromFirestore(
    String userUid,
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return FeeRecord.fromFirestoreMap(userUid, doc.id, data);
  }

  factory FeeRecord.fromFirestoreMap(
    String userUid,
    String id,
    Map<String, dynamic> data,
  ) {
    return FeeRecord(
      id: id,
      userUid: userUid,
      title: data['title'] as String? ?? data['label'] as String? ?? '',
      amount: data['amount']?.toString() ?? '',
      currency: data['currency'] as String? ?? 'LYD',
      dueDate: data['dueDate'] as String? ?? data['due'] as String?,
      status: data['status'] as String? ?? 'pending',
      academicYear: data['academicYear'] as String?,
      updatedAtMs:
          _timestampToMs(data['updatedAt']) ??
          DateTime.now().millisecondsSinceEpoch,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'amount': amount,
      'currency': currency,
      if (dueDate != null) 'dueDate': dueDate,
      'status': status,
      if (academicYear != null) 'academicYear': academicYear,
      'updatedAt': Timestamp.fromMillisecondsSinceEpoch(updatedAtMs),
    };
  }

  factory FeeRecord.fromSqliteMap(Map<String, Object?> row) {
    return FeeRecord(
      id: row['id']! as String,
      userUid: row['user_uid']! as String,
      title: row['title'] as String? ?? '',
      amount: row['amount'] as String? ?? '',
      currency: row['currency'] as String? ?? 'LYD',
      dueDate: row['due_date'] as String?,
      status: row['status'] as String? ?? 'pending',
      academicYear: row['academic_year'] as String?,
      updatedAtMs: row['updated_at'] as int? ?? 0,
    );
  }

  Map<String, Object?> toSqliteMap() {
    return {
      'id': id,
      'user_uid': userUid,
      'title': title,
      'amount': amount,
      'currency': currency,
      'due_date': dueDate,
      'status': status,
      'academic_year': academicYear,
      'updated_at': updatedAtMs,
    };
  }

  static int? _timestampToMs(dynamic value) {
    if (value is Timestamp) return value.millisecondsSinceEpoch;
    return null;
  }
}
