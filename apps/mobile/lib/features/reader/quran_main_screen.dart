import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import '../../core/utils/ordinal_formatter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:imad_flutter/imad_flutter.dart' as imad;
import 'package:just_audio/just_audio.dart';
import 'package:shimmer/shimmer.dart';
import 'package:quran/quran.dart' as quran;
import 'package:quran_flutter/quran_flutter.dart';
import '../../core/theme/app_color_scheme.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/typography_ext.dart';
import '../../data/services/recitation_service.dart';
import '../../data/services/tafseer_service.dart';
import '../../providers/quran_providers.dart';
import '../bookmarks/bookmarks_screen.dart';
import '../hifz/profile_screen.dart';
import '../search/search_screen.dart';
import '../settings/settings_screen.dart';
import 'widgets/page_picker_sheet.dart';
import 'widgets/surah_picker_sheet.dart';
import 'widgets/juz_picker_sheet.dart';
import 'widgets/hizb_picker_sheet.dart';

/// Tab indices: 0=Search, 1=Bookmarks, 2=Quran, 3=Hifz, 4=Settings
const _kQuranTab = 2;

const _localeToQuranLanguage = <String, QuranLanguage>{
  'am': QuranLanguage.amharic,
  'az': QuranLanguage.azerbaijani,
  'bn': QuranLanguage.bengali,
  'bs': QuranLanguage.bosnian,
  'zh': QuranLanguage.chinese,
  'cs': QuranLanguage.czech,
  'nl': QuranLanguage.dutch,
  'en': QuranLanguage.english,
  'fr': QuranLanguage.french,
  'de': QuranLanguage.german,
  'ha': QuranLanguage.hausa,
  'hi': QuranLanguage.hindi,
  'id': QuranLanguage.indonesian,
  'it': QuranLanguage.italian,
  'ja': QuranLanguage.japanese,
  'ko': QuranLanguage.korean,
  'ku': QuranLanguage.kurdish,
  'ms': QuranLanguage.malay,
  'no': QuranLanguage.norwegian,
  'ps': QuranLanguage.pashto,
  'fa': QuranLanguage.persian,
  'pl': QuranLanguage.polish,
  'pt': QuranLanguage.portuguese,
  'ro': QuranLanguage.romanian,
  'ru': QuranLanguage.russian,
  'sd': QuranLanguage.sindhi,
  'so': QuranLanguage.somali,
  'es': QuranLanguage.spanish,
  'sw': QuranLanguage.swahili,
  'sv': QuranLanguage.swedish,
  'tg': QuranLanguage.tajik,
  'ta': QuranLanguage.tamil,
  'th': QuranLanguage.thai,
  'tr': QuranLanguage.turkish,
  'ur': QuranLanguage.urdu,
  'uz': QuranLanguage.uzbek,
};

class QuranMainScreen extends ConsumerWidget {
  const QuranMainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final progressAsync = ref.watch(readingProgressProvider);

    return progressAsync.when(
      data: (progress) {
        FlutterNativeSplash.remove();
        return _AppShell(
          initialPage: quran.getPageNumber(
            progress['surah_number']!,
            progress['ayah_number']!,
          ),
        );
      },
      loading: () => Scaffold(backgroundColor: colors.background),
      error: (_, __) {
        FlutterNativeSplash.remove();
        return const _AppShell(initialPage: 1);
      },
    );
  }
}

class _AppShell extends ConsumerStatefulWidget {
  final int initialPage;
  const _AppShell({required this.initialPage});

  @override
  ConsumerState<_AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<_AppShell> {
  int _activeTab = _kQuranTab;
  late int _currentPage;
  bool _showChrome = false;
  bool _transitioning = false;
  int _currentJuz = 1;
  int _currentHizb = 1;

  final _mushafPageKey = GlobalKey<imad.MushafPageViewState>();

  bool get _isMushaf => _activeTab == _kQuranTab;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
    _loadPageMetadata(widget.initialPage);
  }

