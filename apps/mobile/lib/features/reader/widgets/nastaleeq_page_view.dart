import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:imad_flutter/imad_flutter.dart' as imad;
import 'package:quran/quran.dart' as quran;

const kNastaleeqTotalPages = 604;
const kNastaleeqFontFamily = 'KFGQPCNastaleeq';
const kNastaleeqBasmala = 'بِسمِ اللَّهِ الرَّحمنِ الرَّحيمِ';

const _kMinFontSize = 9.0;
const _kMaxFontSize = 40.0;
const _kJustifyMaxFontSize = 32.0;
const _kFitIterations = 16;
const _kFitSafety = 2.0;

const _kLineHeight = 2.3;
const _kBasmalaHeight = 2.1;
const _kHeaderHeight = 2.0;
const _kBasmalaRatio = 0.92;
const _kHeaderRatio = 0.85;

const _kPagePadding = EdgeInsets.symmetric(horizontal: 22, vertical: 16);
const _kParagraphGap = 6.0;
const _kBasmalaGap = 10.0;
const _kHeaderOuterV = 14.0;
const _kHeaderInnerV = 10.0;
const _kHeaderInnerH = 18.0;
const _kHeaderBorder = 1.2;

const _kHeaderChrome =
    _kHeaderOuterV * 2 + _kHeaderInnerV * 2 + _kHeaderBorder * 2;
const _kHeaderInset = _kHeaderInnerH * 2 + _kHeaderBorder * 2;
const _kMarkerRatio = 1.35;
const _kMarkerAlignment = PlaceholderAlignment.middle;

TextStyle _bodyStyle(TextStyle base, double fontSize, Color color) =>
    base.merge(
      TextStyle(
        fontFamily: kNastaleeqFontFamily,
        fontSize: fontSize,
        height: _kLineHeight,
        color: color,
      ),
    );

TextStyle _basmalaStyle(TextStyle base, double fontSize, Color color) =>
    base.merge(
      TextStyle(
        fontFamily: kNastaleeqFontFamily,
        fontSize: fontSize * _kBasmalaRatio,
        height: _kBasmalaHeight,
        color: color,
      ),
    );

TextStyle _headerStyle(TextStyle base, double fontSize, Color color) =>
    base.merge(
      TextStyle(
        fontFamily: kNastaleeqFontFamily,
        fontSize: fontSize * _kHeaderRatio,
        height: _kHeaderHeight,
        color: color,
      ),
    );

double _measureHeight(
  String text,
  TextStyle style,
  double maxWidth,
  TextScaler scaler,
  TextHeightBehavior? heightBehavior,
) {
  final painter = TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: TextDirection.rtl,
    textScaler: scaler,
    textHeightBehavior: heightBehavior,
    maxLines: null,
  )..layout(maxWidth: maxWidth);
  return painter.height;
}

double _measureParagraph(
  List<imad.PageVerseData> verses,
  TextStyle style,
  double markerSize,
  double maxWidth,
  TextScaler scaler,
  TextHeightBehavior? heightBehavior,
) {
  final spans = <InlineSpan>[];
  for (final verse in verses) {
    spans.add(TextSpan(text: '${verse.text} '));
    spans.add(
      const WidgetSpan(
        alignment: _kMarkerAlignment,
        child: SizedBox.shrink(),
      ),
    );
    spans.add(const TextSpan(text: ' '));
  }
  final painter = TextPainter(
    text: TextSpan(children: spans, style: style),
    textDirection: TextDirection.rtl,
    textScaler: scaler,
    textHeightBehavior: heightBehavior,
    maxLines: null,
  );
  painter.setPlaceholderDimensions(
    List.filled(
      verses.length,
      PlaceholderDimensions(
        size: Size(markerSize, markerSize),
        alignment: _kMarkerAlignment,
      ),
    ),
  );
  painter.layout(maxWidth: maxWidth);
  return painter.height;
}

class NastaleeqPageView extends StatefulWidget {
  final int? initialPage;
  final ValueChanged<int>? onPageChanged;
  final imad.ReadingTheme readingTheme;
  final Color? audioHighlightsColor;
  final VoidCallback? onTap;
  final void Function(int chapterNumber, int verseNumber)? onVerseLongPress;
  final int? initialSelectedVerseKey;

