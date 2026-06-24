import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_project/features/faculty/providers/faculty_provider.dart';

import 'package:flutter_project/l10n/app_localizations.dart';

// â”€â”€ Target audience chip enum â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
enum _BroadcastTarget { all, groupA, groupB, struggling }

// â”€â”€ Lightweight student item for local display â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _StudentItem {
  final String name;
  final String universityId;
  final String major;
  final List<String> initials;
  final Color avatarColor;
  final Color textColor;

  const _StudentItem({
    required this.name,
    required this.universityId,
    required this.major,
    required this.initials,
    required this.avatarColor,
    required this.textColor,
  });
}

class FacultyStudentsPage extends ConsumerStatefulWidget {
  const FacultyStudentsPage({super.key});

  @override
  ConsumerState<FacultyStudentsPage> createState() =>
      _FacultyStudentsPageState();
}

class _FacultyStudentsPageState extends ConsumerState<FacultyStudentsPage> {
  _BroadcastTarget _selectedTarget = _BroadcastTarget.all;
  final TextEditingController _announcementCtrl = TextEditingController();
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String? _selectedCourseId;
  bool _isSending = false;

  @override
  void dispose() {
    _announcementCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final brandTeal =
        isDark
            ? const Color(0xFF10B981)
            : Theme.of(context).colorScheme.primary;
    final brandNavy =
        isDark
            ? const Color(0xFF0D2420)
            : const Color(0xFF00A694);
    final l10n = AppLocalizations.of(context)!;
    final coursesAsync = ref.watch(facultyCoursesProvider);

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF132220) : const Color(0xFFF0FAFA),
      appBar: AppBar(
        title: Text(
          l10n.studentsTitle,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        backgroundColor: brandNavy,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: coursesAsync.when(
        data: (courses) {
          // Initialize selected course if not set
          if (_selectedCourseId == null && courses.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() => _selectedCourseId = courses.first.courseId);
            });
          }

          final selectedCourse =
              _selectedCourseId != null
                  ? courses.firstWhere(
                    (c) => c.courseId == _selectedCourseId,
                    orElse: () => courses.first,
                  )
                  : null;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
            physics: const BouncingScrollPhysics(),
            children: [
              // â”€â”€ Page subtitle â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
              Text(
                l10n.studentsSubtitle,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.right,
              ).animate().fadeIn(duration: 300.ms),

              const SizedBox(height: 20),

              // â”€â”€ Course Selector Dropdown â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
              Text(
                'Ø§Ø®ØªØ± Ø§Ù„Ù…Ù‚Ø±Ø±:',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: brandNavy,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButton<String>(
                dropdownColor: isDark ? const Color(0xFF0D2420) : Colors.white,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  color: isDark ? const Color(0xFFE8E8E8) : Colors.black87,
                ),
                value:
                    _selectedCourseId ??
                    (courses.isNotEmpty ? courses.first.courseId : null),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedCourseId = value);
                  }
                },
                items:
                    courses
                        .map(
                          (c) => DropdownMenuItem(
                            value: c.courseId,
                            child: Text(
                              c.nameAr,
                              style: const TextStyle(fontFamily: 'Cairo'),
                            ),
                          ),
                        )
                        .toList(),
                isExpanded: true,
                underline: Container(),
              ),
              const SizedBox(height: 20),

              // â”€â”€ Announcement Card â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
              _buildAnnouncementCard(context, l10n, brandTeal, brandNavy)
                  .animate()
                  .fadeIn(duration: 380.ms, delay: 50.ms)
                  .slideY(begin: 0.05),

              const SizedBox(height: 24),

              // â”€â”€ Students List â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
              if (selectedCourse != null)
                ref
                    .watch(classStudentsProvider(selectedCourse))
                    .when(
                      data: (students) {
                        final filtered =
                            students
                                .where(
                                  (s) =>
                                      s.fullName.contains(_searchQuery) ||
                                      s.uid.contains(_searchQuery),
                                )
                                .toList();

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [brandNavy, brandTeal],
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '${filtered.length} ${l10n.studentsRegistered.split(' ').first}',
                                    style: const TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 10,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      l10n.studentsRegistered,
                                      style: TextStyle(
                                        fontFamily: 'Cairo',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: brandNavy,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      width: 4,
                                      height: 22,
                                      decoration: BoxDecoration(
                                        color: brandTeal,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Search Field
                            TextField(
                              controller: _searchCtrl,
                              textAlign: TextAlign.right,
                              onChanged:
                                  (v) => setState(() => _searchQuery = v),
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 13,
                              ),
                              decoration: InputDecoration(
                                hintText: l10n.studentsSearch,
                                hintStyle: const TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                                prefixIcon: const Icon(
                                  Icons.search_rounded,
                                  color: Colors.grey,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ).animate().fadeIn(duration: 350.ms, delay: 80.ms),

                            const SizedBox(height: 12),

                            // Student Cards
                            if (filtered.isEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 40,
                                ),
                                child: Center(
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.person_search_rounded,
                                        size: 52,
                                        color: Colors.grey.shade300,
                                      ),
                                      const SizedBox(height: 12),
                                      const Text(
                                        'Ù„Ø§ ÙŠÙˆØ¬Ø¯ Ø·Ù„Ø§Ø¨ Ù…Ø·Ø§Ø¨Ù‚ÙˆÙ† Ù„Ù„Ø¨Ø­Ø«',
                                        style: TextStyle(
                                          fontFamily: 'Cairo',
                                          color: Colors.grey,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else
                              ...filtered.asMap().entries.map((entry) {
                                final idx = entry.key;
                                final student = entry.value;
                                final initials =
                                    student.fullName
                                        .split(' ')
                                        .map((n) => n.isNotEmpty ? n[0] : '')
                                        .take(2)
                                        .toList();
                                final colors = [
                                  const Color(0xFFE0F2F1),
                                  Color(0xFFFFF9C4),
                                  const Color(0xFFE0F2F1),
                                  const Color(0xFFFCE4EC),
                                  const Color(0xFFE8EAF6),
                                  const Color(0xFFE0F2F1),
                                ];
                                final textColors = [
                                  const Color(0xFF009688),
                                  const Color(0xFFB7950B),
                                  const Color(0xFF009688),
                                  const Color(0xFFC2185B),
                                  const Color(0xFF3949AB),
                                  const Color(0xFF009688),
                                ];
                                final avatarColor = colors[idx % colors.length];
                                final textColor =
                                    textColors[idx % textColors.length];

                                return _buildStudentCard(
                                      _StudentItem(
                                        name: student.fullName,
                                        universityId: student.uid,
                                        major: student.major,
                                        initials: initials,
                                        avatarColor: avatarColor,
                                        textColor: textColor,
                                      ),
                                      brandTeal,
                                      brandNavy,
                                      l10n,
                                    )
                                    .animate()
                                    .fadeIn(
                                      duration: 350.ms,
                                      delay: (100 + idx * 55).ms,
                                    )
                                    .slideX(begin: 0.04);
                              }),

                            const SizedBox(height: 24),

                            // â”€â”€ Recent Announcements Log â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                            if (_selectedCourseId != null)
                              _buildAnnouncementsStream(
                                context,
                                _selectedCourseId!,
                                l10n,
                                brandTeal,
                                brandNavy,
                              ),
                          ],
                        );
                      },
                      loading:
                          () => Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 40),
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                      error:
                          (e, st) => Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 40),
                              child: Text(
                                'Ø®Ø·Ø£ ÙÙŠ ØªØ­Ù…ÙŠÙ„ Ø§Ù„Ø·Ù„Ø§Ø¨',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ),
                    ),
            ],
          );
        },
        loading: () => Center(child: CircularProgressIndicator(strokeWidth: 2)),
        error:
            (e, st) => Center(
              child: Text(
                'Ø®Ø·Ø£ ÙÙŠ ØªØ­Ù…ÙŠÙ„ Ø§Ù„Ù…Ù‚Ø±Ø±Ø§Øª',
                style: TextStyle(fontFamily: 'Cairo'),
              ),
            ),
      ),
    );
  }

  Widget _buildAnnouncementsStream(
    BuildContext context,
    String courseId,
    AppLocalizations l10n,
    Color brandTeal,
    Color brandNavy,
  ) {
    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('forum_posts')
              .where('course_id', isEqualTo: courseId)
              .where('status', isEqualTo: 'approved')
              .orderBy('isPinned', descending: true)
              .orderBy('createdAt', descending: true)
              .limit(5)
              .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox();
        }

        final announcements = snapshot.data!.docs;
        if (announcements.isEmpty) {
          return const SizedBox();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  l10n.studentsRecentAnnouncements,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: brandNavy,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 4,
                  height: 22,
                  decoration: BoxDecoration(
                    color: brandTeal,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...announcements.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return _buildAnnouncementLogItem({
                'timeAgo': _formatTimestamp(data['createdAt'] as Timestamp?),
                'target': data['authorName'] ?? 'Ø§Ù„Ù…Ù†ØªØ¯Ù‰',
                'targetColor': Color(0xFFFFF9C4),
                'targetTextColor': Color(0xFFB7950B),
                'text': data['title'] ?? '',
                'confirmations': data['commentsCount'] ?? 0,
                'views': data['viewsCount'] ?? 0,
              }, l10n).animate().fadeIn(duration: 380.ms);
            }),
          ],
        );
      },
    );
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'Ø§Ù„Ø¢Ù†';
    final diff = DateTime.now().difference(timestamp.toDate());
    if (diff.inMinutes < 60) return 'Ù…Ù†Ø° ${diff.inMinutes} Ø¯Ù‚ÙŠÙ‚Ø©';
    if (diff.inHours < 24) return 'Ù…Ù†Ø° ${diff.inHours} Ø³Ø§Ø¹Ø©';
    if (diff.inDays == 1) return 'Ø£Ù…Ø³';
    return 'Ù…Ù†Ø° ${diff.inDays} Ø£ÙŠØ§Ù…';
  }

  // â”€â”€ Announcement compose card â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _buildAnnouncementCard(
    BuildContext context,
    AppLocalizations l10n,
    Color brandTeal,
    Color brandNavy,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border(right: BorderSide(color: brandTeal, width: 4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                l10n.studentsNewAnnouncement,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: brandNavy,
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.campaign_rounded, color: brandNavy, size: 22),
            ],
          ),

          const SizedBox(height: 16),

          // Target chips
          Align(
            alignment: Alignment.centerRight,
            child: const Text(
              'Ø§Ù„Ù…Ø³ØªÙ‡Ø¯ÙÙˆÙ†',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.end,
            children: [
              _buildTargetChip(
                l10n.studentsTargetAll,
                _BroadcastTarget.all,
                brandTeal,
                brandNavy,
              ),
              _buildTargetChip(
                l10n.studentsTargetGroupA,
                _BroadcastTarget.groupA,
                brandTeal,
                brandNavy,
              ),
              _buildTargetChip(
                l10n.studentsTargetGroupB,
                _BroadcastTarget.groupB,
                brandTeal,
                brandNavy,
              ),
              _buildTargetChip(
                l10n.studentsTargetStruggling,
                _BroadcastTarget.struggling,
                brandTeal,
                brandNavy,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Text area
          TextField(
            controller: _announcementCtrl,
            maxLines: 4,
            textAlign: TextAlign.right,
            style: const TextStyle(fontFamily: 'Cairo', fontSize: 13),
            decoration: InputDecoration(
              hintText: l10n.studentsAnnouncementHint,
              hintStyle: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12,
                color: Colors.grey,
              ),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.all(14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: brandTeal),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Broadcast button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed:
                  _isSending
                      ? null
                      : () => _sendAnnouncement(context, l10n, brandTeal),
              style: ElevatedButton.styleFrom(
                backgroundColor: brandNavy,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
              ),
              icon:
                  _isSending
                      ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                      : const Icon(Icons.send_rounded, size: 18),
              label: Text(
                l10n.studentsBroadcastNow,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // â”€â”€ Target selection chip â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _buildTargetChip(
    String label,
    _BroadcastTarget target,
    Color brandTeal,
    Color brandNavy,
  ) {
    final isSelected = _selectedTarget == target;
    return GestureDetector(
      onTap: () => setState(() => _selectedTarget = target),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? (target == _BroadcastTarget.all
                      ? brandNavy
                      : brandTeal.withValues(alpha: 0.12))
                  : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color:
                isSelected
                    ? (target == _BroadcastTarget.all ? brandNavy : brandTeal)
                    : Colors.grey.shade200,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color:
                isSelected
                    ? (target == _BroadcastTarget.all
                        ? Colors.white
                        : brandTeal)
                    : Colors.grey,
          ),
        ),
      ),
    );
  }

  // â”€â”€ Student card â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _buildStudentCard(
    _StudentItem student,
    Color brandTeal,
    Color brandNavy,
    AppLocalizations l10n,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Action buttons (info + message)
          Row(
            children: [
              _iconBtn(
                Icons.info_outline_rounded,
                Colors.grey.shade100,
                Colors.grey,
              ),
              const SizedBox(width: 6),
              _iconBtn(
                Icons.chat_bubble_outline_rounded,
                brandTeal.withValues(alpha: 0.1),
                brandTeal,
              ),
            ],
          ),

          const Spacer(),

          // Student info (right-aligned)
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    student.name,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: brandNavy,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'ID: ${student.universityId} â€¢ ${student.major}',
                    style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              // Avatar
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: student.avatarColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    student.initials.join(' '),
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: student.textColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // â”€â”€ Announcement log item â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _buildAnnouncementLogItem(
    Map<String, dynamic> item,
    AppLocalizations l10n,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.grey.shade300,
          style: BorderStyle.solid,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item['timeAgo'] as String,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 11,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: item['targetColor'] as Color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item['target'] as String,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: item['targetTextColor'] as Color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            item['text'] as String,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13,
              color: Color(0xFF374151),
              height: 1.6,
            ),
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _logStat(
                icon: Icons.check_circle_rounded,
                iconColor: const Color(0xFF009688),
                label: '${item['confirmations']} ${l10n.studentsConfirmations}',
              ),
              const SizedBox(width: 16),
              _logStat(
                icon: Icons.remove_red_eye_outlined,
                iconColor: Colors.grey,
                label: '${item['views']} ${l10n.studentsViews}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _iconBtn(IconData icon, Color bg, Color color) {
    return Container(
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Icon(icon, size: 18, color: color),
    );
  }

  Widget _logStat({
    required IconData icon,
    required Color iconColor,
    required String label,
  }) {
    return Row(
      children: [
        Icon(icon, size: 14, color: iconColor),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 10,
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // â”€â”€ Send to Firestore â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Future<void> _sendAnnouncement(
    BuildContext context,
    AppLocalizations l10n,
    Color brandTeal,
  ) async {
    final text = _announcementCtrl.text.trim();
    if (text.isEmpty) return;

    if (_selectedCourseId == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Ø§Ø®ØªØ± Ø§Ù„Ù…Ù‚Ø±Ø± Ø£ÙˆÙ„Ø§Ù‹',
              style: const TextStyle(fontFamily: 'Cairo'),
            ),
          ),
        );
      }
      return;
    }

    setState(() => _isSending = true);
    try {
      await ref
          .read(announcementsProvider.notifier)
          .addAnnouncement(_selectedCourseId!, '', text);
      _announcementCtrl.clear();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  l10n.studentsMessageSent,
                  style: const TextStyle(fontFamily: 'Cairo'),
                ),
              ],
            ),
            backgroundColor: brandTeal,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Ø®Ø·Ø£: $e',
              style: const TextStyle(fontFamily: 'Cairo'),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }
}
