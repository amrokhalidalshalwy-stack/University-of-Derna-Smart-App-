import 'dart:io';

void main() {
  final file = File('coverage/lcov.info');
  if (!file.existsSync()) {
    // lcov.info not found
    return;
  }

  final lines = file.readAsLinesSync();
  
  Map<String, List<int>> stats = {
    'lib/core/services/': [0, 0],
    'lib/features/faculty/': [0, 0],
    'lib/features/attendance/': [0, 0],
  };

  String currentFile = '';
  
  for (var line in lines) {
    if (line.startsWith('SF:')) {
      currentFile = line.substring(3).replaceAll('\\', '/');
    } else if (line.startsWith('LF:')) {
      int lf = int.parse(line.substring(3));
      for (var key in stats.keys) {
        if (currentFile.startsWith(key)) {
          stats[key]![0] += lf;
        }
      }
    } else if (line.startsWith('LH:')) {
      int lh = int.parse(line.substring(3));
      for (var key in stats.keys) {
        if (currentFile.startsWith(key)) {
          stats[key]![1] += lh;
        }
      }
    }
  }
  
  // totalCov = totalLf > 0 ? (totalLh / totalLf) * 100 : 0;
  // Total Coverage: ${totalCov.toStringAsFixed(2)}% ($totalLh/$totalLf)
  
  for (var _ in stats.keys) {
    // lf = stats[key]![0];
    // lh = stats[key]![1];
    // cov = lf > 0 ? (lh / lf) * 100 : 0;
    // $key Coverage: ${cov.toStringAsFixed(2)}% ($lh/$lf)
  }
}
