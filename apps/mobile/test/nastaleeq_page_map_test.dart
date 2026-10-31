import 'package:flutter_test/flutter_test.dart';
import 'package:quran/quran.dart' as quran;
import 'package:quran_mobile/features/reader/nastaleeq/nastaleeq_edition.dart';
import 'package:quran_mobile/features/reader/nastaleeq/nastaleeq_page_map.dart';
import 'package:quran_mobile/features/reader/nastaleeq/nastaleeq_printed_layout.dart';

import 'support/nastaleeq_test_support.dart';

NastaleeqWordRange range(int chapter, int number, int start, int end) =>
    NastaleeqWordRange(
      chapter: chapter,
      number: number,
      start: start,
      end: end,
    );

Iterable<int> allVerseKeys() sync* {
  for (var chapter = 1; chapter <= 114; chapter++) {
    for (var number = 1; number <= quran.getVerseCount(chapter); number++) {
      yield nastaleeqVerseKey(chapter, number);
    }
  }
}

void main() {
  group('Madinah map', () {
    final map = NastaleeqPageMap.madinah;

    test('has 604 pages that map to themselves', () {
      expect(map.pageCount, 604);
      for (var page = 1; page <= 604; page++) {
        expect(map.madinahPageOf(page), page);
        expect(map.pageForMadinahPage(page, currentPage: 1), page);
        expect(map.pageForMadinahPage(page, currentPage: 604), page);
        expect(map.anchorVerseOf(page), nastaleeqMadinahPageStart(page));
      }
    });

    test('agrees with the quran package for every verse', () {
      for (final key in allVerseKeys()) {
        final page = quran.getPageNumber(
          nastaleeqVerseChapter(key),
          nastaleeqVerseNumber(key),
        );
        expect(map.pageOfVerse(key), page, reason: '$key');
        expect(map.showsVerse(page, key), isTrue, reason: '$key');
      }
    });
  });

  group('printed DigitalKhatt map', () {
    late NastaleeqPrintedLayout layout;
    late NastaleeqPageMap map;

    setUpAll(() {
      final text = loadNastaleeqText(NastaleeqEdition.digitalKhatt);
      layout = text.printedLayout!;
      map = text.pageMap;
    });

    test('spans 610 pages from al-Fatiha to an-Nas', () {
      expect(map.pageCount, 610);
      expect(map.pageOfVerse(1001), 1);
      expect(map.pageOfVerse(2001), 2);
      expect(map.pageOfVerse(2030), 6);
      expect(map.pageOfVerse(114006), 610);
      expect(map.madinahPageOf(1), 1);
      expect(map.madinahPageOf(2), 2);
      expect(map.madinahPageOf(610), 604);
      expect(map.anchorVerseOf(6), 2030);
    });

    test('opens every surah on the page that carries its title', () {
      for (var page = 1; page <= layout.pageCount; page++) {
        for (final line in layout.linesOf(page)) {
          if (line case NastaleeqTitleLine(:final chapter)) {
            expect(
              map.pageOfVerse(nastaleeqVerseKey(chapter, 1)),
              page,
              reason: 'surah $chapter',
            );
          }
        }
      }
    });

    test('shows every verse on the page it maps to', () {
      for (final key in allVerseKeys()) {
        expect(
          map.showsVerse(map.pageOfVerse(key), key),
          isTrue,
          reason: '$key',
        );
      }
    });

    test('round trips every printed page through its Madinah page', () {
      for (var page = 1; page <= map.pageCount; page++) {
        expect(map.pageOfVerse(map.anchorVerseOf(page)), page);
        expect(
          map.pageForMadinahPage(map.madinahPageOf(page), currentPage: page),
          page,
        );
      }
    });

    test('keeps every printed page across repeated edition switches', () {
      final madinah = NastaleeqPageMap.madinah;
      for (var page = 1; page <= map.pageCount; page++) {
        var anchor = map.anchorVerseOf(page);
        for (var round = 0; round < 30; round++) {
          anchor = madinah.keepAnchor(madinah.pageOfVerse(anchor), anchor);
          final printed = map.pageOfVerse(anchor);
          expect(printed, page, reason: 'printed $page, round $round');
          anchor = map.keepAnchor(printed, anchor);
        }
      }
    });

    test('keeps an anchor only while the page shows it', () {
      for (var page = 1; page < map.pageCount; page++) {
        final anchor = map.anchorVerseOf(page);
        expect(map.keepAnchor(page, anchor), anchor);
        final next = map.anchorVerseOf(page + 1);
        expect(
          map.keepAnchor(page + 1, anchor),
          map.showsVerse(page + 1, anchor) ? anchor : next,
        );
      }
    });

    test('stays on a printed page that already shows the Madinah page', () {
      for (var page = 1; page <= map.pageCount; page++) {
        final touched = {
          for (final range in layout.rangesOf(page))
            quran.getPageNumber(range.chapter, range.number),
        };
        for (final madinahPage in touched) {
          expect(
            map.pageForMadinahPage(madinahPage, currentPage: page),
            page,
            reason: 'printed $page, Madinah $madinahPage',
          );
        }
      }
    });

    test(
      'opens the page holding the first verse of a distant Madinah page',
      () {
        for (var madinahPage = 1; madinahPage <= 604; madinahPage++) {
          final current = madinahPage < 302 ? map.pageCount : 1;
          final target = map.pageForMadinahPage(
            madinahPage,
            currentPage: current,
          );
          expect(
            target,
            map.pageOfVerse(nastaleeqMadinahPageStart(madinahPage)),
            reason: 'Madinah $madinahPage',
          );
        }
      },
    );
  });

  group('printed map with a verse spanning two pages', () {
    final map = NastaleeqPageMap.printed(
      NastaleeqPrintedLayout([
        [
          const NastaleeqTitleLine(1),
          NastaleeqWordsLine([
            range(1, 1, 0, 4),
            range(1, 2, 0, 4),
            range(1, 3, 0, 2),
            range(1, 4, 0, 3),
            range(1, 5, 0, 4),
            range(1, 6, 0, 3),
            range(1, 7, 0, 3),
          ]),
        ],
        [
          NastaleeqWordsLine([range(1, 7, 3, 9)]),
        ],
        [
          const NastaleeqTitleLine(2),
          NastaleeqWordsLine([range(2, 1, 0, 1), range(2, 2, 0, 5)]),
        ],
      ]),
    );

    test('maps the verse to the page where it starts', () {
      expect(map.pageOfVerse(1007), 1);
      expect(map.showsVerse(1, 1007), isTrue);
      expect(map.showsVerse(2, 1007), isTrue);
      expect(map.showsVerse(3, 1007), isFalse);
    });

    test('anchors a page with no starting verse on the continuing verse', () {
      expect(map.anchorVerseOf(1), 1001);
      expect(map.anchorVerseOf(2), 1007);
      expect(map.madinahPageOf(2), 1);
    });

    test('keeps the continuation page when asked for its Madinah page', () {
      expect(map.pageForMadinahPage(1, currentPage: 2), 2);
      expect(map.pageForMadinahPage(1, currentPage: 3), 1);
      expect(map.pageForMadinahPage(2, currentPage: 1), 3);
    });
  });
}
