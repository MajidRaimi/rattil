import 'surah.dart';
import 'search_result.dart';

class SearchState {
  final List<Surah> surahMatches;
  final List<SearchResultItem> ayahMatches;
  final bool isArabicMode;

  const SearchState({
    this.surahMatches = const [],
    this.ayahMatches = const [],
    this.isArabicMode = false,
  });

  bool get isEmpty => surahMatches.isEmpty && ayahMatches.isEmpty;
}
