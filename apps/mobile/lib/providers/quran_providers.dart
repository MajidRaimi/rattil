import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/datasources/quran_local_datasource.dart';
import '../data/repositories/quran_repository.dart';
import '../data/models/surah.dart';
import '../data/models/ayah.dart';
import '../data/models/search_result.dart';
import '../data/models/search_state.dart';

part 'quran_providers.g.dart';

/// Request to navigate the main reader to a specific ayah.
class ReaderNavigationRequest {
  final int surahNumber;
  final int ayahNumber;
  final bool highlight;

  const ReaderNavigationRequest({
    required this.surahNumber,
    required this.ayahNumber,
    this.highlight = false,
  });
}

/// Set this to navigate the main mushaf reader to a specific ayah.
/// The main screen listens and clears it after handling.
final readerNavigationProvider =
    StateProvider<ReaderNavigationRequest?>((_) => null);

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

@riverpod
Future<List<Map<String, dynamic>>> allCollections(ref) {
  return ref.watch(quranRepositoryProvider).getAllCollections();
}

@riverpod
Future<List<Map<String, dynamic>>> collectionBookmarks(
    ref, int collectionId) {
  return ref.watch(quranRepositoryProvider).getBookmarksByCollection(collectionId);
}

@riverpod
Future<Set<int>> bookmarkCollectionIds(
    ref, int surahNumber, int ayahNumber) {
  return ref.watch(quranRepositoryProvider).getCollectionIdsForBookmark(
      surahNumber, ayahNumber);
}

@riverpod
Future<Map<String, List<String>>> bookmarkCollectionIcons(ref) {
  return ref.watch(quranRepositoryProvider).getAllBookmarkCollectionIcons();
}

@riverpod
Future<Set<int>> memorizedPages(ref) {
  return ref.watch(quranRepositoryProvider).getMemorizedPages();
}

@riverpod
Future<List<Map<String, int>>> juzPageRanges(ref) {
  return ref.watch(quranRepositoryProvider).getJuzPageRanges();
}

@riverpod
Future<List<Map<String, dynamic>>> juzSurahPageRanges(ref) {
  return ref.watch(quranRepositoryProvider).getJuzSurahPageRanges();
}

@riverpod
Future<List<Map<String, int>>> hizbPageRanges(ref) {
  return ref.watch(quranRepositoryProvider).getHizbPageRanges();
}

@riverpod
Future<bool> wirdCompletedToday(ref) {
  return ref.watch(quranRepositoryProvider).isWirdCompletedToday();
}

@riverpod
Future<bool> khatmahCompletedToday(ref) {
  return ref.watch(quranRepositoryProvider).isKhatmahCompletedToday();
}

bool _containsArabic(String text) =>
    RegExp(r'[\u0600-\u06FF\u0750-\u077F\uFB50-\uFDFF\uFE70-\uFEFF]')
        .hasMatch(text);

@riverpod
Future<SearchState> searchResults(ref, String query) async {
  if (query.trim().isEmpty) return const SearchState();

  final repo = ref.watch(quranRepositoryProvider);
  final allSurahs = await ref.watch(allSurahsProvider.future);

  // Always search surah names (matches Arabic, English, and translation names)
  final surahMatches = repo.searchSurahNames(allSurahs, query);

  // Only run Arabic ayah FTS when input contains Arabic characters
  final ayahMatches = _containsArabic(query)
      ? await repo.searchArabic(query)
      : <SearchResultItem>[];

  return SearchState(
    surahMatches: surahMatches,
    ayahMatches: ayahMatches,
  );
}
