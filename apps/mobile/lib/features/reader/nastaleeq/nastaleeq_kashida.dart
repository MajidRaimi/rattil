import 'dart:math' as math;

import 'nastaleeq_arabic_joining.dart';

const kNastaleeqTatweel = 'ـ';
const kNastaleeqKashidaMinGapEm = 0.15;
const Map<int, double> kNastaleeqLongKashidaMinGapEm = {3: 0.30, 4: 0.50};
const kNastaleeqSecondaryMaxRank = 5;
const kNastaleeqSecondaryMinLetters = 4;

const _kShortWordPenalty = 2;
const _kLowRankCap = 2;
const Map<int, int> _kRankCaps = {1: 4, 2: 4, 3: 3, 4: 3, 5: 3, 6: 2, 7: 2};
const Map<int, int> _kShortWordCaps = {1: 0, 2: 2, 3: 3};

const _kLam = 0x0644;
const _kAllahName = '\u0644\u0644\u0651\u0670\u0647';
const Set<int> _kBlockers = {0x06E5, 0x06E6};
const Set<int> _kAlefForms = {
  0x0622,
  0x0623,
  0x0625,
  0x0627,
  0x0671,
  0x0672,
  0x0673,
  0x0675,
};
const Set<int> _kSeenGroup = {0x0633, 0x0634, 0x0635, 0x0636};
const Set<int> _kHehFinals = {0x0647, 0x0629};
const Set<int> _kTallFinals = {
  0x0627,
  0x0644,
  0x0643,
  0x0637,
  0x0638,
  0x062F,
  0x0630,
};
const Set<int> _kRehWawFinals = {0x0631, 0x0632, 0x0648};

const Set<int> _kMuqattaatChapters = {
  2,
  3,
  7,
  10,
  11,
  12,
  13,
  14,
  15,
  19,
  20,
  26,
  27,
  28,
  29,
  30,
  31,
  32,
  36,
  38,
  40,
  41,
  42,
  43,
  44,
  45,
  46,
  50,
  68,
};

typedef NastaleeqKashidaStep = ({int maxRank, int target, int slot});

const List<NastaleeqKashidaStep> kNastaleeqKashidaSchedule = [
  (maxRank: 3, target: 1, slot: 0),
  (maxRank: 5, target: 1, slot: 0),
  (maxRank: 3, target: 2, slot: 0),
  (maxRank: 7, target: 1, slot: 0),
  (maxRank: 5, target: 2, slot: 0),
  (maxRank: 9, target: 1, slot: 0),
  (maxRank: 5, target: 1, slot: 1),
  (maxRank: 7, target: 2, slot: 0),
  (maxRank: 9, target: 2, slot: 0),
  (maxRank: 5, target: 2, slot: 1),
  (maxRank: 3, target: 3, slot: 0),
  (maxRank: 5, target: 3, slot: 0),
  (maxRank: 5, target: 3, slot: 1),
  (maxRank: 2, target: 4, slot: 0),
];

final class NastaleeqKashidaSite {
  final int insertAt;
  final int rank;
  final int cap;

  const NastaleeqKashidaSite({
    required this.insertAt,
    required this.rank,
    required this.cap,
  });
}

final class NastaleeqKashidaSlot {
  final int insertAt;
  final int rank;
  final int cap;
  final double firstGainEm;

  const NastaleeqKashidaSlot({
    required this.insertAt,
    required this.rank,
    required this.cap,
    required this.firstGainEm,
  });
}

final class NastaleeqKashidaWord {
  final int length;
  final List<NastaleeqKashidaSlot> slots;

  const NastaleeqKashidaWord({required this.length, required this.slots});
}

typedef NastaleeqKashidaPlan = ({List<List<int>> counts, double gainEm});

typedef _Base = ({int index, int code, int end});

bool isNastaleeqMuqattaat(int chapter, int number, int wordIndex) =>
    wordIndex == 0 &&
    ((number == 1 && _kMuqattaatChapters.contains(chapter)) ||
        (chapter == 42 && number == 2));

List<_Base> _basesOf(String word) {
  final starts = [
    for (var index = 0; index < word.length; index++)
      if (!isArabicMark(word.codeUnitAt(index))) index,
  ];
  return [
    for (final (position, index) in starts.indexed)
      (
        index: index,
        code: word.codeUnitAt(index),
        end: position + 1 < starts.length ? starts[position + 1] : word.length,
      ),
  ];
}

bool _isSlotLetter(int code) =>
    isArabicLetter(code) && !_kBlockers.contains(code);

bool _formsLamAlef(int left, int right) =>
    left == _kLam && _kAlefForms.contains(right);

bool _joins(int left, int right) =>
    _isSlotLetter(left) &&
    _isSlotLetter(right) &&
    arabicJoinsToNext(left) &&
    arabicJoinsToPrevious(right) &&
    !_formsLamAlef(left, right);

