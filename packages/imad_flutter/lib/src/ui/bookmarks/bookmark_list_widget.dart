import 'package:flutter/material.dart';

import '../../data/quran/quran_data_provider.dart';
import '../../di/core_module.dart';
import '../../domain/models/bookmark.dart';
import '../../domain/repository/bookmark_repository.dart';
import 'bookmarks_view_model.dart';

/// A reusable bookmark list widget.
///
/// Displays all user bookmarks grouped by chapter with swipe-to-delete,
/// tap-to-navigate, and an empty state. Uses [BookmarksViewModel] internally.
class BookmarkListWidget extends StatefulWidget {
  /// Called when user taps a bookmark, providing the page number to navigate to.
  final void Function(int pageNumber)? onBookmarkTap;

  /// Called when user wants to add a bookmark at the current position.
  final VoidCallback? onAddBookmark;

  const BookmarkListWidget({super.key, this.onBookmarkTap, this.onAddBookmark});

  @override
  State<BookmarkListWidget> createState() => _BookmarkListWidgetState();
}

class _BookmarkListWidgetState extends State<BookmarkListWidget> {
  late final BookmarksViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = BookmarksViewModel(
      bookmarkRepository: mushafGetIt<BookmarkRepository>(),
    );
    _viewModel.initialize();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  String _formatTimestamp(int timestampMs) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestampMs);
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        if (_viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_viewModel.bookmarks.isEmpty) {
          return _EmptyState(onAddBookmark: widget.onAddBookmark);
        }

        // Group bookmarks by chapter
        final grouped = <int, List<Bookmark>>{};
        for (final bm in _viewModel.bookmarks) {
          grouped.putIfAbsent(bm.chapterNumber, () => []).add(bm);
        }

        // Sort chapters by number
        final sortedChapters = grouped.keys.toList()..sort();

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: sortedChapters.length,
          itemBuilder: (context, index) {
            final chapterNum = sortedChapters[index];
            final bookmarks = grouped[chapterNum]!;
            final chapterData = QuranDataProvider.instance.getChapter(
              chapterNum,
            );

            return _ChapterBookmarkGroup(
              chapterNumber: chapterNum,
              chapterName: chapterData.arabicTitle,
              chapterEnglishName: chapterData.englishTitle,
              bookmarks: bookmarks,
              onBookmarkTap: widget.onBookmarkTap,
              onDelete: (id) => _handleDelete(context, id),
              formatTimestamp: _formatTimestamp,
            );
          },
        );
      },
    );
  }

  void _handleDelete(BuildContext context, String bookmarkId) {
    final bookmark = _viewModel.bookmarks.firstWhere((b) => b.id == bookmarkId);
    _viewModel.deleteBookmark(bookmarkId);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Bookmark ${bookmark.verseReference} deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            _viewModel.addBookmark(
              chapterNumber: bookmark.chapterNumber,
              verseNumber: bookmark.verseNumber,
              pageNumber: bookmark.pageNumber,
              note: bookmark.note,
              tags: bookmark.tags,
            );
          },
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty State
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final VoidCallback? onAddBookmark;

  const _EmptyState({this.onAddBookmark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bookmark_outline_rounded,
              size: 80,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              'No Bookmarks Yet',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap on a verse in the Mushaf reader\nto bookmark it for later.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.7,
                ),
              ),
            ),
            if (onAddBookmark != null) ...[
              const SizedBox(height: 24),
              FilledButton.tonal(
                onPressed: onAddBookmark,
                child: const Text('Open Mushaf'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Chapter Bookmark Group
// ─────────────────────────────────────────────────────────────────────────────

class _ChapterBookmarkGroup extends StatelessWidget {
  final int chapterNumber;
  final String chapterName;
  final String chapterEnglishName;
  final List<Bookmark> bookmarks;
  final void Function(int pageNumber)? onBookmarkTap;
  final void Function(String id) onDelete;
  final String Function(int timestampMs) formatTimestamp;

  const _ChapterBookmarkGroup({
    required this.chapterNumber,
    required this.chapterName,
    required this.chapterEnglishName,
    required this.bookmarks,
    required this.onBookmarkTap,
    required this.onDelete,
    required this.formatTimestamp,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Chapter header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    QuranDataProvider.toArabicNumerals(chapterNumber),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chapterName,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                    Text(
                      chapterEnglishName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${bookmarks.length}',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),

        // Bookmark tiles
        ...bookmarks.map(
          (bm) => Dismissible(
            key: ValueKey(bm.id),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              color: theme.colorScheme.error,
              child: Icon(
                Icons.delete_outline_rounded,
                color: theme.colorScheme.onError,
              ),
            ),
            onDismissed: (_) => onDelete(bm.id),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              leading: Icon(
                Icons.bookmark_rounded,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              title: Text(
                'Verse ${bm.verseReference}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: bm.hasNote
                  ? Text(bm.note, maxLines: 1, overflow: TextOverflow.ellipsis)
                  : Text(
                      'Page ${bm.pageNumber} · ${formatTimestamp(bm.createdAt)}',
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
              onTap: () => onBookmarkTap?.call(bm.pageNumber),
            ),
          ),
        ),

        const Divider(height: 1, indent: 16, endIndent: 16),
      ],
    );
  }
}
