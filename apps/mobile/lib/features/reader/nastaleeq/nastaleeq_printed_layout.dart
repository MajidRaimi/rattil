import 'package:quran/quran.dart' as quran;

import '../../../core/constants/quran_constants.dart';
import 'nastaleeq_layout.dart';
import 'nastaleeq_text_format_exception.dart';
import 'nastaleeq_verse_ref.dart';

typedef NastaleeqWordCount = int Function(int chapter, int number);

final class NastaleeqWordRange {
  final int chapter;
  final int number;
  final int start;
  final int end;

  const NastaleeqWordRange({
    required this.chapter,
    required this.number,
    required this.start,
    required this.end,
  });

  int get verseKey => nastaleeqVerseKey(chapter, number);
}

sealed class NastaleeqLine {
  const NastaleeqLine();
}

final class NastaleeqTitleLine extends NastaleeqLine {
  final int chapter;

  const NastaleeqTitleLine(this.chapter);
}

final class NastaleeqBasmalaLine extends NastaleeqLine {
  final int chapter;

  const NastaleeqBasmalaLine(this.chapter);
}

final class NastaleeqWordsLine extends NastaleeqLine {
  final List<NastaleeqWordRange> ranges;

  const NastaleeqWordsLine(this.ranges);
}

final class NastaleeqPrintedLayout {
  final List<List<NastaleeqLine>> pages;

  const NastaleeqPrintedLayout(this.pages);

  factory NastaleeqPrintedLayout.fromJson(
    String asset,
    Object? json, {
    required NastaleeqPrintedSpec spec,
    required NastaleeqWordCount wordCount,
  }) => _PrintedLayoutParser(asset, spec, wordCount).parse(json);

  int get pageCount => pages.length;

  List<NastaleeqLine> linesOf(int page) => pages[page - 1];

  Iterable<NastaleeqWordRange> rangesOf(int page) => linesOf(
    page,
  ).whereType<NastaleeqWordsLine>().expand((line) => line.ranges);
}

final class _PrintedLayoutParser {
  final String asset;
  final NastaleeqPrintedSpec spec;
  final NastaleeqWordCount wordCount;
  int _chapter = 1;
  int _number = 1;
  int _word = 0;
  int _openingLines = 0;

  _PrintedLayoutParser(this.asset, this.spec, this.wordCount);

  bool get _finished => _chapter > QuranConstants.surahCount;

  bool get _atSurahStart => !_finished && _number == 1 && _word == 0;

  int get _expectedOpeningLines => nastaleeqOpensWithBasmala(_chapter) ? 2 : 1;

  NastaleeqTextFormatException _invalid(String reason) =>
      NastaleeqTextFormatException(asset, reason);

  NastaleeqPrintedLayout parse(Object? json) {
    if (json is! List<Object?>) throw _invalid('pages is not a list');
    if (json.length != spec.pageCount) {
      throw _invalid('expected ${spec.pageCount} pages, found ${json.length}');
    }
    final pages = [
      for (final (index, page) in json.indexed)
        _page(page, index + 1, 'pages[$index]'),
    ];
    if (!_finished) {
      throw _invalid('pages end before verse $_chapter:$_number');
    }
    return NastaleeqPrintedLayout(List.unmodifiable(pages));
  }

  List<NastaleeqLine> _page(Object? value, int pageNumber, String path) {
    if (value is! List<Object?>) throw _invalid('$path is not a list');
    final expected = spec.linesOn(pageNumber);
    if (value.length != expected) {
      throw _invalid('$path has ${value.length} lines, expected $expected');
    }
    final lines = [
      for (final (index, line) in value.indexed) _line(line, '$path[$index]'),
    ];
    if (!lines.any((line) => line is NastaleeqWordsLine)) {
      throw _invalid('$path has no text line');
    }
    return List.unmodifiable(lines);
  }

  NastaleeqLine _line(Object? value, String path) => switch (value) {
    {'title': final int chapter} && Map(length: 1) => NastaleeqTitleLine(
      _opening(chapter, 0, path),
    ),
    {'basmala': final int chapter} && Map(length: 1)
        when nastaleeqOpensWithBasmala(chapter) =>
      NastaleeqBasmalaLine(_opening(chapter, 1, path)),
    {'words': final List<Object?> ranges} && Map(length: 1)
        when ranges.isNotEmpty =>
      NastaleeqWordsLine(
        List.unmodifiable([
          for (final (index, range) in ranges.indexed)
            _range(range, '$path.words[$index]'),
        ]),
      ),
    _ => throw _invalid('$path is not a title, basmala or words line'),
  };

  int _opening(int chapter, int position, String path) {
    if (_atSurahStart && chapter == _chapter && _openingLines == position) {
      _openingLines++;
      return chapter;
    }
    throw _invalid('$path opens surah $chapter out of order');
  }

  NastaleeqWordRange _range(Object? value, String path) {
    if (_atSurahStart && _openingLines != _expectedOpeningLines) {
      throw _invalid('$path starts surah $_chapter without its opening lines');
    }
    if (value
        case [
          final int chapter,
          final int number,
          final int start,
          final int end,
        ]
        when !_finished &&
            chapter == _chapter &&
            number == _number &&
            start == _word &&
            end > start &&
            end <= wordCount(chapter, number)) {
      _advance(end);
      return NastaleeqWordRange(
        chapter: chapter,
        number: number,
        start: start,
        end: end,
      );
    }
    throw _invalid(
      '$path does not continue verse $_chapter:$_number at word $_word',
    );
  }

  void _advance(int end) {
    if (end < wordCount(_chapter, _number)) {
      _word = end;
      return;
    }
    _word = 0;
    if (_number < quran.getVerseCount(_chapter)) {
      _number++;
      return;
    }
    _chapter++;
    _number = 1;
    _openingLines = 0;
  }
}
