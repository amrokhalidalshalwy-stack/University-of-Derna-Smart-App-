import 'dart:io';

void main() {
  final file = File('coverage/lcov.info');
  if (!file.existsSync()) {
    // coverage/lcov.info not found
    return;
  }

  final lines = file.readAsLinesSync();
  String currentFile = '';
  int foundLines = 0;
  int hitLines = 0;

  final Map<String, double> coverageData = {};

  for (final line in lines) {
    if (line.startsWith('SF:')) {
      currentFile = line.substring(3);
      foundLines = 0;
      hitLines = 0;
    } else if (line.startsWith('DA:')) {
      final parts = line.substring(3).split(',');
      if (parts.length >= 2) {
        final hit = int.parse(parts[1]);
        foundLines++;
        if (hit > 0) hitLines++;
      }
    } else if (line == 'end_of_record') {
      if (foundLines > 0) {
        coverageData[currentFile] = (hitLines / foundLines) * 100;
      }
    }
  }

  final categoryA = <String, double>{};
  final categoryB = <String, double>{};
  final categoryC = <String, double>{};

  for (final entry in coverageData.entries) {
    final path = entry.key;
    final percentage = entry.value;

    if (percentage <= 20.0) {
      if (path.contains('presentation') || path.contains('screens') || path.contains('widgets') || path.contains('pages') || path.contains('dialogs')) {
        categoryC[path] = percentage;
      } else if (path.contains('data') || path.contains('datasource') || path.contains('firebase') || path.contains('repository')) {
        categoryB[path] = percentage;
      } else if (path.contains('service') || path.contains('validator') || path.contains('utils') || path.contains('core')) {
        categoryA[path] = percentage;
      } else {
        // Default to B or A depending on name
        if (path.contains('model')) {
          categoryB[path] = percentage; // models
        } else {
          categoryA[path] = percentage;
        }
      }
    }
  }

  // --- الفئة (أ) منطق أعمال خالص (services, validators, repositories, utils) ---
  categoryA.entries.toList()..sort((a, b) => a.value.compareTo(b.value))..forEach((e) {
    // ${e.key}: ${e.value.toStringAsFixed(1)}%
  });

  // --- الفئة (ب) طبقة بيانات/تكامل (data sources, Firestore wrappers) ---
  categoryB.entries.toList()..sort((a, b) => a.value.compareTo(b.value))..forEach((e) {
    // ${e.key}: ${e.value.toStringAsFixed(1)}%
  });

  // --- الفئة (ج) واجهات مستخدم (pages, widgets) ---
  categoryC.entries.toList()..sort((a, b) => a.value.compareTo(b.value))..forEach((e) {
    // ${e.key}: ${e.value.toStringAsFixed(1)}%
  });
}
