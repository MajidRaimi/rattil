import 'package:flutter/painting.dart';

import 'nastaleeq_edition.dart';
import 'nastaleeq_kashida.dart';
import 'nastaleeq_layout.dart';
import 'nastaleeq_page_blocks.dart';
import 'nastaleeq_printed_grid.dart';
import 'nastaleeq_printed_layout.dart';
import 'nastaleeq_text.dart';
import 'nastaleeq_typography.dart';

const kNastaleeqSurahEndCentreRatio = 0.7;
const _kShrinkPasses = 2;
const _kKashidaAttempts = 3;
const _kKashidaOverflowMarginEm = 0.01;
const _kPageCacheCapacity = 48;
const _kProbeColor = Color(0xFF000000);
const _kWordSpace = '\u0020';
const _kStretchableSpace = '\u200F$_kWordSpace';

enum NastaleeqLineAlignment { justified, centred, centredWhenShort }

final class NastaleeqLineFit {
  final double fontSize;
  final double wordSpacing;
  final bool justified;

  const NastaleeqLineFit({
    required this.fontSize,
    required this.wordSpacing,
    required this.justified,
  });

  TextStyle applyTo(TextStyle style) =>
      style.copyWith(fontSize: fontSize, wordSpacing: wordSpacing);
}

sealed class NastaleeqLinePlan {
  const NastaleeqLinePlan();
}

final class NastaleeqTitlePlan extends NastaleeqLinePlan {
  final int chapter;

  const NastaleeqTitlePlan(this.chapter);
}

final class NastaleeqBasmalaPlan extends NastaleeqLinePlan {
  const NastaleeqBasmalaPlan();
}

final class NastaleeqVersesPlan extends NastaleeqLinePlan {
  final List<NastaleeqVerseSpan> verses;
  final NastaleeqLineFit fit;

  const NastaleeqVersesPlan({required this.verses, required this.fit});
}

typedef _MeasuredLine = ({
  double fontSize,
  double natural,
  int spaces,
  bool centred,
});

typedef _LineWord = ({String text, List<NastaleeqKashidaSlot> slots});

List<NastaleeqVerseSpan> _lineVersesOf(
  NastaleeqWordsLine line,
  List<List<String>> words,
) {
  final lastIndex = line.ranges.length - 1;
  return List.unmodifiable([
    for (final (index, range) in line.ranges.indexed)
      NastaleeqVerseSpan(
        chapter: range.chapter,
        number: range.number,
        text: [
          ...words[index],
          if (index < lastIndex) '',
        ].join(_kStretchableSpace),
      ),
  ]);
}

List<String> _rangeWords(NastaleeqWordRange range, NastaleeqText text) => text
    .verseWords(range.chapter, range.number)
    .sublist(range.start, range.end);

List<NastaleeqVerseSpan> nastaleeqLineVerses(
  NastaleeqWordsLine line,
  NastaleeqText text,
) => _lineVersesOf(line, [
  for (final range in line.ranges) _rangeWords(range, text),
]);

String nastaleeqLineString(List<NastaleeqVerseSpan> verses) =>
    verses.map((verse) => verse.text).join();

bool nastaleeqLineEndsSurah(NastaleeqWordsLine line, NastaleeqText text) {
  final last = line.ranges.last;
  return last.number == text.verseCount(last.chapter) &&
      last.end == text.verseWords(last.chapter, last.number).length;
}

double measureNastaleeqLine(String line, TextStyle style) {
  final painter = TextPainter(
    text: TextSpan(text: line, style: style),
    textDirection: TextDirection.rtl,
    textScaler: TextScaler.noScaling,
    maxLines: 1,
  )..layout();
  final width = painter.maxIntrinsicWidth;
  painter.dispose();
  return width;
}

_MeasuredLine _measureLine(
  String line, {
  required NastaleeqTypography typography,
  required double columnWidth,
  required NastaleeqLineAlignment alignment,
}) {
  final body = typography.body(_kProbeColor);
  var fontSize = typography.fontSize;
  var natural = measureNastaleeqLine(line, body);
  for (var pass = 0; pass < _kShrinkPasses && natural > columnWidth; pass++) {
    fontSize *= columnWidth / natural;
    natural = measureNastaleeqLine(line, body.copyWith(fontSize: fontSize));
  }
  return (
    fontSize: fontSize,
    natural: natural,
    spaces: _kWordSpace.allMatches(line).length,
    centred: switch (alignment) {
      NastaleeqLineAlignment.justified => false,
      NastaleeqLineAlignment.centred => true,
      NastaleeqLineAlignment.centredWhenShort =>
        natural < columnWidth * kNastaleeqSurahEndCentreRatio,
    },
  );
}

NastaleeqLineFit _justify(
  _MeasuredLine measured, {
  required double width,
  required double columnWidth,
}) {
  if (measured.centred || measured.spaces == 0) {
    return NastaleeqLineFit(
      fontSize: measured.fontSize,
      wordSpacing: 0,
      justified: false,
    );
  }
  return NastaleeqLineFit(
    fontSize: measured.fontSize,
    wordSpacing: (columnWidth - width) / measured.spaces,
    justified: true,
  );
}

NastaleeqLineFit fitNastaleeqLine(
  String line, {
  required NastaleeqTypography typography,
  required double columnWidth,
  required NastaleeqLineAlignment alignment,
}) {
  final measured = _measureLine(
    line,
    typography: typography,
    columnWidth: columnWidth,
    alignment: alignment,
  );
  return _justify(measured, width: measured.natural, columnWidth: columnWidth);
}

