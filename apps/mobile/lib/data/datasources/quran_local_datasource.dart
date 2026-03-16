import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/surah.dart';
import '../models/ayah.dart';
import '../models/search_result.dart';

class QuranLocalDatasource {
  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final documentsDir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(documentsDir.path, 'quran.db');

    // Copy from assets if not exists
    if (!File(dbPath).existsSync()) {
      final data = await rootBundle.load('assets/db/quran.db');
      final bytes = data.buffer.asUint8List();
      await File(dbPath).writeAsBytes(bytes, flush: true);
    }

    return openDatabase(dbPath);
  }

  Future<List<Surah>> getAllSurahs() async {
    final db = await database;
    final results = await db.query('surahs', orderBy: 'number');
    return results.map((row) => Surah.fromJson(row)).toList();
  }

  Future<Surah?> getSurah(int number) async {
    final db = await database;
    final results = await db.query('surahs', where: 'number = ?', whereArgs: [number]);
    if (results.isEmpty) return null;
    return Surah.fromJson(results.first);
  }

  Future<List<Ayah>> getAyahsBySurah(int surahNumber) async {
    final db = await database;
    final results = await db.rawQuery('''
      SELECT a.*, t.text as translation
      FROM ayahs a
      LEFT JOIN translations t ON t.surah_number = a.surah_number AND t.ayah_number = a.ayah_number
      WHERE a.surah_number = ?
      ORDER BY a.ayah_number
    ''', [surahNumber]);
    return results.map((row) => Ayah.fromJson(row)).toList();
  }

  Future<List<Surah>> getSurahsByJuz(int juzNumber) async {
    final db = await database;
    final results = await db.rawQuery('''
      SELECT DISTINCT s.*
      FROM surahs s
      INNER JOIN ayahs a ON a.surah_number = s.number
      WHERE a.juz = ?
      ORDER BY s.number
    ''', [juzNumber]);
    return results.map((row) => Surah.fromJson(row)).toList();
  }

  // Reading progress
  Future<Map<String, int>> getReadingProgress() async {
    final db = await database;
    final results = await db.query('reading_progress', where: 'id = 1');
    if (results.isEmpty) return {'surah_number': 1, 'ayah_number': 1};
    return {
      'surah_number': results.first['surah_number'] as int,
      'ayah_number': results.first['ayah_number'] as int,
    };
  }

  Future<void> updateReadingProgress(int surahNumber, int ayahNumber) async {
    final db = await database;
    await db.update(
      'reading_progress',
      {
        'surah_number': surahNumber,
        'ayah_number': ayahNumber,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = 1',
    );
  }

  // Bookmarks
  Future<Set<String>> getBookmarkKeys() async {
    final db = await database;
    final results = await db.query('bookmarks', columns: ['surah_number', 'ayah_number']);
    return results.map((r) => '${r['surah_number']}:${r['ayah_number']}').toSet();
  }

  Future<List<Map<String, dynamic>>> getAllBookmarks() async {
    final db = await database;
    return db.rawQuery('''
      SELECT b.id, b.surah_number, b.ayah_number, b.created_at,
             s.name_arabic, s.name_english,
             a.text_uthmani, t.text as translation
      FROM bookmarks b
      JOIN surahs s ON s.number = b.surah_number
      JOIN ayahs a ON a.surah_number = b.surah_number AND a.ayah_number = b.ayah_number
      LEFT JOIN translations t ON t.surah_number = b.surah_number AND t.ayah_number = b.ayah_number
      ORDER BY b.created_at DESC
    ''');
  }

  Future<void> addBookmark(int surahNumber, int ayahNumber) async {
    final db = await database;
    await db.insert('bookmarks', {
      'surah_number': surahNumber,
      'ayah_number': ayahNumber,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<void> removeBookmark(int surahNumber, int ayahNumber) async {
    final db = await database;
    await db.delete(
      'bookmarks',
      where: 'surah_number = ? AND ayah_number = ?',
      whereArgs: [surahNumber, ayahNumber],
    );
  }

  // Page metadata (juz/hizb)
  Future<Map<String, int>> getPageMetadata(int pageNumber) async {
    final db = await database;
    final results = await db.query(
      'ayahs',
      columns: ['juz', 'hizb'],
      where: 'page = ?',
      whereArgs: [pageNumber],
      orderBy: 'id',
      limit: 1,
    );
    if (results.isEmpty) return {'juz': 1, 'hizb': 1};
    return {
      'juz': results.first['juz'] as int,
      'hizb': results.first['hizb'] as int,
    };
  }

  // Search

  String _sanitizeFtsQuery(String query) {
    // Remove FTS5 special characters that can cause syntax errors
    final sanitized = query.replaceAll(RegExp(r'["\(\)\*\+\-\^:]'), ' ').trim();
    if (sanitized.isEmpty) return '""';
    // Wrap each word with * for prefix matching
    return sanitized
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .map((w) => '$w*')
        .join(' ');
  }

  SearchResultItem _rowToSearchResult(Map<String, dynamic> row) {
    return SearchResultItem(
      surahNumber: row['surah_number'] as int,
      ayahNumber: row['ayah_number'] as int,
      textUthmani: row['text_uthmani'] as String? ?? '',
      nameArabic: row['name_arabic'] as String? ?? '',
      nameEnglish: row['name_english'] as String? ?? '',
      translation: row['translation'] as String?,
    );
  }

  Future<List<SearchResultItem>> searchTranslations(String query) async {
    final db = await database;
    final ftsQuery = _sanitizeFtsQuery(query);
    final results = await db.rawQuery('''
      SELECT a.surah_number, a.ayah_number, a.text_uthmani, t.text as translation,
             s.name_arabic, s.name_english
      FROM translations_fts fts
      JOIN translations t ON t.id = fts.rowid
      JOIN ayahs a ON a.surah_number = t.surah_number AND a.ayah_number = t.ayah_number
      JOIN surahs s ON s.number = a.surah_number
      WHERE translations_fts MATCH ?
      LIMIT 50
    ''', [ftsQuery]);
    return results.map(_rowToSearchResult).toList();
  }

  Future<List<SearchResultItem>> searchArabic(String query) async {
    final db = await database;
    final ftsQuery = _sanitizeFtsQuery(query);
    final results = await db.rawQuery('''
      SELECT a.surah_number, a.ayah_number, a.text_uthmani, a.text_simple,
             t.text as translation, s.name_arabic, s.name_english
      FROM ayahs_fts fts
      JOIN ayahs a ON a.id = fts.rowid
      JOIN surahs s ON s.number = a.surah_number
      LEFT JOIN translations t ON t.surah_number = a.surah_number AND t.ayah_number = a.ayah_number
      WHERE ayahs_fts MATCH ?
      LIMIT 50
    ''', [ftsQuery]);
    return results.map(_rowToSearchResult).toList();
  }
}
