import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter_project/features/faculty/providers/faculty_provider.dart';
import 'package:flutter_project/features/faculty/models/course_model.dart';
import 'package:flutter_project/core/models/user_profile.dart';
import 'package:flutter_project/l10n/app_localizations.dart';

class ClassDetailPage extends ConsumerStatefulWidget {
  final String courseId;

  const ClassDetailPage({super.key, required this.courseId});

  @override
  ConsumerState<ClassDetailPage> createState() => _ClassDetailPageState();
}

class _ClassDetailPageState extends ConsumerState<ClassDetailPage> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final coursesAsync = ref.watch(facultyCoursesProvider);
    final course =
        coursesAsync.value
            ?.where((c) => c.courseId == widget.courseId)
            .firstOrNull;

    final primaryColor = Theme.of(context).colorScheme.primary;
    final accentColor = const Color(0xFF00A694);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor:
            isDark ? const Color(0xFF132220) : const Color(0xFFF0FAFA),
        appBar: AppBar(
          title: Text(
            course?.nameAr ?? l10n.classDetailTitle,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Cairo',
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: primaryColor,
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 0,
          bottom: TabBar(
            labelColor: isDark ? const Color(0xFF10B981) : const Color(0xFFE8E8E8),
            unselectedLabelColor: isDark ? const Color(0xFFE8E8E8).withValues(alpha: 0.54) : const Color(0xFFE8E8E8).withValues(alpha: 0.7),
            indicatorColor: isDark ? const Color(0xFF10B981) : const Color(0xFFE8E8E8),
            indicatorWeight: 3,
            labelStyle: const TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            unselectedLabelStyle: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13,
            ),
            tabs: [
              Tab(
                icon: const Icon(Icons.people_rounded),
                text: l10n.studentsListTab,
              ),
              Tab(
                icon: const Icon(Icons.campaign_rounded),
                text: l10n.announcementsTab,
              ),
            ],
          ),
        ),
        body:
            course == null
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                  children: [
                    // Tab 1: Student Roster matching _3/ visual specs
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 16.0,
                          ),
                          child: TextField(
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 14,
                            ),
                            decoration: InputDecoration(
                              hintText: l10n.searchStudent,
                              hintStyle: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 13,
                              ),
                              prefixIcon: const Icon(
                                Icons.search,
                                color: Colors.grey,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade200,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade200,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: accentColor,
                                  width: 1.5,
                                ),
                              ),
                            ),
                            onChanged: (val) {
                              setState(() => _searchQuery = val.toLowerCase());
                            },
                          ),
                        ),
                        Expanded(
                          child: _StudentRosterList(
                            course: course,
                            searchQuery: _searchQuery,
                          ),
                        ),
                      ],
                    ),
                    // Tab 2: Announcements History
                    _AnnouncementsHistory(courseId: course.courseId),
                  ],
                ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: isDark ? const Color(0xFF0D2420) : accentColor,
          foregroundColor: isDark ? const Color(0xFF10B981) : Colors.white,
          shape:
              isDark
                  ? RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: const Color(0xFF10B981).withValues(alpha: 0.5),
                    ),
                  )
                  : null,
          elevation: 4,
          onPressed: () {
            if (course != null) {
              _showAddAnnouncementDialog(context, ref, course.courseId);
            }
          },
          icon: const Icon(Icons.campaign_rounded, color: Colors.white),
          label: Text(
            l10n.addAnnouncement,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Cairo',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  void _showAddAnnouncementDialog(
    BuildContext context,
    WidgetRef ref,
    String courseId,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return _AddAnnouncementDialogContent(courseId: courseId, ref: ref);
      },
    );
  }
}

// ─── Custom class to handle State in Announcement Dialog ───
class _AddAnnouncementDialogContent extends StatefulWidget {
  final String courseId;
  final WidgetRef ref;
  const _AddAnnouncementDialogContent({
    required this.courseId,
    required this.ref,
  });

  @override
  State<_AddAnnouncementDialogContent> createState() =>
      _AddAnnouncementDialogContentState();
}