  const NastaleeqPageView({
    super.key,
    this.initialPage,
    this.onPageChanged,
    this.readingTheme = imad.ReadingTheme.light,
    this.audioHighlightsColor,
    this.onTap,
    this.onVerseLongPress,
    this.initialSelectedVerseKey,
  });

  @override
  State<NastaleeqPageView> createState() => NastaleeqPageViewState();
}

class NastaleeqPageViewState extends State<NastaleeqPageView> {
  PageController? _pageController;
  int _currentPage = 0;
  int? _selectedVerseKey;
  int? _currentAudioVerseKey;
  bool _preserveSelection = false;
  bool _ready = false;
  StreamSubscription? _audioSubscription;

  @override
  void initState() {
    super.initState();
    _selectedVerseKey = widget.initialSelectedVerseKey;
    _currentPage = (widget.initialPage ?? 1).clamp(1, kNastaleeqTotalPages);
    _pageController = PageController(
      initialPage: kNastaleeqTotalPages - _currentPage,
    );
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await imad.VerseDataProvider.instance.initialize();
    if (!mounted) return;
    setState(() => _ready = true);
    _listenToAudio();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onPageChanged?.call(_currentPage);
    });
  }

  void _listenToAudio() {
    try {
      _audioSubscription = imad
          .mushafGetIt<imad.AudioRepository>()
          .getPlayerStateStream()
          .listen((state) {
            if (!mounted) return;
            final chapter = state.currentChapter;
            final verse = state.currentVerse;
            if (chapter != null && verse != null && verse != 0) {
              final key = chapter * 1000 + verse;
              if (_currentAudioVerseKey != key) {
                setState(() => _currentAudioVerseKey = key);
              }
            } else if (!state.isPlaying && _currentAudioVerseKey != null) {
              setState(() => _currentAudioVerseKey = null);
            }
          });
    } catch (_) {}
  }

  @override
  void dispose() {
    _audioSubscription?.cancel();
    _pageController?.dispose();
    super.dispose();
  }

  void goToPage(int page, {int? highlightVerseKey}) {
    final clamped = page.clamp(1, kNastaleeqTotalPages);
    _preserveSelection = highlightVerseKey != null;
    setState(() {
      _currentPage = clamped;
      _selectedVerseKey = highlightVerseKey;
    });
    _pageController?.jumpToPage(kNastaleeqTotalPages - clamped);
    widget.onPageChanged?.call(clamped);
  }

  void _onPageChanged(int index) {
    final page = kNastaleeqTotalPages - index;
    setState(() {
      _currentPage = page;
      if (_preserveSelection) {
        _preserveSelection = false;
      } else {
        _selectedVerseKey = null;
      }
    });
    widget.onPageChanged?.call(page);
  }

  void _handleTap() {
    if (_selectedVerseKey != null) {
      setState(() => _selectedVerseKey = null);
    }
    widget.onTap?.call();
  }

  void _handleVerseLongPress(int surah, int ayah) {
    setState(() => _selectedVerseKey = surah * 1000 + ayah);
    widget.onVerseLongPress?.call(surah, ayah);
  }

  @override
  Widget build(BuildContext context) {
    final themeData = imad.ReadingThemeData.fromTheme(
      imad.MushafThemeScope.maybeOf(context)?.readingTheme ??
          widget.readingTheme,
    );

    if (!_ready) {
      return ColoredBox(
        color: themeData.backgroundColor,
        child: const Center(child: CircularProgressIndicator.adaptive()),
      );
    }

    return ColoredBox(
      color: themeData.backgroundColor,
      child: GestureDetector(
        onTap: _handleTap,
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: PageView.builder(
            controller: _pageController,
            itemCount: kNastaleeqTotalPages,
            onPageChanged: _onPageChanged,
            itemBuilder: (context, index) {
              final page = kNastaleeqTotalPages - index;
              return _NastaleeqPage(
                pageNumber: page,
                themeData: themeData,
                selectedVerseKey: page == _currentPage
                    ? _selectedVerseKey
                    : null,
                audioVerseKey: page == _currentPage
                    ? _currentAudioVerseKey
                    : null,
                audioHighlightColor: widget.audioHighlightsColor,
                onVerseLongPress: _handleVerseLongPress,
              );
            },
          ),
        ),
      ),
    );
  }
}

class _PageBlock {
  final List<imad.PageVerseData>? verses;
  final int? surahHeader;
  final bool basmala;

