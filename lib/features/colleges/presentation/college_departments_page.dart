import 'package:flutter/material.dart';
import 'package:flutter_project/core/colleges/college_registry.dart';
import 'package:flutter_project/l10n/app_localizations.dart';

class CollegeDepartmentsPage extends StatelessWidget {
  const CollegeDepartmentsPage({super.key, required this.college});

  final CollegeDefinition college;

  @override
  Widget build(BuildContext context) {
    final departments = college.departments;
    final l10n = AppLocalizations.of(context)!;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    if (departments.isEmpty) {
      return Center(
        child: Text(
          l10n.collegeNoDepartments,
          style: const TextStyle(fontFamily: 'Cairo'),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: departments.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final name = departments[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: college.backgroundColor,
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.bold,
                  color: college.primaryColor,
                ),
              ),
            ),
            title: Text(
              name,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.w600,
              ),
            ),
            trailing: Icon(
              isAr ? Icons.chevron_left : Icons.chevron_right,
              color: college.primaryColor,
            ),
          ),
        );
      },
    );
  }
}
