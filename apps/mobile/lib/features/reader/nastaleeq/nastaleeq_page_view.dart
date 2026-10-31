import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:imad_flutter/imad_flutter.dart' as imad;
import 'package:quran/quran.dart' as quran;

import 'nastaleeq_edition.dart';
import 'nastaleeq_layout.dart';
import 'nastaleeq_load_error.dart';
import 'nastaleeq_page.dart';
import 'nastaleeq_page_map.dart';
import 'nastaleeq_pager.dart';
import 'nastaleeq_printed_page.dart';
import 'nastaleeq_text.dart';
import 'nastaleeq_text_provider.dart';

class NastaleeqPageView extends ConsumerStatefulWidget {
  final NastaleeqEdition edition;
  final int? initialPage;
  final int? initialVerseKey;
  final ValueChanged<int>? onPageChanged;
  final imad.ReadingTheme readingTheme;
  final Color? audioHighlightsColor;
  final VoidCallback? onTap;
  final void Function(int chapterNumber, int verseNumber)? onVerseLongPress;
  final int? initialSelectedVerseKey;

  const NastaleeqPageView({
    super.key,
    required this.edition,
    this.initialPage,
    this.initialVerseKey,
    this.onPageChanged,
    this.readingTheme = imad.ReadingTheme.light,
    this.audioHighlightsColor,
    this.onTap,
    this.onVerseLongPress,
    this.initialSelectedVerseKey,
  });

  @override
  ConsumerState<NastaleeqPageView> createState() => NastaleeqPageViewState();
}

class NastaleeqPageViewState extends ConsumerState<NastaleeqPageView> {
  var _pagerKey = GlobalKey<NastaleeqPagerState>();
  late int _anchorVerseKey = _initialAnchorVerseKey();
  late int? _selectedVerseKey = widget.initialSelectedVerseKey;
  int? _currentAudioVerseKey;
  bool _ready = false;
  StreamSubscription<imad.AudioPlayerState>? _audioSubscription;

  int get anchorVerseKey => _anchorVerseKey;

  int? get currentPage => _pagerKey.currentState?.currentPage;

  int? get pageCount => _pagerKey.currentState?.pageMap.pageCount;

