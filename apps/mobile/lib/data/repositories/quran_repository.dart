import '../datasources/quran_local_datasource.dart';
import '../models/surah.dart';
import '../models/ayah.dart';
import '../models/search_result.dart';

class QuranRepository {
  final QuranLocalDatasource _datasource;

  QuranRepository(this._datasource);

  Future<List<Surah>> getAllSurahs() => _datasource.getAllSurahs();
  Future<Surah?> getSurah(int number) => _datasource.getSurah(number);
  Future<List<Ayah>> getAyahsBySurah(int surahNumber) => _datasource.getAyahsBySurah(surahNumber);
  Future<List<Surah>> getSurahsByJuz(int juzNumber) => _datasource.getSurahsByJuz(juzNumber);
  Future<Map<String, int>> getReadingProgress() => _datasource.getReadingProgress();
  Future<void> updateReadingProgress(int surahNumber, int ayahNumber) =>
      _datasource.updateReadingProgress(surahNumber, ayahNumber);

  // Page metadata
  Future<Map<String, int>> getPageMetadata(int pageNumber) =>
      _datasource.getPageMetadata(pageNumber);

  // Bookmarks
  Future<Set<String>> getBookmarkKeys() => _datasource.getBookmarkKeys();
  Future<List<Map<String, dynamic>>> getAllBookmarks() => _datasource.getAllBookmarks();
  Future<void> addBookmark(int surahNumber, int ayahNumber) =>
      _datasource.addBookmark(surahNumber, ayahNumber);
  Future<void> removeBookmark(int surahNumber, int ayahNumber) =>
      _datasource.removeBookmark(surahNumber, ayahNumber);

  // Search
  Future<List<SearchResultItem>> searchTranslations(String query) =>
      _datasource.searchTranslations(query);
  Future<List<SearchResultItem>> searchArabic(String query) =>
      _datasource.searchArabic(query);

  List<Surah> searchSurahNames(List<Surah> allSurahs, String query) {
    final q = query.trim();
    if (q.isEmpty) return [];

    // Numeric query — match surah number prefix
    final numericMatch = int.tryParse(q);
    if (numericMatch != null) {
      return allSurahs
          .where((s) => s.number.toString().startsWith(q))
          .toList();
    }

    // Check if query contains Arabic characters
    final isArabic =
        RegExp(r'[\u0600-\u06FF\u0750-\u077F\uFB50-\uFDFF\uFE70-\uFEFF]').hasMatch(q);

    final qLower = q.toLowerCase();

    bool matches(Surah s) {
      if (isArabic) return s.nameArabic.contains(q);
      return s.nameEnglish.toLowerCase().contains(qLower) ||
          s.nameTranslation.toLowerCase().contains(qLower);
    }

    bool startMatch(Surah s) {
      if (isArabic) return s.nameArabic.startsWith(q);
      return s.nameEnglish.toLowerCase().startsWith(qLower) ||
          s.nameTranslation.toLowerCase().startsWith(qLower);
    }

    final results = allSurahs.where(matches).toList();
    // Sort: startsWith matches first
    results.sort((a, b) {
      final aStart = startMatch(a) ? 0 : 1;
      final bStart = startMatch(b) ? 0 : 1;
      return aStart.compareTo(bStart);
    });
    return results;
  }
}
