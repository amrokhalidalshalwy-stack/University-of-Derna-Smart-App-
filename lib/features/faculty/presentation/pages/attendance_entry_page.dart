import 'package:flutter/material.dart';
import 'package:flutter_project/features/faculty/presentation/pages/faculty_dashboard_page.dart';

/// Faculty attendance — opens dashboard on the Attendance tab.
class AttendanceEntryPage extends StatelessWidget {
  const AttendanceEntryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const FacultyDashboardPage(initialTab: 2);
  }
}
