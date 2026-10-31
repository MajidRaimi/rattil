import 'package:flutter/material.dart';

import 'nastaleeq_layout.dart';
import 'nastaleeq_page_blocks.dart';
import 'nastaleeq_typography.dart';
import 'nastaleeq_verse_text.dart';

class NastaleeqVerseParagraph extends StatelessWidget {
  final List<NastaleeqVerseSpan> verses;
  final NastaleeqTypography typography;
  final Color textColor;
  final TextAlign textAlign;
  final Color highlightColor;
  final int? selectedVerseKey;
  final int? audioVerseKey;
  final void Function(int surah, int ayah) onVerseLongPress;

  const NastaleeqVerseParagraph({
    super.key,
    required this.verses,
    required this.typography,
    required this.textColor,
    required this.textAlign,
    required this.highlightColor,
    required this.selectedVerseKey,
    required this.audioVerseKey,
    required this.onVerseLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: kNastaleeqParagraphGap),
      child: NastaleeqVerseText(
        verses: verses,
        style: typography.body(textColor),
        strutStyle: typography.paragraphStrut,
        textAlign: textAlign,
        highlightColor: highlightColor,
        selectedVerseKey: selectedVerseKey,
        audioVerseKey: audioVerseKey,
        onVerseLongPress: onVerseLongPress,
      ),
    );
  }
}
