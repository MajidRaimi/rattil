// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bookmark.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BookmarkImpl _$$BookmarkImplFromJson(Map<String, dynamic> json) =>
    _$BookmarkImpl(
      id: (json['id'] as num?)?.toInt(),
      surahNumber: (json['surah_number'] as num).toInt(),
      ayahNumber: (json['ayah_number'] as num).toInt(),
      createdAt: json['created_at'] as String?,
    );

Map<String, dynamic> _$$BookmarkImplToJson(_$BookmarkImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'surah_number': instance.surahNumber,
      'ayah_number': instance.ayahNumber,
      'created_at': instance.createdAt,
    };
