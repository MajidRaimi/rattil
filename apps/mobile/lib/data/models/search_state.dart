import 'surah.dart';
import 'search_result.dart';

class SearchState {
  final List<Surah> surahMatches;
  final List<SearchResultItem> ayahMatches;

  const SearchState({
    this.surahMatches = const [],
    this.ayahMatches = const [],
  });

  bool get isEmpty => surahMatches.isEmpty && ayahMatches.isEmpty;
}
