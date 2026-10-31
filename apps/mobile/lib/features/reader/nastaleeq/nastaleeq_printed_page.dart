import 'package:flutter/material.dart';
import 'package:imad_flutter/imad_flutter.dart' as imad;

import 'nastaleeq_edition.dart';
import 'nastaleeq_layout.dart';
import 'nastaleeq_printed_fit.dart';
import 'nastaleeq_printed_grid.dart';
import 'nastaleeq_printed_layout.dart';
import 'nastaleeq_printed_line.dart';
import 'nastaleeq_text.dart';
import 'nastaleeq_typography.dart';

class NastaleeqPrintedPage extends StatelessWidget {
  final int pageNumber;
  final NastaleeqEdition edition;
  final NastaleeqPrintedSpec spec;
  final NastaleeqPrintedLayout layout;
  final NastaleeqText text;
  final imad.ReadingThemeData themeData;
  final int? selectedVerseKey;
  final int? audioVerseKey;
  final Color? audioHighlightColor;
  final void Function(int surah, int ayah) onVerseLongPress;

  const NastaleeqPrintedPage({
    super.key,
    required this.pageNumber,
    required this.edition,
    required this.spec,
    required this.layout,
    required this.text,
    required this.themeData,
    required this.selectedVerseKey,
    required this.audioVerseKey,
    required this.audioHighlightColor,
    required this.onVerseLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final accent = audioHighlightColor ?? kNastaleeqDefaultHighlight;
    final padding = nastaleeqPagePadding(context);
    final defaults = DefaultTextStyle.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final grid = NastaleeqPrintedGrid.resolve(
          spec,
          padding.deflateSize(constraints.biggest),
        );
        final typography = NastaleeqTypography(
          edition: edition,
          base: defaults.style,
          fontSize: grid.fontSize,
        );
        final plans = planNastaleeqPrintedPage(
          edition: edition,
          pageNumber: pageNumber,
          layout: layout,
          text: text,
          typography: typography,
          grid: grid,
        );
        final column = Column(
          mainAxisAlignment: isNastaleeqOpeningPage(pageNumber)
              ? MainAxisAlignment.center
              : MainAxisAlignment.start,
          children: [
            for (final plan in plans)
              SizedBox(
                width: grid.columnWidth,
                height: grid.slotHeight,
                child: NastaleeqPrintedLine(
                  plan: plan,
                  text: text,
                  typography: typography,
                  heightBehavior: defaults.textHeightBehavior,
                  textColor: themeData.textColor,
                  accent: accent,
                  selectedVerseKey: selectedVerseKey,
                  audioVerseKey: audioVerseKey,
                  onVerseLongPress: onVerseLongPress,
                ),
              ),
          ],
        );

        return grid.scrolls
            ? SingleChildScrollView(
                padding: padding,
                child: Center(child: column),
              )
            : Padding(
                padding: padding,
                child: Center(child: column),
              );
      },
    );
  }
}
