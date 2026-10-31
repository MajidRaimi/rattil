import 'package:flutter_test/flutter_test.dart';
import 'package:quran/quran.dart' as quran;
import 'package:quran_mobile/features/reader/nastaleeq/nastaleeq_edition.dart';
import 'package:quran_mobile/features/reader/nastaleeq/nastaleeq_layout.dart';
import 'package:quran_mobile/features/reader/nastaleeq/nastaleeq_printed_layout.dart';
import 'package:quran_mobile/features/reader/nastaleeq/nastaleeq_text.dart';

import 'support/nastaleeq_test_support.dart';

const int surahCount = 114;

const String rlo = '\u202E';
const String takhallus = '\u0614';
const String sajdaSign = '\u08DB';
const String cgj = '\u034F';
const String shaddaFathaWaw = '\u0648\u0651\u064E';

class IndoPakBundle {
  const IndoPakBundle(this.text);

  factory IndoPakBundle.load(NastaleeqEdition edition) =>
      IndoPakBundle(loadNastaleeqText(edition));

  final NastaleeqText text;

  String get basmala => text.basmala;

  List<String> get titles =>
      List.generate(surahCount, (index) => text.title(index + 1));

  String verse(int surah, int ayah) => text.verse(surah, ayah);

  Iterable<(int, int, String)> get verses sync* {
    for (var surah = 1; surah <= surahCount; surah++) {
      for (var ayah = 1; ayah <= quran.getVerseCount(surah); ayah++) {
        yield (surah, ayah, text.verse(surah, ayah));
      }
    }
  }
}

class EditionExpectation {
  const EditionExpectation({
    required this.name,
    required this.edition,
    required this.embeddedNumber,
    required this.guardedTail,
  });

  final String name;
  final NastaleeqEdition edition;
  final RegExp embeddedNumber;
  final RegExp guardedTail;
}

final digitalKhatt = EditionExpectation(
  name: 'DigitalKhatt',
  edition: NastaleeqEdition.digitalKhatt,
  embeddedNumber: RegExp('\u06DD([\u0660-\u0669]+)'),
  guardedTail: RegExp('^[^\u06DD]*\u00A0\u06DD[^\u06DD]*\$'),
);

final kfgqpc = EditionExpectation(
  name: 'KFGQPC',
  edition: NastaleeqEdition.kfgqpc,
  embeddedNumber: RegExp('\u00A0([\u0660-\u0669]+)[\uFD30-\uFDFF]*\$'),
  guardedTail: RegExp('\u00A0[\u0660-\u0669]+[\uFD30-\uFDFF]*\$'),
);

int parseArabicIndicDigits(String digits) => int.parse(
  String.fromCharCodes(digits.codeUnits.map((unit) => unit - 0x0660 + 0x30)),
);

void expectSharedInvariants(EditionExpectation edition) {
  group(edition.name, () {
    final bundle = IndoPakBundle.load(edition.edition);

    test('has 114 titles and surahs with Hafs verse counts', () {
      expect(bundle.titles.every((title) => title.isNotEmpty), isTrue);
      expect(bundle.verses.length, 6236);
    });

    test('embeds the ayah number of every verse', () {
      for (final (surah, ayah, text) in bundle.verses) {
        final digits = edition.embeddedNumber.firstMatch(text)?.group(1);
        expect(digits, isNotNull, reason: '$surah:$ayah');
        expect(parseArabicIndicDigits(digits!), ayah, reason: '$surah:$ayah');
      }
    });

    test('keeps the medallion tail glued with a no-break space', () {
      for (final (surah, ayah, text) in bundle.verses) {
        expect(
          edition.guardedTail.hasMatch(text),
          isTrue,
          reason: '$surah:$ayah',
        );
      }
      expect(bundle.basmala.contains('\u00A0'), isTrue);
    });

    test('contains no U+202E or U+0614', () {
      final everything = [
        bundle.basmala,
        ...bundle.titles,
        ...bundle.verses.map((verse) => verse.$3),
      ];
      for (final text in everything) {
        expect(text.contains(rlo), isFalse);
        expect(text.contains(takhallus), isFalse);
      }
    });

    test('has no sajda sign at 22:77', () {
      expect(bundle.verse(22, 77).contains(sajdaSign), isFalse);
    });
  });
}

