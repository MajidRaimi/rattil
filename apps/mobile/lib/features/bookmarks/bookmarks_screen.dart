import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/typography_ext.dart';
import '../../core/utils/collection_icons.dart';
import '../../core/utils/quranic_text.dart';
import '../../providers/quran_providers.dart';
import 'widgets/create_collection_sheet.dart';

class BookmarksScreen extends ConsumerStatefulWidget {
  const BookmarksScreen({super.key});

  @override
  ConsumerState<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends ConsumerState<BookmarksScreen> {
  /// null = "All", otherwise the selected collection id
  int? _selectedCollectionId;

  @override
  Widget build(BuildContext context) {
    final bookmarksAsync = ref.watch(allBookmarksProvider);
    final collectionsAsync = ref.watch(allCollectionsProvider);
    final typo = context.typography;
    final colors = context.colors;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            // Title row with "+" button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text(
                    Locales.string(context, 'bookmarks'),
                    style: typo.headlineMedium.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: _createCollection,
                    icon: Icon(Icons.add_rounded,
                        color: colors.gold, size: 24),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Filter chips row
            collectionsAsync.when(
              data: (collections) {
                if (collections.isEmpty) return const SizedBox.shrink();
                return SizedBox(
                  height: 38,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: collections.length + 1,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      if (i == 0) {
                        return _FilterChip(
                          label: Locales.string(context, 'all_bookmarks'),
                          isSelected: _selectedCollectionId == null,
                          onTap: () =>
                              setState(() => _selectedCollectionId = null),
                        );
                      }
                      final c = collections[i - 1];
                      final id = c['id'] as int;
                      return _FilterChip(
                        label: c['title'] as String,
                        iconData: getCollectionIcon(
                            c['icon_name'] as String),
                        isSelected: _selectedCollectionId == id,
                        onTap: () =>
                            setState(() => _selectedCollectionId = id),
                        onLongPress: () => _showCollectionOptions(c),
                      );
                    },
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),

            const SizedBox(height: 12),

            // Bookmark list (filtered or all)
            Expanded(
              child: _selectedCollectionId != null
                  ? _buildFilteredList()
                  : _buildAllList(bookmarksAsync),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllList(AsyncValue<List<Map<String, dynamic>>> bookmarksAsync) {
    final typo = context.typography;
    final colors = context.colors;
    final iconsMap =
        ref.watch(bookmarkCollectionIconsProvider).valueOrNull ??
            <String, List<String>>{};

    return bookmarksAsync.when(
      data: (bookmarks) {
        if (bookmarks.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.bookmark_border,
                    size: 56,
                    color: colors.textTertiary.withValues(alpha: 0.3)),
                const SizedBox(height: 16),
                LocaleText(
                  'no_bookmarks_yet',
                  style:
                      typo.titleMedium.copyWith(color: colors.textTertiary),
                ),
                const SizedBox(height: 6),
                LocaleText(
                  'tap_bookmark_hint',
                  style: typo.bodySmall.copyWith(
                    color: colors.textTertiary.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: bookmarks.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) {
            final key =
                '${bookmarks[i]['surah_number']}:${bookmarks[i]['ayah_number']}';
            return BookmarkCard(
              bookmark: bookmarks[i],
              collectionIcons: iconsMap[key],
              onTap: () {
                ref.read(readerNavigationProvider.notifier).state =
                    ReaderNavigationRequest(
                  surahNumber: bookmarks[i]['surah_number'] as int,
                  ayahNumber: bookmarks[i]['ayah_number'] as int,
                  highlight: true,
                );
              },
              onDismissed: () => _removeBookmark(bookmarks[i]),
            );
          },
        );
      },
      loading: () =>
          Center(child: CircularProgressIndicator(color: colors.gold)),
      error: (_, __) => Center(
        child: LocaleText('error_loading_bookmarks', style: typo.bodyLarge),
      ),
    );
  }

  Widget _buildFilteredList() {
    final typo = context.typography;
    final colors = context.colors;
    final filteredAsync =
        ref.watch(collectionBookmarksProvider(_selectedCollectionId!));

    // Find the selected collection to get its icon
    final collections =
        ref.watch(allCollectionsProvider).valueOrNull ?? <Map<String, dynamic>>[];
    final selectedCollection = collections.cast<Map<String, dynamic>?>().firstWhere(
        (c) => c?['id'] == _selectedCollectionId,
        orElse: () => null);
    final selectedIconName =
        selectedCollection?['icon_name'] as String? ?? 'bookmark';

    return filteredAsync.when(
      data: (bookmarks) {
        if (bookmarks.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.bookmark_border,
                    size: 48,
                    color: colors.textTertiary.withValues(alpha: 0.3)),
                const SizedBox(height: 12),
                LocaleText(
                  'no_bookmarks_yet',
                  style:
                      typo.bodyMedium.copyWith(color: colors.textTertiary),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: bookmarks.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) => BookmarkCard(
            bookmark: bookmarks[i],
            collectionIcons: [selectedIconName],
            onTap: () {
              ref.read(readerNavigationProvider.notifier).state =
                  ReaderNavigationRequest(
                surahNumber: bookmarks[i]['surah_number'] as int,
                ayahNumber: bookmarks[i]['ayah_number'] as int,
                highlight: true,
              );
            },
            onDismissed: () {
              final surahNumber = bookmarks[i]['surah_number'] as int;
              final ayahNumber = bookmarks[i]['ayah_number'] as int;
              ref
                  .read(quranRepositoryProvider)
                  .removeBookmarkFromCollection(
                      _selectedCollectionId!, surahNumber, ayahNumber);
              ref.invalidate(
                  collectionBookmarksProvider(_selectedCollectionId!));
              ref.invalidate(allCollectionsProvider);
            },
          ),
        );
      },
      loading: () =>
          Center(child: CircularProgressIndicator(color: colors.gold)),
      error: (_, __) => Center(
        child: LocaleText('error_loading_bookmarks', style: typo.bodyLarge),
      ),
    );
  }

  Future<void> _createCollection() async {
    final result = await showModalBottomSheet<(String, String)>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CreateCollectionSheet(),
    );
    if (result == null) return;
    await ref
        .read(quranRepositoryProvider)
        .createCollection(result.$1, result.$2);
    ref.invalidate(allCollectionsProvider);
  }

  void _showCollectionOptions(Map<String, dynamic> collection) {
    final colors = context.colors;
    final typo = context.typography;
    final id = collection['id'] as int;
    final title = collection['title'] as String;
    final iconName = collection['icon_name'] as String;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading:
                  Icon(Icons.edit_rounded, color: colors.textSecondary),
              title: Text(
                Locales.string(context, 'edit_collection'),
                style: typo.bodyLarge.copyWith(color: colors.textPrimary),
              ),
              onTap: () async {
                Navigator.pop(ctx);
                final result =
                    await showModalBottomSheet<(String, String)>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => CreateCollectionSheet(
                    initialTitle: title,
                    initialIcon: iconName,
                  ),
                );
                if (result == null) return;
                await ref
                    .read(quranRepositoryProvider)
                    .updateCollection(id, result.$1, result.$2);
                ref.invalidate(allCollectionsProvider);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_outline_rounded,
                  color: colors.error),
              title: Text(
                Locales.string(context, 'delete_collection'),
                style: typo.bodyLarge.copyWith(color: colors.error),
              ),
              onTap: () async {
                Navigator.pop(ctx);
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (dCtx) => AlertDialog(
                    backgroundColor: colors.surface,
                    title: Text(
                      Locales.string(context, 'delete_collection'),
                      style: typo.headlineMedium.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    content: Text(
                      Locales.string(
                          context, 'delete_collection_confirm'),
                      style: typo.bodyMedium
                          .copyWith(color: colors.textSecondary),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dCtx, false),
                        child: Text(
                          Locales.string(context, 'cancel'),
                          style: typo.bodyMedium.copyWith(
                              color: colors.textSecondary),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(dCtx, true),
                        child: Text(
                          Locales.string(context, 'delete'),
                          style: typo.bodyMedium
                              .copyWith(color: colors.error),
                        ),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await ref
                      .read(quranRepositoryProvider)
                      .deleteCollection(id);
                  ref.invalidate(allCollectionsProvider);
                  if (_selectedCollectionId == id) {
                    setState(() => _selectedCollectionId = null);
                  }
                }
              },
            ),
            SizedBox(
                height: MediaQuery.of(context).viewPadding.bottom),
          ],
        ),
      ),
    );
  }

  void _removeBookmark(Map<String, dynamic> bookmark) {
    final surahNumber = bookmark['surah_number'] as int;
    final ayahNumber = bookmark['ayah_number'] as int;

    ref
        .read(quranRepositoryProvider)
        .removeBookmark(surahNumber, ayahNumber);
    ref.invalidate(allBookmarksProvider);
    ref.invalidate(bookmarkKeysProvider);
    ref.invalidate(allCollectionsProvider);
    ref.invalidate(bookmarkCollectionIconsProvider);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(Locales.string(context, 'bookmark_removed')),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: Locales.string(context, 'undo'),
          onPressed: () {
            ref
                .read(quranRepositoryProvider)
                .addBookmark(surahNumber, ayahNumber);
            ref.invalidate(allBookmarksProvider);
            ref.invalidate(bookmarkKeysProvider);
          },
        ),
      ),
    );
  }
}

