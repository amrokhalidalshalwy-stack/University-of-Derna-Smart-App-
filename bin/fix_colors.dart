import 'dart:io';

void main() {
  final Map<String, List<int>> targetFiles = {
    'lib/shared/widgets/empty_state_widget.dart': [39],
    'lib/features/study/presentation/pages/semester_page.dart': [462],
    'lib/features/study/presentation/pages/department_info_page.dart': [156],
    'lib/features/study/presentation/pages/college_info_page.dart': [339, 375, 443, 513],
    'lib/features/student/presentation/pages/academic_plan_page.dart': [196, 209, 215, 245, 288, 298],
    'lib/features/settings/presentation/pages/about_page.dart': [117],
    'lib/features/settings/presentation/pages/privacy_policy_page.dart': [104],
    'lib/features/settings/presentation/pages/college_location_page.dart': [244],
    'lib/features/settings/presentation/pages/branches_info_page.dart': [81],
    'lib/features/fees/presentation/pages/enrollment_renewal_page.dart': [590],
    'lib/features/faculty/screens/faculty_home_screen.dart': [313],
    'lib/features/faculty/presentation/pages/faculty_settings_page.dart': [410],
    'lib/features/attendance/presentation/pages/absence_excuse_page.dart': [217, 360, 462],
    'lib/features/splash/presentation/pages/splash_page.dart': [123, 135, 199],
    'lib/features/gateway/presentation/pages/gateway_page.dart': [361, 374, 678, 716],
    'lib/features/guest/presentation/pages/guest_portal_page.dart': [99, 118, 131, 377, 443],
    'lib/features/faculty/pages/faculty_dashboard_page.dart': [997, 1012, 1120, 1237, 1244, 1331, 1424, 1580, 1615],
    'lib/features/faculty/presentation/widgets/dashboard_attendance_tab.dart': [47, 164, 171, 262],
    'lib/features/faculty/presentation/widgets/dashboard_classes_tab.dart': [69, 84],
    'lib/features/faculty/presentation/widgets/dashboard_grades_tab.dart': [45, 203],
    'lib/features/admin/presentation/pages/verification_queue_page.dart': [124],
  };

  final Map<RegExp, String> replacements = {
    RegExp(r'color:\s*AppTheme\.primaryColor'): 'color: Theme.of(context).colorScheme.primary',
    RegExp(r'color:\s*const\s*Color\(0xFF001835\)'): 'color: Theme.of(context).colorScheme.primary',
    RegExp(r'color:\s*Color\(0xFF001835\)'): 'color: Theme.of(context).colorScheme.primary',
    RegExp(r'color:\s*AppTheme\.onSurfaceColor'): 'color: Theme.of(context).colorScheme.onSurface',
    RegExp(r'color:\s*const\s*Color\(0xFF191C1E\)'): 'color: Theme.of(context).colorScheme.onSurface',
    RegExp(r'color:\s*Color\(0xFF191C1E\)'): 'color: Theme.of(context).colorScheme.onSurface',
    RegExp(r'color:\s*AppTheme\.onSurfaceVariantColor'): 'color: Theme.of(context).colorScheme.onSurfaceVariant',
    RegExp(r'color:\s*const\s*Color\(0xFF43474E\)'): 'color: Theme.of(context).colorScheme.onSurfaceVariant',
    RegExp(r'color:\s*Color\(0xFF43474E\)'): 'color: Theme.of(context).colorScheme.onSurfaceVariant',
    RegExp(r'color:\s*const\s*Color\(0xFF74777F\)'): 'color: Theme.of(context).colorScheme.onSurfaceVariant',
    RegExp(r'color:\s*Color\(0xFF74777F\)'): 'color: Theme.of(context).colorScheme.onSurfaceVariant',
    RegExp(r'color:\s*const\s*Color\(0xFF1565C0\)'): 'color: Theme.of(context).colorScheme.primary',
    RegExp(r'color:\s*Color\(0xFF1565C0\)'): 'color: Theme.of(context).colorScheme.primary',
    RegExp(r'color:\s*AppTheme\.primary'): 'color: Theme.of(context).colorScheme.primary',
  };

  for (final entry in targetFiles.entries) {
    final file = File(entry.key);
    if (!file.existsSync()) {
      continue;
    }
    
    List<String> lines = file.readAsLinesSync();
    bool changed = false;

    for (int lineNum in entry.value) {
      if (lineNum - 1 < lines.length) {
        String line = lines[lineNum - 1];
        String originalLine = line;

        // Apply replacements
        for (final replacement in replacements.entries) {
          line = line.replaceAll(replacement.key, replacement.value);
        }

        // If something was replaced, ensure no 'const ' precedes TextStyle or Icon on the same line
        if (line != originalLine) {
          line = line.replaceAll(RegExp(r'const\s+TextStyle'), 'TextStyle');
          line = line.replaceAll(RegExp(r'const\s+Icon'), 'Icon');
          lines[lineNum - 1] = line;
          changed = true;
          
          // Look backwards for 'const' in previous lines if it was multi-line
          // Very naive lookback for 'const'
          for (int i = lineNum - 2; i >= 0 && i >= lineNum - 5; i--) {
            if (lines[i].contains('const ') && (lines[i].contains('style:') || lines[i].contains('icon:') || lines[i].contains('Text(') || lines[i].contains('Widget'))) {
               // This is tricky, might break things, so we will only do simple replacements.
               if (lines[i].contains('const TextStyle')) {
                 lines[i] = lines[i].replaceAll('const TextStyle', 'TextStyle');
               } else if (lines[i].contains('const Icon')) {
                 lines[i] = lines[i].replaceAll('const Icon', 'Icon');
               } else if (lines[i].trim() == 'const') {
                 lines[i] = lines[i].replaceFirst('const', '');
               }
               break;
            }
          }
        }
      }
    }

    if (changed) {
      file.writeAsStringSync('${lines.join('\n')}\n');
      // Updated ${entry.key}
    }
  }
}
