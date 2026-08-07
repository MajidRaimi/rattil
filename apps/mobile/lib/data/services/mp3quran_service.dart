import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:imad_flutter/imad_flutter.dart' as imad;
import 'package:path_provider/path_provider.dart';

const _kApiBase = 'https://www.mp3quran.net/api/v3';

class Mp3QuranService {
  Mp3QuranService._();
  static final instance = Mp3QuranService._();

  final _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 12),
      receiveTimeout: const Duration(seconds: 20),
      responseType: ResponseType.json,
    ),
  );

  Set<int>? _timedReadIds;
  List<imad.ReciterInfo>? _catalogue;
  String? _cacheDirPath;

  Future<String> get _cacheDir async {
    if (_cacheDirPath != null) return _cacheDirPath!;
    final base = await getApplicationCacheDirectory();
    final dir = Directory('${base.path}/ayah_timing');
    if (!dir.existsSync()) dir.createSync(recursive: true);
    _cacheDirPath = dir.path;
    return _cacheDirPath!;
  }

  Future<Set<int>> timedReadIds() async {
    if (_timedReadIds != null) return _timedReadIds!;
    try {
      final resp = await _dio.get('$_kApiBase/ayat_timing/reads');
      final list = _asList(resp.data);
      _timedReadIds = list
          .whereType<Map>()
          .map((e) => e['id'])
          .whereType<int>()
          .toSet();
    } catch (_) {
      _timedReadIds = <int>{};
    }
    return _timedReadIds!;
  }

  Future<List<imad.ReciterInfo>> catalogue({String language = 'ar'}) async {
    if (_catalogue != null) return _catalogue!;
    final resp = await _dio.get(
      '$_kApiBase/reciters',
      queryParameters: {'language': language},
    );
    final reciters = _asList((resp.data as Map)['reciters']);
    final result = <imad.ReciterInfo>[];
    for (final entry in reciters.whereType<Map>()) {
      final name = entry['name'] as String? ?? '';
      for (final moshaf in _asList(entry['moshaf']).whereType<Map>()) {
        final id = moshaf['id'];
        final server = moshaf['server'] as String?;
        final total = moshaf['surah_total'];
        if (id is! int || server == null || server.isEmpty) continue;
        if (total is int && total < 114) continue;
        result.add(
          imad.ReciterInfo(
            id: id,
            nameArabic: name,
            nameEnglish: name,
            rewaya: moshaf['name'] as String? ?? '',
            folderUrl: server.endsWith('/') ? server : '$server/',
          ),
        );
      }
    }
    _catalogue = result;
    return result;
  }

  Future<List<imad.ReciterInfo>> searchCatalogue(
    String query, {
    String language = 'ar',
  }) async {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return const [];
    final all = await catalogue(language: language);
    final bundledIds = imad.ReciterDataProvider.allReciters
        .map((r) => r.id)
        .toSet();
    return all
        .where((r) => !bundledIds.contains(r.id))
        .where((r) => r.nameArabic.toLowerCase().contains(normalized))
        .toList();
  }

  Future<List<imad.AyahTiming>?> fetchAyahTiming(
    int reciterId,
    int chapterNumber,
  ) async {
    final dir = await _cacheDir;
    final file = File('$dir/${reciterId}_$chapterNumber.json');

    if (file.existsSync()) {
      try {
        return _parseTimings(jsonDecode(await file.readAsString()));
      } catch (_) {
        try {
          file.deleteSync();
        } catch (_) {}
      }
    }

    try {
      final resp = await _dio.get(
        '$_kApiBase/ayat_timing',
        queryParameters: {'surah': chapterNumber, 'read': reciterId},
      );
      final timings = _parseTimings(resp.data);
      if (timings.isEmpty) return null;
      try {
        await file.writeAsString(
          jsonEncode(
            timings
                .map(
                  (t) => {
                    'ayah': t.ayah,
                    'start_time': t.startTime,
                    'end_time': t.endTime,
                  },
                )
                .toList(),
          ),
        );
      } catch (_) {}
      return timings;
    } catch (_) {
      return null;
    }
  }

  List<imad.AyahTiming> _parseTimings(dynamic data) {
    final list = _asList(data);
    final result = <imad.AyahTiming>[];
    for (final entry in list.whereType<Map>()) {
      final ayah = _asInt(entry['ayah']);
      final start = _asInt(entry['start_time']);
      final end = _asInt(entry['end_time']);
      if (ayah == null || start == null || end == null) continue;
      result.add(
        imad.AyahTiming(ayah: ayah, startTime: start, endTime: end),
      );
    }
    return result;
  }

  List<dynamic> _asList(dynamic value) {
    if (value is List) return value;
    if (value is String && value.isNotEmpty) {
      try {
        final decoded = jsonDecode(value);
        if (decoded is List) return decoded;
      } catch (_) {}
    }
    return const [];
  }

  int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}
