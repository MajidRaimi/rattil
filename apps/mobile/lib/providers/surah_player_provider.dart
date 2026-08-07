import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:imad_flutter/imad_flutter.dart' as imad;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/services/audio_focus.dart';

part 'surah_player_provider.g.dart';

const _kSelectedReciterKey = 'surah_reciter_id';
const _kEndBehaviourKey = 'surah_end_behaviour';
const _kLoadTimeout = Duration(seconds: 20);
const _kLastChapter = 114;

@Riverpod(keepAlive: true)
class SelectedReciterId extends _$SelectedReciterId {
  @override
  int build() {
    _loadFromPrefs();
    return imad.ReciterDataProvider.getDefaultReciter().id;
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getInt(_kSelectedReciterKey);
    if (stored != null &&
        imad.ReciterDataProvider.getReciterById(stored) != null) {
      state = stored;
    }
  }

  Future<void> select(int reciterId) async {
    state = reciterId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kSelectedReciterKey, reciterId);
  }
}

@Riverpod(keepAlive: true)
Stream<imad.AudioPlayerState> surahPlayerState(Ref ref) {
  return imad.mushafGetIt<imad.AudioRepository>().getPlayerStateStream();
}

@Riverpod(keepAlive: true)
Stream<int> surahCompleted(Ref ref) {
  return imad.mushafGetIt<imad.AudioRepository>().getChapterCompletedStream();
}

enum SurahEndBehaviour { nextSurah, repeat, stop }

class AyahRange {
  final int start;
  final int end;

  const AyahRange(this.start, this.end);

  @override
  bool operator ==(Object other) =>
      other is AyahRange && other.start == start && other.end == end;

  @override
  int get hashCode => Object.hash(start, end);
}

class SurahPlaybackRequest {
  final int chapterNumber;
  final int reciterId;
  final String chapterTitle;

  const SurahPlaybackRequest({
    required this.chapterNumber,
    required this.reciterId,
    required this.chapterTitle,
  });

  SurahPlaybackRequest copyWith({int? reciterId, String? chapterTitle}) {
    return SurahPlaybackRequest(
      chapterNumber: chapterNumber,
      reciterId: reciterId ?? this.reciterId,
      chapterTitle: chapterTitle ?? this.chapterTitle,
    );
  }
}

enum SurahLoadStatus { idle, loading, ready, failed }

class SurahPlayerSession {
  final SurahPlaybackRequest? request;
  final SurahLoadStatus status;
  final AyahRange? range;
  final SurahEndBehaviour endBehaviour;
  final bool expanded;
  final bool rangeAvailable;

  const SurahPlayerSession({
    this.request,
    this.status = SurahLoadStatus.idle,
    this.range,
    this.endBehaviour = SurahEndBehaviour.nextSurah,
    this.expanded = false,
    this.rangeAvailable = true,
  });

  bool get isActive => request != null;

  SurahPlayerSession copyWith({
    SurahPlaybackRequest? request,
    SurahLoadStatus? status,
    AyahRange? range,
    SurahEndBehaviour? endBehaviour,
    bool? expanded,
    bool? rangeAvailable,
    bool clearRange = false,
  }) {
    return SurahPlayerSession(
      request: request ?? this.request,
      status: status ?? this.status,
      range: clearRange ? null : (range ?? this.range),
      endBehaviour: endBehaviour ?? this.endBehaviour,
      expanded: expanded ?? this.expanded,
      rangeAvailable: rangeAvailable ?? this.rangeAvailable,
    );
  }
}

@Riverpod(keepAlive: true)
class SurahPlayer extends _$SurahPlayer {
  Timer? _loadTimer;
  int? _rangeStartMs;
  int? _rangeEndMs;
  int? _currentVerse;
  int _positionMs = 0;
  int _durationMs = 0;
  bool _handlingEnd = false;

  String Function(int chapterNumber)? titleResolver;

  @override
  SurahPlayerSession build() {
    AudioFocus.register(AudioFocus.surahPlayer, stop);
    _loadEndBehaviour();

    ref.listen(surahPlayerStateProvider, (previous, next) {
      final playerState = next.valueOrNull;
      if (playerState != null) _onPlayerState(playerState);
    });

    ref.listen(surahCompletedProvider, (previous, next) {
      final finished = next.valueOrNull;
      if (finished != null) _onChapterCompleted(finished);
    });

    return const SurahPlayerSession();
  }

  imad.AudioRepository get _audio => imad.mushafGetIt<imad.AudioRepository>();

