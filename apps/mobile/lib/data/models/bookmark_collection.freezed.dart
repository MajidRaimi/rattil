// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bookmark_collection.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

BookmarkCollection _$BookmarkCollectionFromJson(Map<String, dynamic> json) {
  return _BookmarkCollection.fromJson(json);
}

/// @nodoc
mixin _$BookmarkCollection {
  int? get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  @JsonKey(name: 'icon_name')
  String get iconName => throw _privateConstructorUsedError;
  @JsonKey(name: 'sort_order')
  int get sortOrder => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  String? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'bookmark_count')
  int get bookmarkCount => throw _privateConstructorUsedError;

  /// Serializes this BookmarkCollection to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BookmarkCollection
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BookmarkCollectionCopyWith<BookmarkCollection> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BookmarkCollectionCopyWith<$Res> {
  factory $BookmarkCollectionCopyWith(
    BookmarkCollection value,
    $Res Function(BookmarkCollection) then,
  ) = _$BookmarkCollectionCopyWithImpl<$Res, BookmarkCollection>;
  @useResult
  $Res call({
    int? id,
    String title,
    @JsonKey(name: 'icon_name') String iconName,
    @JsonKey(name: 'sort_order') int sortOrder,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'bookmark_count') int bookmarkCount,
  });
}

/// @nodoc
class _$BookmarkCollectionCopyWithImpl<$Res, $Val extends BookmarkCollection>
    implements $BookmarkCollectionCopyWith<$Res> {
  _$BookmarkCollectionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BookmarkCollection
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? title = null,
    Object? iconName = null,
    Object? sortOrder = null,
    Object? createdAt = freezed,
    Object? bookmarkCount = null,
  }) {
    return _then(
      _value.copyWith(
            id: freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int?,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            iconName: null == iconName
                ? _value.iconName
                : iconName // ignore: cast_nullable_to_non_nullable
                      as String,
            sortOrder: null == sortOrder
                ? _value.sortOrder
                : sortOrder // ignore: cast_nullable_to_non_nullable
                      as int,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as String?,
            bookmarkCount: null == bookmarkCount
                ? _value.bookmarkCount
                : bookmarkCount // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BookmarkCollectionImplCopyWith<$Res>
    implements $BookmarkCollectionCopyWith<$Res> {
  factory _$$BookmarkCollectionImplCopyWith(
    _$BookmarkCollectionImpl value,
    $Res Function(_$BookmarkCollectionImpl) then,
  ) = __$$BookmarkCollectionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int? id,
    String title,
    @JsonKey(name: 'icon_name') String iconName,
    @JsonKey(name: 'sort_order') int sortOrder,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'bookmark_count') int bookmarkCount,
  });
}

/// @nodoc
class __$$BookmarkCollectionImplCopyWithImpl<$Res>
    extends _$BookmarkCollectionCopyWithImpl<$Res, _$BookmarkCollectionImpl>
    implements _$$BookmarkCollectionImplCopyWith<$Res> {
  __$$BookmarkCollectionImplCopyWithImpl(
    _$BookmarkCollectionImpl _value,
    $Res Function(_$BookmarkCollectionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BookmarkCollection
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? title = null,
    Object? iconName = null,
    Object? sortOrder = null,
    Object? createdAt = freezed,
    Object? bookmarkCount = null,
  }) {
    return _then(
      _$BookmarkCollectionImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int?,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        iconName: null == iconName
            ? _value.iconName
            : iconName // ignore: cast_nullable_to_non_nullable
                  as String,
        sortOrder: null == sortOrder
            ? _value.sortOrder
            : sortOrder // ignore: cast_nullable_to_non_nullable
                  as int,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as String?,
        bookmarkCount: null == bookmarkCount
            ? _value.bookmarkCount
            : bookmarkCount // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BookmarkCollectionImpl implements _BookmarkCollection {
  const _$BookmarkCollectionImpl({
    this.id,
    required this.title,
    @JsonKey(name: 'icon_name') this.iconName = 'bookmark',
    @JsonKey(name: 'sort_order') this.sortOrder = 0,
    @JsonKey(name: 'created_at') this.createdAt,
    @JsonKey(name: 'bookmark_count') this.bookmarkCount = 0,
  });

  factory _$BookmarkCollectionImpl.fromJson(Map<String, dynamic> json) =>
      _$$BookmarkCollectionImplFromJson(json);

  @override
  final int? id;
  @override
  final String title;
  @override
  @JsonKey(name: 'icon_name')
  final String iconName;
  @override
  @JsonKey(name: 'sort_order')
  final int sortOrder;
  @override
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @override
  @JsonKey(name: 'bookmark_count')
  final int bookmarkCount;

  @override
  String toString() {
    return 'BookmarkCollection(id: $id, title: $title, iconName: $iconName, sortOrder: $sortOrder, createdAt: $createdAt, bookmarkCount: $bookmarkCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BookmarkCollectionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.iconName, iconName) ||
                other.iconName == iconName) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.bookmarkCount, bookmarkCount) ||
                other.bookmarkCount == bookmarkCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    title,
    iconName,
    sortOrder,
    createdAt,
    bookmarkCount,
  );

  /// Create a copy of BookmarkCollection
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BookmarkCollectionImplCopyWith<_$BookmarkCollectionImpl> get copyWith =>
      __$$BookmarkCollectionImplCopyWithImpl<_$BookmarkCollectionImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$BookmarkCollectionImplToJson(this);
  }
}

abstract class _BookmarkCollection implements BookmarkCollection {
  const factory _BookmarkCollection({
    final int? id,
    required final String title,
    @JsonKey(name: 'icon_name') final String iconName,
    @JsonKey(name: 'sort_order') final int sortOrder,
    @JsonKey(name: 'created_at') final String? createdAt,
    @JsonKey(name: 'bookmark_count') final int bookmarkCount,
  }) = _$BookmarkCollectionImpl;

  factory _BookmarkCollection.fromJson(Map<String, dynamic> json) =
      _$BookmarkCollectionImpl.fromJson;

  @override
  int? get id;
  @override
  String get title;
  @override
  @JsonKey(name: 'icon_name')
  String get iconName;
  @override
  @JsonKey(name: 'sort_order')
  int get sortOrder;
  @override
  @JsonKey(name: 'created_at')
  String? get createdAt;
  @override
  @JsonKey(name: 'bookmark_count')
  int get bookmarkCount;

  /// Create a copy of BookmarkCollection
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BookmarkCollectionImplCopyWith<_$BookmarkCollectionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
