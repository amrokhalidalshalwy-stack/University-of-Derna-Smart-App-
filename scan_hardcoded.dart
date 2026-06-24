import 'dart:io';
import 'dart:convert';

void main() async {
  final baseDir = Directory.current.path;
  final dirsToScan = [
    Directory('$baseDir/lib/features'),
    Directory('$baseDir/lib/core'),
  ];
  final arbArPath = '$baseDir/lib/l10n/app_ar.arb';
  final arbEnPath = '$baseDir/lib/l10n/app_en.arb';

  Map<String, dynamic> loadArb(String path) {
    try {
      final file = File(path);
      if (file.existsSync()) {
        final content = file.readAsStringSync();
        return jsonDecode(content) as Map<String, dynamic>;
      }
    } catch (e) {
      // Ignore
    }
    return {};
  }

  final arbAr = loadArb(arbArPath);
  final arbEn = loadArb(arbEnPath);

  final arValues = <String, String>{};
  final enValues = <String, String>{};

  arbAr.forEach((key, value) {
    if (!key.startsWith('@')) {
      arValues[value.toString().trim()] = key;
    }
  });

  arbEn.forEach((key, value) {
    if (!key.startsWith('@')) {
      enValues[value.toString().trim()] = key;
    }
  });

  final uiParamsPattern = RegExp(
    r"(?:Text\s*\(\s*|title\s*:\s*|label\s*:\s*|hint\s*:\s*|hintText\s*:\s*|labelText\s*:\s*|tooltip\s*:\s*|buttonText\s*:\s*).*?(['"
    '"])(.*?[^\\\\]?)\\1',
  );

  final arabicPattern = RegExp(
    r"(['"
    '"])(.*?[^\\\\]?)\\1',
  );
  final arabicCharPattern = RegExp(r'[\u0600-\u06FF]');

  String generateKey(String text, bool isArabic, int counter) {
    if (!isArabic) {
      final cleanText = text.replaceAll(RegExp(r'[^a-zA-Z0-9 ]'), '');
      final words = cleanText.split(' ').where((w) => w.isNotEmpty).toList();
      if (words.isEmpty) return 'uiKey_$counter';

      String key = words[0].toLowerCase();
      for (int i = 1; i < words.length && i < 5; i++) {
        key += words[i][0].toUpperCase() + words[i].substring(1).toLowerCase();
      }
      return key;
    } else {
      return 'arabicString_$counter';
    }
  }

  final results = <String>[];
  final missingKeysDict = <String, dynamic>{};

  int filesScanned = 0;
  final filesWithStrings = <String>{};
  int totalStringsFound = 0;
  int alreadyInArb = 0;
  int missingFromArb = 0;
  int counter = 1;

  for (final dir in dirsToScan) {
    if (!dir.existsSync()) continue;

    final entities = dir.listSync(recursive: true);
    for (final entity in entities) {
      if (entity is File && entity.path.endsWith('.dart')) {
        filesScanned++;
        final lines = entity.readAsLinesSync();

        bool inBuild = false;
        int braceLevel = 0;

        for (int i = 0; i < lines.length; i++) {
          final line = lines[i];
          final cleanLine = line.trim();

          if (cleanLine.startsWith('//')) continue;

          if (cleanLine.contains('Widget build(')) {
            inBuild = true;
            braceLevel = 0;
          }

          if (inBuild) {
            braceLevel +=
                '{'.allMatches(line).length - '}'.allMatches(line).length;
            if (braceLevel <= 0 && line.contains('}')) {
              inBuild = false;
            }
          }

          final foundStrings = <Map<String, dynamic>>[];

          // Check Arabic strings
          for (final match in arabicPattern.allMatches(line)) {
            final text = match.group(2) ?? '';
            if (arabicCharPattern.hasMatch(text)) {
              foundStrings.add({'text': text, 'isArabic': true});
            }
          }

          // Check English UI strings
          for (final match in uiParamsPattern.allMatches(line)) {
            final text = match.group(2) ?? '';
            if (text.isEmpty || text.trim().length < 2) continue;
            if (arabicCharPattern.hasMatch(text)) continue;
            if (!RegExp(r'[A-Za-z]').hasMatch(text)) continue;
            if (text.startsWith(r'$')) continue;

            foundStrings.add({'text': text, 'isArabic': false});
          }

          final seen = <String>{};
          for (final item in foundStrings) {
            final text = item['text'] as String;
            final isAr = item['isArabic'] as bool;

            if (seen.contains(text)) continue;
            seen.add(text);

            if (text.startsWith('/') ||
                text.startsWith('assets/') ||
                text.endsWith('.png')) {
              continue;
            }

            totalStringsFound++;
            filesWithStrings.add(entity.path);

            bool isInArb = false;
            String suggestedKey = '';

            if (isAr) {
              if (arValues.containsKey(text)) {
                isInArb = true;
                suggestedKey = arValues[text]!;
              }
            } else {
              if (enValues.containsKey(text)) {
                isInArb = true;
                suggestedKey = enValues[text]!;
              }
            }

            if (isInArb) {
              alreadyInArb++;
            } else {
              missingFromArb++;
              suggestedKey = generateKey(text, isAr, counter);
              counter++;

              if (isAr) {
                missingKeysDict[suggestedKey] = "[ARABIC] $text";
                missingKeysDict['@$suggestedKey'] = {
                  "description": "Auto-extracted Arabic string",
                };
              } else {
                missingKeysDict[suggestedKey] = text;
                missingKeysDict['@$suggestedKey'] = {
                  "description": "Auto-extracted English string",
                };
              }
            }

            final relPath = entity.path
                .replaceFirst(baseDir, '')
                .replaceAll('\\', '/');
            results.add(
              "FILE: $relPath\n"
              "LINE: ${i + 1}\n"
              "STRING: \"$text\"\n"
              "SUGGESTED_KEY: $suggestedKey\n"
              "ALREADY_IN_ARB: ${isInArb ? 'YES' : 'NO'}\n",
            );
          }
        }
      }
    }
  }

  final reportFile = File('$baseDir/scan_report.txt');
  final buffer = StringBuffer();
  for (final res in results) {
    buffer.writeln(res);
  }
  buffer.writeln("========================================");
  buffer.writeln("SUMMARY:");
  buffer.writeln("Total files scanned: $filesScanned");
  buffer.writeln("Files with hardcoded strings: ${filesWithStrings.length}");
  buffer.writeln("Total hardcoded strings found: $totalStringsFound");
  buffer.writeln("Already in ARB: $alreadyInArb");
  buffer.writeln("Missing from ARB: $missingFromArb");
  buffer.writeln("========================================");
  buffer.writeln("MISSING KEYS JSON BLOCK:");
  buffer.writeln(const JsonEncoder.withIndent('  ').convert(missingKeysDict));

  reportFile.writeAsStringSync(buffer.toString());
}
