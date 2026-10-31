import 'dart:math' as math;

import 'nastaleeq_kashida.dart';
import 'nastaleeq_text_format_exception.dart';

final class NastaleeqKashidaTable {
  static const empty = NastaleeqKashidaTable._(
    words: {},
    tatweelEm: 0,
    rejected: 0,
  );

  final Map<String, List<NastaleeqKashidaSlot>> _words;
  final double tatweelEm;
  final int rejected;

  const NastaleeqKashidaTable._({
    required Map<String, List<NastaleeqKashidaSlot>> words,
    required this.tatweelEm,
    required this.rejected,
  }) : _words = words;

  factory NastaleeqKashidaTable.fromJson(String asset, Object? json) =>
      _KashidaTableParser(asset).parse(json);

  int get length => _words.length;

  bool get isEmpty => _words.isEmpty;

  List<NastaleeqKashidaSlot> slotsOf(String word) => _words[word] ?? const [];
}

final class _KashidaTableParser {
  final String asset;
  int _rejected = 0;

  _KashidaTableParser(this.asset);

  NastaleeqTextFormatException _invalid(String reason) =>
      NastaleeqTextFormatException(asset, reason);

  NastaleeqKashidaTable parse(Object? json) {
    if (json case {
      'unitsPerEm': final int unitsPerEm,
      'tatweelAdvance': final int tatweelAdvance,
      'words': final Map<String, Object?> words,
    } when unitsPerEm > 0 && tatweelAdvance > 0) {
      final resolved = <String, List<NastaleeqKashidaSlot>>{};
      for (final MapEntry(key: word, value: entries) in words.entries) {
        final slots = _resolve(word, _entries(word, entries), unitsPerEm);
        if (slots.isNotEmpty) resolved[word] = List.unmodifiable(slots);
      }
      return NastaleeqKashidaTable._(
        words: Map.unmodifiable(resolved),
        tatweelEm: tatweelAdvance / unitsPerEm,
        rejected: _rejected,
      );
    }
    throw _invalid('kashida table needs unitsPerEm, tatweelAdvance and words');
  }

  List<(int, int, int)> _entries(String word, Object? value) {
    if (value is! List<Object?> || value.isEmpty) {
      throw _invalid('kashida slots of $word are not a non-empty list');
    }
    return [
      for (final entry in value)
        switch (entry) {
          [final int at, final int cap, final int gain]
              when at > 0 && at < word.length && cap > 0 =>
            (at, cap, gain),
          _ => throw _invalid('kashida slot $entry of $word is malformed'),
        },
    ];
  }

  List<NastaleeqKashidaSlot> _resolve(
    String word,
    List<(int, int, int)> entries,
    int unitsPerEm,
  ) {
    final sites = {
      for (final site in nastaleeqKashidaSites(word)) site.insertAt: site,
    };
    final letters = nastaleeqLetterCount(word);
    final slots = <NastaleeqKashidaSlot>[];
    for (final (index, (at, cap, gain)) in entries.indexed) {
      final site = sites[at];
      final allowedCap = site == null ? 0 : math.min(cap, site.cap);
      if (site == null || allowedCap <= 0 || !_allowsAt(index, site, letters)) {
        _rejected++;
        return const [];
      }
      slots.add(
        NastaleeqKashidaSlot(
          insertAt: at,
          rank: site.rank,
          cap: allowedCap,
          firstGainEm: gain / unitsPerEm,
        ),
      );
    }
    return slots;
  }

  bool _allowsAt(int index, NastaleeqKashidaSite site, int letters) =>
      index == 0 ||
      (index == 1 &&
          letters >= kNastaleeqSecondaryMinLetters &&
          site.rank <= kNastaleeqSecondaryMaxRank);
}
