import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_locales/flutter_locales.dart';
import '../../core/utils/ordinal_formatter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:imad_flutter/imad_flutter.dart' as imad;
import 'package:quran/quran.dart' as quran;
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../../core/theme/typography_ext.dart';
import '../../data/models/ayah.dart';
import '../../providers/quran_providers.dart';
import '../bookmarks/widgets/save_to_collection_sheet.dart';
import 'widgets/page_picker_sheet.dart';
import 'widgets/surah_picker_sheet.dart';
import 'widgets/juz_picker_sheet.dart';
import 'widgets/hizb_picker_sheet.dart';

/// Direct surah reader — opened from search results or bookmarks.
class ReaderScreen extends ConsumerStatefulWidget {
  final int surahNumber;
  final int initialAyah;
  final bool highlightInitialAyah;

  const ReaderScreen({
    super.key,
    required this.surahNumber,
    this.initialAyah = 1,
    this.highlightInitialAyah = false,
  });

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  late int _currentPage;
  bool _translationMode = false;
  int _currentJuz = 1;
  int _currentHizb = 1;

  final _mushafPageKey = GlobalKey<imad.MushafPageViewState>();

  final ItemScrollController _scrollController = ItemScrollController();
  final ItemPositionsListener _positionsListener =
      ItemPositionsListener.create();

  bool get _hasBismillah =>
      widget.surahNumber != 1 && widget.surahNumber != 9;

  @override
  void initState() {
    super.initState();
    _currentPage =
        quran.getPageNumber(widget.surahNumber, widget.initialAyah);
    _loadPageMetadata(_currentPage);
    _positionsListener.itemPositions.addListener(_onTranslationScroll);
  }

  Future<void> _loadPageMetadata(int page) async {
    final meta = await ref.read(quranRepositoryProvider).getPageMetadata(page);
    if (mounted) {
      setState(() {
        _currentJuz = meta['juz']!;
        _currentHizb = meta['hizb']!;
      });
    }
  }

