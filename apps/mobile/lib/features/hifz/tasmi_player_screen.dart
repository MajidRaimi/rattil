import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record/record.dart';

import '../../core/theme/app_color_scheme.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/typography_ext.dart';
import '../../core/utils/quranic_text.dart';
import '../../data/models/ayah.dart';
import '../../data/services/analytics_service.dart';
import '../../data/services/tasmi_service.dart';
import '../../providers/quran_providers.dart';
import '../../providers/tasmi_provider.dart';

enum AyahStatus { pending, recording, processing, correct, wrong }

String _toArabicNumeral(int n) {
  const digits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  return n.toString().split('').map((d) => digits[int.parse(d)]).join();
}

class TasmiPlayerScreen extends ConsumerStatefulWidget {
  final TasmiSession session;

  const TasmiPlayerScreen({super.key, required this.session});

  @override
  ConsumerState<TasmiPlayerScreen> createState() => _TasmiPlayerScreenState();
}

class _TasmiPlayerScreenState extends ConsumerState<TasmiPlayerScreen> {
  final _recorder = AudioRecorder();
  final _scrollController = ScrollController();

  List<Ayah> _ayahs = [];
  List<AyahStatus> _ayahStatuses = [];
  int _currentAyahIndex = 0;
  bool _isLoading = true;
  bool _isSessionActive = false;
  bool _isRecording = false;
  bool _isProcessing = false;
  bool _sessionComplete = false;

  // Per-ayah word-level results (populated after recitation)
  final Map<int, List<WordMatch>> _wordResults = {};

  // Tracks confirmed correct words so far (for partial recitation of long ayahs)
  final Map<int, int> _confirmedWordCount = {};

  // Stream-based recording + silence detection
  StreamSubscription? _audioStreamSub;
  final _pcmBuffer = BytesBuilder(copy: false);
  Timer? _silenceTimer;
  bool _hasDetectedSpeech = false;
  static const _silenceThresholdDb = -30.0;
  static const _silenceDuration = Duration(milliseconds: 1500);
  static const _gracePeriod = Duration(seconds: 2);
  static const _sampleRate = 16000;
  DateTime? _recordingStartTime;

  TasmiSession get _session => widget.session;

  @override
  void initState() {
    super.initState();
    _loadAyahs();
  }

