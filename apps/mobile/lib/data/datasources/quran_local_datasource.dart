import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/surah.dart';
import '../models/ayah.dart';

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
}