class _AddAnnouncementDialogContentState
    extends State<_AddAnnouncementDialogContent> {
  final _textController = TextEditingController();
  String _selectedTarget = 'all';

  // قائمة فئات المستهدفين بالإعلان
  final List<String> _targets = const [
    'all',
    'affected',
    'groupA',
    'groupB',
  ];

  String _getTargetLabel(String target, AppLocalizations l10n) {
    switch (target) {
      case 'all':
        return l10n.all;
      case 'affected':
        return l10n.classDetailAffectedStudents;
      case 'groupA':
        return l10n.classDetailGroupA;
      case 'groupB':
        return l10n.classDetailGroupB;
      case 'forum':
        return l10n.classDetailForum;
      default:
        return target;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final accentColor = const Color(0xFF00A694);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.addAnnouncementTitle,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Cairo',
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          // Target Audience pills grid
          Text(
            l10n.classDetailTargetAudience,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                _targets.map((t) {
                  final isSelected = _selectedTarget == t;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedTarget = t),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? accentColor : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              isSelected ? accentColor : Colors.grey.shade300,
                        ),
                      ),
                      child: Text(
                        _getTargetLabel(t, l10n),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color:
                              isSelected ? Colors.white : Colors.grey.shade700,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _textController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: l10n.announcementHint,
              hintStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: accentColor, width: 1.5),
              ),
            ),
            style: const TextStyle(fontFamily: 'Cairo', fontSize: 14),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
              ),
              icon: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 18,
              ),
              onPressed: () {
                if (_textController.text.isNotEmpty) {
                  final textToPost =
                      '[$_selectedTarget] ${_textController.text}';
                  widget.ref
                      .read(announcementsProvider.notifier)
                      .addAnnouncement(widget.courseId, _selectedTarget, textToPost);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        l10n.announcementAdded,
                        style: const TextStyle(fontFamily: 'Cairo'),
                      ),
                      backgroundColor: accentColor,
                    ),
                  );
                }
              },
              label: Text(
                l10n.classDetailPostAnnouncement,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ─── Tab 1: Student Roster List with Initials Avatar Badges & Detail Sheets ───
class _StudentRosterList extends ConsumerWidget {
  final CourseModel course;
  final String searchQuery;

  const _StudentRosterList({required this.course, required this.searchQuery});

  // Helper method to extract student initials
  String _getInitials(String name) {
    if (name.isEmpty) return '??';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}';
    }
    return parts[0][0];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final studentsAsync = ref.watch(classStudentsProvider(course));
    final primaryColor = Theme.of(context).colorScheme.primary;
    final accentColor = const Color(0xFF00A694);

    return studentsAsync.when(
      data: (students) {
        final filtered =
            students.where((student) {
              if (searchQuery.isEmpty) return true;
              final nameAr = student.fullNameAr.toLowerCase();
              final nameEn = student.fullName.toLowerCase();
              final universityId = student.universityId.toLowerCase();
              return nameAr.contains(searchQuery) ||
                  nameEn.contains(searchQuery) ||
                  universityId.contains(searchQuery);
            }).toList();

        if (filtered.isEmpty) {
          return Center(
            child: Text(
              l10n.noStudents,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 15,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final student = filtered[index];
            final name =
                student.fullNameAr.isNotEmpty
                    ? student.fullNameAr
                    : student.fullName;
            final initials = _getInitials(name);

            // Alternate colors for avatar background (teal and yellow)
            final avatarColor =
                index % 2 == 0 ? Colors.teal.shade50 : Colors.amber.shade50;
            final textColor =
                index % 2 == 0
                    ? const Color(0xFF008C8C)
                    : Colors.amber.shade800;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => _showStudentDetailSheet(context, student),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        // Roster Actions
                        IconButton(
                          icon: Icon(
                            Icons.chat_bubble_outline_rounded,
                            color: accentColor,
                            size: 20,
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  l10n.classDetailStartChat(name),
                                  style: const TextStyle(fontFamily: 'Cairo'),
                                ),
                                backgroundColor: primaryColor,
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.info_outline_rounded,
                            color: Colors.grey.shade400,
                            size: 20,
                          ),
                          onPressed:
                              () => _showStudentDetailSheet(context, student),
                        ),
                        const Spacer(),
                        // Student Name and Info
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              name,
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: primaryColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'ID: ${student.universityId} • ${student.major.isNotEmpty ? student.major : l10n.majorSoftwareEngineering}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade500,
                                fontFamily: 'Cairo',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        // Initials Avatar
                        Container(
                          width: 46,
                          height: 46,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: avatarColor,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            initials,
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error: $e')),
    );
  }

  void _showStudentDetailSheet(BuildContext context, UserProfile student) {
    final name =
        student.fullNameAr.isNotEmpty ? student.fullNameAr : student.fullName;
    final initials = _getInitials(name);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final l10n = AppLocalizations.of(ctx)!;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Cairo',
                          ),
                        ),
                        Text(
                          l10n.classDetailUniversityId(student.universityId),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    width: 60,
                    height: 60,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      initials,
                      style: const TextStyle(
                        color: Color(0xFF008C8C),
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 32),
              _buildDetailRow(
                l10n.majorLabel,
                student.major.isNotEmpty ? student.major : l10n.majorSoftwareEngineering,
              ),
              _buildDetailRow(
                l10n.completedHours,
                '${student.completedHours} ${l10n.hours}',
              ),
              _buildDetailRow(l10n.cumulativeGpa, student.gpa.toString()),
              _buildDetailRow(l10n.emailLabel, student.email),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Color(0xFF424242),
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Tab 2: Announcements History ───
class _AnnouncementsHistory extends ConsumerWidget {
  final String courseId;
  const _AnnouncementsHistory({required this.courseId});

  String _getTargetLabel(String target, AppLocalizations l10n) {
    switch (target) {
      case 'all':
        return l10n.all;
      case 'affected':
        return l10n.classDetailAffectedStudents;
      case 'groupA':
        return l10n.classDetailGroupA;
      case 'groupB':
        return l10n.classDetailGroupB;
      case 'forum':
        return l10n.classDetailForum;
      default:
        return target;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream:
          FirebaseFirestore.instance
              .collection('forum_posts')
              .where('course_id', isEqualTo: courseId)
              .where('status', isEqualTo: 'approved')
              .orderBy('isPinned', descending: true)
              .orderBy('createdAt', descending: true)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text(l10n.classDetailLoadingError(snapshot.error.toString())));
        }

        return _buildList(context, ref, snapshot.data?.docs ?? []);
      },
    );
  }

  Widget _buildList(
    BuildContext context,
    WidgetRef ref,
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final accentColor = const Color(0xFF00A694);

    if (docs.isEmpty) {
      return Center(
        child: Text(
          l10n.noAnnouncements,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: docs.length,
      itemBuilder: (context, index) {
        final doc = docs[index];
        final data = doc.data();
        final title = data['title'] as String? ?? l10n.classDetailNoTitle;
        final text = data['content'] as String? ?? '';
        final timestamp = data['createdAt'];
        String targetTag = data['authorName'] as String? ?? 'forum';
        String cleanText = text;

        final bodyPreview = cleanText.length > 100 
            ? '${cleanText.substring(0, 100)}...' 
            : cleanText;

        String formattedTime = '';
        if (timestamp is Timestamp) {
          formattedTime = DateFormat(
            'yyyy-MM-dd HH:mm',
          ).format(timestamp.toDate());
        } else if (timestamp != null) {
          formattedTime = timestamp.toString();
        }

        // Pill background & text colors based on target group
        Color badgeBg = Colors.teal.shade50;
        Color badgeText = const Color(0xFF008C8C);
        if (targetTag == 'affected') {
          badgeBg = Colors.red.shade50;
          badgeText = Colors.redAccent;
        } else if (targetTag.contains('group')) {
          badgeBg = Colors.blue.shade50;
          badgeText = Colors.blue;
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.redAccent,
                        size: 20,
                      ),
                      onPressed: () {
                        _showDeleteConfirmation(context, ref, doc.id);
                      },
                    ),
                    Row(
                      children: [
                        Text(
                          formattedTime,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade400,
                            fontFamily: 'Cairo',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: badgeBg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _getTargetLabel(targetTag, l10n),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: badgeText,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: primaryColor,
                  ),
                  textAlign: TextAlign.right,
                ),
                if (bodyPreview.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    bodyPreview,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13,
                      color: Colors.grey.shade700,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ],
                const Divider(height: 24),
                // confirmation and view log counts matching _3/ spec
                Row(
                  children: [
                    Icon(
                      Icons.remove_red_eye_outlined,
                      size: 14,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${data['viewsCount'] ?? 0} ${l10n.classDetailViews}',
                      style: TextStyle(
                        fontSize: 10,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                        fontFamily: 'Cairo',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.check_circle_outline_rounded,
                      size: 14,
                      color: accentColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${data['commentsCount'] ?? 0} ${l10n.classDetailComments}',
                      style: TextStyle(
                        fontSize: 10,
                        color: accentColor,
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    String docId,
  ) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text(
              l10n.deleteAnnouncement,
              style: const TextStyle(fontFamily: 'Cairo'),
            ),
            content: Text(
              l10n.deleteConfirmation,
              style: const TextStyle(fontFamily: 'Cairo'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  l10n.cancel,
                  style: const TextStyle(fontFamily: 'Cairo'),
                ),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  try {
                    await ref
                        .read(announcementsProvider.notifier)
                        .deleteAnnouncement(courseId, docId);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.announcementDeleted)),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.classDetailDeleteError(e.toString()))),
                      );
                    }
                  }
                },
                child: Text(
                  l10n.delete,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    color: Colors.redAccent,
                  ),
                ),
              ),
            ],
          ),
    );
  }
}