  @override
  void dispose() {
    _toastEntry?.remove();
    _silenceTimer?.cancel();
    _audioStreamSub?.cancel();
    _recorder.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadAyahs() async {
    final allAyahs =
        await ref.read(surahAyahsProvider(_session.surahNumber).future);
    final filtered = allAyahs
        .where((a) =>
            a.ayahNumber >= _session.startVerse &&
            a.ayahNumber <= _session.endVerse)
        .toList();

    if (!mounted) return;
    setState(() {
      _ayahs = filtered;
      _ayahStatuses = List.filled(filtered.length, AyahStatus.pending);
      _currentAyahIndex =
          _session.currentVerse.clamp(0, filtered.length - 1);
      for (int i = 0;
          i < _session.correctVerses && i < filtered.length;
          i++) {
        _ayahStatuses[i] = AyahStatus.correct;
      }
      _isLoading = false;
    });
  }

  OverlayEntry? _toastEntry;

  void _showErrorToast() {
    _toastEntry?.remove();
    final colors = context.colors;
    final overlay = Overlay.of(context);

    _toastEntry = OverlayEntry(
      builder: (_) => Positioned(
        top: MediaQuery.of(context).padding.top + 12,
        left: 20,
        right: 20,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) => Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, -20 * (1 - value)),
              child: child,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFCF6679).withValues(alpha: 0.3),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.wifi_off_rounded,
                      color: Color(0xFFCF6679), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      Locales.currentLocale(context)?.languageCode == 'ar'
                          ? 'حدث خطأ، جاري المحاولة...'
                          : 'Connection error, retrying...',
                      style: TextStyle(
                        fontFamily: 'NeueFrutigerWorld',
                        fontSize: 13,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(_toastEntry!);

    Future.delayed(const Duration(seconds: 3), () {
      _toastEntry?.remove();
      _toastEntry = null;
    });
  }

  // ── Session control ──

  Future<void> _startSession() async {
    setState(() => _isSessionActive = true);
    _startRecording();
  }

  void _stopSession() {
    _silenceTimer?.cancel();
    _audioStreamSub?.cancel();
    _recorder.cancel();
    _pcmBuffer.clear();
    setState(() {
      _isSessionActive = false;
      _isRecording = false;
      _isProcessing = false;
      for (int i = 0; i < _ayahStatuses.length; i++) {
        if (_ayahStatuses[i] == AyahStatus.recording ||
            _ayahStatuses[i] == AyahStatus.processing) {
          _ayahStatuses[i] = AyahStatus.pending;
        }
      }
    });
  }

  // ── PCM amplitude calculation ──

  double _calculateAmplitudeDb(Uint8List pcmData) {
    if (pcmData.length < 2) return -120.0;
    double sumSquares = 0;
    int count = 0;
    for (int i = 0; i < pcmData.length - 1; i += 2) {
      int sample = pcmData[i] | (pcmData[i + 1] << 8);
      if (sample >= 32768) sample -= 65536;
      sumSquares += sample * sample;
      count++;
    }
    if (count == 0) return -120.0;
    final rms = sqrt(sumSquares / count);
    if (rms < 1) return -120.0;
    return 20 * log(rms / 32768) / ln10;
  }

  Uint8List _buildWavFile(Uint8List pcmData) {
    final header = ByteData(44);
    final dataLength = pcmData.length;
    final fileLength = dataLength + 36;

    // RIFF header
    header.setUint8(0, 0x52); // R
    header.setUint8(1, 0x49); // I
    header.setUint8(2, 0x46); // F
    header.setUint8(3, 0x46); // F
    header.setUint32(4, fileLength, Endian.little);
    header.setUint8(8, 0x57); // W
    header.setUint8(9, 0x41); // A
    header.setUint8(10, 0x56); // V
    header.setUint8(11, 0x45); // E

    // fmt chunk
    header.setUint8(12, 0x66); // f
    header.setUint8(13, 0x6D); // m
    header.setUint8(14, 0x74); // t
    header.setUint8(15, 0x20); // (space)
    header.setUint32(16, 16, Endian.little); // chunk size
    header.setUint16(20, 1, Endian.little); // PCM format
    header.setUint16(22, 1, Endian.little); // mono
    header.setUint32(24, _sampleRate, Endian.little);
    header.setUint32(28, _sampleRate * 2, Endian.little); // byte rate
    header.setUint16(32, 2, Endian.little); // block align
    header.setUint16(34, 16, Endian.little); // bits per sample

    // data chunk
    header.setUint8(36, 0x64); // d
    header.setUint8(37, 0x61); // a
    header.setUint8(38, 0x74); // t
    header.setUint8(39, 0x61); // a
    header.setUint32(40, dataLength, Endian.little);

    final wav = BytesBuilder(copy: false);
    wav.add(header.buffer.asUint8List());
    wav.add(pcmData);
    return wav.toBytes();
  }

  // ── Recording ──

  Future<void> _startRecording() async {
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(Locales.string(context, 'tasmi_mic_permission'))),
        );
      }
      _stopSession();
      return;
    }

    _wordResults.remove(_currentAyahIndex);
    _pcmBuffer.clear();
    _hasDetectedSpeech = false;
    _recordingStartTime = DateTime.now();

    // Stream raw PCM data
    final stream = await _recorder.startStream(
      const RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: _sampleRate,
        numChannels: 1,
      ),
    );

    _audioStreamSub = stream.listen((chunk) {
      _pcmBuffer.add(chunk);

      // Calculate amplitude from this chunk
      final db = _calculateAmplitudeDb(Uint8List.fromList(chunk));
      final elapsed = DateTime.now().difference(_recordingStartTime!);

      // Skip grace period
      if (elapsed < _gracePeriod) return;

      if (db >= _silenceThresholdDb) {
        _hasDetectedSpeech = true;
        _silenceTimer?.cancel();
        _silenceTimer = null;
      } else if (_hasDetectedSpeech) {
        _silenceTimer ??= Timer(_silenceDuration, () {
          if (_isRecording && !_isProcessing) {
            _onSilenceDetected();
          }
        });
      }
    });

    setState(() {
      _isRecording = true;
      for (int i = _currentAyahIndex; i < _ayahStatuses.length; i++) {
        if (_ayahStatuses[i] == AyahStatus.pending ||
            _ayahStatuses[i] == AyahStatus.wrong) {
          _ayahStatuses[i] = AyahStatus.recording;
          break;
        }
      }
    });

    _scrollToAyah(_currentAyahIndex);
  }

  Future<void> _onSilenceDetected() async {
    if (!_isRecording || _isProcessing) return;

    _silenceTimer?.cancel();
    _silenceTimer = null;
    _audioStreamSub?.cancel();
    await _recorder.stop();

    final pcmData = _pcmBuffer.toBytes();
    _pcmBuffer.clear();

    setState(() {
      _isRecording = false;
      _isProcessing = true;
      for (int i = _currentAyahIndex; i < _ayahStatuses.length; i++) {
        if (_ayahStatuses[i] == AyahStatus.recording) {
          _ayahStatuses[i] = AyahStatus.processing;
        }
      }
    });

    if (pcmData.length < 3200) {
      // Less than 0.1s of audio
      setState(() {
        _isProcessing = false;
        _ayahStatuses[_currentAyahIndex] = AyahStatus.pending;
      });
      if (_isSessionActive) _startRecording();
      return;
    }

    try {
      // Build WAV file from PCM data
      final wavBytes = _buildWavFile(pcmData);
      debugPrint('[Tasmi] sending ${(wavBytes.length / 1024).toStringAsFixed(0)}KB (${(pcmData.length / _sampleRate / 2).toStringAsFixed(1)}s audio)');

      final text =
          await TasmiService.instance.transcribe(wavBytes, 'recording.wav');
      _onTranscription(text);
    } catch (e) {
      debugPrint('[Tasmi] transcription error: $e');
      if (mounted) {
        _showErrorToast();
        setState(() {
          _isProcessing = false;
          for (int i = 0; i < _ayahStatuses.length; i++) {
            if (_ayahStatuses[i] == AyahStatus.processing) {
              _ayahStatuses[i] = AyahStatus.pending;
            }
          }
        });
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted && _isSessionActive) _startRecording();
        });
      }
    }
  }

  // ── Transcription handling ──

  void _onTranscription(String text) {
    if (!mounted || !_isProcessing) return;

    if (_currentAyahIndex >= _ayahs.length) {
      setState(() => _isProcessing = false);
      return;
    }

    final ayah = _ayahs[_currentAyahIndex];
    final expectedWords = splitArabicWords(ayah.textSimple);
    final transcribedWords = splitArabicWords(text);
    final confirmed = _confirmedWordCount[_currentAyahIndex] ?? 0;

    debugPrint('[Tasmi] ayah ${ayah.ayahNumber}: confirmed=$confirmed, expected=${expectedWords.length}, transcribed=${transcribedWords.length}');

    // Compare transcribed words against remaining expected words
    final (matchedCount, failedIndex) = comparePartial(
      expectedWords: expectedWords,
      transcribedWords: transcribedWords,
      startOffset: confirmed,
    );

    final totalConfirmed = confirmed + matchedCount;
    final isComplete = totalConfirmed >= expectedWords.length;
    final hasError = failedIndex != null;

    if (isComplete) {
      // ── Full verse correct ──
      _confirmedWordCount.remove(_currentAyahIndex);
      setState(() {
        _isProcessing = false;
        _ayahStatuses[_currentAyahIndex] = AyahStatus.correct;
        _wordResults.remove(_currentAyahIndex);
        _resetProcessingStatuses();
      });

      _session.correctVerses =
          _ayahStatuses.where((s) => s == AyahStatus.correct).length;
      _currentAyahIndex++;
      _currentAyahIndex = _currentAyahIndex.clamp(0, _ayahs.length);
      _session.currentVerse = _currentAyahIndex;
      ref.read(tasmiSessionsProvider.notifier).updateSession(_session);

      // Check completion
      if (_ayahStatuses.every((s) => s == AyahStatus.correct)) {
        setState(() => _sessionComplete = true);
        _stopSession();
        ref.read(tasmiSessionsProvider.notifier).deleteSession(_session.id);
        AnalyticsService.event('Tasmi Complete',
            props: {'surah': _session.surahNameEnglish});
        return;
      }

      // Auto-advance to next ayah
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted && _isSessionActive) _startRecording();
      });
    } else if (hasError) {
      // ── Error found — show full verse with wrong words ──
      final wordMatches = <WordMatch>[];
      for (int w = 0; w < expectedWords.length; w++) {
        if (w == failedIndex) {
          wordMatches.add(WordMatch.wrong);
        } else if (w < totalConfirmed || (w > failedIndex && w < confirmed + transcribedWords.length)) {
          // Check remaining transcribed words after the failed one
          final tIdx = w - confirmed;
          if (tIdx >= 0 && tIdx < transcribedWords.length) {
            final e = normalizeArabicForComparison(expectedWords[w]);
            final t = normalizeArabicForComparison(transcribedWords[tIdx]);
            wordMatches.add(fuzzyMatchArabic(e, t) ? WordMatch.correct : WordMatch.wrong);
          } else {
            wordMatches.add(WordMatch.wrong);
          }
        } else {
          wordMatches.add(WordMatch.wrong);
        }
      }

      _confirmedWordCount.remove(_currentAyahIndex);
      setState(() {
        _isProcessing = false;
        _ayahStatuses[_currentAyahIndex] = AyahStatus.wrong;
        _wordResults[_currentAyahIndex] = wordMatches;
        _resetProcessingStatuses();
      });

      // Auto-retry after delay
      Future.delayed(const Duration(milliseconds: 2000), () {
        if (!mounted || !_isSessionActive) return;
        setState(() {
          _ayahStatuses[_currentAyahIndex] = AyahStatus.pending;
          _wordResults.remove(_currentAyahIndex);
        });
        _startRecording();
      });
    } else {
      // ── Partial match — lock in confirmed words, continue recording ──
      _confirmedWordCount[_currentAyahIndex] = totalConfirmed;
      debugPrint('[Tasmi] partial: $totalConfirmed/${expectedWords.length} confirmed');

      setState(() {
        _isProcessing = false;
        _resetProcessingStatuses();
      });

      // Continue recording for the rest
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted && _isSessionActive) _startRecording();
      });
    }
  }

  void _resetProcessingStatuses() {
    for (int i = 0; i < _ayahStatuses.length; i++) {
      if (_ayahStatuses[i] == AyahStatus.processing ||
          _ayahStatuses[i] == AyahStatus.recording) {
        _ayahStatuses[i] = AyahStatus.pending;
      }
    }
  }

  void _scrollToAyah(int index) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      // Estimate position — each verse marker takes ~40px height
      final maxScroll = _scrollController.position.maxScrollExtent;
      final estimatedOffset = (index / _ayahs.length) * maxScroll;
      _scrollController.animateTo(
        estimatedOffset.clamp(0.0, maxScroll),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  double get _progress {
    final correct =
        _ayahStatuses.where((s) => s == AyahStatus.correct).length;
    return _ayahs.isNotEmpty ? correct / _ayahs.length : 0.0;
  }

  // ── Build ──

  @override
  Widget build(BuildContext context) {
    final typo = context.typography;
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: colors.gold))
            : Stack(
                children: [
                  _buildPlayer(typo, colors),
                  if (_sessionComplete) _buildCompleteOverlay(typo, colors),
                ],
              ),
      ),
    );
  }

  Widget _buildPlayer(AppTypography typo, AppColorScheme colors) {
    return Column(
      children: [
        // ── Header ──
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 20, 0),
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  _stopSession();
                  Navigator.pop(context);
                },
                icon: Icon(Icons.arrow_back_rounded,
                    color: colors.textPrimary),
              ),
              const SizedBox(width: 4),
              Text(
                Locales.string(context, 'tasmi_title'),
                style:
                    typo.titleMedium.copyWith(color: colors.textPrimary),
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

        // ── Info Card ──
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
                  '${_ayahStatuses.where((s) => s == AyahStatus.correct).length} ${Locales.string(context, 'tasmi_of')} ${_ayahs.length} ${Locales.string(context, 'ayahs')}',
                  style: typo.bodySmall.copyWith(
                    color: colors.goldDim,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isRecording
                      ? Locales.string(context, 'tasmi_recording')
                      : _isProcessing
                          ? Locales.string(context, 'tasmi_processing')
                          : Locales.string(context, 'tasmi_tap_to_recite'),
                  style: typo.bodySmall.copyWith(
                    color: _isRecording
                        ? const Color(0xFFCF6679)
                        : colors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // ── Arabic Text Area ──
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
                    TextSpan(children: _buildAllVerseSpans(typo, colors)),
                    style: typo.quranArabic.copyWith(fontSize: 24),
                  ),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // ── Progress Bar ──
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
              const SizedBox(width: 56),
              const SizedBox(width: 24),
              GestureDetector(
                onTap: _isSessionActive ? _stopSession : _startSession,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isRecording
                        ? const Color(0xFFCF6679)
                        : colors.gold,
                  ),
                  child: Center(
                    child: _isProcessing
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Icon(
                            _isSessionActive
                                ? Icons.stop_rounded
                                : Icons.mic_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 24),
              const SizedBox(width: 56),
            ],
          ),
        ),

        const SizedBox(height: 24),
      ],
    );
  }

  List<TextSpan> _buildAllVerseSpans(
      AppTypography typo, AppColorScheme colors) {
    final spans = <TextSpan>[];
    const red = Color(0xFFCF6679);

    for (int i = 0; i < _ayahs.length; i++) {
      if (i > 0) spans.add(const TextSpan(text: ' '));

      final ayah = _ayahs[i];
      final status = _ayahStatuses[i];
      final marker =
          ' ${String.fromCharCode(0xFD3F)}${_toArabicNumeral(ayah.ayahNumber)}${String.fromCharCode(0xFD3E)}';

      if (status == AyahStatus.correct) {
        // ── CORRECT: full text in gold ──
        final text = stripQuranicMarks(ayah.textUthmani);
        spans.add(TextSpan(
          text: text,
          style: TextStyle(color: colors.gold),
        ));
        spans.add(TextSpan(
          text: marker,
          style: TextStyle(color: colors.gold),
        ));
      } else if (status == AyahStatus.wrong &&
          _wordResults.containsKey(i)) {
        // ── WRONG: correct words black, wrong words red ──
        final text = stripQuranicMarks(ayah.textUthmani);
        final displayWords = splitArabicWords(text);
        final matches = _wordResults[i]!;

        for (int w = 0; w < displayWords.length; w++) {
          final isWrong =
              w < matches.length && matches[w] == WordMatch.wrong;
          spans.add(TextSpan(
            text:
                '${displayWords[w]}${w < displayWords.length - 1 ? ' ' : ''}',
            style: TextStyle(
                color: isWrong ? red : colors.textPrimary),
          ));
        }
        spans.add(TextSpan(
          text: marker,
          style: const TextStyle(color: red),
        ));
      } else {
        // ── PENDING / RECORDING / PROCESSING ──
        final text = stripQuranicMarks(ayah.textUthmani);
        final confirmed = _confirmedWordCount[i] ?? 0;

        if (confirmed > 0) {
          // Show confirmed words in gold, rest invisible
          final displayWords = splitArabicWords(text);
          for (int w = 0; w < displayWords.length; w++) {
            spans.add(TextSpan(
              text:
                  '${displayWords[w]}${w < displayWords.length - 1 ? ' ' : ''}',
              style: TextStyle(
                color: w < confirmed
                    ? colors.gold
                    : colors.surfaceVariant,
              ),
            ));
          }
        } else {
          // Fully invisible
          spans.add(TextSpan(
            text: text,
            style: TextStyle(color: colors.surfaceVariant),
          ));
        }

        final markerColor = status == AyahStatus.recording
            ? colors.gold.withValues(alpha: 0.5)
            : status == AyahStatus.processing
                ? colors.gold.withValues(alpha: 0.4)
                : colors.textTertiary.withValues(alpha: 0.25);

        spans.add(TextSpan(
          text: marker,
          style: TextStyle(color: markerColor),
        ));
      }
    }

    return spans;
  }

  Widget _buildCompleteOverlay(AppTypography typo, AppColorScheme colors) {
    return Container(
      color: colors.background.withValues(alpha: 0.95),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_rounded, size: 72, color: colors.gold),
            const SizedBox(height: 20),
            Text(
              Locales.string(context, 'tasmi_complete'),
              style: typo.headlineMedium.copyWith(
                color: colors.gold,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${_session.surahNameArabic} · ${_session.totalVerses} ${Locales.string(context, 'ayahs')}',
              style:
                  typo.bodyMedium.copyWith(color: colors.textSecondary),
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 32, vertical: 14),
                decoration: BoxDecoration(
                  color: colors.gold,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  Locales.string(context, 'tasmi_done'),
                  style: typo.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
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