  String get _currentSurahName {
    final pageData = quran.getPageData(_currentPage);
    if (pageData.isEmpty) return '';
    final surahNum = pageData.first['surah'] as int;
    final locale = Locales.currentLocale(context)?.languageCode ?? 'en';
    final prefix = Locales.string(context, 'surah_prefix');
    if (locale == 'ar') return '$prefix ${quran.getSurahNameArabic(surahNum)}';
    return '$prefix ${quran.getSurahName(surahNum)}';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
    ));
  }

  @override
  void dispose() {
    _positionsListener.itemPositions.removeListener(_onTranslationScroll);
    super.dispose();
  }

  void _onTranslationScroll() {
    final positions = _positionsListener.itemPositions.value;
    if (positions.isEmpty) return;
    final first = positions
        .where((p) => p.itemTrailingEdge > 0)
        .reduce((a, b) => a.index < b.index ? a : b);
    final ayahNumber = _hasBismillah ? first.index : first.index + 1;
    if (ayahNumber > 0) {
      ref
          .read(quranRepositoryProvider)
          .updateReadingProgress(widget.surahNumber, ayahNumber);
    }
  }

  void _onMushafPageChanged(int page) {
    setState(() => _currentPage = page);
    _loadPageMetadata(page);
    final pageData = quran.getPageData(page);
    if (pageData.isNotEmpty) {
      final firstSurah = pageData.first['surah'] as int;
      final firstVerse = pageData.first['start'] as int;
      ref
          .read(quranRepositoryProvider)
          .updateReadingProgress(firstSurah, firstVerse);
      ref.invalidate(readingProgressProvider);
    }
  }

  Future<void> _toggleBookmark(int surahNumber, int ayahNumber) async {
    final repo = ref.read(quranRepositoryProvider);
    final keys = ref.read(bookmarkKeysProvider).valueOrNull ?? {};
    final key = '$surahNumber:$ayahNumber';
    if (keys.contains(key)) {
      await repo.removeBookmark(surahNumber, ayahNumber);
    } else {
      await repo.addBookmark(surahNumber, ayahNumber);
    }
    ref.invalidate(bookmarkKeysProvider);
    ref.invalidate(allBookmarksProvider);
  }

  void _showPagePicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PagePickerSheet(
        currentPage: _currentPage,
        onPageSelected: (page) {
          _mushafPageKey.currentState?.goToPage(page);
        },
      ),
    );
  }

  void _showSurahPicker() {
    final pageData = quran.getPageData(_currentPage);
    final currentSurah =
        pageData.isNotEmpty ? pageData.first['surah'] as int : 1;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProviderScope(
        parent: ProviderScope.containerOf(context),
        child: SurahPickerSheet(
          currentSurahNumber: currentSurah,
          onSurahSelected: (surahNumber) {
            final page = quran.getPageNumber(surahNumber, 1);
            _mushafPageKey.currentState?.goToPage(page);
          },
        ),
      ),
    );
  }

  void _showJuzPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProviderScope(
        parent: ProviderScope.containerOf(context),
        child: JuzPickerSheet(
          currentJuz: _currentJuz,
          onJuzSelected: (startPage) {
            _mushafPageKey.currentState?.goToPage(startPage);
          },
        ),
      ),
    );
  }

  void _showHizbPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProviderScope(
        parent: ProviderScope.containerOf(context),
        child: HizbPickerSheet(
          currentHizb: _currentHizb,
          onHizbSelected: (startPage) {
            _mushafPageKey.currentState?.goToPage(startPage);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    ref.watch(bookmarkKeysProvider);

    if (_translationMode) return _buildTranslationScreen();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mushafTheme = isDark
        ? imad.ReadingTheme.dark
        : imad.ReadingTheme.light;
    final readerBg = isDark ? colors.background : const Color(0xFFFFF8E1);

    return imad.MushafThemeScope(
      notifier: imad.MushafThemeNotifier(initialTheme: mushafTheme),
      child: Scaffold(
        backgroundColor: readerBg,
        body: Stack(
          children: [
            Positioned.fill(
              child: imad.MushafPageView(
                key: _mushafPageKey,
                initialPage: _currentPage,
                onPageChanged: _onMushafPageChanged,
                showNavigationControls: false,
                showPageInfo: false,
                showAudioPlayer: false,
                readingTheme: mushafTheme,
                initialSelectedVerseKey: widget.highlightInitialAyah
                    ? widget.surahNumber * 1000 + widget.initialAyah
                    : null,
              ),
            ),
            // ── Top bar ──
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Builder(builder: (context) {
                final chromeBg = isDark
                    ? const Color(0xFF121212)
                    : const Color(0xFFFFF8E1);
                final typo = context.typography;
                final metaStyle = typo.bodySmall.copyWith(
                  color: colors.goldDim,
                  fontWeight: FontWeight.w600,
                );
                return Container(
                  padding: EdgeInsets.fromLTRB(
                      4, MediaQuery.of(context).padding.top + 4, 4, 8),
                  decoration: BoxDecoration(
                    color: chromeBg.withValues(alpha: 0.9),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(Icons.arrow_back_ios_new,
                            color: colors.textPrimary, size: 20),
                      ),
                      // Start: Page & Surah name
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: _showPagePicker,
                            child: Text(
                              '${Locales.string(context, 'page')} $_currentPage / 604',
                              style: metaStyle.copyWith(fontWeight: FontWeight.w400),
                            ),
                          ),
                          const SizedBox(height: 2),
                          GestureDetector(
                            onTap: _showSurahPicker,
                            child: Text(
                              _currentSurahName,
                              style: typo.arabicDisplay.copyWith(
                                fontSize: 16,
                                color: colors.gold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      // End: Juz & Hizb
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: _showJuzPicker,
                            child: Text('${Locales.string(context, 'juz_label')} ${ordinal(_currentJuz, Locales.currentLocale(context)?.languageCode ?? 'en')}', style: metaStyle),
                          ),
                          const SizedBox(height: 2),
                          GestureDetector(
                            onTap: _showHizbPicker,
                            child: Text('${Locales.string(context, 'hizb_label')} ${ordinal(_currentHizb, Locales.currentLocale(context)?.languageCode ?? 'en')}', style: metaStyle.copyWith(fontWeight: FontWeight.w400)),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () => setState(() {
                          _translationMode = true;
                        }),
                        icon: Icon(Icons.translate,
                            color: colors.textSecondary, size: 20),
                        tooltip: Locales.string(context, 'translation_view'),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Translation View ─────────────────────────────────────

  Widget _buildTranslationScreen() {
    final colors = context.colors;
    final typo = context.typography;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildTranslationAppBar(),
            Expanded(
              child: ref.watch(surahAyahsProvider(widget.surahNumber)).when(
                data: (ayahs) => _buildTranslationList(ayahs),
                loading: () => Center(
                  child:
                      CircularProgressIndicator(color: colors.gold),
                ),
                error: (e, _) => Center(
                  child: LocaleText('error_loading_surah',
                      style: typo.bodyLarge),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTranslationAppBar() {
    final colors = context.colors;
    final typo = context.typography;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.divider)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.arrow_back_ios_new,
                color: colors.textPrimary, size: 20),
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  quran.getSurahNameArabic(widget.surahNumber),
                  style:
                      typo.arabicDisplay.copyWith(fontSize: 18),
                ),
                Text(
                  quran.getSurahName(widget.surahNumber),
                  style: typo.bodySmall,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => setState(() {
              _translationMode = false;
            }),
            icon: Icon(Icons.auto_stories,
                color: colors.gold, size: 20),
            tooltip: Locales.string(context, 'mushaf_view'),
          ),
        ],
      ),
    );
  }

  Widget _buildTranslationList(List<Ayah> ayahs) {
    final itemCount = _hasBismillah ? ayahs.length + 1 : ayahs.length;
    final initialIndex = _hasBismillah
        ? (widget.initialAyah).clamp(0, itemCount - 1)
        : (widget.initialAyah - 1).clamp(0, itemCount - 1);

    return ScrollablePositionedList.builder(
      itemScrollController: _scrollController,
      itemPositionsListener: _positionsListener,
      initialScrollIndex: initialIndex,
      itemCount: itemCount,
      padding: const EdgeInsets.only(bottom: 80),
      itemBuilder: (context, index) {
        if (_hasBismillah && index == 0) return _buildBismillahHeader();
        final ayahIndex = _hasBismillah ? index - 1 : index;
        return _buildAyahTile(ayahs[ayahIndex]);
      },
    );
  }

  Widget _buildBismillahHeader() {
    final colors = context.colors;
    final typo = context.typography;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      child: Column(
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: colors.surfaceVariant,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${quran.getPlaceOfRevelation(widget.surahNumber).toUpperCase()} • ${quran.getVerseCount(widget.surahNumber)} AYAHS',
              style: typo.bodySmall.copyWith(
                color: colors.goldDim,
                letterSpacing: 1.2,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 28),
          _buildOrnamentDivider(),
          const SizedBox(height: 28),
          Text(
            quran.basmala,
            style: typo.quranArabic
                .copyWith(color: colors.gold, fontSize: 26),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          _buildOrnamentDivider(),
        ],
      ),
    );
  }

  Widget _buildOrnamentDivider() {
    final colors = context.colors;
    return Row(
      children: [
        Expanded(
            child: Container(
                height: 0.5,
                color: colors.gold.withValues(alpha: 0.3))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Transform.rotate(
            angle: 0.785398,
            child: Container(
              width: 6,
              height: 6,
              color: colors.gold.withValues(alpha: 0.5),
            ),
          ),
        ),
        Expanded(
            child: Container(
                height: 0.5,
                color: colors.gold.withValues(alpha: 0.3))),
      ],
    );
  }

  Widget _buildAyahTile(Ayah ayah) {
    final colors = context.colors;
    final typo = context.typography;
    final isSajdah =
        quran.isSajdahVerse(ayah.surahNumber, ayah.ayahNumber);
    final bookmarkKeys =
        ref.watch(bookmarkKeysProvider).valueOrNull ?? <String>{};
    final isBookmarked =
        bookmarkKeys.contains('${ayah.surahNumber}:${ayah.ayahNumber}');

    return Container(
      decoration: BoxDecoration(
        color: isSajdah ? colors.gold.withValues(alpha: 0.04) : null,
        border:
            Border(bottom: BorderSide(color: colors.divider)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                _VerseNumberBadge(number: ayah.ayahNumber),
                if (isSajdah) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: colors.gold.withValues(alpha: 0.3)),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      Locales.string(context, 'sajdah'),
                      style: typo.bodySmall
                          .copyWith(color: colors.gold, fontSize: 10),
                    ),
                  ),
                ],
                const Spacer(),
                GestureDetector(
                  onLongPress: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => SaveToCollectionSheet(
                        surahNumber: ayah.surahNumber,
                        ayahNumber: ayah.ayahNumber,
                      ),
                    );
                  },
                  child: IconButton(
                    onPressed: () =>
                        _toggleBookmark(ayah.surahNumber, ayah.ayahNumber),
                    icon: Icon(
                      isBookmarked
                          ? Icons.bookmark
                          : Icons.bookmark_border,
                      color: isBookmarked
                          ? colors.gold
                          : colors.textTertiary,
                      size: 20,
                    ),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints(minWidth: 36, minHeight: 36),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '${ayah.textUthmani} ${quran.getVerseEndSymbol(ayah.ayahNumber)}',
              style: typo.quranArabic,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
            ),
            if (ayah.translation != null) ...[
              const SizedBox(height: 14),
              Text(
                ayah.translation!,
                style: typo.bodyLarge.copyWith(height: 1.8),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _VerseNumberBadge extends StatelessWidget {
  final int number;
  const _VerseNumberBadge({required this.number});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typography;
    return SizedBox(
      width: 36,
      height: 36,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.rotate(
            angle: 0.785398,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                border: Border.all(color: colors.gold, width: 1),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          Text(
            '$number',
            style: typo.bodySmall.copyWith(
              color: colors.gold,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