  int _initialAnchorVerseKey() {
    final page = (widget.initialPage ?? 1).clamp(1, quran.totalPagesCount);
    final verseKey = widget.initialVerseKey;
    final verseOnPage =
        verseKey != null &&
        quran.getPageNumber(
              nastaleeqVerseChapter(verseKey),
              nastaleeqVerseNumber(verseKey),
            ) ==
            page;
    return verseOnPage ? verseKey : nastaleeqMadinahPageStart(page);
  }

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void didUpdateWidget(NastaleeqPageView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.edition != widget.edition) {
      _pagerKey = GlobalKey<NastaleeqPagerState>();
    }
  }

  Future<void> _bootstrap() async {
    await imad.VerseDataProvider.instance.initialize();
    if (!mounted) return;
    setState(() => _ready = true);
    _listenToAudio();
  }

  void _listenToAudio() {
    if (!imad.mushafGetIt.isRegistered<imad.AudioRepository>()) return;
    _audioSubscription = imad
        .mushafGetIt<imad.AudioRepository>()
        .getPlayerStateStream()
        .listen(_onAudioState);
  }

  void _onAudioState(imad.AudioPlayerState state) {
    if (!mounted) return;
    final chapter = state.currentChapter;
    final verse = state.currentVerse;
    if (chapter != null && verse != null && verse != 0) {
      final key = nastaleeqVerseKey(chapter, verse);
      if (_currentAudioVerseKey != key) {
        setState(() => _currentAudioVerseKey = key);
      }
    } else if (!state.isPlaying && _currentAudioVerseKey != null) {
      setState(() => _currentAudioVerseKey = null);
    }
  }

  @override
  void dispose() {
    _audioSubscription?.cancel();
    super.dispose();
  }

  void goToPage(int page, {int? highlightVerseKey, int? targetVerseKey}) {
    setState(() => _selectedVerseKey = highlightVerseKey);
    final verseKey = highlightVerseKey ?? targetVerseKey;
    final pager = _pagerKey.currentState;
    if (verseKey != null) {
      _anchorVerseKey = verseKey;
      pager?.jumpTo(pager.pageMap.pageOfVerse(verseKey));
      return;
    }
    if (pager == null) {
      _anchorVerseKey = nastaleeqMadinahPageStart(
        page.clamp(1, quran.totalPagesCount),
      );
      return;
    }
    pager.jumpTo(
      pager.pageMap.pageForMadinahPage(page, currentPage: pager.currentPage),
    );
  }

  void openPage(int page) => _pagerKey.currentState?.jumpTo(page);

  bool showsVerse(int verseKey) {
    final pager = _pagerKey.currentState;
    return pager != null &&
        pager.pageMap.showsVerse(pager.currentPage, verseKey);
  }

  void revealVerse(int verseKey) {
    final pager = _pagerKey.currentState;
    if (pager != null &&
        pager.pageMap.showsVerse(pager.currentPage, verseKey)) {
      return;
    }
    _anchorVerseKey = verseKey;
    pager?.jumpTo(pager.pageMap.pageOfVerse(verseKey));
  }

  void _onPageTurn(NastaleeqPageMap pageMap, int page, NastaleeqPageTurn turn) {
    final swiped = turn == NastaleeqPageTurn.swipe;
    _anchorVerseKey = swiped
        ? pageMap.anchorVerseOf(page)
        : pageMap.keepAnchor(page, _anchorVerseKey);
    if (swiped && _selectedVerseKey != null) {
      setState(() => _selectedVerseKey = null);
    }
    widget.onPageChanged?.call(
      NastaleeqPageMap.madinah.pageOfVerse(_anchorVerseKey),
    );
  }

  void _handleTap() {
    if (_selectedVerseKey != null) {
      setState(() => _selectedVerseKey = null);
    }
    widget.onTap?.call();
  }

  void _handleVerseLongPress(int surah, int ayah) {
    setState(() => _selectedVerseKey = nastaleeqVerseKey(surah, ayah));
    widget.onVerseLongPress?.call(surah, ayah);
  }

  @override
  Widget build(BuildContext context) {
    final themeData = imad.ReadingThemeData.fromTheme(
      imad.MushafThemeScope.maybeOf(context)?.readingTheme ??
          widget.readingTheme,
    );
    final textProvider = nastaleeqTextProvider(widget.edition);
    ref.listen(textProvider, _reportLoadError);
    final text = ref.watch(textProvider);

    return ColoredBox(
      color: themeData.backgroundColor,
      child: switch (text) {
        AsyncData(:final value) when _ready => _buildPages(value, themeData),
        AsyncError() => NastaleeqLoadError(
          themeData: themeData,
          onRetry: () => ref.invalidate(textProvider),
        ),
        _ => const Center(child: CircularProgressIndicator.adaptive()),
      },
    );
  }

  void _reportLoadError(
    AsyncValue<NastaleeqText>? previous,
    AsyncValue<NastaleeqText> next,
  ) {
    if (next case AsyncError(:final error, :final stackTrace)) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'nastaleeq reader',
        ),
      );
    }
  }

  Widget _buildPages(NastaleeqText text, imad.ReadingThemeData themeData) {
    final pageMap = text.pageMap;
    return GestureDetector(
      onTap: _handleTap,
      child: NastaleeqPager(
        key: _pagerKey,
        pageMap: pageMap,
        initialPage: pageMap.pageOfVerse(_anchorVerseKey),
        onPageTurn: (page, turn) => _onPageTurn(pageMap, page, turn),
        pageBuilder: (context, page, isCurrent) =>
            _buildPage(text, themeData, page, isCurrent),
      ),
    );
  }

  Widget _buildPage(
    NastaleeqText text,
    imad.ReadingThemeData themeData,
    int page,
    bool isCurrent,
  ) {
    final selectedVerseKey = isCurrent ? _selectedVerseKey : null;
    final audioVerseKey = isCurrent ? _currentAudioVerseKey : null;
    return switch ((widget.edition.layout, text.printedLayout)) {
      (final NastaleeqPrintedSpec spec, final layout?) => NastaleeqPrintedPage(
        pageNumber: page,
        edition: widget.edition,
        spec: spec,
        layout: layout,
        text: text,
        themeData: themeData,
        selectedVerseKey: selectedVerseKey,
        audioVerseKey: audioVerseKey,
        audioHighlightColor: widget.audioHighlightsColor,
        onVerseLongPress: _handleVerseLongPress,
      ),
      _ => NastaleeqPage(
        pageNumber: page,
        edition: widget.edition,
        text: text,
        themeData: themeData,
        selectedVerseKey: selectedVerseKey,
        audioVerseKey: audioVerseKey,
        audioHighlightColor: widget.audioHighlightsColor,
        onVerseLongPress: _handleVerseLongPress,
      ),
    };
  }
}
