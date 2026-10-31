import 'package:flutter_test/flutter_test.dart';
import 'package:quran/quran.dart' as quran;
import 'package:quran_mobile/features/reader/nastaleeq/nastaleeq_arabic_joining.dart';
import 'package:quran_mobile/features/reader/nastaleeq/nastaleeq_edition.dart';
import 'package:quran_mobile/features/reader/nastaleeq/nastaleeq_kashida.dart';
import 'package:quran_mobile/features/reader/nastaleeq/nastaleeq_kashida_table.dart';
import 'package:quran_mobile/features/reader/nastaleeq/nastaleeq_text.dart';

import 'support/nastaleeq_test_support.dart';

const int lam = 0x0644;
const Set<int> alefForms = {0x0622, 0x0623, 0x0625, 0x0627, 0x0671};
const double tatweelEm = 0.25;
const String allahLigature = '\u0644\u0644\u0651\u0670\u0647';

List<int> sitesOf(String word) =>
    nastaleeqKashidaSites(word).map((site) => site.insertAt).toList();

int baseBefore(String word, int index) {
  var cursor = index - 1;
  while (isArabicMark(word.codeUnitAt(cursor))) {
    cursor--;
  }
  return word.codeUnitAt(cursor);
}

NastaleeqKashidaSlot slot({
  int insertAt = 1,
  int rank = 3,
  int cap = 5,
  double firstGainEm = tatweelEm,
}) => NastaleeqKashidaSlot(
  insertAt: insertAt,
  rank: rank,
  cap: cap,
  firstGainEm: firstGainEm,
);

NastaleeqKashidaWord word(List<NastaleeqKashidaSlot> slots, {int length = 6}) =>
    NastaleeqKashidaWord(length: length, slots: slots);

Iterable<String> corpusWords(NastaleeqText text) sync* {
  for (var chapter = 1; chapter <= 114; chapter++) {
    for (var number = 1; number <= quran.getVerseCount(chapter); number++) {
      yield* text.verseWords(chapter, number);
    }
  }
}

