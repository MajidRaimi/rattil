import 'package:freezed_annotation/freezed_annotation.dart';

part 'surah.freezed.dart';
part 'surah.g.dart';

@freezed
abstract class Surah with _$Surah {
  const factory Surah({
    required int number,
    @JsonKey(name: 'name_arabic') required String nameArabic,
    @JsonKey(name: 'name_english') required String nameEnglish,
    @JsonKey(name: 'name_translation') required String nameTranslation,
    @JsonKey(name: 'revelation_type') required String revelationType,
    @JsonKey(name: 'ayah_count') required int ayahCount,
  }) = _Surah;

  factory Surah.fromJson(Map<String, dynamic> json) => _$SurahFromJson(json);
}
