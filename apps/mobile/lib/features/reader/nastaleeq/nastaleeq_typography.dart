import 'package:flutter/painting.dart';

import 'nastaleeq_edition.dart';
import 'nastaleeq_page_blocks.dart';

const kNastaleeqBasmalaRatio = 0.92;
const kNastaleeqHeaderRatio = 0.85;

const kNastaleeqParagraphHeightBehavior = TextHeightBehavior(
  applyHeightToFirstAscent: true,
  applyHeightToLastDescent: true,
  leadingDistribution: TextLeadingDistribution.proportional,
);

class NastaleeqTypography {
  final NastaleeqEdition edition;
  final TextStyle base;
  final double fontSize;

  const NastaleeqTypography({
    required this.edition,
    required this.base,
    required this.fontSize,
  });

  TextStyle body(Color color) => base.merge(
    TextStyle(
      fontFamily: edition.fontFamily,
      fontSize: fontSize,
      height: edition.lineHeight,
      fontFeatures: const [],
      letterSpacing: 0,
      wordSpacing: 0,
      color: color,
    ),
  );

  TextStyle basmala(Color color) => base.merge(
    TextStyle(
      fontFamily: edition.fontFamily,
      fontSize: fontSize * kNastaleeqBasmalaRatio,
      height: edition.basmalaHeight,
      fontFeatures: edition.basmalaFeatures,
      letterSpacing: 0,
      wordSpacing: 0,
      color: color,
    ),
  );

  TextStyle header(Color color) => base.merge(
    TextStyle(
      fontFamily: edition.fontFamily,
      fontSize: fontSize * kNastaleeqHeaderRatio,
      height: edition.headerHeight,
      fontFeatures: const [],
      letterSpacing: 0,
      wordSpacing: 0,
      color: color,
    ),
  );

  StrutStyle get paragraphStrut => StrutStyle(
    fontFamily: edition.fontFamily,
    fontSize: fontSize,
    height: edition.lineHeight,
    leading: 0,
    forceStrutHeight: true,
  );
}

TextSpan buildNastaleeqParagraphSpan(
  List<NastaleeqVerseSpan> verses,
  TextStyle style, {
  Color? Function(int verseKey)? highlightFor,
}) {
  return TextSpan(
    style: style,
    children: [
      for (final verse in verses)
        TextSpan(
          text: verse.text,
          style: TextStyle(backgroundColor: highlightFor?.call(verse.key)),
        ),
    ],
  );
}

List<int> nastaleeqVerseBoundaries(List<NastaleeqVerseSpan> verses) {
  final boundaries = <int>[];
  var cursor = 0;
  for (final verse in verses) {
    cursor += verse.text.length;
    boundaries.add(cursor);
  }
  return boundaries;
}
