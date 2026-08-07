import 'dart:io';

import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

class SurahAudioCache {
  SurahAudioCache._();
  static final instance = SurahAudioCache._();

  String? _dirPath;

  Future<String> _dir() async {
    if (_dirPath != null) return _dirPath!;
    final base = await getApplicationCacheDirectory();
    final dir = Directory('${base.path}/surah_audio');
    if (!dir.existsSync()) dir.createSync(recursive: true);
    _dirPath = dir.path;
    return _dirPath!;
  }

  Future<File> fileFor(int reciterId, int chapterNumber) async {
    final dir = await _dir();
    return File('$dir/${reciterId}_$chapterNumber.mp3');
  }

  Future<AudioSource> buildSource(
    Uri uri,
    int reciterId,
    int chapterNumber,
  ) async {
    try {
      final file = await fileFor(reciterId, chapterNumber);
      if (file.existsSync() && file.lengthSync() > 0) {
        return AudioSource.file(file.path);
      }
      return LockCachingAudioSource(uri, cacheFile: file);
    } catch (_) {
      return AudioSource.uri(uri);
    }
  }

  Future<bool> isCached(int reciterId, int chapterNumber) async {
    try {
      final file = await fileFor(reciterId, chapterNumber);
      return file.existsSync() && file.lengthSync() > 0;
    } catch (_) {
      return false;
    }
  }

  Future<int> cachedBytes() async {
    try {
      final dir = Directory(await _dir());
      var total = 0;
      for (final entity in dir.listSync()) {
        if (entity is File) total += entity.lengthSync();
      }
      return total;
    } catch (_) {
      return 0;
    }
  }

  Future<void> clear() async {
    try {
      final dir = Directory(await _dir());
      if (dir.existsSync()) dir.deleteSync(recursive: true);
      _dirPath = null;
    } catch (_) {}
  }
}
