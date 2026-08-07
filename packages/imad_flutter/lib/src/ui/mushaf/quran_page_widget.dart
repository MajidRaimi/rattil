import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../data/quran/quran_data_provider.dart';
import '../../data/quran/quran_metadata.dart';
import '../../data/quran/verse_data_provider.dart';
import '../theme/reading_theme.dart';
import 'quran_line_image.dart';

/// Renders a single Quran page — 15 line images with a minimal header.
class QuranPageWidget extends StatefulWidget {
  final int pageNumber;
  final int? selectedVerseKey;
  final int? audioVerseKey;
  final Color? audioHighlightsColor;
  final void Function(int chapterNumber, int verseNumber)? onVerseTap;
  final void Function(int chapterNumber, int verseNumber)? onVerseLongPress;
  final ReadingThemeData? themeData;

  const QuranPageWidget({
    super.key,
    required this.pageNumber,
    this.selectedVerseKey,
    this.audioVerseKey,
    this.audioHighlightsColor,
    this.onVerseTap,
    this.onVerseLongPress,
    this.themeData,
  });

  @override
  State<QuranPageWidget> createState() => _QuranPageWidgetState();
}

class _QuranPageWidgetState extends State<QuranPageWidget> {
  late final QuranDataProvider _dataProvider;
  late List<ChapterData> _chapters;
  late int _juz;

  @override
  void initState() {
    super.initState();
    _dataProvider = QuranDataProvider.instance;
    _updatePageData();
  }

  @override
  void didUpdateWidget(covariant QuranPageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pageNumber != widget.pageNumber) {
      _updatePageData();
    }
  }

  void _updatePageData() {
    _chapters = _dataProvider.getChaptersForPage(widget.pageNumber);
    _juz = _dataProvider.getJuzForPage(widget.pageNumber);
  }

  static const _openingPageNameLines = <int, int>{1: 4, 2: 4};

  static const double _landscapeLineCrop = 0.80;

  Set<int> _surahHeaderLines(List<PageVerseData> pageVerses) {
    final headers = <int>{};
    if (pageVerses.isEmpty) return headers;

    for (final chapter in _chapters) {
      if (chapter.startPage != widget.pageNumber) continue;

      final overrideLine = _openingPageNameLines[widget.pageNumber];
      if (overrideLine != null) {
        headers.add(overrideLine);
        continue;
      }

      PageVerseData? opening;
      for (final verse in pageVerses) {
        if (verse.chapter == chapter.number && verse.number == 1) {
          opening = verse;
          break;
        }
      }
      if (opening == null || opening.highlights1441.isEmpty) continue;

      var firstLine = opening.highlights1441.first.line;
      for (final highlight in opening.highlights1441) {
        if (highlight.line < firstLine) firstLine = highlight.line;
      }

      final run = <int>[];
      var line = firstLine - 1;
      while (line >= 1 && !pageVerses.any((v) => v.occupiesLine(line))) {
        run.insert(0, line);
        line--;
        if (run.length > 2) break;
      }
      if (run.isNotEmpty && run.length <= 2) headers.add(run.first);
    }
    return headers;
  }

  @override
  Widget build(BuildContext context) {
    final verseProvider = VerseDataProvider.instance;
    final pageVerses = verseProvider.getVersesForPage(widget.pageNumber);
    final theme =
        widget.themeData ?? ReadingThemeData.fromTheme(ReadingTheme.light);

    final isDark = theme.backgroundColor.computeLuminance() < 0.3;
    final gold = isDark ? const Color(0xFFD4A843) : const Color(0xFF8B6914);
    final headerLines = _surahHeaderLines(pageVerses);

    final chapterName = _chapters.isNotEmpty
        ? _chapters.map((c) => c.arabicTitle).join(' \u06DE ')
        : '';

    return Container(
      color: theme.backgroundColor,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final lines = List.generate(
                      15,
                      (index) => _buildLine(
                        index + 1,
                        pageVerses,
                        headerLines,
                        theme,
                        gold,
                      ),
                    );

                    if (constraints.maxWidth <= constraints.maxHeight) {
                      return Column(
                        children: [
                          for (final line in lines) Expanded(child: line),
                        ],
                      );
                    }

                    final slotHeight = constraints.maxWidth /
                        QuranLineImage.aspectRatio *
                        _landscapeLineCrop;

                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          for (final line in lines)
                            SizedBox(height: slotHeight, child: line),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),

            SafeArea(
              top: false,
              child: const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLine(
    int line,
    List<PageVerseData> pageVerses,
    Set<int> headerLines,
    ReadingThemeData theme,
    Color gold,
  ) {
    final markers = pageVerses
        .where((v) => v.marker1441 != null && v.marker1441!.line == line)
        .toList();

    final versesOnLine = pageVerses.where((v) => v.occupiesLine(line)).toList();

    final selectionHighlights = <VerseHighlightData>[];
    if (widget.selectedVerseKey != null) {
      final selectedVerse = versesOnLine
          .where((v) => v.chapter * 1000 + v.number == widget.selectedVerseKey)
          .firstOrNull;
      if (selectedVerse != null) {
        selectionHighlights.addAll(
          selectedVerse.highlights1441.where((h) => h.line == line),
        );
      }
    }

    final audioHighlights = <VerseHighlightData>[];
    if (widget.audioVerseKey != null) {
      final audioVerse = versesOnLine
          .where((v) => v.chapter * 1000 + v.number == widget.audioVerseKey)
          .firstOrNull;
      if (audioVerse != null) {
        audioHighlights.addAll(
          audioVerse.highlights1441.where((h) => h.line == line),
        );
      }
    }

    return QuranLineImage(
      page: widget.pageNumber,
      line: line,
      audioHighlights: audioHighlights,
      audioHighlightsColor: widget.audioHighlightsColor,
      selectionHighlights: selectionHighlights,
      markers: markers,
      highlightColor: theme.highlightColor,
      textColor: theme.textColor,
      isSurahHeader: headerLines.contains(line),
      frameColor: gold,
      onTapUpExact: widget.onVerseTap == null
          ? null
          : (tapRatio) {
              final target = _verseAtRatio(versesOnLine, markers, line, tapRatio);
              if (target == null) return;
              if (kDebugMode) {
                print(
                  "Calling onVerseTap with chapter: ${target.chapter}, verse: ${target.number}",
                );
              }
              widget.onVerseTap!(target.chapter, target.number);
            },
      onLongPressExact: widget.onVerseLongPress == null
          ? null
          : (tapRatio) {
              final target = _verseAtRatio(versesOnLine, markers, line, tapRatio);
              if (target == null) return;
              widget.onVerseLongPress!(target.chapter, target.number);
            },
    );
  }

  PageVerseData? _verseAtRatio(
    List<PageVerseData> versesOnLine,
    List<PageVerseData> markers,
    int line,
    double tapRatio,
  ) {
    if (versesOnLine.isEmpty) return null;

    for (final verse in versesOnLine) {
      for (final h in verse.highlights1441.where((h) => h.line == line)) {
        if (tapRatio >= h.left && tapRatio <= h.right) return verse;
      }
    }

    return markers.isNotEmpty ? markers.last : versesOnLine.last;
  }
}