// ── Filter Chip ──

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData? iconData;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const _FilterChip({
    required this.label,
    this.iconData,
    required this.isSelected,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final typo = context.typography;
    final colors = context.colors;
    const duration = Duration(milliseconds: 250);
    const curve = Curves.easeInOut;

    final targetIconColor = isSelected ? Colors.white : colors.gold;
    final targetTextColor =
        isSelected ? Colors.white : colors.textSecondary;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: duration,
        curve: curve,
        padding: EdgeInsets.symmetric(
            horizontal: iconData != null ? 12 : 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? colors.gold : colors.surface,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (iconData != null) ...[
              TweenAnimationBuilder<Color?>(
                tween: ColorTween(end: targetIconColor),
                duration: duration,
                curve: curve,
                builder: (_, color, __) => Icon(
                  iconData,
                  size: 14,
                  color: color,
                ),
              ),
              const SizedBox(width: 6),
            ],
            TweenAnimationBuilder<Color?>(
              tween: ColorTween(end: targetTextColor),
              duration: duration,
              curve: curve,
              builder: (_, color, __) => Text(
                label,
                style: typo.bodySmall.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Bookmark Card ──

class BookmarkCard extends StatelessWidget {
  final Map<String, dynamic> bookmark;
  final VoidCallback onTap;
  final VoidCallback onDismissed;
  final List<String>? collectionIcons;

  const BookmarkCard({
    super.key,
    required this.bookmark,
    required this.onTap,
    required this.onDismissed,
    this.collectionIcons,
  });

  @override
  Widget build(BuildContext context) {
    final typo = context.typography;
    final colors = context.colors;
    final isArabic =
        Locales.currentLocale(context)?.languageCode == 'ar';

    final surahNumber = bookmark['surah_number'] as int;
    final ayahNumber = bookmark['ayah_number'] as int;
    final nameEnglish = bookmark['name_english'] as String;
    final nameArabic = bookmark['name_arabic'] as String;
    final textUthmani = bookmark['text_uthmani'] as String;
    final translation = bookmark['translation'] as String?;

    return Dismissible(
      key: ValueKey('$surahNumber:$ayahNumber'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismissed(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: colors.error.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(Icons.delete_outline, color: colors.error),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: colors.gold.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$surahNumber:$ayahNumber',
                        style: typo.bodySmall.copyWith(
                          color: colors.gold,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        isArabic ? nameArabic : nameEnglish,
                        style: typo.bodyMedium.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    // Collection icons
                    if (collectionIcons != null &&
                        collectionIcons!.isNotEmpty)
                      ...collectionIcons!.map((iconName) => Padding(
                            padding:
                                const EdgeInsetsDirectional.only(end: 4),
                            child: Icon(
                              getCollectionIcon(iconName),
                              size: 14,
                              color: colors.goldDim,
                            ),
                          )),
                    if (!isArabic)
                      Text(
                        nameArabic,
                        style: typo.arabicDisplayBody.copyWith(
                          fontSize: 14,
                          color: colors.textTertiary,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    stripQuranicMarks(textUthmani),
                    style: typo.quranArabic
                        .copyWith(fontSize: 20, height: 1.8),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textDirection: TextDirection.rtl,
                  ),
                ),
                if (translation != null && translation.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    translation,
                    style: typo.bodySmall.copyWith(
                      color: colors.textTertiary,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
