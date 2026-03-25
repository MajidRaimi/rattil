import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../../data/services/analytics_service.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../../core/theme/app_color_scheme.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/typography_ext.dart';
import '../../core/utils/quranic_text.dart';
import '../../data/models/ayah.dart';
import '../../data/services/recitation_service.dart';
import '../../providers/quran_providers.dart';
import '../../providers/tikrar_provider.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// DATA CLASSES
// ═══════════════════════════════════════════════════════════════════════════════

class TikrarStep {
  final List<int> verseNumbers;
  final bool isCombined;

  const TikrarStep({required this.verseNumbers, required this.isCombined});
}

List<TikrarStep> generateSteps(int startVerse, int endVerse) {
  final steps = <TikrarStep>[
    TikrarStep(verseNumbers: [startVerse], isCombined: false),
  ];
  for (var v = startVerse + 1; v <= endVerse; v++) {
    steps.add(TikrarStep(verseNumbers: [v], isCombined: false));
    steps.add(TikrarStep(
      verseNumbers: List.generate(v - startVerse + 1, (i) => startVerse + i),
      isCombined: true,
    ));
  }
  return steps;
}

// ═══════════════════════════════════════════════════════════════════════════════
// PLAYER SCREEN
// ═══════════════════════════════════════════════════════════════════════════════

class HifzPlayerScreen extends ConsumerStatefulWidget {
  final TikrarSession session;

  const HifzPlayerScreen({super.key, required this.session});

  @override
  ConsumerState<HifzPlayerScreen> createState() => _HifzPlayerScreenState();
}

class _HifzPlayerScreenState extends ConsumerState<HifzPlayerScreen> {
  final _player = AudioPlayer();
  final _scrollController = ScrollController();
  final _textKey = GlobalKey();

  late List<TikrarStep> _steps;
  int _currentStepIndex = 0;
  int _currentRepetition = 1;
  int _currentVerseInStep = 0;
  late String _selectedReciterId;
  late int _repetitions;

  bool _isPlaying = false;
  bool _isBuffering = false;
  bool _sessionComplete = false;
  bool _isLoading = true;
  String? _loadError;

  // verse → {reciterId: remoteUrl}
  final Map<int, Map<String, String>> _audioUrls = {};
  // verse → {reciterId: localFilePath}
  final Map<int, Map<String, String>> _localFiles = {};
  List<Ayah> _ayahs = [];

  // Download progress tracking
  int _downloadedCount = 0;
  int _downloadTotal = 0;

  TikrarSession get _session => widget.session;

  @override
  void initState() {
    super.initState();
    // Restore state from session
    _selectedReciterId = _session.reciterId;
    _repetitions = _session.repetitions;
    _currentStepIndex = _session.currentStepIndex;
    _currentRepetition = _session.currentRepetition;
    _currentVerseInStep = _session.currentVerseInStep;
    _steps = generateSteps(_session.startVerse, _session.endVerse);

    // Clamp restored values to valid ranges
    if (_currentStepIndex >= _steps.length) _currentStepIndex = 0;
    if (_currentStepIndex < _steps.length) {
      final stepVerses = _steps[_currentStepIndex].verseNumbers.length;
      if (_currentVerseInStep >= stepVerses) _currentVerseInStep = 0;
    }
    if (_currentRepetition > _repetitions) _currentRepetition = 1;

    // Stream listener for UI updates only (buffering indicator)
    _player.playerStateStream.listen((state) {
      if (!mounted) return;
      final isBuffering =
          state.processingState == ProcessingState.loading ||
              state.processingState == ProcessingState.buffering;
      if (_isBuffering != isBuffering) {
        setState(() => _isBuffering = isBuffering);
      }
    });

    _initSession();
  }

