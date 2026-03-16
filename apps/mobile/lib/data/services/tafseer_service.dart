import 'package:dio/dio.dart';

class TafsirSource {
  final int id;
  final String language;
  const TafsirSource({required this.id, required this.language});
}

const _localeTafsirMap = <String, List<TafsirSource>>{
  'ar': [
    TafsirSource(id: 14, language: 'ar'),
    TafsirSource(id: 15, language: 'ar'),
    TafsirSource(id: 90, language: 'ar'),
    TafsirSource(id: 91, language: 'ar'),
    TafsirSource(id: 16, language: 'ar'),
    TafsirSource(id: 93, language: 'ar'),
    TafsirSource(id: 94, language: 'ar'),
  ],
  'en': [
    TafsirSource(id: 169, language: 'en'),
    TafsirSource(id: 168, language: 'en'),
    TafsirSource(id: 817, language: 'en'),
  ],
  'bn': [
    TafsirSource(id: 164, language: 'bn'),
    TafsirSource(id: 165, language: 'bn'),
    TafsirSource(id: 166, language: 'bn'),
    TafsirSource(id: 381, language: 'bn'),
  ],
  'ur': [
    TafsirSource(id: 160, language: 'ur'),
    TafsirSource(id: 157, language: 'ur'),
    TafsirSource(id: 159, language: 'ur'),
    TafsirSource(id: 818, language: 'ur'),
  ],
  'ru': [
    TafsirSource(id: 170, language: 'ru'),
  ],
  'ku': [
    TafsirSource(id: 804, language: 'ku'),
  ],
};

class TafseerService {
  TafseerService._();
  static final instance = TafseerService._();

  final _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  final _cache = <String, String>{};

  List<TafsirSource> getTafsirsForLocale(String locale) {
    return _localeTafsirMap[locale] ?? _localeTafsirMap['en']!;
  }

  Future<String> fetchTafsir(int tafsirId, int surah, int verse) async {
    final key = '$tafsirId:$surah:$verse';
    if (_cache.containsKey(key)) return _cache[key]!;

    final resp = await _dio.get(
      'https://api.quran.com/api/v4/tafsirs/$tafsirId/by_ayah/$surah:$verse',
    );

    var text = resp.data['tafsir']['text'] as String;
    // Strip HTML tags
    text = text.replaceAll(RegExp(r'<[^>]*>'), '');
    // Decode common HTML entities
    text = text
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&lrm;', '')
        .replaceAll('&rlm;', '');
    text = text.trim();

    _cache[key] = text;
    return text;
  }
}
