import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// SQLite helper for transcript PDF URL metadata (offline-first cache).
///
/// ```sql
/// -- setup.sql
/// CREATE TABLE IF NOT EXISTS local_pdf_cache (
///   id INTEGER PRIMARY KEY AUTOINCREMENT,
///   student_id TEXT NOT NULL,
///   semester TEXT NOT NULL,
///   pdf_url TEXT NOT NULL,
///   cached_at INTEGER NOT NULL,
///   UNIQUE(student_id, semester)
/// );
/// CREATE INDEX IF NOT EXISTS idx_local_pdf_cache_student_semester
///   ON local_pdf_cache(student_id, semester);
/// ```
class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();

  static const _dbName = 'transcript_pdf_cache.db';
  static const _dbVersion = 1;

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
CREATE TABLE local_pdf_cache (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  student_id TEXT NOT NULL,
  semester TEXT NOT NULL,
  pdf_url TEXT NOT NULL,
  cached_at INTEGER NOT NULL,
  UNIQUE(student_id, semester)
);
''');
    await db.execute('''
CREATE INDEX idx_local_pdf_cache_student_semester
  ON local_pdf_cache(student_id, semester);
''');
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
