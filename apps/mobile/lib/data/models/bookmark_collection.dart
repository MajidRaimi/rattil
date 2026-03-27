import 'package:freezed_annotation/freezed_annotation.dart';

part 'bookmark_collection.freezed.dart';
part 'bookmark_collection.g.dart';

@freezed
abstract class BookmarkCollection with _$BookmarkCollection {
  const factory BookmarkCollection({
    int? id,
    required String title,
    @JsonKey(name: 'icon_name') @Default('bookmark') String iconName,
    @JsonKey(name: 'sort_order') @Default(0) int sortOrder,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'bookmark_count') @Default(0) int bookmarkCount,
  }) = _BookmarkCollection;

  factory BookmarkCollection.fromJson(Map<String, dynamic> json) =>
      _$BookmarkCollectionFromJson(json);
}
