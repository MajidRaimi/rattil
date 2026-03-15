// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NoteImpl _$$NoteImplFromJson(Map<String, dynamic> json) => _$NoteImpl(
  id: (json['id'] as num?)?.toInt(),
  surahNumber: (json['surah_number'] as num).toInt(),
  ayahNumber: (json['ayah_number'] as num).toInt(),
  text: json['text'] as String,
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
);

Map<String, dynamic> _$$NoteImplToJson(_$NoteImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'surah_number': instance.surahNumber,
      'ayah_number': instance.ayahNumber,
      'text': instance.text,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
