import 'dart:convert';
import 'dart:isolate';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'nastaleeq_edition.dart';
import 'nastaleeq_kashida_table.dart';
import 'nastaleeq_text.dart';

part 'nastaleeq_text_provider.g.dart';

NastaleeqKashidaTable _kashidaTable(String? asset, String? raw) =>
    switch ((asset, raw)) {
      (final String asset, final String raw) => NastaleeqKashidaTable.fromJson(
        asset,
        jsonDecode(raw),
      ),
      _ => NastaleeqKashidaTable.empty,
    };

@Riverpod(keepAlive: true)
Future<NastaleeqText> nastaleeqText(Ref ref, NastaleeqEdition edition) async {
  final asset = edition.textAsset;
  final kashidaAsset = edition.kashidaAsset;
  final layout = edition.layout;
  final raw = await rootBundle.loadString(asset, cache: false);
  final kashidaRaw = switch (kashidaAsset) {
    final path? => await rootBundle.loadString(path, cache: false),
    null => null,
  };
  return Isolate.run(
    () => NastaleeqText.fromJson(
      asset,
      jsonDecode(raw),
      layout: layout,
      kashida: _kashidaTable(kashidaAsset, kashidaRaw),
    ),
  );
}
