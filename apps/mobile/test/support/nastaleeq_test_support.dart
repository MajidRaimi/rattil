import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:quran_mobile/features/reader/nastaleeq/nastaleeq_edition.dart';
import 'package:quran_mobile/features/reader/nastaleeq/nastaleeq_kashida_table.dart';
import 'package:quran_mobile/features/reader/nastaleeq/nastaleeq_text.dart';

const Map<String, String> nastaleeqFontAssets = {
  'DigitalKhattIndoPak': 'assets/fonts/DigitalKhattIndoPak.ttf',
  'KFGQPCNastaleeq': 'assets/fonts/HafsNastaleeq-Ver10.otf',
};

Future<void> loadNastaleeqFonts() async {
  for (final MapEntry(key: family, value: path)
      in nastaleeqFontAssets.entries) {
    final bytes = File(path).readAsBytesSync();
    final loader = FontLoader(family)
      ..addFont(Future.value(ByteData.sublistView(Uint8List.fromList(bytes))));
    await loader.load();
  }
}

Object? readNastaleeqJson(NastaleeqEdition edition) =>
    jsonDecode(File(edition.textAsset).readAsStringSync());

Iterable<String> readKashidaWords(NastaleeqEdition edition) =>
    switch (edition.kashidaAsset) {
      final asset? => switch (jsonDecode(File(asset).readAsStringSync())) {
        {'words': final Map<String, Object?> words} => words.keys,
        _ => const <String>[],
      },
      null => const <String>[],
    };

NastaleeqKashidaTable loadNastaleeqKashida(NastaleeqEdition edition) =>
    switch (edition.kashidaAsset) {
      final asset? => NastaleeqKashidaTable.fromJson(
        asset,
        jsonDecode(File(asset).readAsStringSync()),
      ),
      null => NastaleeqKashidaTable.empty,
    };

NastaleeqText loadNastaleeqText(NastaleeqEdition edition) =>
    NastaleeqText.fromJson(
      edition.textAsset,
      readNastaleeqJson(edition),
      layout: edition.layout,
      kashida: loadNastaleeqKashida(edition),
    );
