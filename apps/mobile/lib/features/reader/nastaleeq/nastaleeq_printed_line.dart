import 'package:flutter/material.dart';

import 'nastaleeq_printed_fit.dart';
import 'nastaleeq_surah_header.dart';
import 'nastaleeq_text.dart';
import 'nastaleeq_typography.dart';
import 'nastaleeq_verse_text.dart';

class NastaleeqPrintedLine extends StatelessWidget {
  final NastaleeqLinePlan plan;
  final NastaleeqText text;
  final NastaleeqTypography typography;
  final TextHeightBehavior? heightBehavior;
  final Color textColor;
  final Color accent;
  final int? selectedVerseKey;
  final int? audioVerseKey;
  final void Function(int surah, int ayah) onVerseLongPress;

  const NastaleeqPrintedLine({
    super.key,
    required this.plan,
    required this.text,
    required this.typography,
    required this.heightBehavior,
    required this.textColor,
    required this.accent,
    required this.selectedVerseKey,
    required this.audioVerseKey,
    required this.onVerseLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return switch (plan) {
      NastaleeqVersesPlan(:final verses, :final fit) => Center(
        child: NastaleeqVerseText(
          verses: verses,
          style: fit.applyTo(typography.body(textColor)),
          strutStyle: typography.paragraphStrut,
          textAlign: TextAlign.center,
          textScaler: TextScaler.noScaling,
          highlightColor: accent,
          selectedVerseKey: selectedVerseKey,
          audioVerseKey: audioVerseKey,
          onVerseLongPress: onVerseLongPress,
        ),
      ),
      NastaleeqTitlePlan(:final chapter) => NastaleeqSurahHeader.slotted(
        title: text.title(chapter),
        style: typography.header(accent),
        heightBehavior: heightBehavior,
        accent: accent,
      ),
      NastaleeqBasmalaPlan() => NastaleeqBasmala.slotted(
        text: text.basmala,
        style: typography.basmala(textColor),
        heightBehavior: heightBehavior,
      ),
    };
  }
}
