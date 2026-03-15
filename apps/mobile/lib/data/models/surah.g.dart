// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'surah.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SurahImpl _$$SurahImplFromJson(Map<String, dynamic> json) => _$SurahImpl(
  number: (json['number'] as num).toInt(),
  nameArabic: json['name_arabic'] as String,
  nameEnglish: json['name_english'] as String,
  nameTranslation: json['name_translation'] as String,
  revelationType: json['revelation_type'] as String,
  ayahCount: (json['ayah_count'] as num).toInt(),
);

Map<String, dynamic> _$$SurahImplToJson(_$SurahImpl instance) =>
    <String, dynamic>{
      'number': instance.number,
      'name_arabic': instance.nameArabic,
      'name_english': instance.nameEnglish,
      'name_translation': instance.nameTranslation,
      'revelation_type': instance.revelationType,
      'ayah_count': instance.ayahCount,
    };
