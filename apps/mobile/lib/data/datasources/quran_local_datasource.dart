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

    final db = await openDatabase(dbPath);

    // Create hifz tracking table if it doesn't exist
    await db.execute('''
      CREATE TABLE IF NOT EXISTS hifz_pages (
        page INTEGER PRIMARY KEY,
        memorized_at TEXT NOT NULL DEFAULT (datetime('now'))
      )
    ''');

    // Create wird completion tracking table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS wird_completions (
        date TEXT PRIMARY KEY,
        completed_at TEXT NOT NULL DEFAULT (datetime('now'))
      )
    ''');

    // Create khatmah completion tracking table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS khatmah_completions (
        date TEXT PRIMARY KEY,
        completed_at TEXT NOT NULL DEFAULT (datetime('now'))
      )
    ''');

    // Create bookmark collections tables
    await db.execute('''
      CREATE TABLE IF NOT EXISTS bookmark_collections (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        icon_name TEXT NOT NULL DEFAULT 'bookmark',
        sort_order INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL DEFAULT (datetime('now'))
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS bookmark_collection_entries (
        collection_id INTEGER NOT NULL,
        surah_number INTEGER NOT NULL,
        ayah_number INTEGER NOT NULL,
        added_at TEXT NOT NULL DEFAULT (datetime('now')),
        PRIMARY KEY (collection_id, surah_number, ayah_number),
        FOREIGN KEY (collection_id) REFERENCES bookmark_collections(id) ON DELETE CASCADE
      )
    ''');

    return db;
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

  // Bookmark Collections
  Future<List<Map<String, dynamic>>> getAllCollections() async {
    final db = await database;
    return db.rawQuery('''
      SELECT c.*, COUNT(e.collection_id) as bookmark_count
      FROM bookmark_collections c
      LEFT JOIN bookmark_collection_entries e ON e.collection_id = c.id
      GROUP BY c.id
      ORDER BY c.sort_order, c.created_at
    ''');
  }

  Future<int> createCollection(String title, String iconName) async {
    final db = await database;
    return db.insert('bookmark_collections', {
      'title': title,
      'icon_name': iconName,
    });
  }

  Future<void> updateCollection(int id, String title, String iconName) async {
    final db = await database;
    await db.update(
      'bookmark_collections',
      {'title': title, 'icon_name': iconName},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteCollection(int id) async {
    final db = await database;
    await db.delete('bookmark_collection_entries',
        where: 'collection_id = ?', whereArgs: [id]);
    await db.delete('bookmark_collections',
        where: 'id = ?', whereArgs: [id]);
  }

  Future<void> addBookmarkToCollection(
      int collectionId, int surahNumber, int ayahNumber) async {
    final db = await database;
    await db.insert(
      'bookmark_collection_entries',
      {
        'collection_id': collectionId,
        'surah_number': surahNumber,
        'ayah_number': ayahNumber,
      },
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> removeBookmarkFromCollection(
      int collectionId, int surahNumber, int ayahNumber) async {
    final db = await database;
    await db.delete(
      'bookmark_collection_entries',
      where: 'collection_id = ? AND surah_number = ? AND ayah_number = ?',
      whereArgs: [collectionId, surahNumber, ayahNumber],
    );
  }

  Future<List<Map<String, dynamic>>> getBookmarksByCollection(
      int collectionId) async {
    final db = await database;
    return db.rawQuery('''
      SELECT b.id, b.surah_number, b.ayah_number, b.created_at,
             s.name_arabic, s.name_english,
             a.text_uthmani, t.text as translation
      FROM bookmark_collection_entries e
      JOIN bookmarks b ON b.surah_number = e.surah_number AND b.ayah_number = e.ayah_number
      JOIN surahs s ON s.number = b.surah_number
      JOIN ayahs a ON a.surah_number = b.surah_number AND a.ayah_number = b.ayah_number
      LEFT JOIN translations t ON t.surah_number = b.surah_number AND t.ayah_number = b.ayah_number
      WHERE e.collection_id = ?
      ORDER BY e.added_at DESC
    ''', [collectionId]);
  }

  Future<Set<int>> getCollectionIdsForBookmark(
      int surahNumber, int ayahNumber) async {
    final db = await database;
    final results = await db.query(
      'bookmark_collection_entries',
      columns: ['collection_id'],
      where: 'surah_number = ? AND ayah_number = ?',
      whereArgs: [surahNumber, ayahNumber],
    );
    return results.map((r) => r['collection_id'] as int).toSet();
  }

  /// Returns a map of "surah:ayah" -> list of icon_name strings
  Future<Map<String, List<String>>> getAllBookmarkCollectionIcons() async {
    final db = await database;
    final results = await db.rawQuery('''
      SELECT e.surah_number, e.ayah_number, c.icon_name
      FROM bookmark_collection_entries e
      JOIN bookmark_collections c ON c.id = e.collection_id
      ORDER BY e.surah_number, e.ayah_number
    ''');
    final map = <String, List<String>>{};
    for (final r in results) {
      final key = '${r['surah_number']}:${r['ayah_number']}';
      (map[key] ??= []).add(r['icon_name'] as String);
    }
    return map;
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

  // ── Hifz (memorization tracking) ──

  Future<Set<int>> getMemorizedPages() async {
    final db = await database;
    final results = await db.query('hifz_pages', columns: ['page']);
    return results.map((r) => r['page'] as int).toSet();
  }

  /// Toggles a page's memorization state. Returns `true` if now memorized.
  Future<bool> togglePageMemorized(int page) async {
    final db = await database;
    final existing = await db.query(
      'hifz_pages',
      where: 'page = ?',
      whereArgs: [page],
    );
    if (existing.isNotEmpty) {
      await db.delete('hifz_pages', where: 'page = ?', whereArgs: [page]);
      return false;
    } else {
      await db.insert('hifz_pages', {'page': page});
      return true;
    }
  }

  /// Bulk-sets or removes memorization for a list of pages.
  Future<void> bulkSetMemorized(List<int> pages, bool memorized) async {
    final db = await database;
    final batch = db.batch();
    if (memorized) {
      for (final page in pages) {
        batch.insert('hifz_pages', {'page': page},
            conflictAlgorithm: ConflictAlgorithm.ignore);
      }
    } else {
      for (final page in pages) {
        batch.delete('hifz_pages', where: 'page = ?', whereArgs: [page]);
      }
    }
    await batch.commit(noResult: true);
  }

  /// Returns page ranges for each juz: [{juz, startPage, endPage}, ...]
  Future<List<Map<String, int>>> getJuzPageRanges() async {
    final db = await database;
    final results = await db.rawQuery('''
      SELECT juz, MIN(page) as start_page, MAX(page) as end_page
      FROM ayahs
      GROUP BY juz
      ORDER BY juz
    ''');
    return results
        .map((r) => {
              'juz': r['juz'] as int,
              'startPage': r['start_page'] as int,
              'endPage': r['end_page'] as int,
            })
        .toList();
  }

  /// Returns page ranges for each hizb: [{hizb, startPage, endPage}, ...]
  Future<List<Map<String, int>>> getHizbPageRanges() async {
    final db = await database;
    final results = await db.rawQuery('''
      SELECT hizb, MIN(page) as start_page, MAX(page) as end_page
      FROM ayahs
      GROUP BY hizb
      ORDER BY hizb
    ''');
    return results
        .map((r) => {
              'hizb': r['hizb'] as int,
              'startPage': r['start_page'] as int,
              'endPage': r['end_page'] as int,
            })
        .toList();
  }

  /// Returns page ranges per surah within each juz.
  Future<List<Map<String, dynamic>>> getJuzSurahPageRanges() async {
    final db = await database;
    return db.rawQuery('''
      SELECT a.juz, a.surah_number, s.name_arabic, s.name_english,
             MIN(a.page) as start_page, MAX(a.page) as end_page
      FROM ayahs a
      JOIN surahs s ON s.number = a.surah_number
      GROUP BY a.juz, a.surah_number
      ORDER BY a.juz, MIN(a.page)
    ''');
  }

  // Search

  // ── Wird (daily reading tracking) ──

  Future<bool> isWirdCompletedToday() async {
    final db = await database;
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final results = await db.query(
      'wird_completions',
      where: 'date = ?',
      whereArgs: [today],
    );
    return results.isNotEmpty;
  }

  /// Toggles today's wird completion. Returns `true` if now completed.
  Future<bool> toggleWirdCompletion() async {
    final db = await database;
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final existing = await db.query(
      'wird_completions',
      where: 'date = ?',
      whereArgs: [today],
    );
    if (existing.isNotEmpty) {
      await db.delete('wird_completions', where: 'date = ?', whereArgs: [today]);
      return false;
    } else {
      await db.insert('wird_completions', {'date': today});
      return true;
    }
  }

  // ── Khatmah (complete Quran reading tracking) ──

  Future<bool> isKhatmahCompletedToday() async {
    final db = await database;
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final results = await db.query(
      'khatmah_completions',
      where: 'date = ?',
      whereArgs: [today],
    );
    return results.isNotEmpty;
  }

  /// Toggles today's khatmah completion. Returns `true` if now completed.
  Future<bool> toggleKhatmahCompletion() async {
    final db = await database;
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final existing = await db.query(
      'khatmah_completions',
      where: 'date = ?',
      whereArgs: [today],
    );
    if (existing.isNotEmpty) {
      await db.delete('khatmah_completions', where: 'date = ?', whereArgs: [today]);
      return false;
    } else {
      await db.insert('khatmah_completions', {'date': today});
      return true;
    }
  }

  Future<void> clearAllUserData() async {
    final db = await database;
    final batch = db.batch();
    batch.delete('bookmark_collection_entries');
    batch.delete('bookmark_collections');
    batch.delete('bookmarks');
    batch.delete('hifz_pages');
    batch.delete('wird_completions');
    batch.delete('khatmah_completions');
    batch.update(
      'reading_progress',
      {
        'surah_number': 1,
        'ayah_number': 1,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = 1',
    );
    await batch.commit(noResult: true);
  }

  Future<List<SearchResultItem>> searchArabic(String query) async {
    final db = await database;
    // Strip diacritics so bare text matches against text_simple
    final cleaned = query
        .replaceAll(RegExp(r'[\u064B-\u065F\u0610-\u061A\u0670\u06D6-\u06ED]'), '')
        .trim();
    if (cleaned.isEmpty) return [];
    final results = await db.rawQuery('''
      SELECT a.surah_number, a.ayah_number, a.text_uthmani,
             t.text as translation, s.name_arabic, s.name_english
      FROM ayahs a
      JOIN surahs s ON s.number = a.surah_number
      LEFT JOIN translations t ON t.surah_number = a.surah_number AND t.ayah_number = a.ayah_number
      WHERE REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
        a.text_simple,
        char(1611),''), char(1612),''), char(1613),''), char(1614),''),
        char(1615),''), char(1616),''), char(1617),''), char(1618),''),
        char(1648),'') LIKE ?
      LIMIT 50
    ''', ['%$cleaned%']);
    return results.map(_rowToSearchResult).toList();
  }
}
