import 'package:freezed_annotation/freezed_annotation.dart';

part 'bookmark.freezed.dart';
part 'bookmark.g.dart';

@freezed
abstract class Bookmark with _$Bookmark {
  const factory Bookmark({
    int? id,
    @JsonKey(name: 'surah_number') required int surahNumber,
    @JsonKey(name: 'ayah_number') required int ayahNumber,
    @JsonKey(name: 'created_at') String? createdAt,
  }) = _Bookmark;

  factory Bookmark.fromJson(Map<String, dynamic> json) => _$BookmarkFromJson(json);
}
