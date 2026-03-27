import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/typography_ext.dart';
import '../../core/utils/collection_icons.dart';
import '../../providers/quran_providers.dart';
import 'bookmarks_screen.dart';
import 'widgets/create_collection_sheet.dart';

class CollectionBookmarksScreen extends ConsumerStatefulWidget {
  final int collectionId;
  final String title;
  final String iconName;

  const CollectionBookmarksScreen({
    super.key,
    required this.collectionId,
    required this.title,
    required this.iconName,
  });

  @override
  ConsumerState<CollectionBookmarksScreen> createState() =>
      _CollectionBookmarksScreenState();
}

class _CollectionBookmarksScreenState
    extends ConsumerState<CollectionBookmarksScreen> {
  late String _title;
  late String _iconName;

  @override
  void initState() {
    super.initState();
    _title = widget.title;
    _iconName = widget.iconName;
  }

  @override
  Widget build(BuildContext context) {
    final typo = context.typography;
    final colors = context.colors;
    final bookmarksAsync =
        ref.watch(collectionBookmarksProvider(widget.collectionId));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_rounded, color: colors.textPrimary),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(getCollectionIcon(_iconName), color: colors.gold, size: 20),
            const SizedBox(width: 8),
            Text(
              _title,
              style: typo.titleMedium.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert_rounded, color: colors.textSecondary),
            onSelected: (value) {
              if (value == 'edit') _editCollection();
              if (value == 'delete') _deleteCollection();
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_rounded,
                        size: 18, color: colors.textSecondary),
                    const SizedBox(width: 10),
                    Text(Locales.string(context, 'edit_collection')),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline_rounded,
                        size: 18, color: colors.error),
                    const SizedBox(width: 10),
                    Text(
                      Locales.string(context, 'delete_collection'),
                      style: TextStyle(color: colors.error),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      backgroundColor: colors.background,
      body: bookmarksAsync.when(
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
                  Text(
                    Locales.string(context, 'no_bookmarks_yet'),
                    style:
                        typo.bodyMedium.copyWith(color: colors.textTertiary),
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: bookmarks.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) => BookmarkCard(
              bookmark: bookmarks[i],
              onTap: () {
                ref.read(readerNavigationProvider.notifier).state =
                    ReaderNavigationRequest(
                  surahNumber: bookmarks[i]['surah_number'] as int,
                  ayahNumber: bookmarks[i]['ayah_number'] as int,
                  highlight: true,
                );
                Navigator.pop(context);
              },
              onDismissed: () => _removeFromCollection(bookmarks[i]),
            ),
          );
        },
        loading: () =>
            Center(child: CircularProgressIndicator(color: colors.gold)),
        error: (_, __) => Center(
          child: LocaleText('error_loading_bookmarks', style: typo.bodyLarge),
        ),
      ),
    );
  }

  Future<void> _editCollection() async {
    final result = await showModalBottomSheet<(String, String)>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CreateCollectionSheet(
        initialTitle: _title,
        initialIcon: _iconName,
      ),
    );
    if (result == null) return;
    await ref
        .read(quranRepositoryProvider)
        .updateCollection(widget.collectionId, result.$1, result.$2);
    ref.invalidate(allCollectionsProvider);
    setState(() {
      _title = result.$1;
      _iconName = result.$2;
    });
  }

  Future<void> _deleteCollection() async {
    final colors = context.colors;
    final typo = context.typography;
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
          Locales.string(context, 'delete_collection_confirm'),
          style: typo.bodyMedium.copyWith(color: colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dCtx, false),
            child: Text(
              Locales.string(context, 'cancel'),
              style: typo.bodyMedium.copyWith(color: colors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dCtx, true),
            child: Text(
              Locales.string(context, 'delete'),
              style: typo.bodyMedium.copyWith(color: colors.error),
            ),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await ref
          .read(quranRepositoryProvider)
          .deleteCollection(widget.collectionId);
      ref.invalidate(allCollectionsProvider);
      if (mounted) Navigator.pop(context);
    }
  }

  void _removeFromCollection(Map<String, dynamic> bookmark) {
    final surahNumber = bookmark['surah_number'] as int;
    final ayahNumber = bookmark['ayah_number'] as int;

    ref.read(quranRepositoryProvider).removeBookmarkFromCollection(
        widget.collectionId, surahNumber, ayahNumber);
    ref.invalidate(collectionBookmarksProvider(widget.collectionId));
    ref.invalidate(allCollectionsProvider);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(Locales.string(context, 'bookmark_removed')),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: Locales.string(context, 'undo'),
          onPressed: () {
            ref.read(quranRepositoryProvider).addBookmarkToCollection(
                widget.collectionId, surahNumber, ayahNumber);
            ref.invalidate(collectionBookmarksProvider(widget.collectionId));
            ref.invalidate(allCollectionsProvider);
          },
        ),
      ),
    );
  }
}
