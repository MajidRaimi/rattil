import '../datasources/quran_local_datasource.dart';
import '../models/surah.dart';
import '../models/ayah.dart';

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
}
