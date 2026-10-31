import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quran_mobile/features/reader/nastaleeq/nastaleeq_edition.dart';
import 'package:quran_mobile/features/reader/nastaleeq/nastaleeq_layout.dart';
import 'package:quran_mobile/features/reader/nastaleeq/nastaleeq_printed_fit.dart';
import 'package:quran_mobile/features/reader/nastaleeq/nastaleeq_printed_grid.dart';
import 'package:quran_mobile/features/reader/nastaleeq/nastaleeq_printed_layout.dart';
import 'package:quran_mobile/features/reader/nastaleeq/nastaleeq_text.dart';
import 'package:quran_mobile/features/reader/nastaleeq/nastaleeq_typography.dart';

import 'support/nastaleeq_test_support.dart';

const double probeFontSize = 100;
const double minimumShrink = 0.95;
const double maximumWiderShare = 0.002;
const double edgeTolerance = 0.5;
const Size iphone17ProTextArea = Size(358, 746);
const Color probeColor = Color(0xFF000000);
const double maximumMeanExtraGapEm = 0.25;
const String tatweel = '\u0640';

bool onlyInsertsTatweels(String plain, String stretched) {
  var cursor = 0;
  for (final unit in stretched.codeUnits) {
    if (cursor < plain.length && plain.codeUnitAt(cursor) == unit) {
      cursor++;
    } else if (unit != tatweel.codeUnitAt(0)) {
      return false;
    }
  }
  return cursor == plain.length;
}

