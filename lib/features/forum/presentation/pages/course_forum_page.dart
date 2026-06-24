// ============================================================
//  course_forum_page.dart  (FIXED)
//
//  Errors corrected:
//  • Removed all `const` from TextStyle/InputDecoration that reference
//    Theme.of(context) — Theme.of() is a runtime call, never const.
//  • Replaced Colors.grey.shade700 with Colors.grey.shade700 (Color has no
//    [] operator; only MaterialColor does).
//  • Replaced hardcoded Colors.grey / Colors.blue / Colors.red /
//    Colors.black12 with Theme.of(context).colorScheme equivalents
//    so Light/Dark mode works correctly.
//  • Wired FirebaseAuth for the comment author instead of placeholder strings.
// ============================================================

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_project/features/forum/data/forum_models.dart';
import 'package:flutter_project/features/forum/data/forum_service.dart';
import 'package:intl/intl.dart';

// ── CourseForumPage ───────────────────────────────────────────

class CourseForumPage extends StatelessWidget {
  final Course course;
  final ForumService _forumService = ForumService();

  CourseForumPage({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text(
          'نقاشات ${course.nameAr}',
          style: TextStyle(fontFamily: 'Cairo', color: cs.onSurface),
        ),
        backgroundColor: cs.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: StreamBuilder<List<ForumPost>>(
        stream: _forumService.getPostsByCourse(course.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: cs.primary));
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'خطأ: ${snapshot.error}',
                style: TextStyle(color: cs.error, fontFamily: 'Cairo'),
              ),
            );
          }
          final posts = snapshot.data ?? [];
          if (posts.isEmpty) {
            return Center(
              child: Text(
                'لا توجد نقاشات حالياً في هذه المادة.',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  color: cs.onSurfaceVariant,
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder:
                (context, index) => _buildPostCard(context, posts[index], cs),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        child: const Icon(Icons.add_comment),
      ),
    );
  }

  Widget _buildPostCard(BuildContext context, ForumPost post, ColorScheme cs) {
    return Card(
      elevation: 0,
      color: cs.surfaceContainerLow,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          _forumService.incrementViews(post.postId);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => PostDetailPage(post: post)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pinned badge
              if (post.isPinned)
                Row(
                  children: [
                    Icon(Icons.push_pin, size: 15, color: cs.error),
                    const SizedBox(width: 4),
                    Text(
                      'مثبت',
                      style: TextStyle(
                        color: cs.error,
                        fontSize: 12,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    const SizedBox(height: 6),
                  ],
                ),

              // Title
              Text(
                post.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 6),

              // Content preview — FIX: Colors.grey.shade700 → cs.onSurfaceVariant
              Text(
                post.content,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: cs.onSurfaceVariant, // was: Colors.grey.shade700
                  fontFamily: 'Cairo',
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),

              // Author row
              Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: cs.primaryContainer,
                    backgroundImage:
                        post.authorPhotoUrl != null
                            ? NetworkImage(post.authorPhotoUrl!)
                            : null,
                    child:
                        post.authorPhotoUrl == null
                            ? Icon(
                              Icons.person,
                              size: 16,
                              color: cs.onPrimaryContainer,
                            )
                            : null,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    post.authorName,
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'Cairo',
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    DateFormat('yyyy/MM/dd').format(post.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: cs.onSurfaceVariant, // was: Colors.grey
                      fontFamily: 'Cairo',
                    ),
                  ),
                ],
              ),

              Divider(color: cs.outlineVariant, height: 20),

              // Stats row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStat(
                    context,
                    Icons.comment_outlined,
                    post.commentsCount.toString(),
                    cs,
                  ),
                  _buildStat(
                    context,
                    Icons.visibility_outlined,
                    post.viewsCount.toString(),
                    cs,
                  ),
                  _buildStat(
                    context,
                    Icons.attach_file,
                    post.references.length.toString(),
                    cs,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(
    BuildContext context,
    IconData icon,
    String value,
    ColorScheme cs,
  ) {
    return Row(
      children: [
        Icon(icon, size: 17, color: cs.onSurfaceVariant), // was: Colors.grey
        const SizedBox(width: 4),
        // FIX: removed `const` — value is a runtime string
        Text(
          value,
          style: TextStyle(
            color: cs.onSurfaceVariant,
          ), // was: const TextStyle(color: Colors.grey)
        ),
      ],
    );
  }
}

// ── PostDetailPage ────────────────────────────────────────────

