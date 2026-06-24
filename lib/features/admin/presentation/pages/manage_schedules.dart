// lib/features/admin/presentation/pages/manage_schedules.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../screens/admin_sidebar.dart';
import '../../screens/admin_app_bar.dart';

const _kNavy = Color(0xFF1A365D);
const _kGold = Color(0xFFD4AF37);

// Providers
final schedulesProvider = StreamProvider<List<Schedule>>((ref) {
  return FirebaseFirestore.instance
      .collection('schedules')
      .orderBy('dayOfWeek')
      .orderBy('startTime')
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => Schedule.fromFirestore(doc))
          .toList());
});

final coursesProviderForSchedule = FutureProvider<List<Course>>((ref) async {
  final snapshot = await FirebaseFirestore.instance.collection('courses').get();
  return snapshot.docs.map((doc) => Course.fromFirestore(doc)).toList();
});

// Models
class Schedule {
  final String id;
  final String courseId;
  final String courseName;
  final String courseCode;
  final String instructorName;
  final int dayOfWeek; // 0=Ø§Ù„Ø£Ø­Ø¯, 1=Ø§Ù„Ø¥Ø«Ù†ÙŠÙ†, ..., 5=Ø§Ù„Ø®Ù…ÙŠØ³
  final String startTime;
  final String endTime;
  final String room;
  final String academicYear;
  final String semester;

  Schedule({
    required this.id,
    required this.courseId,
    required this.courseName,
    required this.courseCode,
    required this.instructorName,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.room,
    required this.academicYear,
    required this.semester,
  });

  factory Schedule.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Schedule(
      id: doc.id,
      courseId: data['course_id'] ?? data['course_id'] ?? '',
      courseName: data['course_name'] ?? data['course_name'] ?? '',
      courseCode: data['course_code'] ?? data['courseCode'] ?? '',
      instructorName: data['instructor_name'] ?? data['instructorName'] ?? '',
      dayOfWeek: data['day_of_week'] ?? data['dayOfWeek'] ?? 0,
      startTime: data['start_time'] ?? data['startTime'] ?? '',
      endTime: data['end_time'] ?? data['endTime'] ?? '',
      room: data['room'] ?? '',
      academicYear: data['academic_year'] ?? data['academicYear'] ?? '',
      semester: data['semester'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'course_id': courseId,
      'course_name': courseName,
      'course_code': courseCode,
      'instructor_name': instructorName,
      'day_of_week': dayOfWeek,
      'start_time': startTime,
      'end_time': endTime,
      'room': room,
      'academic_year': academicYear,
      'semester': semester,
    };
  }
}

class Course {
  final String id;
  final String code;
  final String name;
  final int credits;
  final String? instructorId;
  final String? instructorName;

  Course({
    required this.id,
    required this.code,
    required this.name,
    required this.credits,
    this.instructorId,
    this.instructorName,
  });

  factory Course.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Course(
      id: doc.id,
      code: data['code'] ?? '',
      name: data['name'] ?? '',
      credits: data['credits'] ?? 0,
      instructorId: data['instructor_id'] ?? data['instructorId'],
      instructorName: data['instructor_name'] ?? data['instructorName'],
    );
  }
}

// Main Page
class ManageSchedulesPage extends ConsumerStatefulWidget {
  const ManageSchedulesPage({super.key});

  @override
  ConsumerState<ManageSchedulesPage> createState() => _ManageSchedulesPageState();
}

