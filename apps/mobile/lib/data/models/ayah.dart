import 'package:freezed_annotation/freezed_annotation.dart';

part 'ayah.freezed.dart';
part 'ayah.g.dart';

@freezed
abstract class Ayah with _$Ayah {
  const factory Ayah({
    required int id,
    @JsonKey(name: 'surah_number') required int surahNumber,
    @JsonKey(name: 'ayah_number') required int ayahNumber,
    @JsonKey(name: 'text_uthmani') required String textUthmani,
    @JsonKey(name: 'text_simple') required String textSimple,
    required int juz,
    required int hizb,
    required int page,
    String? translation,
  }) = _Ayah;

  factory Ayah.fromJson(Map<String, dynamic> json) => _$AyahFromJson(json);
}