class PostDetailPage extends StatefulWidget {
  final ForumPost post;
  const PostDetailPage({super.key, required this.post});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  final ForumService _forumService = ForumService();
  final TextEditingController _commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: const Text(
          'تفاصيل النقاش',
          style: TextStyle(fontFamily: 'Cairo'),
        ),
        backgroundColor: cs.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildPostContent(cs),
                Divider(height: 32, color: cs.outlineVariant),
                Text(
                  'التعليقات',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                _buildCommentsList(cs),
              ],
            ),
          ),
          _buildCommentInput(cs),
        ],
      ),
    );
  }

  Widget _buildPostContent(ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.post.title,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            fontFamily: 'Cairo',
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            CircleAvatar(
              backgroundColor: cs.primaryContainer,
              backgroundImage:
                  widget.post.authorPhotoUrl != null
                      ? NetworkImage(widget.post.authorPhotoUrl!)
                      : null,
              child:
                  widget.post.authorPhotoUrl == null
                      ? Icon(Icons.person, color: cs.onPrimaryContainer)
                      : null,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.post.authorName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                    color: cs.onSurface,
                  ),
                ),
                Text(
                  DateFormat('yyyy/MM/dd HH:mm').format(widget.post.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: cs.onSurfaceVariant, // was: Colors.grey
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          widget.post.content,
          style: TextStyle(
            fontSize: 16,
            height: 1.5,
            fontFamily: 'Cairo',
            color: cs.onSurface,
          ),
        ),
        if (widget.post.references.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text(
            'المراجع والملفات:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'Cairo',
              color: cs.onSurface,
            ),
          ),
          ...widget.post.references.map(
            (ref) => ListTile(
              leading: Icon(
                ref['type'] == 'url' ? Icons.link : Icons.insert_drive_file,
                color: cs.primary,
              ),
              title: Text(
                ref['value']!,
                // was: const TextStyle(color: Colors.blue)
                style: TextStyle(color: cs.primary, fontFamily: 'Cairo'),
              ),
              onTap: () {},
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCommentsList(ColorScheme cs) {
    return StreamBuilder<List<ForumComment>>(
      stream: _forumService.getComments(widget.post.postId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: cs.primary));
        }
        final comments = snapshot.data ?? [];
        if (comments.isEmpty) {
          return Center(
            child: Text(
              'لا توجد تعليقات بعد. كن أول من يعلق!',
              style: TextStyle(fontFamily: 'Cairo', color: cs.onSurfaceVariant),
            ),
          );
        }
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: comments.length,
          separatorBuilder: (_, _) => Divider(color: cs.outlineVariant),
          itemBuilder: (context, index) {
            final comment = comments[index];
            return ListTile(
              leading: CircleAvatar(
                radius: 16,
                backgroundColor: cs.secondaryContainer,
                backgroundImage:
                    comment.authorPhotoUrl != null
                        ? NetworkImage(comment.authorPhotoUrl!)
                        : null,
                child:
                    comment.authorPhotoUrl == null
                        ? Icon(
                          Icons.person,
                          size: 20,
                          color: cs.onSecondaryContainer,
                        )
                        : null,
              ),
              title: Text(
                comment.authorName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  fontFamily: 'Cairo',
                  color: cs.onSurface,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    comment.content,
                    style: TextStyle(fontFamily: 'Cairo', color: cs.onSurface),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('yyyy/MM/dd HH:mm').format(comment.createdAt),
                    style: TextStyle(
                      fontSize: 10,
                      color: cs.onSurfaceVariant, // was: Colors.grey
                      fontFamily: 'Cairo',
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCommentInput(ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        // FIX: was BoxShadow(color: Colors.black12 …)
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              style: TextStyle(color: cs.onSurface, fontFamily: 'Cairo'),
              decoration: InputDecoration(
                hintText: 'اكتب تعليقك هنا...',
                // FIX: was const InputDecoration — contains cs which is runtime
                hintStyle: TextStyle(
                  color: cs.onSurfaceVariant,
                  fontFamily: 'Cairo',
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
          ),
          IconButton(
            // FIX: was const Icon(Icons.send, color: Colors.blue)
            icon: Icon(Icons.send, color: cs.primary),
            onPressed: _submitComment,
          ),
        ],
      ),
    );
  }

  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    // FIX: use real FirebaseAuth user instead of placeholder strings
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final newComment = ForumComment(
      commentId: '',
      postId: widget.post.postId,
      authorUid: user.uid, // was: 'current_user_uid'
      authorName: user.displayName ?? 'طالب', // was: 'اسم المستخدم الحالي'
      authorPhotoUrl: user.photoURL,
      content: text,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      status: 'approved',
    );

    await _forumService.addComment(widget.post.postId, newComment);
    _commentController.clear();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}