typedef PrintedTextLine = ({
  int page,
  NastaleeqWordsLine line,
  String text,
  double widthEm,
});

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const edition = NastaleeqEdition.digitalKhatt;
  final spec = edition.layout as NastaleeqPrintedSpec;
  late NastaleeqText text;
  late List<PrintedTextLine> lines;

  NastaleeqTypography typographyAt(double fontSize) => NastaleeqTypography(
    edition: edition,
    base: const TextStyle(),
    fontSize: fontSize,
  );

  setUpAll(() async {
    await loadNastaleeqFonts();
    text = loadNastaleeqText(edition);
    final layout = text.printedLayout!;
    final body = typographyAt(probeFontSize).body(probeColor);
    lines = [
      for (var page = 1; page <= layout.pageCount; page++)
        for (final line in layout.linesOf(page).whereType<NastaleeqWordsLine>())
          _measure(page, line, text, body),
    ];
  });

  test('covers every printed text line', () {
    expect(lines, hasLength(8905));
  });

  test('keeps lines wider than the column under the chosen share', () {
    final wider = lines.where((line) => line.widthEm > spec.lineWidthEm);
    expect(wider.length / lines.length, lessThan(maximumWiderShare));
  });

  test(
    'never shrinks a printed line below $minimumShrink of the body size',
    () {
      final shrinks = lines.map(
        (line) => line.widthEm > spec.lineWidthEm
            ? spec.lineWidthEm / line.widthEm
            : 1.0,
      );
      expect(
        shrinks.reduce((a, b) => a < b ? a : b),
        greaterThanOrEqualTo(minimumShrink),
      );
    },
  );

  test('fits every line inside the column and justifies to both edges', () {
    final grid = NastaleeqPrintedGrid.resolve(spec, iphone17ProTextArea);
    final typography = typographyAt(grid.fontSize);
    final body = typography.body(probeColor);
    for (final line in lines) {
      final fit = fitNastaleeqLine(
        line.text,
        typography: typography,
        columnWidth: grid.columnWidth,
        alignment: NastaleeqLineAlignment.justified,
      );
      final width = measureNastaleeqLine(line.text, fit.applyTo(body));
      expect(fit.fontSize, lessThanOrEqualTo(grid.fontSize));
      expect(
        width,
        closeTo(grid.columnWidth, edgeTolerance),
        reason: 'page ${line.page}: ${line.text}',
      );
    }
  });

  test('keeps every justified line on one line at the column width', () {
    final grid = NastaleeqPrintedGrid.resolve(spec, iphone17ProTextArea);
    final typography = typographyAt(grid.fontSize);
    final body = typography.body(probeColor);
    final wrapped = <int>[];
    for (final line in lines) {
      final verses = nastaleeqLineVerses(line.line, text);
      final fit = fitNastaleeqLine(
        line.text,
        typography: typography,
        columnWidth: grid.columnWidth,
        alignment: NastaleeqLineAlignment.justified,
      );
      final painter = TextPainter(
        text: buildNastaleeqParagraphSpan(verses, fit.applyTo(body)),
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.center,
        textScaler: TextScaler.noScaling,
        strutStyle: typography.paragraphStrut,
        textHeightBehavior: kNastaleeqParagraphHeightBehavior,
      )..layout(maxWidth: grid.columnWidth);
      if (painter.computeLineMetrics().length != 1) wrapped.add(line.page);
      painter.dispose();
    }
    expect(wrapped, isEmpty);
  });

  test('centres only short surah endings', () {
    final grid = NastaleeqPrintedGrid.resolve(spec, iphone17ProTextArea);
    final typography = typographyAt(grid.fontSize);
    final endings = lines.where(
      (line) =>
          line.page > kNastaleeqOpeningPageCount &&
          nastaleeqLineEndsSurah(line.line, text),
    );
    final centred = endings.where(
      (line) => !fitNastaleeqLine(
        line.text,
        typography: typography,
        columnWidth: grid.columnWidth,
        alignment: NastaleeqLineAlignment.centredWhenShort,
      ).justified,
    );
    expect(endings, hasLength(113));
    expect(centred.length, inInclusiveRange(30, 60));
    for (final line in centred) {
      expect(
        line.widthEm,
        lessThan(spec.lineWidthEm * kNastaleeqSurahEndCentreRatio),
      );
    }
  });

  group('kashida plans', () {
    late NastaleeqTypography typography;
    late double columnWidth;
    late List<(PrintedTextLine, NastaleeqVersesPlan)> plans;

    setUpAll(() {
      final grid = NastaleeqPrintedGrid.resolve(spec, iphone17ProTextArea);
      typography = typographyAt(grid.fontSize);
      columnWidth = grid.columnWidth;
      plans = [
        for (final line in lines)
          (
            line,
            planNastaleeqWordsLine(
              line.line,
              text: text,
              typography: typography,
              columnWidth: columnWidth,
              alignment: nastaleeqLineAlignment(line.page, line.line, text),
            ),
          ),
      ];
    });

    test('reach both edges of the column without overflowing', () {
      final body = typography.body(probeColor);
      for (final (line, plan) in plans.where(
        (entry) => entry.$2.fit.justified,
      )) {
        final width = measureNastaleeqLine(
          nastaleeqLineString(plan.verses),
          plan.fit.applyTo(body),
        );
        expect(plan.fit.wordSpacing, greaterThanOrEqualTo(0));
        expect(
          width,
          closeTo(columnWidth, edgeTolerance),
          reason: 'page ${line.page}: ${line.text}',
        );
      }
    });

    test('only insert tatweels into the verse text', () {
      for (final (line, plan) in plans) {
        final plain = nastaleeqLineVerses(line.line, text);
        expect(plan.verses, hasLength(plain.length));
        for (final (index, verse) in plan.verses.indexed) {
          expect(verse.key, plain[index].key);
          expect(
            onlyInsertsTatweels(plain[index].text, verse.text),
            isTrue,
            reason: 'page ${line.page}: ${verse.text}',
          );
        }
      }
    });

    test('never stretch a centred line', () {
      final centred = plans.where((entry) => !entry.$2.fit.justified);
      expect(centred, isNotEmpty);
      for (final (line, plan) in centred) {
        expect(nastaleeqLineString(plan.verses), line.text);
      }
    });

    test('keep word gaps close to natural', () {
      final justified = [
        for (final (_, plan) in plans)
          if (plan.fit.justified) plan.fit.wordSpacing / plan.fit.fontSize,
      ];
      final mean = justified.reduce((a, b) => a + b) / justified.length;
      expect(mean, lessThan(maximumMeanExtraGapEm));
      final stretched = plans.where(
        (entry) =>
            nastaleeqLineString(entry.$2.verses).contains(tatweel) &&
            entry.$2.fit.justified,
      );
      expect(stretched.length / justified.length, greaterThan(0.9));
    });
  });

  test('stretches every U+0020 and never the no-break space', () {
    const spacing = 10.0;
    final body = typographyAt(probeFontSize).body(probeColor);
    final spaced = body.copyWith(wordSpacing: spacing);
    expect(lines.where((line) => line.text.contains('\u00A0')), isNotEmpty);
    for (final line in lines) {
      final spaces = ' '.allMatches(line.text).length;
      final stretch =
          measureNastaleeqLine(line.text, spaced) -
          line.widthEm * probeFontSize;
      expect(
        stretch,
        closeTo(spaces * spacing, 0.05),
        reason: 'page ${line.page}: ${line.text}',
      );
    }
  });
}

PrintedTextLine _measure(
  int page,
  NastaleeqWordsLine line,
  NastaleeqText text,
  TextStyle body,
) {
  final string = nastaleeqLineString(nastaleeqLineVerses(line, text));
  return (
    page: page,
    line: line,
    text: string,
    widthEm: measureNastaleeqLine(string, body) / probeFontSize,
  );
}