  const _PageBlock.paragraph(this.verses) : surahHeader = null, basmala = false;
  const _PageBlock.header(this.surahHeader) : verses = null, basmala = false;
  const _PageBlock.basmala()
    : verses = null,
      surahHeader = null,
      basmala = true;
}

List<_PageBlock> _buildBlocks(List<imad.PageVerseData> verses) {
  final blocks = <_PageBlock>[];
  var run = <imad.PageVerseData>[];

  void flush() {
    if (run.isEmpty) return;
    blocks.add(_PageBlock.paragraph(run));
    run = [];
  }

  for (final verse in verses) {
    if (verse.number == 1) {
      flush();
      blocks.add(_PageBlock.header(verse.chapter));
      if (verse.chapter != 1 && verse.chapter != 9) {
        blocks.add(const _PageBlock.basmala());
      }
    }
    run.add(verse);
  }
  flush();
  return blocks;
}

double _measurePage(
  List<_PageBlock> blocks,
  double fontSize,
  double maxWidth,
  TextScaler scaler,
  TextStyle base,
  TextHeightBehavior? heightBehavior,
) {
  const probe = Color(0xFF000000);
  var total = 0.0;
  for (final block in blocks) {
    if (block.verses != null) {
      total +=
          _measureParagraph(
            block.verses!,
            _bodyStyle(base, fontSize, probe),
            fontSize * _kMarkerRatio,
            maxWidth,
            scaler,
            heightBehavior,
          ) +
          _kParagraphGap;
    } else if (block.surahHeader != null) {
      total +=
          _measureHeight(
            quran.getSurahNameArabic(block.surahHeader!),
            _headerStyle(base, fontSize, probe),
            maxWidth - _kHeaderInset,
            scaler,
            heightBehavior,
          ) +
          _kHeaderChrome;
    } else {
      total +=
          _measureHeight(
            kNastaleeqBasmala,
            _basmalaStyle(base, fontSize, probe),
            maxWidth,
            scaler,
            heightBehavior,
          ) +
          _kBasmalaGap;
    }
  }
  return total;
}

double _fitFontSize(
  List<_PageBlock> blocks,
  double maxWidth,
  double maxHeight,
  TextScaler scaler,
  TextStyle base,
  TextHeightBehavior? heightBehavior,
) {
  if (maxWidth <= 0 || maxHeight <= 0) return _kMinFontSize;
  final budget = maxHeight - _kFitSafety;
  var low = _kMinFontSize;
  var high = _kMaxFontSize;
  if (_measurePage(blocks, high, maxWidth, scaler, base, heightBehavior) <=
      budget) {
    return high;
  }
  for (var i = 0; i < _kFitIterations; i++) {
    final mid = (low + high) / 2;
    if (_measurePage(blocks, mid, maxWidth, scaler, base, heightBehavior) <=
        budget) {
      low = mid;
    } else {
      high = mid;
    }
  }
  return low;
}

class _NastaleeqPage extends StatelessWidget {
  final int pageNumber;
  final imad.ReadingThemeData themeData;
  final int? selectedVerseKey;
  final int? audioVerseKey;
  final Color? audioHighlightColor;
  final void Function(int surah, int ayah) onVerseLongPress;