  Future<void> _loadEndBehaviour() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_kEndBehaviourKey);
    if (stored == null) return;
    state = state.copyWith(
      endBehaviour: SurahEndBehaviour.values.firstWhere(
        (b) => b.name == stored,
        orElse: () => SurahEndBehaviour.nextSurah,
      ),
    );
  }

  void _onPlayerState(imad.AudioPlayerState playerState) {
    _positionMs = playerState.currentPositionMs;
    _durationMs = playerState.durationMs;
    if (playerState.currentVerse != null) {
      _currentVerse = playerState.currentVerse;
    }

    final endMs = _rangeEndMs;
    if (endMs == null || !state.isActive) return;
    if (playerState.currentPositionMs < endMs) return;
    _handleEndOfSelection();
  }

  void _onChapterCompleted(int chapterNumber) {
    if (!state.isActive) return;
    if (state.request?.chapterNumber != chapterNumber) return;
    _handleEndOfSelection();
  }

  void _handleEndOfSelection() {
    if (_handlingEnd) return;
    _handlingEnd = true;
    Future(() async {
      try {
        switch (state.endBehaviour) {
          case SurahEndBehaviour.repeat:
            _audio.seekTo(_rangeStartMs ?? 0);
            _audio.play();
          case SurahEndBehaviour.stop:
            await stop();
          case SurahEndBehaviour.nextSurah:
            await _playNextChapter();
        }
      } finally {
        _handlingEnd = false;
      }
    });
  }

  Future<void> _playNextChapter() async {
    final request = state.request;
    if (request == null) return;
    final next = request.chapterNumber + 1;
    if (next > _kLastChapter) {
      await stop();
      return;
    }
    await play(
      SurahPlaybackRequest(
        chapterNumber: next,
        reciterId: request.reciterId,
        chapterTitle: titleResolver?.call(next) ?? '',
      ),
    );
  }

  Future<void> play(SurahPlaybackRequest request) async {
    _loadTimer?.cancel();
    final chapterChanged = state.request?.chapterNumber != request.chapterNumber;
    _clearRangeBounds();
    _currentVerse = null;

    state = state.copyWith(
      request: request,
      status: SurahLoadStatus.loading,
      clearRange: chapterChanged || state.range != null,
    );

    await AudioFocus.claim(AudioFocus.surahPlayer);

    _loadTimer = Timer(_kLoadTimeout, () {
      if (state.status == SurahLoadStatus.loading) {
        state = state.copyWith(status: SurahLoadStatus.failed);
      }
    });

    try {
      unawaited(
        _audio.preloadTiming(
          request.reciterId,
          chapterNumber: request.chapterNumber,
        ),
      );
      await _audio.loadChapter(
        request.chapterNumber,
        request.reciterId,
        autoPlay: true,
        chapterTitle: request.chapterTitle,
      );
      _loadTimer?.cancel();
      if (state.request == request) {
        state = state.copyWith(status: SurahLoadStatus.ready);
      }
      unawaited(_refreshRangeAvailability());
    } catch (_) {
      _loadTimer?.cancel();
      if (state.request == request) {
        state = state.copyWith(status: SurahLoadStatus.failed);
      }
    }
  }

  Future<void> changeReciter(int reciterId) async {
    final request = state.request;
    if (request == null || request.reciterId == reciterId) return;

    final resumeVerse = _currentVerse;
    final fraction = _durationMs > 0 ? _positionMs / _durationMs : 0.0;
    final range = state.range;

    await play(request.copyWith(reciterId: reciterId));
    if (state.status == SurahLoadStatus.failed) return;

    if (range != null) await setRange(range, seek: false);

    if (resumeVerse != null) {
      final timing = await _audio.getAyahTiming(
        reciterId,
        request.chapterNumber,
        resumeVerse,
      );
      if (timing != null) {
        _audio.seekTo(timing.startTime);
        return;
      }
    }

    if (fraction > 0) {
      final duration = _audio.getDuration();
      if (duration > 0) _audio.seekTo((duration * fraction).round());
    }
  }

  Future<void> _refreshRangeAvailability() async {
    final request = state.request;
    if (request == null) return;
    final timings = await _audio.getChapterTimings(
      request.reciterId,
      request.chapterNumber,
    );
    if (state.request?.reciterId != request.reciterId) return;
    state = state.copyWith(rangeAvailable: timings.isNotEmpty);
  }

  void _clearRangeBounds() {
    _rangeStartMs = null;
    _rangeEndMs = null;
  }

  Future<void> setRange(AyahRange? range, {bool seek = true}) async {
    final request = state.request;
    if (request == null) return;

    if (range == null) {
      _clearRangeBounds();
      state = state.copyWith(clearRange: true);
      return;
    }

    final startTiming = await _audio.getAyahTiming(
      request.reciterId,
      request.chapterNumber,
      range.start,
    );
    final endTiming = await _audio.getAyahTiming(
      request.reciterId,
      request.chapterNumber,
      range.end,
    );

    if (startTiming == null || endTiming == null) {
      state = state.copyWith(rangeAvailable: false);
      return;
    }

    final previousStart = state.range?.start;
    _rangeStartMs = startTiming.startTime;
    _rangeEndMs = endTiming.endTime;
    state = state.copyWith(range: range, rangeAvailable: true);

    if (seek && previousStart != range.start) {
      _audio.seekTo(startTiming.startTime);
      _audio.play();
    }
  }

  Future<void> setEndBehaviour(SurahEndBehaviour behaviour) async {
    state = state.copyWith(endBehaviour: behaviour);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kEndBehaviourKey, behaviour.name);
  }

  void setExpanded(bool expanded) {
    if (state.expanded == expanded) return;
    state = state.copyWith(expanded: expanded);
  }

  Future<void> retry() async {
    final request = state.request;
    if (request != null) await play(request);
  }

  void resume() => _audio.play();

  void pause() => _audio.pause();

  void seekTo(int positionMs) => _audio.seekTo(positionMs);

  void setSpeed(double speed) => _audio.setPlaybackSpeed(speed);

  Future<void> stop() async {
    _loadTimer?.cancel();
    _clearRangeBounds();
    _currentVerse = null;
    _audio.stop();
    state = SurahPlayerSession(endBehaviour: state.endBehaviour);
  }
}
