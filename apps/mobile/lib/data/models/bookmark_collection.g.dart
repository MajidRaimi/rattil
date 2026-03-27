// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bookmark_collection.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BookmarkCollectionImpl _$$BookmarkCollectionImplFromJson(
  Map<String, dynamic> json,
) => _$BookmarkCollectionImpl(
  id: (json['id'] as num?)?.toInt(),
  title: json['title'] as String,
  iconName: json['icon_name'] as String? ?? 'bookmark',
  sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
  createdAt: json['created_at'] as String?,
  bookmarkCount: (json['bookmark_count'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$$BookmarkCollectionImplToJson(
  _$BookmarkCollectionImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'icon_name': instance.iconName,
  'sort_order': instance.sortOrder,
  'created_at': instance.createdAt,
  'bookmark_count': instance.bookmarkCount,
};
