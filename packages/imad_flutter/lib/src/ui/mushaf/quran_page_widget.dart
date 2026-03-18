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

  @override
  Widget build(BuildContext context) {
    final verseProvider = VerseDataProvider.instance;
    final pageVerses = verseProvider.getVersesForPage(widget.pageNumber);
    final theme =
        widget.themeData ?? ReadingThemeData.fromTheme(ReadingTheme.light);

    final isDark = theme.backgroundColor.computeLuminance() < 0.3;
    final gold = isDark ? const Color(0xFFD4A843) : const Color(0xFF8B6914);

    final chapterName = _chapters.isNotEmpty
        ? _chapters.map((c) => c.arabicTitle).join(' \u06DE ')
        : '';

    return Container(
      color: theme.backgroundColor,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── 15 line images ──
            Expanded(
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Column(
                    children: List.generate(15, (index) {
                      final line = index + 1;

                      final markers = pageVerses
                          .where(
                            (v) =>
                                v.marker1441 != null &&
                                v.marker1441!.line == line,
                          )
                          .toList();

                      final versesOnLine = pageVerses
                          .where((v) => v.occupiesLine(line))
                          .toList();

                      final selectionHighlights = <VerseHighlightData>[];
                      if (widget.selectedVerseKey != null) {
                        final selectedVerse = versesOnLine
                            .where(
                              (v) =>
                                  v.chapter * 1000 + v.number ==
                                  widget.selectedVerseKey,
                            )
                            .firstOrNull;
                        if (selectedVerse != null) {
                          selectionHighlights.addAll(
                            selectedVerse.highlights1441
                                .where((h) => h.line == line),
                          );
                        }
                      }

                      final audioHighlights = <VerseHighlightData>[];
                      if (widget.audioVerseKey != null) {
                        final audioVerse = versesOnLine
                            .where(
                              (v) =>
                                  v.chapter * 1000 + v.number ==
                                  widget.audioVerseKey,
                            )
                            .firstOrNull;
                        if (audioVerse != null) {
                          audioHighlights.addAll(
                            audioVerse.highlights1441
                                .where((h) => h.line == line),
                          );
                        }
                      }

                      return Expanded(
                        child: QuranLineImage(
                          page: widget.pageNumber,
                          line: line,
                          audioHighlights: audioHighlights,
                          audioHighlightsColor: widget.audioHighlightsColor,
                          selectionHighlights: selectionHighlights,
                          markers: markers,
                          highlightColor: theme.highlightColor,
                          textColor: theme.textColor,
                          onTapUpExact: widget.onVerseTap == null
                              ? null
                              : (tapRatio) {
                                  if (versesOnLine.isEmpty) return;

                                  PageVerseData? target;
                                  for (final verse in versesOnLine) {
                                    final hList = verse.highlights1441
                                        .where((h) => h.line == line);
                                    for (final h in hList) {
                                      if (tapRatio >= h.left &&
                                          tapRatio <= h.right) {
                                        target = verse;
                                        break;
                                      }
                                    }
                                    if (target != null) break;
                                  }

                                  target ??= markers.isNotEmpty
                                      ? markers.last
                                      : versesOnLine.last;

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
                                  if (versesOnLine.isEmpty) return;

                                  PageVerseData? target;
                                  for (final verse in versesOnLine) {
                                    final hList = verse.highlights1441
                                        .where((h) => h.line == line);
                                    for (final h in hList) {
                                      if (tapRatio >= h.left &&
                                          tapRatio <= h.right) {
                                        target = verse;
                                        break;
                                      }
                                    }
                                    if (target != null) break;
                                  }

                                  target ??= markers.isNotEmpty
                                      ? markers.last
                                      : versesOnLine.last;

                                  widget.onVerseLongPress!(
                                      target.chapter, target.number);
                                },
                        ),
                      );
                    }),
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
}