  const _NastaleeqPage({
    required this.pageNumber,
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

    final gold = audioHighlightColor ?? const Color(0xFFD4A843);
    final blocks = _buildBlocks(verses);
    final inset = MediaQuery.paddingOf(context);
    final padding = _kPagePadding.add(
      EdgeInsets.only(top: inset.top, bottom: inset.bottom),
    );

    final defaults = DefaultTextStyle.of(context);
    final base = defaults.style;
    final heightBehavior = defaults.textHeightBehavior;

    return LayoutBuilder(
      builder: (context, constraints) {
        final fontSize = _fitFontSize(
          blocks,
          constraints.maxWidth - padding.horizontal,
          constraints.maxHeight - padding.vertical,
          MediaQuery.textScalerOf(context),
          base,
          heightBehavior,
        );
        final justify = fontSize <= _kJustifyMaxFontSize;

        return Padding(
          padding: padding,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: constraints.maxWidth - padding.horizontal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final block in blocks)
                    if (block.verses != null)
                      _VerseParagraph(
                        key: ValueKey(
                          '$pageNumber:${block.verses!.first.chapter}:${block.verses!.first.number}',
                        ),
                        verses: block.verses!,
                        style: _bodyStyle(base, fontSize, themeData.textColor),
                        justify: justify,
                        markerSize: fontSize * _kMarkerRatio,
                        highlightColor: gold,
                        selectedVerseKey: selectedVerseKey,
                        audioVerseKey: audioVerseKey,
                        onVerseLongPress: onVerseLongPress,
                      )
                    else if (block.surahHeader != null)
                      _buildSurahHeader(
                        block.surahHeader!,
                        base,
                        fontSize,
                        gold,
                      )
                    else
                      _buildBasmala(base, fontSize),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSurahHeader(
    int surah,
    TextStyle base,
    double fontSize,
    Color gold,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: _kHeaderOuterV),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: _kHeaderInnerV,
          horizontal: _kHeaderInnerH,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: gold.withValues(alpha: 0.55),
            width: _kHeaderBorder,
          ),
          borderRadius: BorderRadius.circular(10),
          color: gold.withValues(alpha: 0.06),
        ),
        child: Text(
          quran.getSurahNameArabic(surah),
          textAlign: TextAlign.center,
          textDirection: TextDirection.rtl,
          style: _headerStyle(base, fontSize, gold),
        ),
      ),
    );
  }

  Widget _buildBasmala(TextStyle base, double fontSize) {
    return Padding(
      padding: const EdgeInsets.only(bottom: _kBasmalaGap),
      child: Text(
        kNastaleeqBasmala,
        textAlign: TextAlign.center,
        textDirection: TextDirection.rtl,
        style: _basmalaStyle(base, fontSize, themeData.textColor),
      ),
    );
  }
}

class _VerseParagraph extends StatefulWidget {
  final List<imad.PageVerseData> verses;
  final TextStyle style;
  final bool justify;
  final double markerSize;
  final Color highlightColor;
  final int? selectedVerseKey;
  final int? audioVerseKey;
  final void Function(int surah, int ayah) onVerseLongPress;

  const _VerseParagraph({
    super.key,
    required this.verses,
    required this.style,
    required this.justify,
    required this.markerSize,
    required this.highlightColor,
    required this.selectedVerseKey,
    required this.audioVerseKey,
    required this.onVerseLongPress,
  });

  @override
  State<_VerseParagraph> createState() => _VerseParagraphState();
}

class _VerseParagraphState extends State<_VerseParagraph> {
  final _paragraphKey = GlobalKey();
  final List<int> _boundaries = [];

  void _handleLongPress(LongPressStartDetails details) {
    final renderObject = _paragraphKey.currentContext?.findRenderObject();
    if (renderObject is! RenderParagraph) return;

    final local = renderObject.globalToLocal(details.globalPosition);
    final offset = renderObject.getPositionForOffset(local).offset;

    for (var i = 0; i < _boundaries.length; i++) {
      if (offset < _boundaries[i]) {
        final verse = widget.verses[i];
        widget.onVerseLongPress(verse.chapter, verse.number);
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _boundaries.clear();
    final spans = <InlineSpan>[];
    var cursor = 0;

    for (final verse in widget.verses) {
      cursor += verse.text.length + 3;
      _boundaries.add(cursor);

      final key = verse.chapter * 1000 + verse.number;
      final isPlaying = widget.audioVerseKey == key;
      final isSelected = widget.selectedVerseKey == key;
      final highlight = isPlaying
          ? widget.highlightColor.withValues(alpha: 0.22)
          : isSelected
          ? widget.highlightColor.withValues(alpha: 0.14)
          : null;

      spans.add(
        TextSpan(
          text: '${verse.text} ',
          style: TextStyle(backgroundColor: highlight),
        ),
      );
      spans.add(
        WidgetSpan(
          alignment: _kMarkerAlignment,
          child: imad.VerseFasel(
            number: verse.number,
            size: widget.markerSize,
            numberColor: widget.style.color,
          ),
        ),
      );
      spans.add(const TextSpan(text: ' '));
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: _kParagraphGap),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onLongPressStart: _handleLongPress,
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Text.rich(
            TextSpan(children: spans),
            key: _paragraphKey,
            textAlign: widget.justify ? TextAlign.justify : TextAlign.start,
            style: widget.style,
          ),
        ),
      ),
    );
  }
}
