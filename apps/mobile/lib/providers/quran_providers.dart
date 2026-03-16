import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/datasources/quran_local_datasource.dart';
import '../data/repositories/quran_repository.dart';
import '../data/models/surah.dart';
import '../data/models/ayah.dart';
import '../data/models/search_state.dart';

part 'quran_providers.g.dart';

@Riverpod(keepAlive: true)
QuranLocalDatasource quranLocalDatasource(ref) {
  return QuranLocalDatasource();
}

@Riverpod(keepAlive: true)
QuranRepository quranRepository(ref) {
  return QuranRepository(ref.watch(quranLocalDatasourceProvider));
}

@riverpod
Future<List<Surah>> allSurahs(ref) {
  return ref.watch(quranRepositoryProvider).getAllSurahs();
}

@riverpod
Future<List<Ayah>> surahAyahs(ref, int surahNumber) {
  return ref.watch(quranRepositoryProvider).getAyahsBySurah(surahNumber);
}

@riverpod
Future<Surah?> surah(ref, int number) {
  return ref.watch(quranRepositoryProvider).getSurah(number);
}

@riverpod
Future<Map<String, int>> readingProgress(ref) {
  return ref.watch(quranRepositoryProvider).getReadingProgress();
}

@riverpod
Future<Set<String>> bookmarkKeys(ref) {
  return ref.watch(quranRepositoryProvider).getBookmarkKeys();
}

@riverpod
Future<List<Map<String, dynamic>>> allBookmarks(ref) {
  return ref.watch(quranRepositoryProvider).getAllBookmarks();
}

bool _containsArabic(String text) =>
    RegExp(r'[\u0600-\u06FF\u0750-\u077F\uFB50-\uFDFF\uFE70-\uFEFF]')
        .hasMatch(text);

@riverpod
Future<SearchState> searchResults(ref, String query) async {
  if (query.trim().isEmpty) return const SearchState();

  final repo = ref.watch(quranRepositoryProvider);
  final allSurahs = await ref.watch(allSurahsProvider.future);
  final isArabic = _containsArabic(query);

  final surahMatches = repo.searchSurahNames(allSurahs, query);
  final ayahMatches = isArabic
      ? await repo.searchArabic(query)
      : await repo.searchTranslations(query);

  return SearchState(
    surahMatches: surahMatches,
    ayahMatches: ayahMatches,
    isArabicMode: isArabic,
  );
}
