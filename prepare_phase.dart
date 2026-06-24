// ignore_for_file: avoid_print, prefer_interpolation_to_compose_strings
import 'dart:io';
import 'dart:convert';

void main() {
  final reportFile = File('scan_report.txt');
  if (!reportFile.existsSync()) {
    print('scan_report.txt not found');
    return;
  }

  final lines = reportFile.readAsLinesSync();

  int uiCount = 0;
  int backendCount = 0;
  int errorCount = 0;
  int constCount = 0;

  final uiStrings = <String, Map<String, dynamic>>{};
  final batches = <String, Set<String>>{};

  final tableRows = <String>[];

  String? currentFile;
  String? currentLine;
  String? currentString;
  bool alreadyInArb = false;

  for (final line in lines) {
    if (line.startsWith('FILE: ')) currentFile = line.substring(6).trim();
    if (line.startsWith('LINE: ')) currentLine = line.substring(6).trim();
    if (line.startsWith('STRING: ')) {
      currentString = line.substring(8).trim();
      if (currentString.startsWith('"') && currentString.endsWith('"')) {
        currentString = currentString.substring(1, currentString.length - 1);
      }
    }
    if (line.startsWith('ALREADY_IN_ARB: ')) {
      alreadyInArb = line.substring(16).trim() == 'YES';

      // Categorize
      String category = '';
      if (currentString!.contains(r'${') ||
          currentString.endsWith('[') ||
          currentString.endsWith('(') ||
          currentString.contains('["')) {
        category = 'ERROR';
        errorCount++;
      } else if (currentFile!.contains('/data/') ||
          currentFile.contains('/services/') ||
          currentFile.contains('/repository/') ||
          currentFile.contains('/domain/') ||
          currentFile.contains('/impl/')) {
        category = 'BACKEND';
        backendCount++;
      } else if (currentFile.contains('/constants/') ||
          currentFile.contains('/models/') ||
          currentFile.contains('/core/errors/')) {
        category = 'CONST';
        constCount++;
      } else {
        category = 'UI';
        uiCount++;

        // Group by feature
        final parts = currentFile.split('/');
        String feature = 'shared';
        if (parts.contains('features')) {
          final idx = parts.indexOf('features');
          if (idx + 1 < parts.length) {
            feature = parts[idx + 1];
          }
        }

        batches.putIfAbsent(feature, () => <String>{});
        batches[feature]!.add(currentFile);

        if (!alreadyInArb) {
          if (!uiStrings.containsKey(currentString)) {
            uiStrings[currentString] = {
              'file': currentFile,
              'feature': feature,
            };
          }
        }
      }

      if (tableRows.length < 50) {
        String dispStr =
            currentString.length > 35
                ? currentString.substring(0, 35) + '...'
                : currentString;
        dispStr = dispStr.replaceAll('\n', ' ');
        tableRows.add(
          '| ${currentFile!.split('/').last} | $currentLine | $dispStr | [$category] |',
        );
      }
    }
  }

  print('==== PHASE A ====');
  print('| File | Line | String | Category |');
  print('|------|------|--------|----------|');
  for (var row in tableRows.take(15)) {
    print(row);
  }
  print('... (truncated for brevity)');

  print('\nCounts:');
  print('UI strings to localize:    $uiCount');
  print('BACKEND — skip:            $backendCount');
  print('ERROR — skip:              $errorCount');
  print('CONST — review manually:   $constCount');

  print('\n==== PHASE C ====');
  batches.forEach((feature, files) {
    print('Batch: $feature/ files: ${files.length}');
  });

  File(
    'ui_strings.json',
  ).writeAsStringSync(JsonEncoder.withIndent('  ').convert(uiStrings));
}