  Future<void> _initSession() async {
    try {
      // Phase 1: Load ayahs + fetch audio URLs in parallel
      final ayahsFuture = ref.read(
        surahAyahsProvider(_session.surahNumber).future,
      );

      final urlFutures = <Future>[];
      for (var v = _session.startVerse; v <= _session.endVerse; v++) {
        urlFutures.add(
          RecitationService.instance
              .fetchReciters(_session.surahNumber, v)
              .then((reciters) {
            final map = <String, String>{};
            for (final r in reciters) {
              map[r.id] = r.audioUrl;
            }
            _audioUrls[v] = map;
          }),
        );
      }

      final results = await Future.wait([
        ayahsFuture,
        Future.wait(urlFutures),
      ]);

      final ayahs = results[0] as List<Ayah>;
      _ayahs = ayahs
          .where((a) =>
              a.ayahNumber >= _session.startVerse &&
              a.ayahNumber <= _session.endVerse)
          .toList();

      // Phase 2: Download MP3 files to disk for the selected reciter
      await _downloadReciterFiles(_selectedReciterId);

      if (mounted) {
        setState(() => _isLoading = false);
        _scrollToActiveVerse();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadError = e.toString();
        });
      }
    }
  }

  /// Downloads all verse MP3s for [reciterId] to disk.
  Future<void> _downloadReciterFiles(String reciterId) async {
    final verses = List.generate(
      _session.endVerse - _session.startVerse + 1,
      (i) => _session.startVerse + i,
    );

    int alreadyCached = 0;
    for (final v in verses) {
      if (_localFiles[v]?[reciterId] != null) alreadyCached++;
    }
    if (alreadyCached == verses.length) return;

    if (mounted) {
      setState(() {
        _downloadedCount = alreadyCached;
        _downloadTotal = verses.length;
      });
    }

    final pending = <Future>[];
    for (final v in verses) {
      if (_localFiles[v]?[reciterId] != null) continue;

      final url = _audioUrls[v]?[reciterId];
      if (url == null) continue;

      final future = RecitationService.instance
          .downloadVerse(
        surah: _session.surahNumber,
        verse: v,
        reciterId: reciterId,
        url: url,
      )
          .then((localPath) {
        _localFiles.putIfAbsent(v, () => {})[reciterId] = localPath;
        if (mounted) {
          setState(() => _downloadedCount++);
        }
      });

      pending.add(future);
      if (pending.length >= 4) {
        await Future.wait(pending);
        pending.clear();
      }
    }
    if (pending.isNotEmpty) await Future.wait(pending);
  }

  // ── Session persistence ──

  void _saveSession() {
    _session
      ..currentStepIndex = _currentStepIndex
      ..currentRepetition = _currentRepetition
      ..currentVerseInStep = _currentVerseInStep
      ..repetitions = _repetitions
      ..reciterId = _selectedReciterId;
    ref.read(tikrarSessionsProvider.notifier).updateSession(_session);
  }

  void _deleteSession() {
    ref.read(tikrarSessionsProvider.notifier).deleteSession(_session.id);
  }

  // ── Playback engine (sequential async loop) ──

  /// Incremented to cancel any running playback loop.
  int _playbackGen = 0;

  /// Plays a single verse and awaits its completion.
  /// Returns true if the verse played to completion,
  /// false if cancelled (stop/skip/dispose).
  Future<bool> _playAndAwait(int verseNum, int gen) async {
    String? path = _localFiles[verseNum]?[_selectedReciterId];

    // Fallback: download if not cached
    if (path == null) {
      final url = _audioUrls[verseNum]?[_selectedReciterId];
      if (url == null) return true; // skip verse
      try {
        path = await RecitationService.instance.downloadVerse(
          surah: _session.surahNumber,
          verse: verseNum,
          reciterId: _selectedReciterId,
          url: url,
        );
        _localFiles.putIfAbsent(verseNum, () => {})[_selectedReciterId] = path;
      } catch (_) {
        return true; // skip verse on download error
      }
    }

    if (gen != _playbackGen || !mounted) return false;

    try {
      await _player.setAudioSource(
        AudioSource.file(path),
        initialPosition: Duration.zero,
      );
      _player.play();

      // Wait for this specific playback to reach completed or idle (stopped)
      await for (final state in _player.processingStateStream) {
        if (gen != _playbackGen) return false;
        if (state == ProcessingState.completed) return true;
        if (state == ProcessingState.idle) return false;
      }
      return false;
    } catch (_) {
      return true; // skip verse on playback error
    }
  }

  /// Main playback loop. Plays from current position through all
  /// remaining verses, repetitions, and steps.
  Future<void> _startPlayback() async {
    _playbackGen++;
    final gen = _playbackGen;

    while (_isPlaying && mounted && !_sessionComplete && gen == _playbackGen) {
      final step = _steps[_currentStepIndex];
      final verseNum = step.verseNumbers[_currentVerseInStep];

      // Update UI to show current verse
      setState(() {});
      _scrollToActiveVerse();

      final ok = await _playAndAwait(verseNum, gen);
      if (!ok || gen != _playbackGen || !mounted) return;

      // ── Advance state machine ──
      if (_currentVerseInStep < step.verseNumbers.length - 1) {
        setState(() => _currentVerseInStep++);
      } else if (_currentRepetition < _repetitions) {
        setState(() {
          _currentRepetition++;
          _currentVerseInStep = 0;
        });
      } else if (_currentStepIndex < _steps.length - 1) {
        setState(() {
          _currentStepIndex++;
          _currentRepetition = 1;
          _currentVerseInStep = 0;
        });
      } else {
        // Session complete
        setState(() {
          _isPlaying = false;
          _sessionComplete = true;
        });
        _player.stop();
        _deleteSession();
        return;
      }
    }
  }

  void _togglePlayPause() {
    if (_sessionComplete) return;
    if (_isPlaying) {
      _player.pause();
      setState(() => _isPlaying = false);
      _saveSession();
    } else {
      setState(() => _isPlaying = true);
      // If player is paused mid-verse, just resume it — the running
      // loop is suspended in _playAndAwait and will continue on completion.
      if (_player.processingState == ProcessingState.ready &&
          !_player.playing) {
        _player.play();
      } else {
        _startPlayback();
      }
    }
  }

  void _skipNext() {
    if (_currentStepIndex < _steps.length - 1) {
      _player.stop();
      _playbackGen++; // cancel running loop
      setState(() {
        _currentStepIndex++;
        _currentRepetition = 1;
        _currentVerseInStep = 0;
      });
      _scrollController.jumpTo(0);
      _saveSession();
      if (_isPlaying) _startPlayback();
    }
  }

  void _skipPrevious() {
    if (_currentStepIndex > 0) {
      _player.stop();
      _playbackGen++;
      setState(() {
        _currentStepIndex--;
        _currentRepetition = 1;
        _currentVerseInStep = 0;
      });
      _scrollController.jumpTo(0);
      _saveSession();
      if (_isPlaying) _startPlayback();
    }
  }

  void _endSession() {
    _player.stop();
    _playbackGen++;
    AnalyticsService.event('Tikrar Completed', props: {'surah': widget.session.surahNameEnglish});
    setState(() {
      _isPlaying = false;
      _sessionComplete = true;
    });
    _deleteSession();
  }

  void _changeReciter(String reciterId) {
    if (reciterId == _selectedReciterId) return;
    final wasPlaying = _isPlaying;
    _player.stop();
    _playbackGen++;
    setState(() {
      _selectedReciterId = reciterId;
      _isPlaying = false;
      _isBuffering = wasPlaying;
    });
    _saveSession();

    _downloadReciterFiles(reciterId).then((_) {
      if (!mounted) return;
      setState(() => _isBuffering = false);
      if (wasPlaying) {
        setState(() => _isPlaying = true);
        _startPlayback();
      }
    });
  }

  void _changeRepetitions(int delta) {
    final newReps = (_repetitions + delta).clamp(2, 10);
    if (newReps != _repetitions) {
      setState(() {
        _repetitions = newReps;
        if (_currentRepetition > _repetitions) {
          _currentRepetition = _repetitions;
        }
      });
      _saveSession();
    }
  }

  double get _progress {
    int totalPlays = 0;
    int completedPlays = 0;

    for (int i = 0; i < _steps.length; i++) {
      final versesInStep = _steps[i].verseNumbers.length;
      final playsForStep = versesInStep * _repetitions;
      totalPlays += playsForStep;

      if (i < _currentStepIndex) {
        completedPlays += playsForStep;
      } else if (i == _currentStepIndex) {
        completedPlays +=
            (_currentRepetition - 1) * versesInStep + _currentVerseInStep;
      }
    }

    return totalPlays > 0 ? completedPlays / totalPlays : 0.0;
  }

  Ayah? _ayahForVerse(int verseNum) {
    try {
      return _ayahs.firstWhere((a) => a.ayahNumber == verseNum);
    } catch (_) {
      return null;
    }
  }

  void _scrollToActiveVerse() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      final step = _steps[_currentStepIndex];
      if (step.verseNumbers.length <= 1) return;

      // For first verse, just scroll to top
      if (_currentVerseInStep == 0) {
        _scrollController.animateTo(0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut);
        return;
      }

      final renderObj = _textKey.currentContext?.findRenderObject();
      if (renderObj is! RenderParagraph) return;

      // Calculate character offset for the start of the active verse
      int charOffset = 0;
      for (int i = 0; i < _currentVerseInStep; i++) {
        final verseNum = step.verseNumbers[i];
        final ayah = _ayahForVerse(verseNum);
        final text = stripQuranicMarks(ayah?.textUthmani ?? '');
        final marker =
            ' ${String.fromCharCode(0xFD3F)}${_toArabicNumeral(verseNum)}${String.fromCharCode(0xFD3E)}';
        charOffset += text.length + marker.length + 1; // +1 for space
      }

      final caretOffset = renderObj.getOffsetForCaret(
        TextPosition(offset: charOffset),
        Rect.zero,
      );

      final maxExtent = _scrollController.position.maxScrollExtent;
      if (maxExtent <= 0) return;

      final viewportHeight = _scrollController.position.viewportDimension;
      final target = (caretOffset.dy - viewportHeight * 0.3)
          .clamp(0.0, maxExtent);

      _scrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _player.dispose();
    _scrollController.dispose();
    if (!_sessionComplete) {
      _saveSession();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final typo = context.typography;
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: _isLoading
            ? _buildLoading(typo, colors)
            : _loadError != null
                ? _buildError(typo, colors)
                : Stack(
                    children: [
                      _buildPlayer(typo, colors),
                      if (_sessionComplete) _buildCompleteOverlay(typo, colors),
                    ],
                  ),
      ),
    );
  }

  Widget _buildLoading(AppTypography typo, AppColorScheme colors) {
    final downloadProgress = _downloadTotal > 0
        ? _downloadedCount / _downloadTotal
        : 0.0;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.downloading_rounded,
                size: 48, color: colors.goldDim.withValues(alpha: 0.6)),
            const SizedBox(height: 24),
            if (_downloadTotal > 0) ...[
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: downloadProgress),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) => ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: value,
                    minHeight: 6,
                    backgroundColor: colors.divider,
                    valueColor: AlwaysStoppedAnimation(colors.gold),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '$_downloadedCount / $_downloadTotal',
                style: typo.titleMedium.copyWith(
                  color: colors.gold,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
            ],
            Text(
              Locales.string(context, 'tikrar_loading'),
              style: typo.bodyMedium.copyWith(color: colors.textTertiary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(AppTypography typo, AppColorScheme colors) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline_rounded, size: 56, color: colors.error),
          const SizedBox(height: 16),
          Text(
            Locales.string(context, 'error_loading_reciters'),
            style: typo.titleMedium.copyWith(color: colors.textTertiary),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              setState(() {
                _isLoading = true;
                _loadError = null;
              });
              _initSession();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.gold),
              ),
              child: Text(
                Locales.string(context, 'retry'),
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

  Widget _buildPlayer(AppTypography typo, AppColorScheme colors) {
    final step = _steps[_currentStepIndex];
    final stepLabel = step.isCombined
        ? '${Locales.string(context, 'tikrar_verses_label')} ${step.verseNumbers.first}–${step.verseNumbers.last}'
        : '${Locales.string(context, 'tikrar_verse_label')} ${step.verseNumbers.first}';

    return Column(
      children: [
        // ── Header ──
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 20, 0),
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  _player.stop();
                  Navigator.pop(context);
                },
                icon: Icon(Icons.arrow_back_rounded, color: colors.textPrimary),
              ),
              const SizedBox(width: 4),
              Text(
                Locales.string(context, 'memorization'),
                style: typo.titleMedium.copyWith(color: colors.textPrimary),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Text(
                _session.surahNameArabic,
                style: typo.arabicDisplay.copyWith(color: colors.gold),
              ),
              Text(
                '${Locales.string(context, 'tikrar_verses_label')} ${_session.startVerse}–${_session.endVerse}',
                style: typo.bodySmall.copyWith(color: colors.textTertiary),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // ── Step Info Card ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.divider),
            ),
            child: Column(
              children: [
                Text(
                  '${Locales.string(context, 'tikrar_step').toUpperCase()} ${_currentStepIndex + 1} ${Locales.string(context, 'tikrar_of')} ${_steps.length}',
                  style: typo.bodySmall.copyWith(
                    color: colors.goldDim,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  stepLabel,
                  style: typo.titleMedium.copyWith(color: colors.textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  '${Locales.string(context, 'tikrar_repetition')} $_currentRepetition ${Locales.string(context, 'tikrar_of')} $_repetitions',
                  style: typo.bodySmall.copyWith(color: colors.textTertiary),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // ── Arabic Text ──
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: colors.surfaceVariant,
                borderRadius: BorderRadius.circular(16),
              ),
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(20),
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Text.rich(
                    key: _textKey,
                    TextSpan(
                      children: [
                        for (int i = 0; i < step.verseNumbers.length; i++) ...[
                          if (i > 0) const TextSpan(text: ' '),
                          ..._buildVerseSpans(
                            step.verseNumbers[i],
                            i == _currentVerseInStep && _isPlaying,
                            typo,
                            colors,
                          ),
                        ],
                      ],
                    ),
                    style: typo.quranArabic.copyWith(fontSize: 24),
                  ),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // ── Progress ──
        Directionality(
          textDirection: TextDirection.ltr,
          child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: _progress),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) => ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: value,
                minHeight: 4,
                backgroundColor: colors.divider,
                valueColor: AlwaysStoppedAnimation(colors.gold),
              ),
            ),
          ),
        ),
        ),

        const SizedBox(height: 16),

        // ── Controls ──
        Directionality(
          textDirection: TextDirection.ltr,
          child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: _currentStepIndex > 0 ? _skipPrevious : null,
              icon: Icon(
                Icons.skip_previous_rounded,
                size: 32,
                color: _currentStepIndex > 0
                    ? colors.textSecondary
                    : colors.textTertiary.withValues(alpha: 0.3),
              ),
            ),
            const SizedBox(width: 24),
            GestureDetector(
              onTap: _togglePlayPause,
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.gold,
                ),
                child: Center(
                  child: _isBuffering
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Icon(
                          _isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                ),
              ),
            ),
            const SizedBox(width: 24),
            _currentStepIndex < _steps.length - 1
                ? IconButton(
                    onPressed: _skipNext,
                    icon: Icon(
                      Icons.skip_next_rounded,
                      size: 32,
                      color: colors.textSecondary,
                    ),
                  )
                : IconButton(
                    onPressed: _endSession,
                    icon: Icon(
                      Icons.check_circle_outline_rounded,
                      size: 32,
                      color: colors.gold,
                    ),
                  ),
          ],
        ),
        ),

        const SizedBox(height: 16),

        // ── Bottom Settings ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => _showReciterPicker(context),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.person_rounded,
                        size: 18, color: colors.textTertiary),
                    const SizedBox(width: 6),
                    Text(
                      Locales.string(context, 'reciter_$_selectedReciterId'),
                      style: typo.bodySmall
                          .copyWith(color: colors.textSecondary),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _showRepetitionAdjuster(context),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '×$_repetitions',
                      style: typo.bodyMedium.copyWith(
                        color: colors.gold,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Icon(Icons.expand_more_rounded,
                        size: 18, color: colors.gold),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildCompleteOverlay(AppTypography typo, AppColorScheme colors) {
    return Positioned.fill(
      child: Container(
        color: colors.background.withValues(alpha: 0.8),
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colors.divider),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_rounded,
                    size: 64, color: colors.gold),
                const SizedBox(height: 16),
                Text(
                  Locales.string(context, 'tikrar_complete'),
                  style: typo.headlineMedium.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: colors.gold,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          Locales.string(context, 'tikrar_done'),
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
        ),
      ),
    );
  }

  void _showReciterPicker(BuildContext context) {
    final colors = context.colors;
    final typo = context.typography;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.fromLTRB(
            20, 12, 20, MediaQuery.of(context).padding.bottom + 16),
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
              Locales.string(context, 'tikrar_reciter'),
              style: typo.headlineMedium.copyWith(color: colors.textPrimary),
            ),
            const SizedBox(height: 16),
            for (var i = 1; i <= 5; i++) ...[
              GestureDetector(
                onTap: () {
                  _changeReciter('$i');
                  Navigator.pop(context);
                },
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: _selectedReciterId == '$i'
                        ? colors.gold.withValues(alpha: 0.12)
                        : colors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedReciterId == '$i'
                          ? colors.gold
                          : colors.divider,
                    ),
                  ),
                  child: Text(
                    Locales.string(context, 'reciter_$i'),
                    style: typo.bodyMedium.copyWith(
                      color: _selectedReciterId == '$i'
                          ? colors.gold
                          : colors.textPrimary,
                      fontWeight: _selectedReciterId == '$i'
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showRepetitionAdjuster(BuildContext context) {
    final colors = context.colors;
    final typo = context.typography;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.fromLTRB(
              20, 12, 20, MediaQuery.of(context).padding.bottom + 16),
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
                Locales.string(context, 'tikrar_repetitions'),
                style:
                    typo.headlineMedium.copyWith(color: colors.textPrimary),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: _repetitions > 2
                        ? () {
                            _changeRepetitions(-1);
                            setSheetState(() {});
                          }
                        : null,
                    icon: Icon(Icons.remove_rounded,
                        color: _repetitions > 2
                            ? colors.textSecondary
                            : colors.textTertiary.withValues(alpha: 0.3)),
                    style: IconButton.styleFrom(
                      backgroundColor:
                          colors.divider.withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Text(
                    '$_repetitions',
                    style: typo.headlineLarge.copyWith(
                      color: colors.gold,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 24),
                  IconButton(
                    onPressed: _repetitions < 10
                        ? () {
                            _changeRepetitions(1);
                            setSheetState(() {});
                          }
                        : null,
                    icon: Icon(Icons.add_rounded,
                        color: _repetitions < 10
                            ? colors.textSecondary
                            : colors.textTertiary.withValues(alpha: 0.3)),
                    style: IconButton.styleFrom(
                      backgroundColor:
                          colors.divider.withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  List<TextSpan> _buildVerseSpans(
    int verseNum,
    bool isHighlighted,
    AppTypography typo,
    AppColorScheme colors,
  ) {
    final ayah = _ayahForVerse(verseNum);
    final color = isHighlighted ? colors.gold : colors.textArabic;
    final verseEnd = ' ${String.fromCharCode(0xFD3F)}${_toArabicNumeral(verseNum)}${String.fromCharCode(0xFD3E)}';
    return [
      TextSpan(
        text: '${stripQuranicMarks(ayah?.textUthmani ?? '')}$verseEnd',
        style: TextStyle(color: color),
      ),
    ];
  }

  static String _toArabicNumeral(int number) {
    const digits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number.toString().split('').map((d) => digits[int.parse(d)]).join();
  }
}
