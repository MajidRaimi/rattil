import 'package:dio/dio.dart';

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
}