  Future<void> _navigateToReader(ReaderNavigationRequest req) async {
    final page = quran.getPageNumber(req.surahNumber, req.ayahNumber);
    final verseKey = req.highlight
        ? req.surahNumber * 1000 + req.ayahNumber
        : null;

    // If already on the Quran tab, just navigate the page directly.
    if (_activeTab == _kQuranTab) {
      _mushafPageKey.currentState?.goToPage(page,
          highlightVerseKey: verseKey);
      return;
    }

    if (_transitioning) return;

    // Phase 1: fade out the current view.
    setState(() => _transitioning = true);
    await Future.delayed(const Duration(milliseconds: 150));
    if (!mounted) return;

    // Phase 2: switch tab and jump to page (hidden behind overlay).
    setState(() {
      _activeTab = _kQuranTab;
      _showChrome = true;
    });
    _mushafPageKey.currentState?.goToPage(page,
        highlightVerseKey: verseKey);

    // Let the target page render one frame.
    await Future.delayed(const Duration(milliseconds: 50));
    if (!mounted) return;

    // Phase 3: fade in the reader.
    setState(() => _transitioning = false);
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
    ));
  }

  void _onPageChanged(int page) {
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

  String get _currentSurahName {
    final pageData = quran.getPageData(_currentPage);
    if (pageData.isEmpty) return '';
    final surahNum = pageData.first['surah'] as int;
    final locale = Locales.currentLocale(context)?.languageCode ?? 'en';
    final prefix = Locales.string(context, 'surah_prefix');
    if (locale == 'ar') return '$prefix ${quran.getSurahNameArabic(surahNum)}';
    return '$prefix ${quran.getSurahNameEnglish(surahNum)}';
  }

  void _toggleChrome() => setState(() => _showChrome = !_showChrome);

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

  Future<void> _switchTab(int index) async {
    if (index == _activeTab || _transitioning) return;

    // Fade out
    setState(() => _transitioning = true);
    await Future.delayed(const Duration(milliseconds: 150));
    if (!mounted) return;

    // Swap content behind overlay
    setState(() {
      _activeTab = index;
      _showChrome = true;
    });

    // Let new view render a frame
    await Future.delayed(const Duration(milliseconds: 50));
    if (!mounted) return;

    // Fade in
    setState(() => _transitioning = false);
  }

  @override
  Widget build(BuildContext context) {
    // Listen for navigation requests from search / bookmarks / etc.
    ref.listen(readerNavigationProvider, (prev, next) {
      if (next == null) return;
      ref.read(readerNavigationProvider.notifier).state = null;
      _navigateToReader(next);
    });

    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mushafTheme = isDark
        ? imad.ReadingTheme.dark
        : imad.ReadingTheme.light;
    final readerBg = isDark ? colors.background : const Color(0xFFFFF8E1);

    return imad.MushafThemeScope(
      notifier:
          imad.MushafThemeNotifier(initialTheme: mushafTheme),
      child: Scaffold(
        backgroundColor: readerBg,
        body: Stack(
          children: [
            // ── Views ──
            Positioned.fill(
              child: IndexedStack(
                index: _activeTab,
                children: [
                  const SearchScreen(),      // 0
                  const BookmarksScreen(),    // 1
                  _buildMushafView(mushafTheme), // 2 (center)
                  const ProfileScreen(),      // 3
                  const SettingsScreen(),     // 4
                ],
              ),
            ),

            // ── Transition overlay (between views and chrome/bar) ──
            Positioned.fill(
              child: IgnorePointer(
                ignoring: !_transitioning,
                child: AnimatedOpacity(
                  opacity: _transitioning ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 150),
                  curve: Curves.easeInOut,
                  child: ColoredBox(color: colors.background),
                ),
              ),
            ),

            // ── Top chrome (mushaf only) ──
            if (_isMushaf) _buildTopChrome(),

            // ── Bottom bar ──
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildMushafView(imad.ReadingTheme mushafTheme) {
    return imad.MushafPageView(
      key: _mushafPageKey,
      initialPage: _currentPage,
      onPageChanged: _onPageChanged,
      onTap: _toggleChrome,
      onVerseLongPress: _onVerseLongPress,
      showNavigationControls: false,
      showPageInfo: false,
      showAudioPlayer: false,
      readingTheme: mushafTheme,
    );
  }

  void _showReciterSheet(
      BuildContext parentCtx, int surahNumber, int verseNumber) {
    final colors = context.colors;
    showModalBottomSheet(
      context: parentCtx,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _ReciterSheet(
        surahNumber: surahNumber,
        verseNumber: verseNumber,
      ),
    );
  }

  void _showTafseerSheet(
      BuildContext parentCtx, int surahNumber, int verseNumber) {
    final colors = context.colors;
    showModalBottomSheet(
      context: parentCtx,
      backgroundColor: colors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.55,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => _TafseerSheet(
          surahNumber: surahNumber,
          verseNumber: verseNumber,
          scrollController: scrollController,
        ),
      ),
    );
  }

  String _localizedSurahName(int surahNumber) {
    final locale = Locales.currentLocale(context)?.languageCode ?? 'en';
    final prefix = Locales.string(context, 'surah_prefix');
    if (locale == 'ar') return '$prefix ${quran.getSurahNameArabic(surahNumber)}';
    return '$prefix ${quran.getSurahNameEnglish(surahNumber)}';
  }

  void _onVerseLongPress(int surahNumber, int verseNumber) {
    // Show chrome if hidden
    if (!_showChrome) setState(() => _showChrome = true);

    final colors = context.colors;
    final typo = context.typography;
    final locale = Locales.currentLocale(context)?.languageCode ?? 'en';
    final quranLang = _localeToQuranLanguage[locale];
    final translation = locale == 'ar'
        ? Quran.getVerse(surahNumber: surahNumber, verseNumber: verseNumber).text
        : quranLang != null
            ? Quran.getVerse(
                surahNumber: surahNumber,
                verseNumber: verseNumber,
                language: quranLang,
              ).text
            : quran.getVerseTranslation(surahNumber, verseNumber);

    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.45,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.surfaceHigh,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Verse info row
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _localizedSurahName(surahNumber),
                                    style: typo.titleMedium,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if ((Locales.currentLocale(context)?.languageCode ?? 'en') != 'ar')
                                    Text(
                                      quran.getSurahNameArabic(surahNumber),
                                      style: typo.arabicDisplay.copyWith(
                                        fontSize: 14,
                                        color: colors.textSecondary,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: colors.surfaceVariant,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '$surahNumber:$verseNumber',
                                style: typo.bodySmall.copyWith(
                                  color: colors.gold,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Consumer(
                        builder: (ctx2, ref2, _) {
                          final keysAsync = ref2.watch(bookmarkKeysProvider);
                          final isBookmarked = keysAsync.whenOrNull(
                                data: (keys) =>
                                    keys.contains('$surahNumber:$verseNumber'),
                              ) ??
                              false;
                          return IconButton(
                            onPressed: () async {
                              final repo = ref2.read(quranRepositoryProvider);
                              if (isBookmarked) {
                                await repo.removeBookmark(
                                    surahNumber, verseNumber);
                              } else {
                                await repo.addBookmark(
                                    surahNumber, verseNumber);
                              }
                              ref2.invalidate(bookmarkKeysProvider);
                              ref2.invalidate(allBookmarksProvider);
                            },
                            icon: Icon(
                              isBookmarked
                                  ? Icons.bookmark
                                  : Icons.bookmark_border,
                              color: isBookmarked
                                  ? colors.gold
                                  : colors.textSecondary,
                              size: 22,
                            ),
                          );
                        },
                      ),
                      IconButton(
                        onPressed: () {
                          _showTafseerSheet(
                              ctx, surahNumber, verseNumber);
                        },
                        icon: Icon(
                          Icons.menu_book_rounded,
                          color: colors.textSecondary,
                          size: 22,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          _showReciterSheet(
                              ctx, surahNumber, verseNumber);
                        },
                        icon: Icon(
                          Icons.volume_up_rounded,
                          color: colors.textSecondary,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Translation (scrollable)
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colors.background,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          translation,
                          style: typo.bodyLarge.copyWith(height: 1.8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTopChrome() {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final typo = context.typography;
    final chromeBg = isDark ? const Color(0xFF121212) : const Color(0xFFFFF8E1);
    final metaStyle = typo.bodySmall.copyWith(
      color: colors.goldDim,
      fontWeight: FontWeight.w600,
    );

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: IgnorePointer(
        ignoring: !_showChrome,
        child: AnimatedSlide(
          offset: Offset(0, _showChrome ? 0 : -1),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          child: AnimatedOpacity(
            opacity: _showChrome ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 250),
            child: Container(
              padding: EdgeInsets.fromLTRB(
                  20, MediaQuery.of(context).padding.top + 8, 20, 14),
              decoration: BoxDecoration(
                color: chromeBg.withValues(alpha: 0.9),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Start: Page number & Surah name
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
                            fontSize: 20,
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final bool visible = _showChrome || !_isMushaf;
    final readerBg = isDark ? colors.background : const Color(0xFFFFF8E1);
    final barBg = _isMushaf ? readerBg : colors.background;

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: IgnorePointer(
        ignoring: !visible,
        child: AnimatedSlide(
          offset: Offset(0, visible ? 0 : 1),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          child: AnimatedOpacity(
            opacity: visible ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 250),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOut,
              decoration: isDark
                  ? BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          barBg.withValues(alpha: 0.7),
                          barBg.withValues(alpha: 0.85),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    )
                  : const BoxDecoration(),
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, bottomPad + 12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 4, vertical: 4),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isDark
                          ? colors.divider.withValues(alpha: 0.5)
                          : Colors.transparent,
                    ),
                  ),
                  child: Row(
                    children: [
                      _BarIcon(
                        icon: Icons.search_rounded,
                        isActive: _activeTab == 0,
                        onTap: () => _switchTab(0),
                      ),
                      _BarIcon(
                        icon: Icons.bookmark_rounded,
                        isActive: _activeTab == 1,
                        onTap: () => _switchTab(1),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _switchTab(_kQuranTab),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutCubic,
                            padding:
                                const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: _activeTab == _kQuranTab
                                  ? colors.gold
                                      .withValues(alpha: 0.12)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: TweenAnimationBuilder<Color?>(
                              tween: ColorTween(
                                end: _activeTab == _kQuranTab
                                    ? colors.gold
                                    : colors.textSecondary,
                              ),
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOutCubic,
                              builder: (context, color, _) =>
                                  AnimatedScale(
                                scale:
                                    _activeTab == _kQuranTab ? 1.1 : 1.0,
                                duration:
                                    const Duration(milliseconds: 300),
                                curve: Curves.easeOutCubic,
                                child: Icon(
                                  Icons.auto_stories_rounded,
                                  color: color,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      _BarIcon(
                        icon: Icons.person_rounded,
                        isActive: _activeTab == 3,
                        onTap: () => _switchTab(3),
                      ),
                      _BarIcon(
                        icon: Icons.settings_rounded,
                        isActive: _activeTab == 4,
                        onTap: () => _switchTab(4),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ReciterSheet extends StatefulWidget {
  final int surahNumber;
  final int verseNumber;

  const _ReciterSheet({
    required this.surahNumber,
    required this.verseNumber,
  });

  @override
  State<_ReciterSheet> createState() => _ReciterSheetState();
}

class _ReciterSheetState extends State<_ReciterSheet> {
  final _player = AudioPlayer();
  List<ReciterInfo>? _reciters;
  bool _loading = true;
  String? _error;
  String? _playingUrl;
  bool _buffering = false;

  @override
  void initState() {
    super.initState();
    _loadReciters();
    _player.playerStateStream.listen((state) {
      if (!mounted) return;
      final isBuffering =
          state.processingState == ProcessingState.loading ||
              state.processingState == ProcessingState.buffering;
      final completed =
          state.processingState == ProcessingState.completed;
      setState(() {
        _buffering = isBuffering;
        if (completed) _playingUrl = null;
      });
    });
  }

  Future<void> _loadReciters() async {
    try {
      final reciters = await RecitationService.instance
          .fetchReciters(widget.surahNumber, widget.verseNumber);
      if (mounted) setState(() { _reciters = reciters; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _togglePlay(ReciterInfo reciter) async {
    if (_playingUrl == reciter.audioUrl) {
      await _player.stop();
      setState(() => _playingUrl = null);
    } else {
      setState(() {
        _playingUrl = reciter.audioUrl;
        _buffering = true;
      });
      try {
        await _player.setUrl(reciter.audioUrl);
        await _player.play();
      } catch (_) {
        if (mounted) setState(() { _playingUrl = null; _buffering = false; });
      }
    }
  }

  Widget _buildShimmerCard(AppColorScheme colors) {
    return Shimmer.fromColors(
      baseColor: colors.surfaceVariant,
      highlightColor: colors.surfaceHigh,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        height: 52,
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.divider),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typography;

    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 12, 20, MediaQuery.of(context).padding.bottom + 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colors.surfaceHigh,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          // Title
          Row(
            children: [
              Icon(Icons.volume_up_rounded,
                  color: colors.gold, size: 20),
              const SizedBox(width: 8),
              Text(
                '${widget.surahNumber}:${widget.verseNumber}',
                style: typo.titleMedium.copyWith(color: colors.gold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Content
          if (_loading)
            ...List.generate(5, (i) => _buildShimmerCard(colors))
          else if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  Icon(Icons.wifi_off_rounded,
                      color: colors.textTertiary, size: 32),
                  const SizedBox(height: 8),
                  Text(
                    Locales.string(context, 'error_loading_reciters'),
                    style: typo.bodyMedium.copyWith(
                        color: colors.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _loading = true;
                        _error = null;
                      });
                      _loadReciters();
                    },
                    icon: Icon(Icons.refresh_rounded,
                        color: colors.gold, size: 18),
                    label: Text(
                        Locales.string(context, 'retry'),
                        style: typo.bodySmall
                            .copyWith(color: colors.gold)),
                  ),
                ],
              ),
            )
          else
            ...(_reciters ?? []).map((reciter) {
              final isPlaying = _playingUrl == reciter.audioUrl;
              final isThisBuffering = isPlaying && _buffering;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: isPlaying
                      ? colors.gold.withValues(alpha: 0.08)
                      : colors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isPlaying
                        ? colors.gold.withValues(alpha: 0.3)
                        : colors.divider,
                  ),
                ),
                child: InkWell(
                  onTap: () => _togglePlay(reciter),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: isThisBuffering
                              ? CircularProgressIndicator(
                                  color: colors.gold,
                                  strokeWidth: 2,
                                )
                              : Icon(
                                  isPlaying
                                      ? Icons.stop_rounded
                                      : Icons.play_arrow_rounded,
                                  color: isPlaying
                                      ? colors.gold
                                      : colors.textSecondary,
                                  size: 24,
                                ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            Locales.string(
                                context, 'reciter_${reciter.id}'),
                            style: typo.bodyMedium.copyWith(
                              color: isPlaying
                                  ? colors.gold
                                  : colors.textPrimary,
                              fontWeight: isPlaying
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _TafseerSheet extends StatefulWidget {
  final int surahNumber;
  final int verseNumber;
  final ScrollController scrollController;

  const _TafseerSheet({
    required this.surahNumber,
    required this.verseNumber,
    required this.scrollController,
  });

  @override
  State<_TafseerSheet> createState() => _TafseerSheetState();
}

class _TafseerSheetState extends State<_TafseerSheet> {
  List<TafsirSource>? _sources;
  TafsirSource? _selectedSource;
  String? _tafsirText;
  bool _loading = false;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_sources == null) {
      final locale = Locales.currentLocale(context)?.languageCode ?? 'en';
      _sources = TafseerService.instance.getTafsirsForLocale(locale);
    }
  }

  Future<void> _loadTafsir(TafsirSource source) async {
    setState(() {
      _selectedSource = source;
      _loading = true;
      _error = null;
      _tafsirText = null;
    });
    try {
      final text = await TafseerService.instance
          .fetchTafsir(source.id, widget.surahNumber, widget.verseNumber);
      if (mounted) setState(() { _tafsirText = text; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Widget _buildShimmerLoading(AppColorScheme colors) {
    return Shimmer.fromColors(
      baseColor: colors.surfaceVariant,
      highlightColor: colors.surfaceHigh,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  bool get _isRtlTafsir {
    final lang = _selectedSource?.language ?? 'en';
    return lang == 'ar' || lang == 'ur' || lang == 'ku';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typography;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colors.surfaceHigh,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          // Header
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  if (_selectedSource != null) {
                    setState(() {
                      _selectedSource = null;
                      _tafsirText = null;
                      _error = null;
                      _loading = false;
                    });
                  } else {
                    Navigator.pop(context);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Icon(Icons.chevron_left_rounded,
                      color: colors.textSecondary, size: 24),
                ),
              ),
              Expanded(
                child: Text(
                  _selectedSource != null
                      ? Locales.string(
                          context, 'tafsir_${_selectedSource!.id}')
                      : Locales.string(context, 'select_tafseer'),
                  style: typo.titleMedium.copyWith(color: colors.gold),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Invisible spacer to balance the chevron and keep text centered
              const SizedBox(width: 32),
            ],
          ),
          const SizedBox(height: 16),
          // Content
          Expanded(
            child: _selectedSource == null
                ? _buildSourceList(colors, typo)
                : _buildTafsirContent(colors, typo),
          ),
        ],
      ),
    );
  }

  Widget _buildSourceList(AppColorScheme colors, AppTypography typo) {
    return ListView.builder(
      controller: widget.scrollController,
      itemCount: _sources!.length,
      itemBuilder: (context, index) {
        final source = _sources![index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.divider),
          ),
          child: InkWell(
            onTap: () => _loadTafsir(source),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Icon(Icons.article_outlined,
                      color: colors.textSecondary, size: 22),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      Locales.string(context, 'tafsir_${source.id}'),
                      style: typo.bodyMedium
                          .copyWith(color: colors.textPrimary),
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded,
                      color: colors.textTertiary, size: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTafsirContent(AppColorScheme colors, AppTypography typo) {
    if (_loading) {
      return _buildShimmerLoading(colors);
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded,
                color: colors.textTertiary, size: 32),
            const SizedBox(height: 8),
            Text(
              Locales.string(context, 'error_loading_tafsir'),
              style:
                  typo.bodyMedium.copyWith(color: colors.textSecondary),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () => _loadTafsir(_selectedSource!),
              icon: Icon(Icons.refresh_rounded,
                  color: colors.gold, size: 18),
              label: Text(Locales.string(context, 'retry'),
                  style: typo.bodySmall.copyWith(color: colors.gold)),
            ),
          ],
        ),
      );
    }

    final textStyle = typo.bodyLarge.copyWith(height: 1.8);

    return SingleChildScrollView(
      controller: widget.scrollController,
      child: Directionality(
        textDirection: _isRtlTafsir ? TextDirection.rtl : TextDirection.ltr,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _tafsirText ?? '',
            style: textStyle,
            textAlign: TextAlign.justify,
          ),
        ),
      ),
    );
  }
}

class _BarIcon extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;
  final bool enabled;

  const _BarIcon({
    required this.icon,
    required this.isActive,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final activeColor = colors.gold;
    final inactiveColor = colors.textSecondary;
    return AnimatedOpacity(
      opacity: enabled ? 1.0 : 0.3,
      duration: const Duration(milliseconds: 200),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isActive
                  ? activeColor.withValues(alpha: 0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: TweenAnimationBuilder<Color?>(
              tween: ColorTween(
                end: isActive ? activeColor : inactiveColor,
              ),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              builder: (context, color, _) => AnimatedScale(
                scale: isActive ? 1.1 : 1.0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                child: Icon(icon, color: color, size: 22),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