void main() {
  group('insertion points', () {
    test('sit after the letter and all its marks', () {
      expect(sitesOf('قَالَ'), [2]);
      expect(sitesOf('بِسْمِ'), [2, 4]);
    });

    test('never follow a letter that does not join forward', () {
      expect(sitesOf('وَرَدَ'), isEmpty);
      expect(sitesOf('دَارٌ'), isEmpty);
      expect(sitesOf('اُذْكُرُوْا'), [6]);
    });

    test('never split lam-alef', () {
      expect(sitesOf('لَا'), isEmpty);
      expect(sitesOf('فَلَا'), [2]);
      expect(sitesOf('اَلْاَرْضِ'), isEmpty);
    });

    test('never sit beside a non-letter', () {
      expect(sitesOf('بِ ۝بِ'), isEmpty);
      expect(sitesOf('ۦب'), isEmpty);
    });

    test('rank seen first and short words last', () {
      final sites = nastaleeqKashidaSites('نَسْتَعِيْنُ');
      expect(sites.first.rank, 7);
      expect(sites[1].rank, 1);
      expect(sites[1].cap, 4);
      expect(nastaleeqKashidaSites('بَلْ').single.rank, 6);
      expect(nastaleeqKashidaSites('بَلْ').single.cap, 2);
    });

    test('lock the muqattaat by location', () {
      expect(isNastaleeqMuqattaat(2, 1, 0), isTrue);
      expect(isNastaleeqMuqattaat(42, 2, 0), isTrue);
      expect(isNastaleeqMuqattaat(2, 1, 1), isFalse);
      expect(isNastaleeqMuqattaat(1, 1, 0), isFalse);
    });
  });

  group('stretching', () {
    test('inserts tatweels at each slot', () {
      const plain = 'بِسْمِ';
      final stretched = stretchNastaleeqWord(
        plain,
        [slot(insertAt: 2), slot(insertAt: 4)],
        [2, 1],
      );
      expect(stretched, 'بِــسْـمِ');
      expect(stretched.replaceAll(kNastaleeqTatweel, ''), plain);
    });

    test('leaves a word without counts unchanged', () {
      expect(stretchNastaleeqWord('قَالَ', [slot(insertAt: 2)], [0]), 'قَالَ');
    });
  });

  group('distribution', () {
    test('fills the budget to within one tatweel', () {
      final words = [
        for (var index = 0; index < 8; index++) word([slot(rank: 1, cap: 6)]),
      ];
      final plan = distributeNastaleeqKashida(
        words,
        budgetEm: 3.3,
        spaces: 7,
        tatweelEm: tatweelEm,
      );
      expect(plan.gainEm, lessThanOrEqualTo(3.3));
      expect(3.3 - plan.gainEm, lessThan(tatweelEm));
      final total = plan.counts.expand((counts) => counts).fold(0, _sum);
      expect(total * tatweelEm, closeTo(plan.gainEm, 1e-9));
    });

    test('spreads kashidas across words before lengthening any', () {
      final words = [
        for (var index = 0; index < 4; index++) word([slot()]),
      ];
      final plan = distributeNastaleeqKashida(
        words,
        budgetEm: 1.0,
        spaces: 3,
        tatweelEm: tatweelEm,
      );
      expect(plan.counts, [
        [1],
        [1],
        [1],
        [1],
      ]);
    });

    test('never exceeds a slot cap or a low rank target', () {
      final words = [
        word([slot(rank: 6, cap: 2)]),
        word([slot(rank: 1, cap: 6)]),
      ];
      final plan = distributeNastaleeqKashida(
        words,
        budgetEm: 50,
        spaces: 1,
        tatweelEm: tatweelEm,
      );
      expect(plan.counts[0].single, 2);
      expect(plan.counts[1].single, 4);
    });

    test('keeps long kashidas back when gaps would stay tight', () {
      final words = [
        for (var index = 0; index < 4; index++) word([slot(rank: 1, cap: 6)]),
      ];
      final plan = distributeNastaleeqKashida(
        words,
        budgetEm: 2.5,
        spaces: 20,
        tatweelEm: tatweelEm,
      );
      expect(plan.counts.every((counts) => counts.single == 2), isTrue);
      expect(plan.gainEm, 2.0);
    });

    test('adds a fourth tatweel only when gaps would stay wide', () {
      final words = [
        for (var index = 0; index < 4; index++) word([slot(rank: 1, cap: 6)]),
      ];
      final plan = distributeNastaleeqKashida(
        words,
        budgetEm: 4.0,
        spaces: 4,
        tatweelEm: tatweelEm,
      );
      expect(plan.counts.every((counts) => counts.single == 3), isTrue);
      final wide = distributeNastaleeqKashida(
        words,
        budgetEm: 6.0,
        spaces: 4,
        tatweelEm: tatweelEm,
      );
      expect(wide.counts.every((counts) => counts.single == 4), isTrue);
    });

    test('uses a secondary slot only after the primaries', () {
      final words = [
        word([slot(insertAt: 2), slot(insertAt: 5, rank: 4)]),
        word([slot(insertAt: 2)]),
      ];
      final plan = distributeNastaleeqKashida(
        words,
        budgetEm: 0.5,
        spaces: 1,
        tatweelEm: tatweelEm,
      );
      expect(plan.counts, [
        [1, 0],
        [1],
      ]);
    });

    test('skips a slot whose first tatweel would not widen the word', () {
      final plan = distributeNastaleeqKashida(
        [
          word([slot(firstGainEm: -0.1)]),
        ],
        budgetEm: 2,
        spaces: 1,
        tatweelEm: tatweelEm,
      );
      expect(plan.counts.single.single, 0);
      expect(plan.gainEm, 0);
    });

    test('returns nothing without a budget', () {
      final plan = distributeNastaleeqKashida(
        [
          word([slot()]),
        ],
        budgetEm: 0,
        spaces: 1,
        tatweelEm: tatweelEm,
      );
      expect(plan.gainEm, 0);
    });
  });

  group('DigitalKhatt table', () {
    const edition = NastaleeqEdition.digitalKhatt;
    final text = loadNastaleeqText(edition);
    final table = text.kashida;

    test('loads every verified word and rejects none', () {
      expect(table.length, 23399);
      expect(table.rejected, 0);
      expect(table.tatweelEm, tatweelEm);
    });

    test('only names words that appear in the text', () {
      final words = corpusWords(text).toSet();
      final raw = readKashidaWords(edition);
      expect(raw.where((word) => !words.contains(word)), isEmpty);
    });

    test('never places a kashida inside marks, after a non-joiner or in '
        'lam-alef', () {
      for (final word in corpusWords(text).toSet()) {
        for (final slot in table.slotsOf(word)) {
          final right = word.codeUnitAt(slot.insertAt);
          final left = baseBefore(word, slot.insertAt);
          expect(isArabicMark(right), isFalse, reason: word);
          expect(arabicJoinsToNext(left), isTrue, reason: word);
          expect(arabicJoinsToPrevious(right), isTrue, reason: word);
          expect(left == lam && alefForms.contains(right), isFalse);
        }
      }
    });

    test('leaves the name of Allah untouched', () {
      final named = corpusWords(
        text,
      ).toSet().where((word) => word.contains(allahLigature));
      expect(named, isNotEmpty);
      for (final word in named) {
        final start = word.indexOf(allahLigature);
        final end = start + allahLigature.length;
        for (final slot in table.slotsOf(word)) {
          expect(
            slot.insertAt <= start || slot.insertAt >= end,
            isTrue,
            reason: word,
          );
        }
      }
    });

    test('has nothing for the empty table', () {
      expect(NastaleeqKashidaTable.empty.slotsOf('بِسْمِ'), isEmpty);
    });
  });
}

int _sum(int a, int b) => a + b;
