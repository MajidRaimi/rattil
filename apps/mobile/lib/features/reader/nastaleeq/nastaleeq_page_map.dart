import 'package:quran/quran.dart' as quran;

import '../../../core/constants/quran_constants.dart';
import 'nastaleeq_printed_layout.dart';
import 'nastaleeq_verse_ref.dart';

export 'nastaleeq_verse_ref.dart';

final List<int> _chapterOffsets = _buildChapterOffsets();

List<int> _buildChapterOffsets() {
  final offsets = [0];
  for (var chapter = 1; chapter < QuranConstants.surahCount; chapter++) {
    offsets.add(offsets.last + quran.getVerseCount(chapter));
  }
  return List.unmodifiable(offsets);
}

int nastaleeqVerseOrdinal(int verseKey) =>
    _chapterOffsets[nastaleeqVerseChapter(verseKey) - 1] +
    nastaleeqVerseNumber(verseKey) -
    1;

int nastaleeqMadinahPageStart(int madinahPage) {
  final first = quran.getPageData(madinahPage).first;
  if (first case {'surah': final int chapter, 'start': final int number}) {
    return nastaleeqVerseKey(chapter, number);
  }
  throw StateError('Madinah page $madinahPage has no opening verse');
}

int _lastAtOrBefore(List<int> sorted, int value) {
  var low = 0;
  var high = sorted.length;
  while (low < high) {
    final mid = (low + high) ~/ 2;
    if (sorted[mid] <= value) {
      low = mid + 1;
    } else {
      high = mid;
    }
  }
  return low - 1;
}

int _firstAtOrAfter(List<int> sorted, int value) {
  var low = 0;
  var high = sorted.length;
  while (low < high) {
    final mid = (low + high) ~/ 2;
    if (sorted[mid] < value) {
      low = mid + 1;
    } else {
      high = mid;
    }
  }
  return low;
}

final class NastaleeqPageMap {
  final List<int> _firstOrdinals;
  final List<int> _lastOrdinals;
  final List<int> _anchorVerseKeys;

  const NastaleeqPageMap._(
    this._firstOrdinals,
    this._lastOrdinals,
    this._anchorVerseKeys,
  );

  static final NastaleeqPageMap madinah = _buildMadinah();

  static NastaleeqPageMap _buildMadinah() {
    final anchors = List<int>.generate(
      quran.totalPagesCount,
      (index) => nastaleeqMadinahPageStart(index + 1),
      growable: false,
    );
    final firsts = anchors.map(nastaleeqVerseOrdinal).toList(growable: false);
    final lasts = List<int>.generate(
      firsts.length,
      (index) => index + 1 < firsts.length
          ? firsts[index + 1] - 1
          : quran.totalVerseCount - 1,
      growable: false,
    );
    return NastaleeqPageMap._(firsts, lasts, anchors);
  }

  factory NastaleeqPageMap.printed(NastaleeqPrintedLayout layout) {
    final firsts = <int>[];
    final lasts = <int>[];
    final anchors = <int>[];
    for (var page = 1; page <= layout.pageCount; page++) {
      final ranges = layout.rangesOf(page).toList(growable: false);
      final anchor = ranges.firstWhere(
        (range) => range.start == 0,
        orElse: () => ranges.first,
      );
      firsts.add(nastaleeqVerseOrdinal(ranges.first.verseKey));
      lasts.add(nastaleeqVerseOrdinal(ranges.last.verseKey));
      anchors.add(anchor.verseKey);
    }
    return NastaleeqPageMap._(
      List.unmodifiable(firsts),
      List.unmodifiable(lasts),
      List.unmodifiable(anchors),
    );
  }

  int get pageCount => _anchorVerseKeys.length;

  int clampPage(int page) => page.clamp(1, pageCount);

  int anchorVerseOf(int page) => _anchorVerseKeys[clampPage(page) - 1];

  int keepAnchor(int page, int verseKey) =>
      showsVerse(page, verseKey) ? verseKey : anchorVerseOf(page);

  int pageOfVerse(int verseKey) =>
      _firstAtOrAfter(_lastOrdinals, nastaleeqVerseOrdinal(verseKey)) + 1;

  bool showsVerse(int page, int verseKey) {
    final index = clampPage(page) - 1;
    final ordinal = nastaleeqVerseOrdinal(verseKey);
    return _firstOrdinals[index] <= ordinal && ordinal <= _lastOrdinals[index];
  }

  int madinahPageOf(int page) =>
      madinah._pageOfOrdinal(nastaleeqVerseOrdinal(anchorVerseOf(page)));

  int pageForMadinahPage(int madinahPage, {required int currentPage}) {
    final source = madinah;
    final target = source.clampPage(madinahPage) - 1;
    final first = source._firstOrdinals[target];
    final last = source._lastOrdinals[target];
    final current = clampPage(currentPage) - 1;
    if (_firstOrdinals[current] <= last && first <= _lastOrdinals[current]) {
      return current + 1;
    }
    return _firstAtOrAfter(_lastOrdinals, first) + 1;
  }

  int _pageOfOrdinal(int ordinal) =>
      _lastAtOrBefore(_firstOrdinals, ordinal) + 1;
}
