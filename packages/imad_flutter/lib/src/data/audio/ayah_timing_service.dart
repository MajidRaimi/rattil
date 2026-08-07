import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';

import '../../domain/models/reciter_timing.dart';
import 'reciter_data_provider.dart';

typedef AyahTimingRemoteFetcher =
    Future<List<AyahTiming>?> Function(int reciterId, int chapterNumber);

/// Service for loading and querying verse timing data for audio sync.
/// Internal implementation.
class AyahTimingService {
  final Map<int, ReciterTiming> _timingCache = {};
  final Map<String, List<AyahTiming>> _chapterCache = {};
  final Map<String, Future<List<AyahTiming>>> _inFlight = {};

  static AyahTimingRemoteFetcher? remoteFetcher;

  static String _key(int reciterId, int chapterNumber) =>
      '$reciterId:$chapterNumber';

  /// Load timing data for a specific reciter from assets.
  Future<ReciterTiming?> loadTimingData(int reciterId) async {
    if (_timingCache.containsKey(reciterId)) {
      return _timingCache[reciterId];
    }
    if (!ReciterDataProvider.bundledTimingIds.contains(reciterId)) return null;

    try {
      final jsonString = await rootBundle.loadString(
        'packages/imad_flutter/assets/ayah_timing/read_$reciterId.json',
      );
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final timing = ReciterTiming.fromJson(json);
      _timingCache[reciterId] = timing;
      return timing;
    } catch (e) {
      return null;
    }
  }

  /// Get verse timing for a specific ayah.
  Future<AyahTiming?> getAyahTiming(
    int reciterId,
    int chapterNumber,
    int ayahNumber,
  ) async {
    final timings = await getChapterTimings(reciterId, chapterNumber);
    for (final timing in timings) {
      if (timing.ayah == ayahNumber) return timing;
    }
    return null;
  }

  /// Get the current verse being recited based on playback position.
  Future<int?> getCurrentVerse(
    int reciterId,
    int chapterNumber,
    int currentTimeMs,
  ) async {
    final timings = _chapterCache[_key(reciterId, chapterNumber)];
    if (timings == null) {
      unawaited(getChapterTimings(reciterId, chapterNumber));
      return null;
    }

    for (final timing in timings) {
      if (currentTimeMs >= timing.startTime && currentTimeMs < timing.endTime) {
        return timing.ayah == 0 ? null : timing.ayah;
      }
    }
    return null;
  }

  Future<List<AyahTiming>> getChapterTimings(
    int reciterId,
    int chapterNumber,
  ) async {
    final key = _key(reciterId, chapterNumber);
    final cached = _chapterCache[key];
    if (cached != null) return cached;

    final bundled = await loadTimingData(reciterId);
    if (bundled != null) {
      for (final chapter in bundled.chapters) {
        if (chapter.id == chapterNumber) {
          _chapterCache[key] = chapter.ayaTiming;
          return chapter.ayaTiming;
        }
      }
      return const [];
    }

    final fetcher = remoteFetcher;
    if (fetcher == null) return const [];

    final pending = _inFlight[key];
    if (pending != null) return pending;

    final request = fetcher(reciterId, chapterNumber)
        .then((result) {
          final timings = result ?? const <AyahTiming>[];
          _chapterCache[key] = timings;
          return timings;
        })
        .catchError((_) => const <AyahTiming>[])
        .whenComplete(() => _inFlight.remove(key));

    _inFlight[key] = request;
    return request;
  }

  bool hasTimingForReciter(int reciterId) {
    return ReciterDataProvider.bundledTimingIds.contains(reciterId) ||
        _timingCache.containsKey(reciterId) ||
        remoteFetcher != null;
  }

  Future<void> preloadTiming(int reciterId, {int? chapterNumber}) async {
    if (chapterNumber != null) {
      await getChapterTimings(reciterId, chapterNumber);
      return;
    }
    await loadTimingData(reciterId);
  }
}
