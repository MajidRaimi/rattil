import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class TasmiService {
  TasmiService._();
  static final instance = TasmiService._();

  static const _baseUrl = 'https://api.rattil.app';

  final _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(minutes: 2),
  ));

  /// Transcribes audio bytes via HTTP POST. Returns the transcribed text.
  Future<String> transcribe(Uint8List audioBytes, String fileName) async {
    debugPrint('[Tasmi] sending ${audioBytes.length} bytes to API...');
    final formData = FormData.fromMap({
      'audio': MultipartFile.fromBytes(audioBytes,
          filename: fileName, contentType: DioMediaType('audio', 'wav')),
    });
    final resp = await _dio.post('$_baseUrl/tasmi/transcribe', data: formData);
    final text = (resp.data as Map<String, dynamic>)['text'] as String;
    debugPrint('[Tasmi] received: $text');
    return text;
  }
}
