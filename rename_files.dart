import 'dart:io';

void main() {
  final filesToRename = {
    'lib/jadwaly/Jadwaly.dart': 'lib/jadwaly/jadwaly.dart',
    'lib/settings/sub_settings/college_location_Page.dart':
        'lib/settings/sub_settings/college_location_page.dart',
    'lib/settings/sub_settings/edit_profile_Image_page.dart':
        'lib/settings/sub_settings/edit_profile_image_page.dart',
    'lib/settings/sub_settings/reportIssue_page.dart':
        'lib/settings/sub_settings/report_issue_page.dart',
    'lib/jadwaly/alfosol/chatpage/file_picker.dart':
        'lib/jadwaly/alfosol/chatpage/file_picker_service.dart',
  };

  for (final entry in filesToRename.entries) {
    final oldFile = File(entry.key);
    final newFile = File(entry.value);

    if (oldFile.existsSync()) {
      // On Windows, renaming to just a case difference requires an intermediate name
      final tempFile = File('${entry.key}.tmp');
      oldFile.renameSync(tempFile.path);
      tempFile.renameSync(newFile.path);
      stdout.writeln('Renamed ${entry.key} to ${entry.value}');
    } else {
      stdout.writeln('File not found: ${entry.key}');
    }
  }
  stdout.writeln('Done renaming files.');
}
