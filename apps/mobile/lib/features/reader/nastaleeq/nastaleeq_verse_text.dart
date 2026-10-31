import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'nastaleeq_page_blocks.dart';
import 'nastaleeq_typography.dart';

class NastaleeqVerseText extends StatefulWidget {
  final List<NastaleeqVerseSpan> verses;
  final TextStyle style;
  final StrutStyle strutStyle;
  final TextAlign textAlign;
  final bool softWrap;
  final TextScaler? textScaler;
  final Color highlightColor;
  final int? selectedVerseKey;
  final int? audioVerseKey;
  final void Function(int surah, int ayah) onVerseLongPress;

  const NastaleeqVerseText({
    super.key,
    required this.verses,
    required this.style,
    required this.strutStyle,
    required this.textAlign,
    required this.highlightColor,
    required this.selectedVerseKey,
    required this.audioVerseKey,
    required this.onVerseLongPress,
    this.softWrap = true,
    this.textScaler,
  });

  @override
  State<NastaleeqVerseText> createState() => _NastaleeqVerseTextState();
}

class _NastaleeqVerseTextState extends State<NastaleeqVerseText> {
  final _paragraphKey = GlobalKey();
  late List<int> _boundaries = nastaleeqVerseBoundaries(widget.verses);

  @override
  void didUpdateWidget(NastaleeqVerseText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.verses, widget.verses)) {
      _boundaries = nastaleeqVerseBoundaries(widget.verses);
    }
  }

  Color? _highlightFor(int verseKey) {
    if (widget.audioVerseKey == verseKey) {
      return widget.highlightColor.withValues(alpha: 0.22);
    }
    if (widget.selectedVerseKey == verseKey) {
      return widget.highlightColor.withValues(alpha: 0.14);
    }
    return null;
  }

  void _handleLongPress(LongPressStartDetails details) {
    final renderObject = _paragraphKey.currentContext?.findRenderObject();
    if (renderObject is! RenderParagraph) return;

    final local = renderObject.globalToLocal(details.globalPosition);
    final offset = renderObject.getPositionForOffset(local).offset;
    final index = _boundaries.indexWhere((boundary) => offset < boundary);
    final verse = widget.verses[index < 0 ? widget.verses.length - 1 : index];
    widget.onVerseLongPress(verse.chapter, verse.number);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onLongPressStart: _handleLongPress,
      child: Text.rich(
        buildNastaleeqParagraphSpan(
          widget.verses,
          widget.style,
          highlightFor: _highlightFor,
        ),
        key: _paragraphKey,
        textDirection: TextDirection.rtl,
        textAlign: widget.textAlign,
        softWrap: widget.softWrap,
        textScaler: widget.textScaler,
        textHeightBehavior: kNastaleeqParagraphHeightBehavior,
        strutStyle: widget.strutStyle,
      ),
    );
  }
}
