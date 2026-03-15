// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ayah.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AyahImpl _$$AyahImplFromJson(Map<String, dynamic> json) => _$AyahImpl(
  id: (json['id'] as num).toInt(),
  surahNumber: (json['surah_number'] as num).toInt(),
  ayahNumber: (json['ayah_number'] as num).toInt(),
  textUthmani: json['text_uthmani'] as String,
  textSimple: json['text_simple'] as String,
  juz: (json['juz'] as num).toInt(),
  hizb: (json['hizb'] as num).toInt(),
  page: (json['page'] as num).toInt(),
  translation: json['translation'] as String?,
);

Map<String, dynamic> _$$AyahImplToJson(_$AyahImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'surah_number': instance.surahNumber,
      'ayah_number': instance.ayahNumber,
      'text_uthmani': instance.textUthmani,
      'text_simple': instance.textSimple,
      'juz': instance.juz,
      'hizb': instance.hizb,
      'page': instance.page,
      'translation': instance.translation,
    };
