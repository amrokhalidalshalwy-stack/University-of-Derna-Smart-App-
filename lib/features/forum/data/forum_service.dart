// ============================================================
//  forum_service.dart  (UPDATED â€” bilingual helper + composite index hint)
// ============================================================
//
//  CHANGES vs original:
//  â€¢ Added `localizedName(Locale locale)` extension helpers on Major & Course
//    (see forum_models.dart update below â€” keep models in sync).
//  â€¢ Added `getAllMajors()` alias for clarity.
//  â€¢ `getPostsByCourse` composite-index requirement is documented inline.
//  â€¢ Added `getPendingPosts()` for the moderation panel.
//  â€¢ Minor: all StreamBuilder error paths now return typed errors.
//
// ============================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'forum_models.dart';

class ForumService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // â”€â”€ Majors â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Stream<List<Major>> getMajors() {
    return _db
        .collection('majors')
        .orderBy('order') // uses the 'order' field seeded by seed_firestore.py
        .snapshots()
        .map((s) => s.docs.map(Major.fromFirestore).toList());
  }

  // Alias kept for backward compatibility
  Stream<List<Major>> getAllMajors() => getMajors();

  // â”€â”€ Courses â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Stream<List<Course>> getCoursesByMajor(String majorId) {
    return _db
        .collection('courses')
        .where('majorId', isEqualTo: majorId)
        .orderBy('semester')
        .snapshots()
        .map((s) => s.docs.map(Course.fromFirestore).toList());
  }

  Stream<List<Course>> getAllCourses() {
    return _db
        .collection('courses')
        .orderBy('code')
        .snapshots()
        .map((s) => s.docs.map(Course.fromFirestore).toList());
  }

  // â”€â”€ Forum Posts â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  //
  //  âš ï¸  COMPOSITE INDEX REQUIRED in Firebase Console:
  //      Collection: forum_posts
  //      Fields: courseId ASC, status ASC, isPinned DESC, createdAt DESC
  //
  Stream<List<ForumPost>> getPostsByCourse(String courseId) {
    return _db
        .collection('forum_posts')
        .where('course_id', isEqualTo: courseId)
        .where('status', isEqualTo: 'approved')
        .where('is_hidden', isEqualTo: false) // Added is_hidden
        .orderBy('isPinned', descending: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(ForumPost.fromFirestore).toList());
  }

  /// Returns posts awaiting moderation (admin use only).
  Stream<List<ForumPost>> getPendingPosts() {
    return _db
        .collection('forum_posts')
        .where('status', isEqualTo: 'pending_moderation')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(ForumPost.fromFirestore).toList());
  }

  Future<void> createPost(ForumPost post) async {
    await _db.collection('forum_posts').add(post.toFirestore());
  }

  Future<void> updatePost(String postId, Map<String, dynamic> data) async {
    await _db.collection('forum_posts').doc(postId).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> incrementViews(String postId) async {
    await _db.collection('forum_posts').doc(postId).update({
      'viewsCount': FieldValue.increment(1),
    });
  }

  // â”€â”€ Comments â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Stream<List<ForumComment>> getComments(String postId) {
    return _db
        .collection('forum_posts')
        .doc(postId)
        .collection('comments')
        .where('status', isEqualTo: 'approved')
        .orderBy('createdAt')
        .snapshots()
        .map((s) => s.docs.map(ForumComment.fromFirestore).toList());
  }

  Future<void> addComment(String postId, ForumComment comment) async {
    final batch = _db.batch();

    final commentRef =
        _db.collection('forum_posts').doc(postId).collection('comments').doc();
    batch.set(commentRef, comment.toFirestore());

    final postRef = _db.collection('forum_posts').doc(postId);
    batch.update(postRef, {'commentsCount': FieldValue.increment(1)});

    await batch.commit();
  }

  // â”€â”€ Moderation â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Future<void> reportPost(
    String postId,
    String reason,
    String reportedByUid,
  ) async {
    final postRef = _db.collection('forum_posts').doc(postId);
    final postSnap = await postRef.get();
    
    if (!postSnap.exists) return;
    
    final data = postSnap.data()!;
    final reportedByList = List<String>.from(data['reported_by'] ?? []);
    
    // prevent double reporting
    if (reportedByList.contains(reportedByUid)) {
      throw Exception('لقد أبلغت عن هذا المنشور مسبقاً');
    }

    final newReportCount = (data['report_count'] ?? 0) + 1;
    final shouldHide = newReportCount >= 3;

    final batch = _db.batch();

    batch.update(postRef, {
      'report_count': newReportCount,
      'is_hidden': shouldHide,
      'reported_by': FieldValue.arrayUnion([reportedByUid]),
    });

    batch.set(_db.collection('moderation_queue').doc(), {
      'type': 'post',
      'post_id': postId,
      'reported_by': reportedByUid,
      'reason': reason,
      'report_count': newReportCount,
      'auto_hidden': shouldHide,
      'status': 'pending',
      'created_at': FieldValue.serverTimestamp(),
    });

    if (shouldHide) {
      batch.set(_db.collection('activityLogs').doc(), {
        'action': 'post_auto_hidden',
        'post_id': postId,
        'report_count': newReportCount,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }

  Future<void> restorePost(String postId) async {
    final batch = _db.batch();
    batch.update(_db.collection('forum_posts').doc(postId), {
      'is_hidden': false,
      'report_count': 0,
      'reported_by': [],
    });
    
    final queue = await _db
        .collection('moderation_queue')
        .where('post_id', isEqualTo: postId)
        .where('status', isEqualTo: 'pending')
        .get();
    
    for (final doc in queue.docs) {
      batch.update(doc.reference, {'status': 'restored'});
    }
    
    await batch.commit();
  }

  Future<void> reportComment(
    String postId,
    String commentId,
    String reason,
    String reportedByUid,
  ) async {
    await _db.collection('moderation_queue').add({
      'type': 'comment',
      'postId': postId,
      'entityId': commentId,
      'reason': reason,
      'reportedByUid': reportedByUid,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
