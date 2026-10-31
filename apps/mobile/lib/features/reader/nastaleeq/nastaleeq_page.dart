import 'package:flutter/material.dart';
import 'package:imad_flutter/imad_flutter.dart' as imad;

import 'nastaleeq_edition.dart';
import 'nastaleeq_page_blocks.dart';
import 'nastaleeq_layout.dart';
import 'nastaleeq_page_fit.dart';
import 'nastaleeq_surah_header.dart';
import 'nastaleeq_text.dart';
import 'nastaleeq_typography.dart';
import 'nastaleeq_verse_paragraph.dart';

class NastaleeqPage extends StatelessWidget {
  final int pageNumber;
  final NastaleeqEdition edition;
  final NastaleeqText text;
  final imad.ReadingThemeData themeData;
  final int? selectedVerseKey;
  final int? audioVerseKey;
  final Color? audioHighlightColor;
  final void Function(int surah, int ayah) onVerseLongPress;

  const NastaleeqPage({
    super.key,
    required this.pageNumber,
    required this.edition,
    required this.text,
    required this.themeData,
    required this.selectedVerseKey,
    required this.audioVerseKey,
    required this.audioHighlightColor,
    required this.onVerseLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final verses = imad.VerseDataProvider.instance.getVersesForPage(pageNumber);
    if (verses.isEmpty) return const SizedBox.shrink();

    final gold = audioHighlightColor ?? kNastaleeqDefaultHighlight;
    final blocks = buildNastaleeqPageBlocks(verses, text);
    final padding = nastaleeqPagePadding(context);
    final scaler = MediaQuery.textScalerOf(context);
    final defaults = DefaultTextStyle.of(context);
    final isOpeningPage = isNastaleeqOpeningPage(pageNumber);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth - padding.horizontal;
        final fontSize = fitNastaleeqFontSize(
          NastaleeqFitRequest(
            pageNumber: pageNumber,
            edition: edition,
            blocks: blocks,
            maxWidth: width,
            maxHeight: constraints.maxHeight - padding.vertical,
            scaler: scaler,
            base: defaults.style,
            heightBehavior: defaults.textHeightBehavior,
          ),
        );
        final typography = NastaleeqTypography(
          edition: edition,
          base: defaults.style,
          fontSize: fontSize,
        );

        return Padding(
          padding: padding,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: isOpeningPage ? Alignment.center : Alignment.topCenter,
            child: SizedBox(
              width: width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final block in blocks)
                    switch (block) {
                      NastaleeqVerseBlock(:final verses) =>
                        NastaleeqVerseParagraph(
                          key: ValueKey(
                            '${edition.name}:$pageNumber:${verses.first.key}',
                          ),
                          verses: verses,
                          typography: typography,
                          textColor: themeData.textColor,
                          textAlign: isOpeningPage
                              ? TextAlign.center
                              : TextAlign.justify,
                          highlightColor: gold,
                          selectedVerseKey: selectedVerseKey,
                          audioVerseKey: audioVerseKey,
                          onVerseLongPress: onVerseLongPress,
                        ),
                      NastaleeqHeaderBlock(:final title) =>
                        NastaleeqSurahHeader(
                          title: title,
                          style: typography.header(gold),
                          heightBehavior: defaults.textHeightBehavior,
                          accent: gold,
                        ),
                      NastaleeqBasmalaBlock(:final text) => NastaleeqBasmala(
                        text: text,
                        style: typography.basmala(themeData.textColor),
                        heightBehavior: defaults.textHeightBehavior,
                      ),
                    },
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