class _ManageSchedulesPageState extends ConsumerState<ManageSchedulesPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _searchQuery = '';
  int? _filterDay;

  final List<String> _days = ['Ø§Ù„Ø£Ø­Ø¯', 'Ø§Ù„Ø¥Ø«Ù†ÙŠÙ†', 'Ø§Ù„Ø«Ù„Ø§Ø«Ø§Ø¡', 'Ø§Ù„Ø£Ø±Ø¨Ø¹Ø§Ø¡', 'Ø§Ù„Ø®Ù…ÙŠØ³'];

  @override
  Widget build(BuildContext context) {
    final schedulesAsync = ref.watch(schedulesProvider);

    return Scaffold(
      key: _scaffoldKey,
      drawer: const AdminSidebar(),
      appBar: AdminAppBar(
        title: 'Ø¥Ø¯Ø§Ø±Ø© Ø§Ù„Ø¬Ø¯Ø§ÙˆÙ„ Ø§Ù„Ø²Ù…Ù†ÙŠØ©',
        scaffoldKey: _scaffoldKey,
      ),
      body: Column(
        children: [
          // Ø´Ø±ÙŠØ· Ø§Ù„Ø¨Ø­Ø« ÙˆØ§Ù„ÙÙ„ØªØ±Ø©
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Ø¨Ø­Ø« Ø¹Ù† Ù…Ø§Ø¯Ø© Ø£Ùˆ Ù‚Ø§Ø¹Ø©...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
                  ),
                ),
                const SizedBox(width: 12),
                DropdownButton<int?>(
                  value: _filterDay,
                  hint: const Text('Ø§Ù„ÙŠÙˆÙ…'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Ø§Ù„ÙƒÙ„')),
                    ..._days.asMap().entries.map((entry) => DropdownMenuItem(
                          value: entry.key,
                          child: Text(entry.value),
                        )),
                  ],
                  onChanged: (value) => setState(() => _filterDay = value),
                ),
                const SizedBox(width: 12),
                FloatingActionButton.small(
                  onPressed: () => _showAddScheduleDialog(),
                  child: const Icon(Icons.add),
                ),
              ],
            ),
          ),

          // Ø¹Ø±Ø¶ Ø§Ù„Ø¬Ø¯ÙˆÙ„
          Expanded(
            child: schedulesAsync.when(
              data: (schedules) {
                var filteredSchedules = schedules;
                if (_searchQuery.isNotEmpty) {
                  filteredSchedules = filteredSchedules.where((s) =>
                      s.courseName.toLowerCase().contains(_searchQuery) ||
                      s.room.toLowerCase().contains(_searchQuery)).toList();
                }
                if (_filterDay != null) {
                  filteredSchedules = filteredSchedules
                      .where((s) => s.dayOfWeek == _filterDay)
                      .toList();
                }

                if (filteredSchedules.isEmpty) {
                  return const Center(child: Text('Ù„Ø§ ØªÙˆØ¬Ø¯ Ø¬Ø¯Ø§ÙˆÙ„ Ø­Ø§Ù„ÙŠØ§Ù‹'));
                }

                // ØªØ¬Ù…ÙŠØ¹ Ø§Ù„Ø¬Ø¯Ø§ÙˆÙ„ Ø­Ø³Ø¨ Ø§Ù„ÙŠÙˆÙ…
                final groupedSchedules = <int, List<Schedule>>{};
                for (var schedule in filteredSchedules) {
                  groupedSchedules.putIfAbsent(schedule.dayOfWeek, () => []);
                  groupedSchedules[schedule.dayOfWeek]!.add(schedule);
                }

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: _days.asMap().entries.map((entry) {
                    final dayIndex = entry.key;
                    final dayName = entry.value;
                    final daySchedules = groupedSchedules[dayIndex] ?? [];

                    if (daySchedules.isEmpty) return const SizedBox.shrink();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          decoration: BoxDecoration(
                            color: _kNavy,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            dayName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...daySchedules.map((schedule) => _buildScheduleCard(schedule)),
                        const SizedBox(height: 16),
                      ],
                    );
                  }).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Ø®Ø·Ø£: $e')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard(Schedule schedule) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: _kGold.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.schedule, color: _kGold),
        ),
        title: Text(
          '${schedule.courseCode} - ${schedule.courseName}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${schedule.startTime} - ${schedule.endTime}'),
            Text('Ø§Ù„Ù‚Ø§Ø¹Ø©: ${schedule.room}'),
            Text('Ø§Ù„Ø¯ÙƒØªÙˆØ±: ${schedule.instructorName}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _showEditScheduleDialog(schedule),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _showDeleteConfirmation(schedule),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddScheduleDialog() async {
    final formKey = GlobalKey<FormState>();
    String? selectedCourseId;
    String? selectedDay;
    String? startTime;
    String? endTime;
    String? room;
    String academicYear = '2024-2025';
    String semester = 'Ø§Ù„Ø®Ø±ÙŠÙÙŠ';

    // âœ… Ø§Ø³ØªØ®Ø¯Ø§Ù… await Ø¨Ø¯Ù„Ø§Ù‹ Ù…Ù† then
    final courses = await ref.read(coursesProviderForSchedule.future);
    
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ø¥Ø¶Ø§ÙØ© Ø¬Ø¯ÙˆÙ„ Ø¬Ø¯ÙŠØ¯'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Ø§Ù„Ù…Ø§Ø¯Ø© Ø§Ù„Ø¯Ø±Ø§Ø³ÙŠØ©'),
                  items: courses.map((course) {
                    return DropdownMenuItem(
                      value: course.id,
                      child: Text('${course.code} - ${course.name}'),
                    );
                  }).toList(),
                  onChanged: (value) => selectedCourseId = value,
                  validator: (value) => value == null ? 'Ø§Ø®ØªØ± Ù…Ø§Ø¯Ø©' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Ø§Ù„ÙŠÙˆÙ…'),
                  items: _days.map((day) {
                    return DropdownMenuItem(value: day, child: Text(day));
                  }).toList(),
                  onChanged: (value) => selectedDay = value,
                  validator: (value) => value == null ? 'Ø§Ø®ØªØ± Ø§Ù„ÙŠÙˆÙ…' : null,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(labelText: 'ÙˆÙ‚Øª Ø§Ù„Ø¨Ø¯Ø§ÙŠØ©'),
                        onChanged: (value) => startTime = value,
                        validator: (value) => value == null || value.isEmpty ? 'Ø£Ø¯Ø®Ù„ ÙˆÙ‚Øª Ø§Ù„Ø¨Ø¯Ø§ÙŠØ©' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(labelText: 'ÙˆÙ‚Øª Ø§Ù„Ù†Ù‡Ø§ÙŠØ©'),
                        onChanged: (value) => endTime = value,
                        validator: (value) => value == null || value.isEmpty ? 'Ø£Ø¯Ø®Ù„ ÙˆÙ‚Øª Ø§Ù„Ù†Ù‡Ø§ÙŠØ©' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Ø±Ù‚Ù… Ø§Ù„Ù‚Ø§Ø¹Ø©'),
                  onChanged: (value) => room = value,
                  validator: (value) => value == null || value.isEmpty ? 'Ø£Ø¯Ø®Ù„ Ø±Ù‚Ù… Ø§Ù„Ù‚Ø§Ø¹Ø©' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: academicYear,
                  decoration: const InputDecoration(labelText: 'Ø§Ù„Ø³Ù†Ø© Ø§Ù„Ø¯Ø±Ø§Ø³ÙŠØ©'),
                  onChanged: (value) => academicYear = value,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: semester,  // âœ… ØªÙ… Ø§Ù„ØªØµØ­ÙŠØ­
                  decoration: const InputDecoration(labelText: 'Ø§Ù„ÙØµÙ„ Ø§Ù„Ø¯Ø±Ø§Ø³ÙŠ'),
                  items: ['Ø§Ù„Ø®Ø±ÙŠÙÙŠ', 'Ø§Ù„Ø±Ø¨ÙŠØ¹ÙŠ', 'Ø§Ù„ØµÙŠÙÙŠ'].map((s) {
                    return DropdownMenuItem(value: s, child: Text(s));
                  }).toList(),
                  onChanged: (value) => semester = value!,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Ø¥Ù„ØºØ§Ø¡'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate() && selectedCourseId != null) {
                final selectedCourse = courses.firstWhere((c) => c.id == selectedCourseId);
                final dayIndex = _days.indexOf(selectedDay!);
                final newSchedule = Schedule(
                  id: '',
                  courseId: selectedCourseId!,
                  courseName: selectedCourse.name,
                  courseCode: selectedCourse.code,
                  instructorName: selectedCourse.instructorName ?? '',
                  dayOfWeek: dayIndex,
                  startTime: startTime!,
                  endTime: endTime!,
                  room: room!,
                  academicYear: academicYear,
                  semester: semester,
                );
                await FirebaseFirestore.instance
                    .collection('schedules')
                    .add(newSchedule.toMap());
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('ØªÙ…Øª Ø¥Ø¶Ø§ÙØ© Ø§Ù„Ø¬Ø¯ÙˆÙ„ Ø¨Ù†Ø¬Ø§Ø­')),
                  );
                }
              }
            },
            child: const Text('Ø­ÙØ¸'),
          ),
        ],
      ),
    );
  }

  void _showEditScheduleDialog(Schedule schedule) {
    // Ù…Ø´Ø§Ø¨Ù‡ Ù„Ù„Ø¥Ø¶Ø§ÙØ© Ù…Ø¹ ØªØ¹Ø¨Ø¦Ø© Ø§Ù„Ø­Ù‚ÙˆÙ„ Ø¨Ù‚ÙŠÙ… schedule Ø§Ù„Ø­Ø§Ù„ÙŠØ©
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('ÙˆØ¸ÙŠÙØ© Ø§Ù„ØªØ¹Ø¯ÙŠÙ„ Ù‚ÙŠØ¯ Ø§Ù„ØªØ·ÙˆÙŠØ±')),
    );
  }

  void _showDeleteConfirmation(Schedule schedule) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ØªØ£ÙƒÙŠØ¯ Ø§Ù„Ø­Ø°Ù'),
        content: Text('Ù‡Ù„ Ø£Ù†Øª Ù…ØªØ£ÙƒØ¯ Ù…Ù† Ø­Ø°Ù Ø§Ù„Ø¬Ø¯ÙˆÙ„ Ø§Ù„Ø®Ø§Øµ Ø¨Ù…Ø§Ø¯Ø© "${schedule.courseName}"ØŸ'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Ø¥Ù„ØºØ§Ø¡'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('schedules')
                  .doc(schedule.id)
                  .delete();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('ØªÙ… Ø­Ø°Ù Ø§Ù„Ø¬Ø¯ÙˆÙ„ Ø¨Ù†Ø¬Ø§Ø­')),
                );
              }
            },
            child: const Text('Ø­Ø°Ù'),
          ),
        ],
      ),
    );
  }
}