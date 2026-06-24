import 'package:flutter/material.dart';
import 'package:flutter_project/features/faculty/presentation/pages/faculty_dashboard_page.dart';

/// Faculty grade entry — opens dashboard on the Grades tab.
class GradeEntryPage extends StatelessWidget {
  const GradeEntryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const FacultyDashboardPage(initialTab: 3);
  }
}
