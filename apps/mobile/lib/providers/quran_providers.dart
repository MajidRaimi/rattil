import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/datasources/quran_local_datasource.dart';
import '../data/repositories/quran_repository.dart';
import '../data/models/surah.dart';
import '../data/models/ayah.dart';

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