List<List<_LineWord>> _lineWords(NastaleeqWordsLine line, NastaleeqText text) =>
    [
      for (final range in line.ranges)
        [
          for (final (offset, word) in _rangeWords(range, text).indexed)
            (
              text: word,
              slots:
                  isNastaleeqMuqattaat(
                    range.chapter,
                    range.number,
                    range.start + offset,
                  )
                  ? const <NastaleeqKashidaSlot>[]
                  : text.kashida.slotsOf(word),
            ),
        ],
    ];

List<List<String>> _stretchedWords(
  List<List<_LineWord>> words,
  List<List<int>> counts,
) {
  var cursor = 0;
  return [
    for (final range in words)
      [
        for (final word in range)
          stretchNastaleeqWord(word.text, word.slots, counts[cursor++]),
      ],
  ];
}

NastaleeqVersesPlan? _kashidaPlan(
  NastaleeqWordsLine line,
  List<List<_LineWord>> words,
  _MeasuredLine measured, {
  required NastaleeqTypography typography,
  required double tatweelEm,
  required double columnWidth,
}) {
  final style = typography
      .body(_kProbeColor)
      .copyWith(fontSize: measured.fontSize);
  final candidates = [
    for (final word in words.expand((range) => range))
      NastaleeqKashidaWord(length: word.text.length, slots: word.slots),
  ];
  var budgetEm =
      (columnWidth - measured.natural) / measured.fontSize -
      kNastaleeqKashidaMinGapEm * measured.spaces;
  for (
    var attempt = 0;
    attempt < _kKashidaAttempts && budgetEm > 0;
    attempt++
  ) {
    final distribution = distributeNastaleeqKashida(
      candidates,
      budgetEm: budgetEm,
      spaces: measured.spaces,
      tatweelEm: tatweelEm,
    );
    if (distribution.gainEm <= 0) return null;
    final verses = _lineVersesOf(
      line,
      _stretchedWords(words, distribution.counts),
    );
    final width = measureNastaleeqLine(nastaleeqLineString(verses), style);
    if (width <= columnWidth) {
      return NastaleeqVersesPlan(
        verses: verses,
        fit: _justify(measured, width: width, columnWidth: columnWidth),
      );
    }
    budgetEm =
        distribution.gainEm -
        (width - columnWidth) / measured.fontSize -
        _kKashidaOverflowMarginEm;
  }
  return null;
}

NastaleeqVersesPlan planNastaleeqWordsLine(
  NastaleeqWordsLine line, {
  required NastaleeqText text,
  required NastaleeqTypography typography,
  required double columnWidth,
  required NastaleeqLineAlignment alignment,
}) {
  final words = _lineWords(line, text);
  final verses = _lineVersesOf(line, [
    for (final range in words) [for (final word in range) word.text],
  ]);
  final measured = _measureLine(
    nastaleeqLineString(verses),
    typography: typography,
    columnWidth: columnWidth,
    alignment: alignment,
  );
  final fit = _justify(
    measured,
    width: measured.natural,
    columnWidth: columnWidth,
  );
  final stretched = fit.justified && measured.natural < columnWidth
      ? _kashidaPlan(
          line,
          words,
          measured,
          typography: typography,
          tatweelEm: text.kashida.tatweelEm,
          columnWidth: columnWidth,
        )
      : null;
  return stretched ?? NastaleeqVersesPlan(verses: verses, fit: fit);
}

NastaleeqLineAlignment nastaleeqLineAlignment(
  int pageNumber,
  NastaleeqWordsLine line,
  NastaleeqText text,
) {
  if (isNastaleeqOpeningPage(pageNumber)) return NastaleeqLineAlignment.centred;
  if (nastaleeqLineEndsSurah(line, text)) {
    return NastaleeqLineAlignment.centredWhenShort;
  }
  return NastaleeqLineAlignment.justified;
}

NastaleeqLinePlan _planLine(
  int pageNumber,
  NastaleeqLine line,
  NastaleeqText text,
  NastaleeqTypography typography,
  double columnWidth,
) {
  switch (line) {
    case NastaleeqTitleLine(:final chapter):
      return NastaleeqTitlePlan(chapter);
    case NastaleeqBasmalaLine():
      return const NastaleeqBasmalaPlan();
    case NastaleeqWordsLine():
      return planNastaleeqWordsLine(
        line,
        text: text,
        typography: typography,
        columnWidth: columnWidth,
        alignment: nastaleeqLineAlignment(pageNumber, line, text),
      );
  }
}

final Map<String, List<NastaleeqLinePlan>> _pagePlanCache = {};

List<NastaleeqLinePlan> planNastaleeqPrintedPage({
  required NastaleeqEdition edition,
  required int pageNumber,
  required NastaleeqPrintedLayout layout,
  required NastaleeqText text,
  required NastaleeqTypography typography,
  required NastaleeqPrintedGrid grid,
}) {
  final key = '${edition.name}:$pageNumber:${grid.cacheKey}';
  final plans =
      _pagePlanCache.remove(key) ??
      List<NastaleeqLinePlan>.unmodifiable([
        for (final line in layout.linesOf(pageNumber))
          _planLine(pageNumber, line, text, typography, grid.columnWidth),
      ]);
  _pagePlanCache[key] = plans;
  if (_pagePlanCache.length > _kPageCacheCapacity) {
    _pagePlanCache.remove(_pagePlanCache.keys.first);
  }
  return plans;
}
