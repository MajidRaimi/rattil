import 'dart:ui';

import '../../../providers/mushaf_script_provider.dart';
import 'nastaleeq_layout.dart';

enum NastaleeqEdition {
  digitalKhatt(
    fontFamily: 'DigitalKhattIndoPak',
    textAsset: 'assets/quran/indopak-digitalkhatt.json',
    kashidaAsset: 'assets/quran/indopak-digitalkhatt-kashida.json',
    basmalaFeatures: [FontFeature('basm')],
    lineHeight: 2.3,
    basmalaHeight: 2.3,
    headerHeight: 2.2,
    layout: NastaleeqPrintedSpec(
      pageCount: 610,
      linesPerPage: 15,
      openingPageLines: 8,
      closingPageLines: 10,
      lineWidthEm: 20.7,
      minSlotEm: 2.3,
    ),
  ),
  kfgqpc(
    fontFamily: 'KFGQPCNastaleeq',
    textAsset: 'assets/quran/indopak-kfgqpc.json',
    kashidaAsset: null,
    basmalaFeatures: [],
    lineHeight: 2.0,
    basmalaHeight: 2.0,
    headerHeight: 1.9,
    layout: NastaleeqFlowingSpec(pageCount: 604),
  );

  final String fontFamily;
  final String textAsset;
  final String? kashidaAsset;
  final List<FontFeature> basmalaFeatures;
  final double lineHeight;
  final double basmalaHeight;
  final double headerHeight;
  final NastaleeqLayoutSpec layout;

  const NastaleeqEdition({
    required this.fontFamily,
    required this.textAsset,
    required this.kashidaAsset,
    required this.basmalaFeatures,
    required this.lineHeight,
    required this.basmalaHeight,
    required this.headerHeight,
    required this.layout,
  });
}

extension MushafScriptNastaleeqEdition on MushafScript {
  NastaleeqEdition? get nastaleeqEdition => switch (this) {
    MushafScript.madinah => null,
    MushafScript.nastaleeq => NastaleeqEdition.digitalKhatt,
    MushafScript.nastaleeqKfgqpc => NastaleeqEdition.kfgqpc,
  };
}
