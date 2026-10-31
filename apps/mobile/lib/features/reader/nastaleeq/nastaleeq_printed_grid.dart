import 'dart:math' as math;
import 'dart:ui';

import 'nastaleeq_layout.dart';

const kNastaleeqMinPrintedFontSize = 14.0;

final class NastaleeqPrintedGrid {
  final double fontSize;
  final double slotHeight;
  final double columnWidth;
  final bool scrolls;

  const NastaleeqPrintedGrid({
    required this.fontSize,
    required this.slotHeight,
    required this.columnWidth,
    required this.scrolls,
  });

  factory NastaleeqPrintedGrid.resolve(NastaleeqPrintedSpec spec, Size area) {
    final widthBound = area.width / spec.lineWidthEm;
    final fullSlot = area.height / spec.linesPerPage;
    final heightBound = fullSlot / spec.minSlotEm;
    if (heightBound < kNastaleeqMinPrintedFontSize &&
        heightBound < widthBound) {
      return NastaleeqPrintedGrid(
        fontSize: widthBound,
        slotHeight: widthBound * spec.minSlotEm,
        columnWidth: area.width,
        scrolls: true,
      );
    }
    final fontSize = math.min(widthBound, heightBound);
    return NastaleeqPrintedGrid(
      fontSize: fontSize,
      slotHeight: fullSlot,
      columnWidth: math.min(area.width, fontSize * spec.lineWidthEm),
      scrolls: false,
    );
  }

  String get cacheKey => '$fontSize:$columnWidth';
}