bool _insideAllahName(String word, int insertAt) {
  for (
    var start = word.indexOf(_kAllahName);
    start >= 0 && start < insertAt;
    start = word.indexOf(_kAllahName, start + 1)
  ) {
    if (insertAt < start + _kAllahName.length) return true;
  }
  return false;
}

int _letterCount(List<_Base> bases) =>
    bases.where((base) => isArabicLetter(base.code)).length;

int nastaleeqLetterCount(String word) => _letterCount(_basesOf(word));

int _baseRankOf({
  required int left,
  required int right,
  required bool rightIsFinal,
  required bool leftIsInitial,
}) {
  if (_kSeenGroup.contains(left)) return 1;
  if (rightIsFinal && _kHehFinals.contains(right)) return 2;
  if (!rightIsFinal && !leftIsInitial) return 3;
  if (rightIsFinal && _kTallFinals.contains(right)) return 4;
  if (rightIsFinal && _kRehWawFinals.contains(right)) return 6;
  if (rightIsFinal) return 5;
  return 7;
}

int nastaleeqKashidaCap(int rank, int letters) {
  final rankCap = _kRankCaps[rank] ?? _kLowRankCap;
  final shortCap = _kShortWordCaps[letters];
  return shortCap == null ? rankCap : math.min(rankCap, shortCap);
}

List<NastaleeqKashidaSite> nastaleeqKashidaSites(String word) {
  final bases = _basesOf(word);
  final letters = _letterCount(bases);
  final sites = <NastaleeqKashidaSite>[];
  for (var k = 0; k + 1 < bases.length; k++) {
    final left = bases[k];
    final right = bases[k + 1];
    if (!_joins(left.code, right.code) || _insideAllahName(word, left.end)) {
      continue;
    }
    final after = k + 2 < bases.length ? bases[k + 2] : null;
    final before = k > 0 ? bases[k - 1] : null;
    final rightIsFinal =
        !(arabicJoinsToNext(right.code) &&
            after != null &&
            arabicJoinsToPrevious(after.code));
    final leftIsInitial =
        !(before != null &&
            arabicJoinsToNext(before.code) &&
            arabicJoinsToPrevious(left.code));
    final baseRank = _baseRankOf(
      left: left.code,
      right: right.code,
      rightIsFinal: rightIsFinal,
      leftIsInitial: leftIsInitial,
    );
    final rank = letters <= 2 ? baseRank + _kShortWordPenalty : baseRank;
    sites.add(
      NastaleeqKashidaSite(
        insertAt: left.end,
        rank: rank,
        cap: nastaleeqKashidaCap(rank, letters),
      ),
    );
  }
  return sites;
}

int _compareWords(List<NastaleeqKashidaWord> words, int a, int b) {
  final byRank = words[a].slots.first.rank.compareTo(words[b].slots.first.rank);
  if (byRank != 0) return byRank;
  final byLength = words[b].length.compareTo(words[a].length);
  return byLength != 0 ? byLength : a.compareTo(b);
}

NastaleeqKashidaPlan distributeNastaleeqKashida(
  List<NastaleeqKashidaWord> words, {
  required double budgetEm,
  required int spaces,
  required double tatweelEm,
}) {
  final counts = [
    for (final word in words) List<int>.filled(word.slots.length, 0),
  ];
  final order = [
    for (final (index, word) in words.indexed)
      if (word.slots.isNotEmpty) index,
  ]..sort((a, b) => _compareWords(words, a, b));
  var used = 0.0;
  for (final step in kNastaleeqKashidaSchedule) {
    final longGapEm = kNastaleeqLongKashidaMinGapEm[step.target];
    if (spaces > 0 &&
        longGapEm != null &&
        (budgetEm - used) / spaces + kNastaleeqKashidaMinGapEm < longGapEm) {
      continue;
    }
    for (final index in order) {
      final slots = words[index].slots;
      if (step.slot >= slots.length) continue;
      final slot = slots[step.slot];
      final current = counts[index][step.slot];
      if (slot.rank > step.maxRank ||
          step.target > slot.cap ||
          current >= step.target) {
        continue;
      }
      final gain = current == 0 ? slot.firstGainEm : tatweelEm;
      if (gain <= 0 || used + gain > budgetEm) continue;
      counts[index][step.slot] = current + 1;
      used += gain;
    }
  }
  return (counts: counts, gainEm: used);
}

String stretchNastaleeqWord(
  String word,
  List<NastaleeqKashidaSlot> slots,
  List<int> counts,
) {
  final insertions = [
    for (final (index, slot) in slots.indexed)
      if (counts[index] > 0) (at: slot.insertAt, count: counts[index]),
  ]..sort((a, b) => a.at.compareTo(b.at));
  if (insertions.isEmpty) return word;
  final buffer = StringBuffer();
  var cursor = 0;
  for (final insertion in insertions) {
    buffer
      ..write(word.substring(cursor, insertion.at))
      ..write(kNastaleeqTatweel * insertion.count);
    cursor = insertion.at;
  }
  buffer.write(word.substring(cursor));
  return buffer.toString();
}
