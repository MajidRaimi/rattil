import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:flutter/material.dart';
import '../../data/services/analytics_service.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:progress_border/progress_border.dart';
import 'package:quran/quran.dart' as quran;
import 'package:showcaseview/showcaseview.dart';
import 'package:tab_container/tab_container.dart';
import '../../core/theme/app_color_scheme.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/typography_ext.dart';
import '../../core/utils/ordinal_formatter.dart';
import '../../data/models/surah.dart';
import '../../data/services/notification_service.dart';
import '../../providers/quran_providers.dart';
import '../../providers/tikrar_provider.dart';
import '../home/widgets/surah_search_tile.dart';
import '../tutorial/tutorial_keys.dart';
import '../../providers/wird_provider.dart';
import '../../providers/khatmah_provider.dart';
import 'hifz_player_screen.dart';
import 'tasmi_player_screen.dart';
import '../../providers/tasmi_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => ProfileScreenState();
}

class ProfileScreenState extends ConsumerState<ProfileScreen>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void switchToTab(int index) {
    _tabController.animateTo(index);
  }

  @override
  Widget build(BuildContext context) {
    final typo = context.typography;
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Title ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Text(
                Locales.string(context, 'profile'),
                style: typo.headlineMedium.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ── Tab Container ──
            Expanded(
              child: Showcase(
                key: TutorialKeys.profileTabs,
                title: Locales.string(context, 'tutorial_profile_title'),
                description: Locales.string(context, 'tutorial_profile_desc'),
                tooltipBackgroundColor: colors.surface,
                titleTextStyle: TextStyle(fontFamily: 'NeueFrutigerWorld', color: colors.gold, fontWeight: FontWeight.w600, fontSize: 16),
                descTextStyle: TextStyle(fontFamily: 'NeueFrutigerWorld', color: colors.textSecondary, fontSize: 13),
                targetBorderRadius: BorderRadius.circular(16),
                overlayOpacity: 0.75,
                child: TabContainer(
                  controller: _tabController,
                  tabEdge: TabEdge.top,
                  tabExtent: 40,
                  borderRadius: BorderRadius.zero,
                  tabBorderRadius: BorderRadius.circular(10),
                  childPadding: EdgeInsets.zero,
                  color: colors.surface,
                  selectedTextStyle: typo.bodySmall.copyWith(
                    color: colors.gold,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                  unselectedTextStyle: typo.bodySmall.copyWith(
                    color: colors.textTertiary,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                  tabs: [
                    Text(Locales.string(context, 'hifz_tab')),
                    Text(Locales.string(context, 'tasmi_tab')),
                    Text(Locales.string(context, 'wird_tab')),
                    Text(Locales.string(context, 'khatmah_tab')),
                    Text(Locales.string(context, 'progress_tab')),
                  ],
                  children: [
                    _HifzTab(),
                    _TasmiTab(),
                    Showcase(
                      key: TutorialKeys.wirdContent,
                      title: Locales.string(context, 'tutorial_wird_tab_title'),
                      description: Locales.string(context, 'tutorial_wird_tab_desc'),
                      tooltipBackgroundColor: colors.surface,
                      titleTextStyle: TextStyle(fontFamily: 'NeueFrutigerWorld', color: colors.gold, fontWeight: FontWeight.w600, fontSize: 16),
                      descTextStyle: TextStyle(fontFamily: 'NeueFrutigerWorld', color: colors.textSecondary, fontSize: 13),
                      targetBorderRadius: BorderRadius.circular(16),
                      overlayOpacity: 0.75,
                      child: _WirdTab(),
                    ),
                    Showcase(
                      key: TutorialKeys.khatmahContent,
                      title: Locales.string(context, 'tutorial_khatmah_tab_title'),
                      description: Locales.string(context, 'tutorial_khatmah_tab_desc'),
                      tooltipBackgroundColor: colors.surface,
                      titleTextStyle: TextStyle(fontFamily: 'NeueFrutigerWorld', color: colors.gold, fontWeight: FontWeight.w600, fontSize: 16),
                      descTextStyle: TextStyle(fontFamily: 'NeueFrutigerWorld', color: colors.textSecondary, fontSize: 13),
                      targetBorderRadius: BorderRadius.circular(16),
                      overlayOpacity: 0.75,
                      child: _KhatmahTab(),
                    ),
                    Showcase(
                      key: TutorialKeys.progressContent,
                      title: Locales.string(context, 'tutorial_progress_tab_title'),
                      description: Locales.string(context, 'tutorial_progress_tab_desc'),
                      tooltipBackgroundColor: colors.surface,
                      titleTextStyle: TextStyle(fontFamily: 'NeueFrutigerWorld', color: colors.gold, fontWeight: FontWeight.w600, fontSize: 16),
                      descTextStyle: TextStyle(fontFamily: 'NeueFrutigerWorld', color: colors.textSecondary, fontSize: 13),
                      targetBorderRadius: BorderRadius.circular(16),
                      overlayOpacity: 0.75,
                      child: _ProgressTab(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// TAB 1 — Hifz (Tikrar sessions)
// ═══════════════════════════════════════════════════════════════════════════════

class _HifzTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(tikrarSessionsProvider);
    if (sessions.isEmpty) return _HifzEmptyState();
    return _HifzSessionsList(sessions: sessions);
  }
}

class _HifzEmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final typo = context.typography;
    final colors = context.colors;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.headphones_rounded,
              size: 56, color: colors.goldDim.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          Text(
            Locales.string(context, 'tikrar_title'),
            style: typo.titleMedium.copyWith(color: colors.textTertiary),
          ),
          const SizedBox(height: 8),
          Text(
            Locales.string(context, 'tikrar_subtitle'),
            style: typo.bodySmall.copyWith(color: colors.textTertiary),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => _showSurahSelectionSheet(context),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.gold),
              ),
              child: Text(
                Locales.string(context, 'tikrar_start'),
                style: typo.bodyMedium.copyWith(
                  color: colors.gold,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HifzSessionsList extends ConsumerWidget {
  final List<TikrarSession> sessions;
  const _HifzSessionsList({required this.sessions});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typo = context.typography;
    final colors = context.colors;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (int i = 0; i < sessions.length; i++) ...[
          _SessionCard(
            session: sessions[i],
            onResume: () => _resumeSession(context, sessions[i]),
            onDelete: () => ref
                .read(tikrarSessionsProvider.notifier)
                .deleteSession(sessions[i].id),
          ),
          if (i < sessions.length - 1) const SizedBox(height: 10),
        ],
        const SizedBox(height: 20),
        Center(
          child: GestureDetector(
            onTap: () => _showSurahSelectionSheet(context),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.gold),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_rounded, size: 18, color: colors.gold),
                  const SizedBox(width: 6),
                  Text(
                    Locales.string(context, 'tikrar_new_session'),
                    style: typo.bodyMedium.copyWith(
                      color: colors.gold,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _resumeSession(BuildContext context, TikrarSession session) {
    AnalyticsService.event('Tikrar Started', props: {'surah': session.surahNameEnglish});
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HifzPlayerScreen(session: session),
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  final TikrarSession session;
  final VoidCallback onResume;
  final VoidCallback onDelete;

  const _SessionCard({
    required this.session,
    required this.onResume,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final typo = context.typography;
    final colors = context.colors;

    final totalSteps = session.totalSteps;
    final progress = session.progress;
    final progressPercent = (progress * 100).toInt();

    return Dismissible(
      key: ValueKey(session.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: AlignmentDirectional.centerEnd,
        padding: const EdgeInsetsDirectional.only(end: 20),
        decoration: BoxDecoration(
          color: colors.error.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(Icons.delete_outline_rounded, color: colors.error),
      ),
      child: GestureDetector(
        onTap: onResume,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.divider),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.surahNameArabic,
                      style: typo.arabicDisplay.copyWith(
                        color: colors.textPrimary,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      session.surahNameEnglish,
                      style: typo.bodyMedium
                          .copyWith(color: colors.textSecondary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${Locales.string(context, 'tikrar_verses_label')} ${session.startVerse}–${session.endVerse}',
                      style: typo.bodySmall
                          .copyWith(color: colors.textTertiary),
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 4,
                        backgroundColor: colors.divider,
                        valueColor: AlwaysStoppedAnimation(colors.gold),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${Locales.string(context, 'tikrar_step')} ${session.currentStepIndex + 1} ${Locales.string(context, 'tikrar_of')} $totalSteps · $progressPercent%',
                      style: typo.bodySmall.copyWith(
                        color: colors.gold,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.gold,
                ),
                child: const Icon(Icons.play_arrow_rounded,
                    color: Colors.white, size: 24),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _showSurahSelectionSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _SurahSelectionSheet(),
  );
}

class _SurahSelectionSheet extends ConsumerStatefulWidget {
  const _SurahSelectionSheet();

  @override
  ConsumerState<_SurahSelectionSheet> createState() =>
      _SurahSelectionSheetState();
}

class _SurahSelectionSheetState extends ConsumerState<_SurahSelectionSheet> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final typo = context.typography;
    final colors = context.colors;
    final surahsAsync = ref.watch(allSurahsProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  Locales.string(context, 'tikrar_select_surah'),
                  style: typo.headlineMedium
                      .copyWith(color: colors.textPrimary),
                ),
                const SizedBox(height: 16),
                TextField(
                  onChanged: (v) => setState(() => _searchQuery = v),
                  style: typo.bodyMedium.copyWith(color: colors.textPrimary),
                  decoration: InputDecoration(
                    hintText: Locales.string(context, 'tikrar_search_surah'),
                    hintStyle: typo.bodyMedium
                        .copyWith(color: colors.textTertiary),
                    prefixIcon: Icon(Icons.search_rounded,
                        color: colors.textTertiary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colors.divider),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colors.divider),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colors.gold),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          Expanded(
            child: surahsAsync.when(
              data: (surahs) {
                final filtered = _searchQuery.isEmpty
                    ? surahs
                    : surahs.where((s) {
                        final q = _searchQuery.toLowerCase();
                        return s.nameEnglish.toLowerCase().contains(q) ||
                            s.nameArabic.contains(_searchQuery) ||
                            s.nameTranslation.toLowerCase().contains(q);
                      }).toList();

                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final surah = filtered[index];
                    return SurahSearchTile(
                      surah: surah,
                      onTap: () {
                        Navigator.pop(context);
                        _showTikrarConfigSheet(context, surah);
                      },
                    );
                  },
                );
              },
              loading: () => Center(
                child: CircularProgressIndicator(color: colors.gold),
              ),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}

void _showTikrarConfigSheet(BuildContext context, Surah surah) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _TikrarConfigSheet(surah: surah),
  );
}

class _TikrarConfigSheet extends ConsumerStatefulWidget {
  final Surah surah;
  const _TikrarConfigSheet({required this.surah});

  @override
  ConsumerState<_TikrarConfigSheet> createState() => _TikrarConfigSheetState();
}

class _TikrarConfigSheetState extends ConsumerState<_TikrarConfigSheet> {
  late int _startVerse;
  late int _endVerse;
  int _repetitions = 3;
  String _reciterId = '1';

  late final TextEditingController _startController;
  late final TextEditingController _endController;
  late final TextEditingController _repController;

  @override
  void initState() {
    super.initState();
    _startVerse = 1;
    _endVerse = widget.surah.ayahCount;
    _startController = TextEditingController(text: '$_startVerse');
    _endController = TextEditingController(text: '$_endVerse');
    _repController = TextEditingController(text: '$_repetitions');
  }

  @override
  void dispose() {
    _startController.dispose();
    _endController.dispose();
    _repController.dispose();
    super.dispose();
  }

  void _updateStart(int delta) {
    setState(() {
      _startVerse =
          (_startVerse + delta).clamp(1, widget.surah.ayahCount);
      if (_endVerse < _startVerse) _endVerse = _startVerse;
      _startController.text = '$_startVerse';
      _endController.text = '$_endVerse';
    });
  }

  void _updateEnd(int delta) {
    setState(() {
      _endVerse =
          (_endVerse + delta).clamp(_startVerse, widget.surah.ayahCount);
      _endController.text = '$_endVerse';
    });
  }

  void _updateRep(int delta) {
    setState(() {
      _repetitions = (_repetitions + delta).clamp(2, 10);
      _repController.text = '$_repetitions';
    });
  }

  @override
  Widget build(BuildContext context) {
    final typo = context.typography;
    final colors = context.colors;
    final verseCount = _endVerse - _startVerse + 1;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
          20, 12, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.surah.nameArabic,
              style: typo.arabicDisplay.copyWith(color: colors.textPrimary),
            ),
            Text(
              widget.surah.nameEnglish,
              style: typo.bodyMedium.copyWith(color: colors.textSecondary),
            ),
            const SizedBox(height: 24),

            // Start Verse
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                Locales.string(context, 'tikrar_start_verse').toUpperCase(),
                style: typo.bodySmall.copyWith(
                  color: colors.goldDim,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 8),
            _NumberPickerRow(
              controller: _startController,
              onDecrement: () => _updateStart(-1),
              onIncrement: () => _updateStart(1),
              onChanged: (val) {
                final n = int.tryParse(val);
                if (n != null && n >= 1 && n <= widget.surah.ayahCount) {
                  setState(() {
                    _startVerse = n;
                    if (_endVerse < _startVerse) {
                      _endVerse = _startVerse;
                      _endController.text = '$_endVerse';
                    }
                  });
                }
              },
            ),
            const SizedBox(height: 20),

            // End Verse
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                Locales.string(context, 'tikrar_end_verse').toUpperCase(),
                style: typo.bodySmall.copyWith(
                  color: colors.goldDim,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 8),
            _NumberPickerRow(
              controller: _endController,
              onDecrement: () => _updateEnd(-1),
              onIncrement: () => _updateEnd(1),
              onChanged: (val) {
                final n = int.tryParse(val);
                if (n != null &&
                    n >= _startVerse &&
                    n <= widget.surah.ayahCount) {
                  setState(() => _endVerse = n);
                }
              },
            ),
            const SizedBox(height: 20),

            // Repetitions
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                Locales.string(context, 'tikrar_repetitions').toUpperCase(),
                style: typo.bodySmall.copyWith(
                  color: colors.goldDim,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 8),
            _NumberPickerRow(
              controller: _repController,
              onDecrement: () => _updateRep(-1),
              onIncrement: () => _updateRep(1),
              onChanged: (val) {
                final n = int.tryParse(val);
                if (n != null && n >= 2 && n <= 10) {
                  setState(() => _repetitions = n);
                }
              },
            ),
            const SizedBox(height: 20),

            // Reciter
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                Locales.string(context, 'tikrar_reciter').toUpperCase(),
                style: typo.bodySmall.copyWith(
                  color: colors.goldDim,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var i = 1; i <= 5; i++)
                  GestureDetector(
                    onTap: () => setState(() => _reciterId = '$i'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: _reciterId == '$i'
                            ? colors.gold
                            : colors.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _reciterId == '$i'
                              ? colors.gold
                              : colors.textTertiary.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        Locales.string(context, 'reciter_$i'),
                        style: typo.bodySmall.copyWith(
                          color: _reciterId == '$i'
                              ? Colors.white
                              : colors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Summary
            Text(
              '$verseCount ${Locales.string(context, 'tikrar_verses_label')} · $_repetitions ${Locales.string(context, 'tikrar_repetitions').toLowerCase()}',
              style: typo.bodyMedium.copyWith(color: colors.gold),
            ),
            const SizedBox(height: 24),

            // Begin button
            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: () async {
                  final session = await ref
                      .read(tikrarSessionsProvider.notifier)
                      .createSession(
                        surahNumber: widget.surah.number,
                        surahNameArabic: widget.surah.nameArabic,
                        surahNameEnglish: widget.surah.nameEnglish,
                        startVerse: _startVerse,
                        endVerse: _endVerse,
                        repetitions: _repetitions,
                        reciterId: _reciterId,
                      );
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HifzPlayerScreen(session: session),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: colors.gold,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      Locales.string(context, 'tikrar_begin'),
                      style: typo.bodyMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// TAB 2 — Wird (daily reading)
// ═══════════════════════════════════════════════════════════════════════════════

class _WirdTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(wirdConfigNotifierProvider);
    if (config == null) return _WirdEmptyState();
    return _WirdActiveState(config: config);
  }
}

class _WirdEmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final typo = context.typography;
    final colors = context.colors;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_stories_rounded,
              size: 56, color: colors.goldDim.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          Text(
            Locales.string(context, 'wird_set_title'),
            style: typo.titleMedium.copyWith(color: colors.textTertiary),
          ),
          const SizedBox(height: 8),
          Text(
            Locales.string(context, 'wird_set_subtitle'),
            style: typo.bodySmall.copyWith(color: colors.textTertiary),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => _showSetWirdSheet(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.gold),
              ),
              child: Text(
                Locales.string(context, 'wird_set_button'),
                style: typo.bodyMedium.copyWith(
                  color: colors.gold,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WirdActiveState extends ConsumerWidget {
  final WirdConfig config;
  const _WirdActiveState({required this.config});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typo = context.typography;
    final colors = context.colors;
    final completedAsync = ref.watch(wirdCompletedTodayProvider);
    final isDone = completedAsync.valueOrNull ?? false;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ── Wird Card ──
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF0D0D0D)
                : const Color(0xFFF7F5F0),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colors.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                Locales.string(context, 'wird_daily').toUpperCase(),
                style: typo.bodySmall.copyWith(
                  color: colors.goldDim,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${Locales.string(context, 'page')} ${config.currentStartPage} – ${config.endPage}',
                          style: typo.headlineMedium.copyWith(
                            color: colors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${config.pageCount} ${Locales.string(context, 'wird_pages')}',
                          style: typo.bodySmall.copyWith(
                            color: colors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      final isNowCompleted = await ref
                          .read(quranRepositoryProvider)
                          .toggleWirdCompletion();
                      final notifier =
                          ref.read(wirdConfigNotifierProvider.notifier);
                      if (isNowCompleted) {
                        await notifier.onWirdCompleted();
                      } else {
                        await notifier.onWirdUncompleted();
                      }
                      ref.invalidate(wirdCompletedTodayProvider);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDone ? colors.gold : Colors.transparent,
                        border: Border.all(
                          color: colors.gold,
                          width: 2,
                        ),
                      ),
                      child: isDone
                          ? const Icon(Icons.check_rounded,
                              color: Colors.white, size: 28)
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    isDone
                        ? Icons.check_circle_rounded
                        : Icons.circle_outlined,
                    size: 16,
                    color: isDone ? colors.gold : colors.textTertiary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    Locales.string(
                      context,
                      isDone ? 'wird_completed' : 'wird_not_completed',
                    ),
                    style: typo.bodySmall.copyWith(
                      color: isDone ? colors.gold : colors.textTertiary,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      final pageNum = config.currentStartPage;
                      final verseData = quran.getPageData(pageNum);
                      if (verseData.isNotEmpty) {
                        final first = verseData.first;
                        ref.read(readerNavigationProvider.notifier).state =
                            ReaderNavigationRequest(
                          surahNumber: first['surah'] as int,
                          ayahNumber: first['start'] as int,
                        );
                      }
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          Locales.string(context, 'wird_read'),
                          style: typo.bodyMedium.copyWith(
                            color: colors.gold,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Icon(Icons.chevron_right_rounded,
                            color: colors.gold, size: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // ── Reminder row ──
        Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.divider),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _showReminderPicker(context, ref),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Icon(Icons.notifications_outlined,
                      color: colors.textSecondary, size: 22),
                  const SizedBox(width: 12),
                  Text(
                    Locales.string(context, 'wird_reminder'),
                    style: typo.bodyMedium.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    config.hasReminder
                        ? _formatTime(config.reminderHour!, config.reminderMinute!)
                        : Locales.string(context, 'wird_reminder_off'),
                    style: typo.bodyMedium.copyWith(
                      color: colors.textTertiary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.chevron_right_rounded,
                      color: colors.textTertiary, size: 20),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),

        // ── Actions ──
        Row(
          children: [
            GestureDetector(
              onTap: () => _showEditWirdSheet(context),
              child: Text(
                Locales.string(context, 'wird_change'),
                style: typo.bodyMedium.copyWith(
                  color: colors.gold,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => _showClearConfirmation(context, ref),
              child: Text(
                Locales.string(context, 'wird_clear'),
                style: typo.bodyMedium.copyWith(
                  color: colors.textTertiary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatTime(int hour, int minute) {
    final h = hour % 12 == 0 ? 12 : hour % 12;
    final period = hour < 12 ? 'AM' : 'PM';
    return '${h.toString()}:${minute.toString().padLeft(2, '0')} $period';
  }

  void _showReminderPicker(BuildContext context, WidgetRef ref) async {
    final config = ref.read(wirdConfigNotifierProvider);
    final initial = config?.hasReminder == true
        ? TimeOfDay(hour: config!.reminderHour!, minute: config.reminderMinute!)
        : TimeOfDay.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            textTheme: Theme.of(context).textTheme.apply(
                  fontFamily: 'NeueFrutigerWorld',
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      await NotificationService.requestPermission();
      await ref
          .read(wirdConfigNotifierProvider.notifier)
          .setReminder(picked.hour, picked.minute);
      await NotificationService.scheduleDailyWirdReminder(
        picked.hour,
        picked.minute,
        title: Locales.string(context, 'wird_notification_title'),
        body: Locales.string(context, 'wird_notification_body'),
      );
    }
  }

  void _showClearConfirmation(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typo = context.typography;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          Locales.string(context, 'wird_clear'),
          style: typo.titleMedium.copyWith(color: colors.textPrimary),
        ),
        content: Text(
          Locales.string(context, 'wird_clear_confirm'),
          style: typo.bodyMedium.copyWith(color: colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              Locales.string(context, 'wird_cancel'),
              style: typo.bodyMedium.copyWith(color: colors.textTertiary),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await NotificationService.cancelWirdReminder();
              await ref
                  .read(wirdConfigNotifierProvider.notifier)
                  .clearWird();
            },
            child: Text(
              Locales.string(context, 'wird_confirm'),
              style: typo.bodyMedium.copyWith(color: colors.gold),
            ),
          ),
        ],
      ),
    );
  }
}

void _showSetWirdSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _SetWirdSheet(),
  );
}

void _showEditWirdSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _EditWirdSheet(),
  );
}

// ── Setup sheet (pages per day only) ──

class _SetWirdSheet extends ConsumerStatefulWidget {
  const _SetWirdSheet();

  @override
  ConsumerState<_SetWirdSheet> createState() => _SetWirdSheetState();
}

class _SetWirdSheetState extends ConsumerState<_SetWirdSheet> {
  late final TextEditingController _controller;
  int _pageCount = 5;

  @override
  void initState() {
    super.initState();
    final config = ref.read(wirdConfigNotifierProvider);
    _pageCount = config?.pageCount ?? 5;
    _controller = TextEditingController(text: '$_pageCount');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _update(int delta) {
    setState(() {
      _pageCount = (_pageCount + delta).clamp(1, 604);
      _controller.text = '$_pageCount';
    });
  }

  @override
  Widget build(BuildContext context) {
    final typo = context.typography;
    final colors = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
          20, 12, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            Locales.string(context, 'wird_set_title'),
            style: typo.headlineMedium.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            Locales.string(context, 'wird_set_subtitle'),
            style: typo.bodySmall.copyWith(color: colors.textTertiary),
          ),
          const SizedBox(height: 24),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              Locales.string(context, 'wird_per_day').toUpperCase(),
              style: typo.bodySmall.copyWith(
                color: colors.goldDim,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),
          _NumberPickerRow(
            controller: _controller,
            onDecrement: () => _update(-1),
            onIncrement: () => _update(1),
            onChanged: (val) {
              final n = int.tryParse(val);
              if (n != null && n >= 1 && n <= 604) {
                setState(() => _pageCount = n);
              }
            },
          ),
          const SizedBox(height: 16),
          Text(
            '$_pageCount ${Locales.string(context, 'wird_pages')}',
            style: typo.bodyMedium.copyWith(color: colors.gold),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: () {
                ref
                    .read(wirdConfigNotifierProvider.notifier)
                    .setWird(_pageCount);
                Navigator.pop(context);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: colors.gold,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    Locales.string(context, 'wird_set_button'),
                    style: typo.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Edit sheet (start page + pages per day) ──

class _EditWirdSheet extends ConsumerStatefulWidget {
  const _EditWirdSheet();

  @override
  ConsumerState<_EditWirdSheet> createState() => _EditWirdSheetState();
}

class _EditWirdSheetState extends ConsumerState<_EditWirdSheet> {
  late final TextEditingController _startController;
  late final TextEditingController _countController;
  int _startPage = 1;
  int _pageCount = 5;

  @override
  void initState() {
    super.initState();
    final config = ref.read(wirdConfigNotifierProvider);
    _startPage = config?.currentStartPage ?? 1;
    _pageCount = config?.pageCount ?? 5;
    _startController = TextEditingController(text: '$_startPage');
    _countController = TextEditingController(text: '$_pageCount');
  }

  @override
  void dispose() {
    _startController.dispose();
    _countController.dispose();
    super.dispose();
  }

  void _updateStart(int delta) {
    setState(() {
      _startPage = (_startPage + delta).clamp(1, 604);
      _startController.text = '$_startPage';
    });
  }

  void _updateCount(int delta) {
    setState(() {
      _pageCount = (_pageCount + delta).clamp(1, 604);
      _countController.text = '$_pageCount';
    });
  }

  @override
  Widget build(BuildContext context) {
    final typo = context.typography;
    final colors = context.colors;
    final endPage = (_startPage + _pageCount - 1).clamp(1, 604);

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
          20, 12, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            Locales.string(context, 'wird_change'),
            style: typo.headlineMedium.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          // Start page
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              Locales.string(context, 'wird_start_page').toUpperCase(),
              style: typo.bodySmall.copyWith(
                color: colors.goldDim,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),
          _NumberPickerRow(
            controller: _startController,
            onDecrement: () => _updateStart(-1),
            onIncrement: () => _updateStart(1),
            onChanged: (val) {
              final n = int.tryParse(val);
              if (n != null && n >= 1 && n <= 604) {
                setState(() => _startPage = n);
              }
            },
          ),
          const SizedBox(height: 20),

          // Pages per day
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              Locales.string(context, 'wird_per_day').toUpperCase(),
              style: typo.bodySmall.copyWith(
                color: colors.goldDim,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),
          _NumberPickerRow(
            controller: _countController,
            onDecrement: () => _updateCount(-1),
            onIncrement: () => _updateCount(1),
            onChanged: (val) {
              final n = int.tryParse(val);
              if (n != null && n >= 1 && n <= 604) {
                setState(() => _pageCount = n);
              }
            },
          ),
          const SizedBox(height: 16),

          // Summary
          Text(
            '${Locales.string(context, 'page')} $_startPage – $endPage',
            style: typo.bodyMedium.copyWith(color: colors.gold),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: () {
                ref
                    .read(wirdConfigNotifierProvider.notifier)
                    .editWird(_startPage, _pageCount);
                Navigator.pop(context);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: colors.gold,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    Locales.string(context, 'wird_confirm'),
                    style: typo.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared number picker row ──

class _NumberPickerRow extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final ValueChanged<String> onChanged;

  const _NumberPickerRow({
    required this.controller,
    required this.onDecrement,
    required this.onIncrement,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final typo = context.typography;
    final colors = context.colors;

    return Row(
      children: [
        IconButton(
          onPressed: onDecrement,
          icon: Icon(Icons.remove_rounded, color: colors.textSecondary),
          style: IconButton.styleFrom(
            backgroundColor: colors.divider.withValues(alpha: 0.5),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: typo.headlineMedium.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colors.divider),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colors.divider),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colors.gold),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onChanged: onChanged,
          ),
        ),
        const SizedBox(width: 12),
        IconButton(
          onPressed: onIncrement,
          icon: Icon(Icons.add_rounded, color: colors.textSecondary),
          style: IconButton.styleFrom(
            backgroundColor: colors.divider.withValues(alpha: 0.5),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// TAB — Khatmah (complete Quran reading)
// ═══════════════════════════════════════════════════════════════════════════════

class _KhatmahTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(khatmahConfigNotifierProvider);
    if (config == null) return _KhatmahEmptyState();
    if (config.isComplete) return _KhatmahCompleteState();
    return _KhatmahActiveState(config: config);
  }
}

class _KhatmahEmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final typo = context.typography;
    final colors = context.colors;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.menu_book_rounded,
              size: 56, color: colors.goldDim.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          Text(
            Locales.string(context, 'khatmah_set_title'),
            style: typo.titleMedium.copyWith(color: colors.textTertiary),
          ),
          const SizedBox(height: 8),
          Text(
            Locales.string(context, 'khatmah_set_subtitle'),
            style: typo.bodySmall.copyWith(color: colors.textTertiary),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => _showSetKhatmahSheet(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.gold),
              ),
              child: Text(
                Locales.string(context, 'khatmah_set_button'),
                style: typo.bodyMedium.copyWith(
                  color: colors.gold,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _KhatmahCompleteState extends ConsumerStatefulWidget {
  @override
  ConsumerState<_KhatmahCompleteState> createState() =>
      _KhatmahCompleteStateState();
}

class _KhatmahCompleteStateState extends ConsumerState<_KhatmahCompleteState>
    with TickerProviderStateMixin {
  late final AnimationController _iconController;
  late final AnimationController _contentController;
  late final Animation<double> _iconScale;
  late final Animation<double> _contentFade;
  late final Animation<Offset> _contentSlide;

  @override
  void initState() {
    super.initState();
    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _iconScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.2), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 0.9), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.0), weight: 20),
    ]).animate(CurvedAnimation(
      parent: _iconController,
      curve: Curves.easeOut,
    ));

    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _contentFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeOut),
    );
    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOutCubic,
    ));

    _iconController.forward();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _contentController.forward();
    });
  }

  @override
  void dispose() {
    _iconController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final typo = context.typography;
    final colors = context.colors;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Animated Icon ──
            ScaleTransition(
              scale: _iconScale,
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.gold.withValues(alpha: 0.12),
                ),
                child: Icon(Icons.check_rounded,
                    size: 52, color: colors.gold),
              ),
            ),
            const SizedBox(height: 24),

            // ── Animated Content ──
            SlideTransition(
              position: _contentSlide,
              child: FadeTransition(
                opacity: _contentFade,
                child: Column(
                  children: [
                    Text(
                      Locales.string(context, 'khatmah_complete_title'),
                      style: typo.headlineMedium.copyWith(
                        color: colors.gold,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      Locales.string(context, 'khatmah_complete_subtitle'),
                      style: typo.bodyMedium.copyWith(
                        color: colors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // ── New Khatmah Button ──
                    SizedBox(
                      width: double.infinity,
                      child: GestureDetector(
                        onTap: () => _showSetKhatmahSheet(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: colors.gold,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              Locales.string(context, 'khatmah_new'),
                              style: typo.bodyMedium.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ── End Khatmah Button ──
                    SizedBox(
                      width: double.infinity,
                      child: GestureDetector(
                        onTap: () => ref
                            .read(khatmahConfigNotifierProvider.notifier)
                            .clearKhatmah(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: colors.divider),
                          ),
                          child: Center(
                            child: Text(
                              Locales.string(context, 'khatmah_clear'),
                              style: typo.bodyMedium.copyWith(
                                color: colors.textTertiary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KhatmahActiveState extends ConsumerStatefulWidget {
  final KhatmahConfig config;
  const _KhatmahActiveState({required this.config});

  @override
  ConsumerState<_KhatmahActiveState> createState() =>
      _KhatmahActiveStateState();
}

class _KhatmahActiveStateState extends ConsumerState<_KhatmahActiveState>
    with SingleTickerProviderStateMixin {
  late final AnimationController _checkController;
  late final Animation<double> _scaleAnim;

  KhatmahConfig get config => widget.config;

  @override
  void initState() {
    super.initState();
    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 0.9), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.0), weight: 30),
    ]).animate(CurvedAnimation(
      parent: _checkController,
      curve: Curves.easeOut,
    ));
    if (config.completedDays >= config.currentDay) {
      _checkController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _checkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final typo = context.typography;
    final colors = context.colors;
    final isDone = config.completedDays >= config.currentDay;

    final estimatedEnd = config.estimatedEndDate;
    final endFormatted =
        '${estimatedEnd.year}-${estimatedEnd.month.toString().padLeft(2, '0')}-${estimatedEnd.day.toString().padLeft(2, '0')}';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ── Khatmah Card ──
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF0D0D0D)
                : const Color(0xFFF7F5F0),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colors.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    Locales.string(context, 'khatmah_daily').toUpperCase(),
                    style: typo.bodySmall.copyWith(
                      color: colors.goldDim,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${Locales.string(context, 'khatmah_day_of')} ${config.currentDay} / ${config.totalDays}',
                    style: typo.bodySmall.copyWith(
                      color: colors.textTertiary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${Locales.string(context, 'page')} ${config.todayStartPage} – ${config.todayEndPage}',
                          style: typo.headlineMedium.copyWith(
                            color: colors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${config.pagesPerDay} ${Locales.string(context, 'khatmah_pages_per_day')}',
                          style: typo.bodySmall.copyWith(
                            color: colors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      final notifier =
                          ref.read(khatmahConfigNotifierProvider.notifier);
                      if (isDone) {
                        _checkController.reverse();
                        await notifier.onDayUncompleted();
                      } else {
                        _checkController.forward(from: 0.0);
                        await notifier.onDayCompleted();
                      }
                    },
                    child: ScaleTransition(
                      scale: _scaleAnim,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDone ? colors.gold : Colors.transparent,
                          border: Border.all(
                            color: colors.gold,
                            width: 2,
                          ),
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          transitionBuilder: (child, anim) => ScaleTransition(
                            scale: anim,
                            child: child,
                          ),
                          child: isDone
                              ? const Icon(Icons.check_rounded,
                                  key: ValueKey('check'),
                                  color: Colors.white,
                                  size: 28)
                              : const SizedBox.shrink(
                                  key: ValueKey('empty')),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (config.lastReadPage != null && !isDone) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.bookmark_rounded,
                        size: 14, color: colors.gold.withValues(alpha: 0.6)),
                    const SizedBox(width: 4),
                    Text(
                      '${Locales.string(context, 'page')} ${config.lastReadPage}',
                      style: typo.bodySmall.copyWith(
                        color: colors.gold,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, anim) => ScaleTransition(
                      scale: anim,
                      child: child,
                    ),
                    child: Icon(
                      isDone
                          ? Icons.check_circle_rounded
                          : Icons.circle_outlined,
                      key: ValueKey(isDone),
                      size: 16,
                      color: isDone ? colors.gold : colors.textTertiary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      Locales.string(
                        context,
                        isDone ? 'khatmah_completed' : 'khatmah_not_completed',
                      ),
                      key: ValueKey(isDone),
                      style: typo.bodySmall.copyWith(
                        color: isDone ? colors.gold : colors.textTertiary,
                      ),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      ref.read(khatmahConfigNotifierProvider.notifier).resumeKhatmah();
                      final pageNum = config.lastReadPage ?? config.todayStartPage;
                      final verseData = quran.getPageData(pageNum);
                      if (verseData.isNotEmpty) {
                        final first = verseData.first;
                        ref.read(readerNavigationProvider.notifier).state =
                            ReaderNavigationRequest(
                          surahNumber: first['surah'] as int,
                          ayahNumber: first['start'] as int,
                        );
                      }
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          Locales.string(context, 'khatmah_read'),
                          style: typo.bodyMedium.copyWith(
                            color: colors.gold,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Icon(Icons.chevron_right_rounded,
                            color: colors.gold, size: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // ── Overall Progress ──
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                Locales.string(context, 'khatmah_progress').toUpperCase(),
                style: typo.bodySmall.copyWith(
                  color: colors.goldDim,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: config.overallProgress),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) => ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: value,
                    backgroundColor: colors.gold.withValues(alpha: 0.15),
                    valueColor: AlwaysStoppedAnimation<Color>(colors.gold),
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AnimatedFlipCounter(
                    value: (config.overallProgress * 100).round(),
                    suffix: '%',
                    duration: const Duration(milliseconds: 600),
                    textStyle: typo.bodySmall.copyWith(
                      color: colors.gold,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedFlipCounter(
                        value: config.completedPages,
                        duration: const Duration(milliseconds: 600),
                        textStyle: typo.bodySmall.copyWith(
                          color: colors.textTertiary,
                        ),
                      ),
                      Text(
                        ' / 604',
                        style: typo.bodySmall.copyWith(
                          color: colors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // ── Estimated completion ──
        Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.divider),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(Icons.calendar_today_rounded,
                    color: colors.textSecondary, size: 22),
                const SizedBox(width: 12),
                Text(
                  Locales.string(context, 'khatmah_estimated_end'),
                  style: typo.bodyMedium.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                const Spacer(),
                Text(
                  endFormatted,
                  style: typo.bodyMedium.copyWith(
                    color: colors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // ── Reminder row ──
        Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.divider),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _showKhatmahReminderPicker(context, ref),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Icon(Icons.notifications_outlined,
                      color: colors.textSecondary, size: 22),
                  const SizedBox(width: 12),
                  Text(
                    Locales.string(context, 'khatmah_reminder'),
                    style: typo.bodyMedium.copyWith(
                      color: colors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    config.hasReminder
                        ? _formatTime(config.reminderHour!, config.reminderMinute!)
                        : Locales.string(context, 'khatmah_reminder_off'),
                    style: typo.bodyMedium.copyWith(
                      color: colors.textTertiary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.chevron_right_rounded,
                      color: colors.textTertiary, size: 20),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),

        // ── Actions ──
        Row(
          children: [
            GestureDetector(
              onTap: () => _showEditKhatmahSheet(context),
              child: Text(
                Locales.string(context, 'khatmah_change'),
                style: typo.bodyMedium.copyWith(
                  color: colors.gold,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => _showKhatmahClearConfirmation(context, ref),
              child: Text(
                Locales.string(context, 'khatmah_clear'),
                style: typo.bodyMedium.copyWith(
                  color: colors.textTertiary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatTime(int hour, int minute) {
    final h = hour % 12 == 0 ? 12 : hour % 12;
    final period = hour < 12 ? 'AM' : 'PM';
    return '${h.toString()}:${minute.toString().padLeft(2, '0')} $period';
  }

  void _showKhatmahReminderPicker(BuildContext context, WidgetRef ref) async {
    final config = ref.read(khatmahConfigNotifierProvider);
    final initial = config?.hasReminder == true
        ? TimeOfDay(hour: config!.reminderHour!, minute: config.reminderMinute!)
        : TimeOfDay.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            textTheme: Theme.of(context).textTheme.apply(
                  fontFamily: 'NeueFrutigerWorld',
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      await NotificationService.requestPermission();
      await ref
          .read(khatmahConfigNotifierProvider.notifier)
          .setReminder(picked.hour, picked.minute);
      await NotificationService.scheduleDailyWirdReminder(
        picked.hour,
        picked.minute,
        title: Locales.string(context, 'khatmah_notification_title'),
        body: Locales.string(context, 'khatmah_notification_body'),
      );
    }
  }

  void _showKhatmahClearConfirmation(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typo = context.typography;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          Locales.string(context, 'khatmah_clear'),
          style: typo.titleMedium.copyWith(color: colors.textPrimary),
        ),
        content: Text(
          Locales.string(context, 'khatmah_clear_confirm'),
          style: typo.bodyMedium.copyWith(color: colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              Locales.string(context, 'khatmah_cancel'),
              style: typo.bodyMedium.copyWith(color: colors.textTertiary),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref
                  .read(khatmahConfigNotifierProvider.notifier)
                  .clearKhatmah();
            },
            child: Text(
              Locales.string(context, 'khatmah_confirm'),
              style: typo.bodyMedium.copyWith(color: colors.gold),
            ),
          ),
        ],
      ),
    );
  }
}

void _showEditKhatmahSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _EditKhatmahSheet(),
  );
}

void _showSetKhatmahSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _SetKhatmahSheet(),
  );
}

class _SetKhatmahSheet extends ConsumerStatefulWidget {
  const _SetKhatmahSheet();

  @override
  ConsumerState<_SetKhatmahSheet> createState() => _SetKhatmahSheetState();
}

class _SetKhatmahSheetState extends ConsumerState<_SetKhatmahSheet> {
  late final TextEditingController _controller;
  int _totalDays = 30;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '$_totalDays');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _update(int delta) {
    setState(() {
      _totalDays = (_totalDays + delta).clamp(1, 365);
      _controller.text = '$_totalDays';
    });
  }

  void _setPreset(int days) {
    setState(() {
      _totalDays = days;
      _controller.text = '$_totalDays';
    });
  }

  @override
  Widget build(BuildContext context) {
    final typo = context.typography;
    final colors = context.colors;
    final pagesPerDay = (604 / _totalDays).ceil();

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
          20, 12, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            Locales.string(context, 'khatmah_set_title'),
            style: typo.headlineMedium.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            Locales.string(context, 'khatmah_set_subtitle'),
            style: typo.bodySmall.copyWith(color: colors.textTertiary),
          ),
          const SizedBox(height: 20),

          // ── Presets ──
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [10, 15, 30, 60].map((days) {
              final selected = _totalDays == days;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: GestureDetector(
                  onTap: () => _setPreset(days),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected
                          ? colors.gold
                          : colors.gold.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$days',
                      style: typo.bodySmall.copyWith(
                        color: selected ? Colors.white : colors.gold,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // ── Custom number picker ──
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              Locales.string(context, 'khatmah_days').toUpperCase(),
              style: typo.bodySmall.copyWith(
                color: colors.goldDim,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),
          _NumberPickerRow(
            controller: _controller,
            onDecrement: () => _update(-1),
            onIncrement: () => _update(1),
            onChanged: (val) {
              final n = int.tryParse(val);
              if (n != null && n >= 1 && n <= 365) {
                setState(() => _totalDays = n);
              }
            },
          ),
          const SizedBox(height: 16),
          Text(
            '$pagesPerDay ${Locales.string(context, 'khatmah_pages_per_day')}',
            style: typo.bodyMedium.copyWith(color: colors.gold),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: () {
                ref
                    .read(khatmahConfigNotifierProvider.notifier)
                    .startKhatmah(_totalDays);
                Navigator.pop(context);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: colors.gold,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    Locales.string(context, 'khatmah_set_button'),
                    style: typo.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EditKhatmahSheet extends ConsumerStatefulWidget {
  const _EditKhatmahSheet();

  @override
  ConsumerState<_EditKhatmahSheet> createState() => _EditKhatmahSheetState();
}

class _EditKhatmahSheetState extends ConsumerState<_EditKhatmahSheet> {
  late final TextEditingController _controller;
  int _totalDays = 30;

  @override
  void initState() {
    super.initState();
    final config = ref.read(khatmahConfigNotifierProvider);
    _totalDays = config?.totalDays ?? 30;
    _controller = TextEditingController(text: '$_totalDays');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _update(int delta) {
    setState(() {
      _totalDays = (_totalDays + delta).clamp(1, 365);
      _controller.text = '$_totalDays';
    });
  }

  void _setPreset(int days) {
    setState(() {
      _totalDays = days;
      _controller.text = '$_totalDays';
    });
  }

  @override
  Widget build(BuildContext context) {
    final typo = context.typography;
    final colors = context.colors;
    final pagesPerDay = (604 / _totalDays).ceil();

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
          20, 12, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            Locales.string(context, 'khatmah_change'),
            style: typo.headlineMedium.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // ── Presets ──
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [10, 15, 30, 60].map((days) {
              final selected = _totalDays == days;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: GestureDetector(
                  onTap: () => _setPreset(days),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected
                          ? colors.gold
                          : colors.gold.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$days',
                      style: typo.bodySmall.copyWith(
                        color: selected ? Colors.white : colors.gold,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // ── Custom number picker ──
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              Locales.string(context, 'khatmah_days').toUpperCase(),
              style: typo.bodySmall.copyWith(
                color: colors.goldDim,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),
          _NumberPickerRow(
            controller: _controller,
            onDecrement: () => _update(-1),
            onIncrement: () => _update(1),
            onChanged: (val) {
              final n = int.tryParse(val);
              if (n != null && n >= 1 && n <= 365) {
                setState(() => _totalDays = n);
              }
            },
          ),
          const SizedBox(height: 16),
          Text(
            '$pagesPerDay ${Locales.string(context, 'khatmah_pages_per_day')}',
            style: typo.bodyMedium.copyWith(color: colors.gold),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: () {
                ref
                    .read(khatmahConfigNotifierProvider.notifier)
                    .editKhatmah(_totalDays);
                Navigator.pop(context);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: colors.gold,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    Locales.string(context, 'khatmah_confirm'),
                    style: typo.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// TAB 3 — Progress (page-by-page memorization tracking)
// ═══════════════════════════════════════════════════════════════════════════════

class _ProgressTab extends ConsumerStatefulWidget {
  @override
  ConsumerState<_ProgressTab> createState() => _ProgressTabState();
}

class _ProgressTabState extends ConsumerState<_ProgressTab> {
  int? _expandedJuz;
  bool _showSurahs = false;

  @override
  Widget build(BuildContext context) {
    final memorizedAsync = ref.watch(memorizedPagesProvider);
    final juzRangesAsync = ref.watch(juzPageRangesProvider);
    final surahRangesAsync = ref.watch(juzSurahPageRangesProvider);
    final typo = context.typography;
    final colors = context.colors;

    return memorizedAsync.when(
      data: (memorized) => juzRangesAsync.when(
        data: (juzRanges) => surahRangesAsync.when(
          data: (surahRanges) => _buildContent(
              context, memorized, juzRanges, surahRanges, typo, colors),
          loading: () => Center(
            child: CircularProgressIndicator(color: colors.gold),
          ),
          error: (_, __) => const SizedBox.shrink(),
        ),
        loading: () => Center(
          child: CircularProgressIndicator(color: colors.gold),
        ),
        error: (_, __) => const SizedBox.shrink(),
      ),
      loading: () => Center(
        child: CircularProgressIndicator(color: colors.gold),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildContent(
    BuildContext context,
    Set<int> memorized,
    List<Map<String, int>> juzRanges,
    List<Map<String, dynamic>> surahRanges,
    AppTypography typo,
    AppColorScheme colors,
  ) {
    final locale = Locales.currentLocale(context)?.languageCode ?? 'en';
    final isArabic = locale == 'ar';
    const totalPages = quran.totalPagesCount;
    final memorizedCount = memorized.length;
    final progress = totalPages > 0 ? memorizedCount / totalPages : 0.0;

    // Group surah ranges by juz number (for Pages view)
    final surahsByJuz = <int, List<Map<String, dynamic>>>{};
    for (final row in surahRanges) {
      final juz = row['juz'] as int;
      surahsByJuz.putIfAbsent(juz, () => []).add(row);
    }

    // Merge surah ranges across juz (for Surahs view)
    final mergedSurahs = <int, Map<String, dynamic>>{};
    for (final row in surahRanges) {
      final num = row['surah_number'] as int;
      if (mergedSurahs.containsKey(num)) {
        final e = mergedSurahs[num]!;
        final sp = row['start_page'] as int;
        final ep = row['end_page'] as int;
        if (sp < (e['start_page'] as int)) e['start_page'] = sp;
        if (ep > (e['end_page'] as int)) e['end_page'] = ep;
      } else {
        mergedSurahs[num] = Map<String, dynamic>.from(row);
      }
    }
    final surahList = mergedSurahs.values.toList()
      ..sort((a, b) =>
          (a['surah_number'] as int).compareTo(b['surah_number'] as int));

    final sectionKey =
        _showSurahs ? 'surahs_section' : 'hifz_juz_section';
    final sectionCount =
        _showSurahs ? surahList.length : juzRanges.length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        _OverallProgressCard(
          memorizedCount: memorizedCount,
          totalPages: totalPages,
          progress: progress,
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 4, bottom: 8),
          child: Row(
            children: [
              Text(
                Locales.string(context, sectionKey).toUpperCase(),
                style: typo.bodySmall.copyWith(
                  color: colors.goldDim,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: colors.goldDim.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$sectionCount',
                  style: typo.bodySmall.copyWith(
                    color: colors.goldDim,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              _ViewToggleChip(
                labelKey: 'view_pages',
                isSelected: !_showSurahs,
                onTap: () => setState(() => _showSurahs = false),
              ),
              const SizedBox(width: 6),
              _ViewToggleChip(
                labelKey: 'view_surahs',
                isSelected: _showSurahs,
                onTap: () => setState(() => _showSurahs = true),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        if (_showSurahs)
          for (int i = 0; i < surahList.length; i++) ...[
            _SurahCard(
              surah: surahList[i],
              memorized: memorized,
              isArabic: isArabic,
              onToggleSurah: (pages, shouldMark) =>
                  _toggleSurah(pages, shouldMark),
            ),
            if (i < surahList.length - 1) const SizedBox(height: 10),
          ]
        else
          for (int i = 0; i < juzRanges.length; i++) ...[
            _JuzCard(
              juz: juzRanges[i]['juz']!,
              startPage: juzRanges[i]['startPage']!,
              endPage: juzRanges[i]['endPage']!,
              memorized: memorized,
              isExpanded: _expandedJuz == juzRanges[i]['juz'],
              locale: locale,
              isArabic: isArabic,
              surahs: surahsByJuz[juzRanges[i]['juz']!] ?? [],
              onToggleExpand: () {
                setState(() {
                  final juz = juzRanges[i]['juz']!;
                  _expandedJuz = _expandedJuz == juz ? null : juz;
                });
              },
              onTogglePage: (page) => _togglePage(page),
            ),
            if (i < juzRanges.length - 1) const SizedBox(height: 10),
          ],
        const SizedBox(height: 32),
      ],
    );
  }

  Future<void> _togglePage(int page) async {
    await ref.read(quranRepositoryProvider).togglePageMemorized(page);
    ref.invalidate(memorizedPagesProvider);
  }

  Future<void> _toggleSurah(List<int> pages, bool shouldMark) async {
    await ref
        .read(quranRepositoryProvider)
        .bulkSetMemorized(pages, shouldMark);
    ref.invalidate(memorizedPagesProvider);
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SHARED WIDGETS
// ═══════════════════════════════════════════════════════════════════════════════

class _OverallProgressCard extends StatelessWidget {
  final int memorizedCount;
  final int totalPages;
  final double progress;

  const _OverallProgressCard({
    required this.memorizedCount,
    required this.totalPages,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final typo = context.typography;
    final colors = context.colors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF0D0D0D)
            : const Color(0xFFF7F5F0),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.divider),
      ),
      child: Column(
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress),
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOutCubic,
            builder: (context, animatedProgress, child) {
              return Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: ProgressBorder.all(
                    color: colors.gold,
                    width: 8,
                    progress: animatedProgress,
                    backgroundColor: colors.divider,
                  ),
                ),
                child: child,
              );
            },
            child: Center(
              child: AnimatedFlipCounter(
                value: progress * 100,
                fractionDigits: 1,
                suffix: '%',
                duration: const Duration(milliseconds: 150),
                textStyle: typo.headlineMedium.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedFlipCounter(
                value: memorizedCount,
                duration: const Duration(milliseconds: 150),
                textStyle: typo.bodyLarge.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              Text(
                ' ${Locales.string(context, 'hifz_of_pages')}',
                style: typo.bodyLarge.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _JuzCard extends StatelessWidget {
  final int juz;
  final int startPage;
  final int endPage;
  final Set<int> memorized;
  final bool isExpanded;
  final String locale;
  final bool isArabic;
  final List<Map<String, dynamic>> surahs;
  final VoidCallback onToggleExpand;
  final ValueChanged<int> onTogglePage;

  const _JuzCard({
    required this.juz,
    required this.startPage,
    required this.endPage,
    required this.memorized,
    required this.isExpanded,
    required this.locale,
    required this.isArabic,
    required this.surahs,
    required this.onToggleExpand,
    required this.onTogglePage,
  });

  @override
  Widget build(BuildContext context) {
    final typo = context.typography;
    final colors = context.colors;

    final totalInJuz = endPage - startPage + 1;
    final memorizedInJuz = List.generate(totalInJuz, (i) => startPage + i)
        .where((p) => memorized.contains(p))
        .length;
    final juzProgress = totalInJuz > 0 ? memorizedInJuz / totalInJuz : 0.0;

    final juzLabel = isArabic
        ? '${Locales.string(context, 'juz_label')} ${ordinal(juz, locale)}'
        : '${Locales.string(context, 'juz_label')} $juz';

    return Container(
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.divider),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          InkWell(
            onTap: onToggleExpand,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: colors.gold.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            '$juz',
                            style: typo.bodyMedium.copyWith(
                              color: colors.gold,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              juzLabel,
                              style: typo.bodyMedium.copyWith(
                                color: colors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${Locales.string(context, 'page')} $startPage – $endPage',
                              style: typo.bodySmall.copyWith(
                                color: colors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedFlipCounter(
                            value: memorizedInJuz,
                            duration: const Duration(milliseconds: 150),
                            textStyle: typo.bodySmall.copyWith(
                              color: memorizedInJuz == totalInJuz
                                  ? colors.gold
                                  : colors.textTertiary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '/$totalInJuz',
                            style: typo.bodySmall.copyWith(
                              color: memorizedInJuz == totalInJuz
                                  ? colors.gold
                                  : colors.textTertiary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      AnimatedRotation(
                        turns: isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: colors.textTertiary,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: juzProgress),
                    duration: const Duration(milliseconds: 150),
                    curve: Curves.easeOutCubic,
                    builder: (context, animatedValue, _) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: animatedValue,
                          minHeight: 4,
                          backgroundColor: colors.divider,
                          valueColor: AlwaysStoppedAnimation(
                            colors.gold,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: isExpanded
                ? _JuzSurahsGrid(
                    surahs: surahs,
                    memorized: memorized,
                    isArabic: isArabic,
                    onTogglePage: onTogglePage,
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _ViewToggleChip extends StatelessWidget {
  final String labelKey;
  final bool isSelected;
  final VoidCallback onTap;

  const _ViewToggleChip({
    required this.labelKey,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typography;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.gold.withValues(alpha: 0.12)
              : colors.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? colors.gold.withValues(alpha: 0.5)
                : colors.divider,
          ),
        ),
        child: Text(
          Locales.string(context, labelKey),
          style: typo.bodySmall.copyWith(
            color: isSelected ? colors.gold : colors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _SurahCard extends StatelessWidget {
  final Map<String, dynamic> surah;
  final Set<int> memorized;
  final bool isArabic;
  final void Function(List<int> pages, bool shouldMark) onToggleSurah;

  const _SurahCard({
    required this.surah,
    required this.memorized,
    required this.isArabic,
    required this.onToggleSurah,
  });

  @override
  Widget build(BuildContext context) {
    final typo = context.typography;
    final colors = context.colors;

    final surahNumber = surah['surah_number'] as int;
    final nameArabic = surah['name_arabic'] as String;
    final nameEnglish = surah['name_english'] as String;
    final startPage = surah['start_page'] as int;
    final endPage = surah['end_page'] as int;
    final pages = List.generate(endPage - startPage + 1, (i) => startPage + i);
    final memorizedCount = pages.where((p) => memorized.contains(p)).length;
    final totalPages = pages.length;
    final allMemorized = memorizedCount == totalPages;
    final progress = totalPages > 0 ? memorizedCount / totalPages : 0.0;

    return GestureDetector(
      onTap: () => onToggleSurah(pages, !allMemorized),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: allMemorized
                ? colors.gold.withValues(alpha: 0.4)
                : colors.divider,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: colors.gold.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      '$surahNumber',
                      style: typo.bodyMedium.copyWith(
                        color: colors.gold,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isArabic ? nameArabic : nameEnglish,
                        style: typo.bodyMedium.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$totalPages ${Locales.string(context, 'view_pages').toLowerCase()}',
                        style: typo.bodySmall.copyWith(
                          color: colors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedFlipCounter(
                      value: memorizedCount,
                      duration: const Duration(milliseconds: 150),
                      textStyle: typo.bodySmall.copyWith(
                        color: allMemorized ? colors.gold : colors.textTertiary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '/$totalPages',
                      style: typo.bodySmall.copyWith(
                        color: allMemorized ? colors.gold : colors.textTertiary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                Icon(
                  allMemorized
                      ? Icons.check_circle_rounded
                      : Icons.circle_outlined,
                  color: allMemorized
                      ? colors.gold
                      : colors.textTertiary.withValues(alpha: 0.3),
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 4,
                backgroundColor: colors.divider,
                valueColor: AlwaysStoppedAnimation(
                  colors.gold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _JuzSurahsGrid extends StatelessWidget {
  final List<Map<String, dynamic>> surahs;
  final Set<int> memorized;
  final bool isArabic;
  final ValueChanged<int> onTogglePage;

  const _JuzSurahsGrid({
    required this.surahs,
    required this.memorized,
    required this.isArabic,
    required this.onTogglePage,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Column(
        children: [
          Divider(color: colors.divider, height: 1),
          for (final surah in surahs)
            _SurahSection(
              surah: surah,
              memorized: memorized,
              isArabic: isArabic,
              onTogglePage: onTogglePage,
            ),
        ],
      ),
    );
  }
}

class _SurahSection extends StatelessWidget {
  final Map<String, dynamic> surah;
  final Set<int> memorized;
  final bool isArabic;
  final ValueChanged<int> onTogglePage;

  const _SurahSection({
    required this.surah,
    required this.memorized,
    required this.isArabic,
    required this.onTogglePage,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typography;

    final surahNumber = surah['surah_number'] as int;
    final nameArabic = surah['name_arabic'] as String;
    final nameEnglish = surah['name_english'] as String;
    final startPage = surah['start_page'] as int;
    final endPage = surah['end_page'] as int;
    final pages = List.generate(endPage - startPage + 1, (i) => startPage + i);
    final memorizedCount = pages.where((p) => memorized.contains(p)).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: colors.goldDim.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: Text(
                  '$surahNumber',
                  style: typo.bodySmall.copyWith(
                    color: colors.goldDim,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                isArabic ? nameArabic : nameEnglish,
                style: typo.bodySmall.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedFlipCounter(
                  value: memorizedCount,
                  duration: const Duration(milliseconds: 150),
                  textStyle: typo.bodySmall.copyWith(
                    color: memorizedCount == pages.length
                        ? colors.gold
                        : colors.textTertiary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '/${pages.length}',
                  style: typo.bodySmall.copyWith(
                    color: memorizedCount == pages.length
                        ? colors.gold
                        : colors.textTertiary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.0,
          ),
          itemCount: pages.length,
          itemBuilder: (context, index) {
            final page = pages[index];
            final isMemo = memorized.contains(page);
            return GestureDetector(
              onTap: () => onTogglePage(page),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isMemo
                      ? colors.gold.withValues(alpha: 0.15)
                      : colors.surfaceVariant,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isMemo
                        ? colors.gold.withValues(alpha: 0.3)
                        : colors.divider,
                  ),
                ),
                child: Center(
                  child: Text(
                    '$page',
                    style: typo.bodySmall.copyWith(
                      color: isMemo ? colors.gold : colors.textTertiary,
                      fontWeight: isMemo ? FontWeight.w600 : FontWeight.w400,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// TAB 4 — Tasmi' (recitation checking)
// ═══════════════════════════════════════════════════════════════════════════════

class _TasmiTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(tasmiSessionsProvider);
    if (sessions.isEmpty) return _TasmiEmptyState();
    return _TasmiSessionsList(sessions: sessions);
  }
}

class _TasmiEmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final typo = context.typography;
    final colors = context.colors;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.mic_rounded,
              size: 56, color: colors.goldDim.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          Text(
            Locales.string(context, 'tasmi_title'),
            style: typo.titleMedium.copyWith(color: colors.textTertiary),
          ),
          const SizedBox(height: 8),
          Text(
            Locales.string(context, 'tasmi_subtitle'),
            style: typo.bodySmall.copyWith(color: colors.textTertiary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => _showTasmiSurahSheet(context),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.gold),
              ),
              child: Text(
                Locales.string(context, 'tasmi_start'),
                style: typo.bodyMedium.copyWith(
                  color: colors.gold,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TasmiSessionsList extends ConsumerWidget {
  final List<TasmiSession> sessions;
  const _TasmiSessionsList({required this.sessions});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typo = context.typography;
    final colors = context.colors;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (int i = 0; i < sessions.length; i++) ...[
          _TasmiSessionCard(
            session: sessions[i],
            onResume: () {
              AnalyticsService.event('Tasmi Started',
                  props: {'surah': sessions[i].surahNameEnglish});
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TasmiPlayerScreen(session: sessions[i]),
                ),
              );
            },
            onDelete: () => ref
                .read(tasmiSessionsProvider.notifier)
                .deleteSession(sessions[i].id),
          ),
          if (i < sessions.length - 1) const SizedBox(height: 10),
        ],
        const SizedBox(height: 20),
        Center(
          child: GestureDetector(
            onTap: () => _showTasmiSurahSheet(context),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.gold),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_rounded, size: 18, color: colors.gold),
                  const SizedBox(width: 6),
                  Text(
                    Locales.string(context, 'tasmi_new_session'),
                    style: typo.bodyMedium.copyWith(
                      color: colors.gold,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TasmiSessionCard extends StatelessWidget {
  final TasmiSession session;
  final VoidCallback onResume;
  final VoidCallback onDelete;

  const _TasmiSessionCard({
    required this.session,
    required this.onResume,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final typo = context.typography;
    final colors = context.colors;
    final progressPercent = (session.progress * 100).toInt();

    return Dismissible(
      key: ValueKey(session.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline_rounded,
            color: Colors.red, size: 22),
      ),
      child: GestureDetector(
        onTap: onResume,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          session.surahNameArabic,
                          style: typo.arabicDisplay.copyWith(
                            fontSize: 16,
                            color: colors.textPrimary,
                          ),
                        ),
                        Text(
                          '${session.surahNameEnglish} · ${session.startVerse}-${session.endVerse}',
                          style: typo.bodySmall
                              .copyWith(color: colors.textTertiary),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: colors.gold,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.mic_rounded,
                        color: colors.background, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: session.progress,
                  backgroundColor: colors.divider,
                  valueColor: AlwaysStoppedAnimation<Color>(colors.gold),
                  minHeight: 4,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '$progressPercent% · ${session.correctVerses}/${session.totalVerses} ${Locales.string(context, 'ayahs')}',
                style: typo.bodySmall.copyWith(
                  color: colors.textTertiary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _showTasmiSurahSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _TasmiSurahSheet(),
  );
}

class _TasmiSurahSheet extends ConsumerStatefulWidget {
  @override
  ConsumerState<_TasmiSurahSheet> createState() => _TasmiSurahSheetState();
}

class _TasmiSurahSheetState extends ConsumerState<_TasmiSurahSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final typo = context.typography;
    final colors = context.colors;
    final surahsAsync = ref.watch(allSurahsProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  Locales.string(context, 'tikrar_select_surah'),
                  style: typo.titleMedium.copyWith(color: colors.gold),
                ),
                const SizedBox(height: 12),
                TextField(
                  onChanged: (v) => setState(() => _query = v),
                  style: typo.bodyMedium.copyWith(color: colors.textPrimary),
                  decoration: InputDecoration(
                    hintText:
                        Locales.string(context, 'tikrar_search_surah'),
                    hintStyle: typo.bodyMedium
                        .copyWith(color: colors.textTertiary),
                    prefixIcon: Icon(Icons.search_rounded,
                        color: colors.textTertiary, size: 20),
                    filled: true,
                    fillColor: colors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: surahsAsync.when(
              data: (surahs) {
                final filtered = _query.isEmpty
                    ? surahs
                    : surahs
                        .where((s) =>
                            s.nameEnglish
                                .toLowerCase()
                                .contains(_query.toLowerCase()) ||
                            s.nameArabic.contains(_query))
                        .toList();
                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, i) {
                    final surah = filtered[i];
                    return SurahSearchTile(
                      surah: surah,
                      onTap: () {
                        Navigator.pop(context);
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) =>
                              _TasmiConfigSheet(surah: surah),
                        );
                      },
                    );
                  },
                );
              },
              loading: () =>
                  Center(child: CircularProgressIndicator(color: colors.gold)),
              error: (_, __) => Center(
                child: Text(Locales.string(context, 'error_loading_surah'),
                    style: typo.bodyMedium
                        .copyWith(color: colors.textTertiary)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TasmiConfigSheet extends ConsumerStatefulWidget {
  final Surah surah;
  const _TasmiConfigSheet({required this.surah});

  @override
  ConsumerState<_TasmiConfigSheet> createState() => _TasmiConfigSheetState();
}

class _TasmiConfigSheetState extends ConsumerState<_TasmiConfigSheet> {
  late int _startVerse;
  late int _endVerse;
  late final TextEditingController _startController;
  late final TextEditingController _endController;

  @override
  void initState() {
    super.initState();
    _startVerse = 1;
    _endVerse = widget.surah.ayahCount;
    _startController = TextEditingController(text: '$_startVerse');
    _endController = TextEditingController(text: '$_endVerse');
  }

  @override
  void dispose() {
    _startController.dispose();
    _endController.dispose();
    super.dispose();
  }

  void _updateStart(int delta) {
    setState(() {
      _startVerse = (_startVerse + delta).clamp(1, widget.surah.ayahCount);
      if (_endVerse < _startVerse) _endVerse = _startVerse;
      _startController.text = '$_startVerse';
      _endController.text = '$_endVerse';
    });
  }

  void _updateEnd(int delta) {
    setState(() {
      _endVerse =
          (_endVerse + delta).clamp(_startVerse, widget.surah.ayahCount);
      _endController.text = '$_endVerse';
    });
  }

  @override
  Widget build(BuildContext context) {
    final typo = context.typography;
    final colors = context.colors;
    final verseCount = _endVerse - _startVerse + 1;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
          20, 12, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.surah.nameArabic,
              style: typo.arabicDisplay.copyWith(color: colors.textPrimary),
            ),
            Text(
              widget.surah.nameEnglish,
              style: typo.bodyMedium.copyWith(color: colors.textSecondary),
            ),
            const SizedBox(height: 24),

            // Start Verse
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                Locales.string(context, 'tikrar_start_verse').toUpperCase(),
                style: typo.bodySmall.copyWith(
                  color: colors.goldDim,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 8),
            _NumberPickerRow(
              controller: _startController,
              onDecrement: () => _updateStart(-1),
              onIncrement: () => _updateStart(1),
              onChanged: (val) {
                final n = int.tryParse(val);
                if (n != null && n >= 1 && n <= widget.surah.ayahCount) {
                  setState(() {
                    _startVerse = n;
                    if (_endVerse < _startVerse) {
                      _endVerse = _startVerse;
                      _endController.text = '$_endVerse';
                    }
                  });
                }
              },
            ),
            const SizedBox(height: 20),

            // End Verse
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                Locales.string(context, 'tikrar_end_verse').toUpperCase(),
                style: typo.bodySmall.copyWith(
                  color: colors.goldDim,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 8),
            _NumberPickerRow(
              controller: _endController,
              onDecrement: () => _updateEnd(-1),
              onIncrement: () => _updateEnd(1),
              onChanged: (val) {
                final n = int.tryParse(val);
                if (n != null &&
                    n >= _startVerse &&
                    n <= widget.surah.ayahCount) {
                  setState(() => _endVerse = n);
                }
              },
            ),
            const SizedBox(height: 16),

            // Summary
            Text(
              '$verseCount ${Locales.string(context, 'tikrar_verses_label')}',
              style: typo.bodyMedium.copyWith(color: colors.gold),
            ),
            const SizedBox(height: 24),

            // Begin button
            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: () async {
                  final session = await ref
                      .read(tasmiSessionsProvider.notifier)
                      .createSession(
                        surahNumber: widget.surah.number,
                        surahNameArabic: widget.surah.nameArabic,
                        surahNameEnglish: widget.surah.nameEnglish,
                        startVerse: _startVerse,
                        endVerse: _endVerse,
                      );
                  if (!context.mounted) return;
                  AnalyticsService.event('Tasmi Started',
                      props: {'surah': widget.surah.nameEnglish});
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TasmiPlayerScreen(session: session),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: colors.gold,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      Locales.string(context, 'tasmi_begin'),
                      style: typo.bodyMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
