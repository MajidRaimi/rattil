import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class ReciterInfo {
  final String id;
  final String audioUrl;

  const ReciterInfo({required this.id, required this.audioUrl});
}

class RecitationService {
  RecitationService._();
  static final instance = RecitationService._();

  final _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  final _cache = <String, List<ReciterInfo>>{};

  /// In-memory map of already-resolved local file paths.
  /// Key: "{surah}_{verse}_{reciterId}"
  final _fileCache = <String, String>{};

  String? _tikrarDirPath;

  Future<String> get _tikrarDir async {
    if (_tikrarDirPath != null) return _tikrarDirPath!;
    final cacheDir = await getApplicationCacheDirectory();
    final dir = Directory('${cacheDir.path}/tikrar');
    if (!dir.existsSync()) dir.createSync(recursive: true);
    _tikrarDirPath = dir.path;
    return _tikrarDirPath!;
  }

  Future<List<ReciterInfo>> fetchReciters(int surah, int verse) async {
    final key = '$surah:$verse';
    if (_cache.containsKey(key)) return _cache[key]!;

    final resp = await _dio.get(
      'https://quranapi.pages.dev/api/$surah/$verse.json',
    );

    final audio = resp.data['audio'] as Map<String, dynamic>;
    final list = audio.entries
        .map((e) => ReciterInfo(
              id: e.key,
              audioUrl: (e.value as Map<String, dynamic>)['url'] as String,
            ))
        .toList();

    _cache[key] = list;
    return list;
  }

  /// Downloads the MP3 for [surah]:[verse] by [reciterId] to disk.
  /// Returns the local file path. Instant if already cached.
  Future<String> downloadVerse({
    required int surah,
    required int verse,
    required String reciterId,
    required String url,
  }) async {
    final cacheKey = '${surah}_${verse}_$reciterId';
    if (_fileCache.containsKey(cacheKey)) return _fileCache[cacheKey]!;

    final dir = await _tikrarDir;
    final filePath = '$dir/$cacheKey.mp3';
    final file = File(filePath);

    if (file.existsSync()) {
      _fileCache[cacheKey] = filePath;
      return filePath;
    }

    await _dio.download(url, filePath);
    _fileCache[cacheKey] = filePath;
    return filePath;
  }
}
