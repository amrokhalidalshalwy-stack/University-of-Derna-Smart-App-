import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import 'package:flutter_project/features/transcript/data/database/database_helper.dart';

class CachedPdfEntry {
  const CachedPdfEntry({
    required this.studentId,
    required this.semester,
    required this.pdfUrl,
    required this.cachedAt,
  });

  final String studentId;
  final String semester;
  final String pdfUrl;
  final int cachedAt;
}

/// Reads and writes PDF URL metadata in SQLite.
class LocalPdfCacheDataSource {
  LocalPdfCacheDataSource(this._dbHelper);

  final DatabaseHelper _dbHelper;

  static const _table = 'local_pdf_cache';

  Future<CachedPdfEntry?> getCachedPdf(String studentId, String semester) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      _table,
      where: 'student_id = ? AND semester = ?',
      whereArgs: [studentId, semester],
      limit: 1,
    );
    if (rows.isEmpty) {
      debugPrint('[LocalPdfCache] cache miss for $studentId / $semester');
      return null;
    }
    final row = rows.first;
    debugPrint('[LocalPdfCache] cache hit for $studentId / $semester');
    return CachedPdfEntry(
      studentId: row['student_id'] as String,
      semester: row['semester'] as String,
      pdfUrl: row['pdf_url'] as String,
      cachedAt: row['cached_at'] as int,
    );
  }

  Future<void> savePdfUrl(
    String studentId,
    String semester,
    String pdfUrl,
  ) async {
    final db = await _dbHelper.database;
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.insert(
      _table,
      {
        'student_id': studentId,
        'semester': semester,
        'pdf_url': pdfUrl,
        'cached_at': now,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    debugPrint('[LocalPdfCache] saved URL for $studentId / $semester at $now');
  }
}
