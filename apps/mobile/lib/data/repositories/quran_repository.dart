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

  // Hifz (memorization tracking)
  Future<Set<int>> getMemorizedPages() => _datasource.getMemorizedPages();
  Future<bool> togglePageMemorized(int page) =>
      _datasource.togglePageMemorized(page);
  Future<void> bulkSetMemorized(List<int> pages, bool memorized) =>
      _datasource.bulkSetMemorized(pages, memorized);
  Future<List<Map<String, int>>> getJuzPageRanges() =>
      _datasource.getJuzPageRanges();
  Future<List<Map<String, dynamic>>> getJuzSurahPageRanges() =>
      _datasource.getJuzSurahPageRanges();

  // Wird (daily reading tracking)
  Future<bool> isWirdCompletedToday() => _datasource.isWirdCompletedToday();
  Future<bool> toggleWirdCompletion() => _datasource.toggleWirdCompletion();

  // Search
  Future<List<SearchResultItem>> searchArabic(String query) =>
      _datasource.searchArabic(query);

  /// Searches surah names across all fields (Arabic, English, translation).
  /// Always matches against all name fields regardless of input language.
  List<Surah> searchSurahNames(List<Surah> allSurahs, String query) {
    final q = query.trim();
    if (q.isEmpty) return [];

    // Numeric query — match surah number prefix
    if (int.tryParse(q) != null) {
      return allSurahs
          .where((s) => s.number.toString().startsWith(q))
          .toList();
    }

    final qLower = q.toLowerCase();

    bool matches(Surah s) {
      return s.nameArabic.contains(q) ||
          s.nameEnglish.toLowerCase().contains(qLower) ||
          s.nameTranslation.toLowerCase().contains(qLower);
    }

    bool startMatch(Surah s) {
      return s.nameArabic.startsWith(q) ||
          s.nameEnglish.toLowerCase().startsWith(qLower) ||
          s.nameTranslation.toLowerCase().startsWith(qLower);
    }

    final results = allSurahs.where(matches).toList();
    results.sort((a, b) {
      final aStart = startMatch(a) ? 0 : 1;
      final bStart = startMatch(b) ? 0 : 1;
      return aStart.compareTo(bStart);
    });
    return results;
  }
}
