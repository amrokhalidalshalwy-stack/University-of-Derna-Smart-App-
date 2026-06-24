import 'package:cloud_firestore/cloud_firestore.dart';

enum RequestType {
  graduationCertificate,
  officialTranscript,
  semesterDeferral,
  majorChange,
}

enum RequestStatus { pending, approved, rejected, readyForPickup }

class StudentRequest {
  const StudentRequest({
    required this.id,
    required this.studentId,
    required this.type,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.details,
    this.adminNote,
  });

  final String id;
  final String studentId;
  final RequestType type;
  final RequestStatus status;
  final Timestamp createdAt;
  final Timestamp updatedAt;
  final Map<String, dynamic> details;
  final String? adminNote;

  factory StudentRequest.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StudentRequest.fromMap(doc.id, data);
  }

  factory StudentRequest.fromMap(String id, Map<String, dynamic> data) {
    return StudentRequest(
      id: id,
      studentId: data['student_id'] ?? data['student_id'] ?? '',
      type: _parseRequestType(data['type'] as String?),
      status: _parseRequestStatus(data['status'] as String?),
      createdAt: data['createdAt'] as Timestamp? ?? Timestamp.now(),
      updatedAt: data['updatedAt'] as Timestamp? ?? Timestamp.now(),
      details: data['details'] as Map<String, dynamic>? ?? {},
      adminNote: data['adminNote'] as String?,
    );
  }

  static RequestType _parseRequestType(String? value) {
    switch (value) {
      case 'graduationCertificate':
        return RequestType.graduationCertificate;
      case 'officialTranscript':
        return RequestType.officialTranscript;
      case 'semesterDeferral':
        return RequestType.semesterDeferral;
      case 'majorChange':
        return RequestType.majorChange;
      default:
        return RequestType.graduationCertificate;
    }
  }

  static RequestStatus _parseRequestStatus(String? value) {
    switch (value) {
      case 'pending':
        return RequestStatus.pending;
      case 'approved':
        return RequestStatus.approved;
      case 'rejected':
        return RequestStatus.rejected;
      case 'readyForPickup':
        return RequestStatus.readyForPickup;
      default:
        return RequestStatus.pending;
    }
  }

  String get typeString {
    switch (type) {
      case RequestType.graduationCertificate:
        return 'graduationCertificate';
      case RequestType.officialTranscript:
        return 'officialTranscript';
      case RequestType.semesterDeferral:
        return 'semesterDeferral';
      case RequestType.majorChange:
        return 'majorChange';
    }
  }

  String get statusString {
    switch (status) {
      case RequestStatus.pending:
        return 'pending';
      case RequestStatus.approved:
        return 'approved';
      case RequestStatus.rejected:
        return 'rejected';
      case RequestStatus.readyForPickup:
        return 'readyForPickup';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'student_id': studentId,
      'type': typeString,
      'status': statusString,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'details': details,
      if (adminNote != null) 'adminNote': adminNote,
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'student_id': studentId,
      'type': typeString,
      'status': statusString,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'details': details,
      if (adminNote != null) 'adminNote': adminNote,
    };
  }

  StudentRequest copyWith({
    String? id,
    String? studentId,
    RequestType? type,
    RequestStatus? status,
    Timestamp? createdAt,
    Timestamp? updatedAt,
    Map<String, dynamic>? details,
    String? adminNote,
  }) {
    return StudentRequest(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      type: type ?? this.type,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      details: details ?? this.details,
      adminNote: adminNote ?? this.adminNote,
    );
  }
}
