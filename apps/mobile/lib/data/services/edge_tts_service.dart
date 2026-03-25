import 'dart:typed_data';
import 'package:dio/dio.dart';

class EdgeTtsService {
  EdgeTtsService._();
  static final instance = EdgeTtsService._();

  static const _baseUrl = 'https://api.rattil.app';

  final _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(minutes: 5),
    responseType: ResponseType.bytes,
  ));

  /// Fetches TTS audio from the API as MP3 bytes.
  Future<Uint8List> synthesize(String text, {String language = 'ar'}) async {
    final resp = await _dio.get(
      '$_baseUrl/tts/speak',
      queryParameters: {'text': text, 'lang': language},
    );
    return Uint8List.fromList(resp.data);
  }
}
