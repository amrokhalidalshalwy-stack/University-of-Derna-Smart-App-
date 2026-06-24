import 'package:cloud_firestore/cloud_firestore.dart';

/// Ù†Ù…ÙˆØ°Ø¬ Ø§Ù„ØªØ®ØµØµ (Major)
class Major {
  final String id;
  final String nameAr;
  final String nameEn;
  final String? code;

  Major({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    this.code,
  });

  factory Major.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Major(
      id: doc.id,
      nameAr: data['nameAr'] ?? '',
      nameEn: data['nameEn'] ?? '',
      code: data['code'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {'nameAr': nameAr, 'nameEn': nameEn, 'code': code};
  }
}

/// Ù†Ù…ÙˆØ°Ø¬ Ø§Ù„Ù…Ø§Ø¯Ø© (Course)
class Course {
  final String id;
  final String nameAr;
  final String nameEn;
  final String code;
  final String? majorId;

  Course({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.code,
    this.majorId,
  });

  factory Course.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Course(
      id: doc.id,
      nameAr: data['nameAr'] ?? '',
      nameEn: data['nameEn'] ?? '',
      code: data['code'] ?? '',
      majorId: data['majorId'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'nameAr': nameAr,
      'nameEn': nameEn,
      'code': code,
      'majorId': majorId,
    };
  }
}

/// Ù†Ù…ÙˆØ°Ø¬ Ø§Ù„Ù…Ù†Ø´ÙˆØ± (ForumPost)
class ForumPost {
  final String postId;
  final String courseId;
  final String? majorId;
  final String title;
  final String content;
  final String authorUid;
  final String authorName;
  final String? authorPhotoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Map<String, String>> references;
  final List<String> tags;
  final String status; // pending_moderation, approved, rejected
  final bool isPinned;
  final int viewsCount;
  final int commentsCount;
  final int reportCount;
  final bool isHidden;
  final List<String> reportedBy;

  ForumPost({
    required this.postId,
    required this.courseId,
    this.majorId,
    required this.title,
    required this.content,
    required this.authorUid,
    required this.authorName,
    this.authorPhotoUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.references,
    required this.tags,
    required this.status,
    this.isPinned = false,
    this.viewsCount = 0,
    this.commentsCount = 0,
    this.reportCount = 0,
    this.isHidden = false,
    this.reportedBy = const [],
  });

  factory ForumPost.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return ForumPost(
      postId: doc.id,
      courseId: data['course_id'] ?? '',
      majorId: data['majorId'],
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      authorUid: data['authorUid'] ?? '',
      authorName: data['authorName'] ?? '',
      authorPhotoUrl: data['authorPhotoUrl'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      references: List<Map<String, String>>.from(
        (data['references'] as List? ?? []).map(
          (item) => Map<String, String>.from(item),
        ),
      ),
      tags: List<String>.from(data['tags'] ?? []),
      status: data['status'] ?? 'pending_moderation',
      isPinned: data['isPinned'] ?? false,
      viewsCount: data['viewsCount'] ?? 0,
      commentsCount: data['commentsCount'] ?? 0,
      reportCount: data['report_count'] ?? 0,
      isHidden: data['is_hidden'] ?? false,
      reportedBy: List<String>.from(data['reported_by'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'course_id': courseId,
      'majorId': majorId,
      'title': title,
      'content': content,
      'authorUid': authorUid,
      'authorName': authorName,
      'authorPhotoUrl': authorPhotoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'references': references,
      'tags': tags,
      'status': status,
      'isPinned': isPinned,
      'viewsCount': viewsCount,
      'commentsCount': commentsCount,
      'report_count': reportCount,
      'is_hidden': isHidden,
      'reported_by': reportedBy,
    };
  }
}

/// Ù†Ù…ÙˆØ°Ø¬ Ø§Ù„ØªØ¹Ù„ÙŠÙ‚ (ForumComment)
class ForumComment {
  final String commentId;
  final String postId;
  final String authorUid;
  final String authorName;
  final String? authorPhotoUrl;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String status;

  ForumComment({
    required this.commentId,
    required this.postId,
    required this.authorUid,
    required this.authorName,
    this.authorPhotoUrl,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
  });

  factory ForumComment.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return ForumComment(
      commentId: doc.id,
      postId: data['postId'] ?? '',
      authorUid: data['authorUid'] ?? '',
      authorName: data['authorName'] ?? '',
      authorPhotoUrl: data['authorPhotoUrl'],
      content: data['content'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      status: data['status'] ?? 'approved',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'postId': postId,
      'authorUid': authorUid,
      'authorName': authorName,
      'authorPhotoUrl': authorPhotoUrl,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'status': status,
    };
  }
}