void main() {
  expectSharedInvariants(digitalKhatt);
  expectSharedInvariants(kfgqpc);

  test('DigitalKhatt carries the four idgham shadda fixes', () {
    final bundle = IndoPakBundle.load(digitalKhatt.edition);
    const fixes = {(2, 41): 16, (2, 231): 25, (3, 24): 9, (33, 44): 4};
    fixes.forEach((key, wordIndex) {
      final words = bundle.verse(key.$1, key.$2).split(' ');
      expect(
        words[wordIndex].startsWith(shaddaFathaWaw),
        isTrue,
        reason: '${key.$1}:${key.$2}',
      );
    });
  });

  test('DigitalKhatt keeps the other fourteen sajda signs', () {
    final bundle = IndoPakBundle.load(digitalKhatt.edition);
    final carriers = bundle.verses
        .where((verse) => verse.$3.contains(sajdaSign))
        .map((verse) => '${verse.$1}:${verse.$2}');
    expect(carriers, hasLength(14));
  });

  test(
    'KFGQPC marks sajda only at the fourteen Hafs sajda verses, not at 22:77',
    () {
      final bundle = IndoPakBundle.load(kfgqpc.edition);
      const sajdaMarks = ['\uFDB6', '\uFDB7', '\uFDF3', '\uFDC2'];
      final carriers = bundle.verses
          .where((verse) => sajdaMarks.any(verse.$3.contains))
          .map((verse) => '${verse.$1}:${verse.$2}')
          .toList();
      expect(carriers, [
        '7:206',
        '13:15',
        '16:50',
        '17:109',
        '19:58',
        '22:18',
        '25:60',
        '27:26',
        '32:15',
        '38:24',
        '41:38',
        '53:62',
        '84:21',
        '96:19',
      ]);
    },
  );

  test('KFGQPC carries the CGJ fix in exactly the eight affected verses', () {
    final bundle = IndoPakBundle.load(kfgqpc.edition);
    final carriers = bundle.verses
        .where((verse) => verse.$3.contains(cgj))
        .map((verse) => '${verse.$1}:${verse.$2}')
        .toList();
    expect(carriers, [
      '2:249',
      '3:34',
      '9:66',
      '18:74',
      '27:52',
      '29:35',
      '43:28',
      '59:7',
    ]);
    for (final key in carriers) {
      final parts = key.split(':').map(int.parse).toList();
      expect(
        bundle.verse(parts[0], parts[1]).contains('\u064B$cgj\u06E3'),
        isTrue,
        reason: key,
      );
    }
  });

  group('printed pages', () {
    const edition = NastaleeqEdition.digitalKhatt;
    final spec = edition.layout as NastaleeqPrintedSpec;

    Map<String, Object?> freshJson(NastaleeqEdition source) =>
        readNastaleeqJson(source)! as Map<String, Object?>;

    List<Object?> pagesOf(Map<String, Object?> json) =>
        json['pages']! as List<Object?>;

    List<Object?> linesOf(Map<String, Object?> json, int page) =>
        pagesOf(json)[page - 1]! as List<Object?>;

    Matcher rejects() => throwsA(isA<NastaleeqTextFormatException>());

    NastaleeqText parse(NastaleeqEdition target, Map<String, Object?> json) =>
        NastaleeqText.fromJson(target.textAsset, json, layout: target.layout);

    test('DigitalKhatt carries the 15 line, 610 page layout', () {
      final layout = IndoPakBundle.load(edition).text.printedLayout!;
      expect(layout.pageCount, spec.pageCount);
      final lineCounts = [
        for (var page = 1; page <= layout.pageCount; page++)
          layout.linesOf(page).length,
      ];
      expect(lineCounts.take(2), [8, 8]);
      expect(lineCounts.last, 10);
      expect(
        lineCounts.sublist(2, lineCounts.length - 1),
        everyElement(spec.linesPerPage),
      );
      final lines = layout.pages.expand((page) => page).toList();
      expect(
        lines.whereType<NastaleeqTitleLine>().map((line) => line.chapter),
        List.generate(surahCount, (index) => index + 1),
      );
      expect(
        lines.whereType<NastaleeqBasmalaLine>().map((line) => line.chapter),
        [
          for (var chapter = 2; chapter <= surahCount; chapter++)
            if (chapter != 9) chapter,
        ],
      );
    });

    test('KFGQPC stays flowing', () {
      expect(
        IndoPakBundle.load(NastaleeqEdition.kfgqpc).text.printedLayout,
        isNull,
      );
    });

    test('rejects DigitalKhatt without pages', () {
      final json = freshJson(edition)..remove('pages');
      expect(() => parse(edition, json), rejects());
    });

    test('rejects pages on a flowing edition', () {
      final json = freshJson(NastaleeqEdition.kfgqpc)
        ..['pages'] = pagesOf(freshJson(edition));
      expect(() => parse(NastaleeqEdition.kfgqpc, json), rejects());
    });

    test('rejects a missing page', () {
      final json = freshJson(edition);
      pagesOf(json).removeLast();
      expect(() => parse(edition, json), rejects());
    });

    test('rejects a gap in the word coverage', () {
      final json = freshJson(edition);
      final line = linesOf(json, 6).first! as Map<String, Object?>;
      final ranges = line['words']! as List<Object?>;
      ranges[0] = [2, 30, 0, 9];
      expect(() => parse(edition, json), rejects());
    });

    int pageWithTitle(Map<String, Object?> json, int chapter) =>
        pagesOf(json).indexWhere(
          (page) => (page! as List<Object?>).any(
            (line) => line is Map && line['title'] == chapter,
          ),
        ) +
        1;

    int titleIndex(List<Object?> lines, int chapter) =>
        lines.indexWhere((line) => line is Map && line['title'] == chapter);

    List<Object?>? wordsOf(Object? line) =>
        line is Map<String, Object?> ? line['words'] as List<Object?>? : null;

    void mergeTwoWordsLines(List<Object?> lines) {
      final index = lines.lastIndexWhere(
        (line) => wordsOf(line) != null,
        lines.length - 1,
      );
      final first = wordsOf(lines[index - 1])!;
      final second = wordsOf(lines.removeAt(index))!;
      lines[index - 1] = {
        'words': [...first, ...second],
      };
    }

    void splitLastWordsLine(List<Object?> lines) {
      final index = lines.lastIndexWhere(
        (line) => (wordsOf(line)?.length ?? 0) > 1,
      );
      final ranges = wordsOf(lines[index])!;
      lines
        ..[index] = {'words': ranges.sublist(0, 1)}
        ..insert(index + 1, {'words': ranges.sublist(1)});
    }

    Matcher rejectsAt(String path) => throwsA(
      isA<NastaleeqTextFormatException>().having(
        (error) => error.toString(),
        'message',
        matches(RegExp('${RegExp.escape(path)}[ .]')),
      ),
    );

    for (final chapter in [1, 9]) {
      test('rejects a basmala line for surah $chapter', () {
        final json = freshJson(edition);
        final page = pageWithTitle(json, chapter);
        final lines = linesOf(json, page);
        mergeTwoWordsLines(lines);
        final index = titleIndex(lines, chapter) + 1;
        lines.insert(index, {'basmala': chapter});
        expect(
          () => parse(edition, json),
          rejectsAt('pages[${page - 1}][$index]'),
        );
      });
    }

    test('rejects a page with the wrong line count', () {
      final json = freshJson(edition);
      mergeTwoWordsLines(linesOf(json, 50));
      expect(() => parse(edition, json), rejectsAt('pages[49]'));
    });

    test('rejects a missing surah title', () {
      final json = freshJson(edition);
      final page = pageWithTitle(json, 5);
      final lines = linesOf(json, page);
      final index = titleIndex(lines, 5);
      lines.removeAt(index);
      splitLastWordsLine(lines);
      expect(
        () => parse(edition, json),
        rejectsAt('pages[${page - 1}][$index]'),
      );
    });

    test('rejects a duplicate surah title', () {
      final json = freshJson(edition);
      final page = pageWithTitle(json, 2);
      final lines = linesOf(json, page);
      mergeTwoWordsLines(lines);
      final index = titleIndex(lines, 2);
      lines.insert(index, {'title': 2});
      expect(
        () => parse(edition, json),
        rejectsAt('pages[${page - 1}][${index + 1}]'),
      );
    });

    test('rejects a basmala placed before its title', () {
      final json = freshJson(edition);
      final page = pageWithTitle(json, 3);
      final lines = linesOf(json, page);
      final index = titleIndex(lines, 3);
      lines.insert(index, lines.removeAt(index + 1));
      expect(
        () => parse(edition, json),
        rejectsAt('pages[${page - 1}][$index]'),
      );
    });

    test('rejects a surah that starts without its basmala', () {
      final json = freshJson(edition);
      final page = pageWithTitle(json, 3);
      final lines = linesOf(json, page);
      final index = titleIndex(lines, 3) + 1;
      lines.removeAt(index);
      splitLastWordsLine(lines);
      expect(
        () => parse(edition, json),
        rejectsAt('pages[${page - 1}][$index]'),
      );
    });

    test('rejects a line that is neither title, basmala nor words', () {
      final json = freshJson(edition);
      linesOf(json, 3)[0] = {'words': <Object?>[], 'title': 2};
      expect(() => parse(edition, json), rejects());
    });
  });
}
