import 'dart:async';
import 'package:flutter/material.dart';
import 'package:imad_flutter/imad_flutter.dart' show mushafGetIt, AudioRepository;
import 'package:qcf_quran_plus/qcf_quran_plus.dart';

class QcfMushafView extends StatefulWidget {
  final int initialPage;
  final ValueChanged<int>? onPageChanged;
  final VoidCallback? onTap;
  final void Function(int surah, int verse)? onVerseLongPress;
  final bool isDarkMode;
  final int? initialHighlightVerseKey; // surah * 1000 + verse

  const QcfMushafView({
    super.key,
    required this.initialPage,
    this.onPageChanged,
    this.onTap,
    this.onVerseLongPress,
    this.isDarkMode = false,
    this.initialHighlightVerseKey,
  });

  @override
  QcfMushafViewState createState() => QcfMushafViewState();
}

class QcfMushafViewState extends State<QcfMushafView> {
  late PageController _pageController;
  List<HighlightVerse> _highlights = [];
  late int _currentPage;
  StreamSubscription? _audioSub;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
    _pageController = PageController(
      initialPage: totalPagesCount - widget.initialPage,
    );

    // Set initial highlight if provided
    if (widget.initialHighlightVerseKey != null) {
      final surah = widget.initialHighlightVerseKey! ~/ 1000;
      final verse = widget.initialHighlightVerseKey! % 1000;
      _highlights = [
        HighlightVerse(
          surah: surah,
          verseNumber: verse,
          page: widget.initialPage,
          color: Colors.amber.withValues(alpha: 0.3),
        ),
      ];
    }

    // Listen to audio stream for verse highlighting
    _setupAudioHighlighting();
  }

  void _setupAudioHighlighting() {
    try {
      _audioSub = mushafGetIt<AudioRepository>()
          .getPlayerStateStream()
          .listen((state) {
        if (!mounted) return;
        if (state.currentChapter != null && state.currentVerse != null) {
          final page = getPageNumber(
            state.currentChapter!,
            state.currentVerse!,
          );
          setState(() {
            _highlights = [
              HighlightVerse(
                surah: state.currentChapter!,
                verseNumber: state.currentVerse!,
                page: page,
                color: Colors.blue.withValues(alpha: 0.3),
              ),
            ];
          });
        } else if (!state.isPlaying && _highlights.isNotEmpty) {
          setState(() => _highlights = []);
        }
      });
    } catch (_) {
      // AudioRepository may not be registered yet
    }
  }

  void goToPage(int page, {int? highlightVerseKey}) {
    final pageIndex = totalPagesCount - page;
    _pageController.jumpToPage(pageIndex);

    if (highlightVerseKey != null) {
      final surah = highlightVerseKey ~/ 1000;
      final verse = highlightVerseKey % 1000;
      setState(() {
        _highlights = [
          HighlightVerse(
            surah: surah,
            verseNumber: verse,
            page: page,
            color: Colors.amber.withValues(alpha: 0.3),
          ),
        ];
      });
    }
  }

  void _onPageChanged(int pageNumber) {
    setState(() => _currentPage = pageNumber);
    // Clear selection highlights on page change (keep audio highlights)
    if (_highlights.isNotEmpty &&
        _highlights.first.color == Colors.amber.withValues(alpha: 0.3)) {
      setState(() => _highlights = []);
    }
    // Preload nearby pages for smooth scrolling
    QcfFontLoader.preloadPages(pageNumber, radius: 3);
    widget.onPageChanged?.call(pageNumber);
  }

  @override
  void dispose() {
    _audioSub?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.isDarkMode
        ? const Color(0xFF0D0D0D)
        : const Color(0xFFFFF8E1);

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        color: bgColor,
        child: QuranPageView(
          pageController: _pageController,
          onPageChanged: _onPageChanged,
          highlights: _highlights,
          isDarkMode: widget.isDarkMode,
          isTajweed: true,
          pageBackgroundColor: bgColor,
          onLongPress: widget.onVerseLongPress != null
              ? (surah, verse, _) => widget.onVerseLongPress!(surah, verse)
              : null,
        ),
      ),
    );
  }
}
