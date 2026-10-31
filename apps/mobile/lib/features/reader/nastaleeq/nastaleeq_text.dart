import 'package:quran/quran.dart' as quran;

import '../../../core/constants/quran_constants.dart';
import 'nastaleeq_kashida_table.dart';
import 'nastaleeq_layout.dart';
import 'nastaleeq_page_map.dart';
import 'nastaleeq_printed_layout.dart';
import 'nastaleeq_text_format_exception.dart';

export 'nastaleeq_text_format_exception.dart';

const _kWordSeparator = ' ';

class NastaleeqText {
  final String basmala;
  final NastaleeqPrintedLayout? printedLayout;
  final NastaleeqPageMap pageMap;
  final NastaleeqKashidaTable kashida;
  final List<String> _titles;
  final List<List<String>> _surahs;
  final List<List<List<String>>> _words;

  NastaleeqText._({
    required this.basmala,
    required this.printedLayout,
    required this.kashida,
    required List<String> titles,
    required List<List<String>> surahs,
    required List<List<List<String>>> words,
  }) : pageMap = switch (printedLayout) {
         final layout? => NastaleeqPageMap.printed(layout),
         null => NastaleeqPageMap.madinah,
       },
       _titles = titles,
       _surahs = surahs,
       _words = words;

  factory NastaleeqText.fromJson(
    String asset,
    Object? json, {
    required NastaleeqLayoutSpec layout,
    NastaleeqKashidaTable kashida = NastaleeqKashidaTable.empty,
  }) {
    if (json is! Map<String, Object?>) {
      throw NastaleeqTextFormatException(asset, 'root is not an object');
    }
    final titles = _stringList(asset, json['titles'], 'titles');
    final surahs = _surahList(asset, json['surahs']);
    _validateCounts(asset, titles, surahs);
    final words = List<List<List<String>>>.unmodifiable([
      for (final surah in surahs)
        List<List<String>>.unmodifiable([
          for (final verse in surah)
            List<String>.unmodifiable(verse.split(_kWordSeparator)),
        ]),
    ]);
    return NastaleeqText._(
      basmala: _nonEmptyString(asset, json['basmala'], 'basmala'),
      printedLayout: _printedLayout(asset, json, layout, words),
      kashida: kashida,
      titles: titles,
      surahs: surahs,
      words: words,
    );
  }

  String verse(int chapter, int number) => _surahs[chapter - 1][number - 1];

  List<String> verseWords(int chapter, int number) =>
      _words[chapter - 1][number - 1];

  int verseCount(int chapter) => _surahs[chapter - 1].length;

  String title(int chapter) => _titles[chapter - 1];

  static NastaleeqPrintedLayout? _printedLayout(
    String asset,
    Map<String, Object?> json,
    NastaleeqLayoutSpec layout,
    List<List<List<String>>> words,
  ) {
    final hasPages = json.containsKey('pages');
    return switch (layout) {
      NastaleeqPrintedSpec() when !hasPages =>
        throw NastaleeqTextFormatException(
          asset,
          'printed layout requires pages',
        ),
      NastaleeqPrintedSpec() => NastaleeqPrintedLayout.fromJson(
        asset,
        json['pages'],
        spec: layout,
        wordCount: (chapter, number) => words[chapter - 1][number - 1].length,
      ),
      NastaleeqFlowingSpec() when hasPages =>
        throw NastaleeqTextFormatException(
          asset,
          'flowing layout must not carry pages',
        ),
      NastaleeqFlowingSpec() => null,
    };
  }

  static void _validateCounts(
    String asset,
    List<String> titles,
    List<List<String>> surahs,
  ) {
    if (titles.length != QuranConstants.surahCount ||
        surahs.length != QuranConstants.surahCount) {
      throw NastaleeqTextFormatException(
        asset,
        'expected $QuranConstants.surahCount titles and surahs, found '
        '${titles.length} and ${surahs.length}',
      );
    }
    var total = 0;
    for (var chapter = 1; chapter <= QuranConstants.surahCount; chapter++) {
      final found = surahs[chapter - 1].length;
      final expected = quran.getVerseCount(chapter);
      if (found != expected) {
        throw NastaleeqTextFormatException(
          asset,
          'surah $chapter has $found verses, expected $expected',
        );
      }
      total += found;
    }
    if (total != QuranConstants.ayahCount) {
      throw NastaleeqTextFormatException(
        asset,
        'found $total verses, expected $QuranConstants.ayahCount',
      );
    }
  }

  static String _nonEmptyString(String asset, Object? value, String field) {
    if (value is String && value.isNotEmpty) return value;
    throw NastaleeqTextFormatException(
      asset,
      '$field is not a non-empty string',
    );
  }

  static List<String> _stringList(String asset, Object? value, String field) {
    if (value is! List<Object?>) {
      throw NastaleeqTextFormatException(asset, '$field is not a list');
    }
    return List.unmodifiable([
      for (final (index, item) in value.indexed)
        _nonEmptyString(asset, item, '$field[$index]'),
    ]);
  }

  static List<List<String>> _surahList(String asset, Object? value) {
    if (value is! List<Object?>) {
      throw NastaleeqTextFormatException(asset, 'surahs is not a list');
    }
    return List.unmodifiable([
      for (final (index, surah) in value.indexed)
        _stringList(asset, surah, 'surahs[$index]'),
    ]);
  }
}
