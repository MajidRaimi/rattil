import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/typography_ext.dart';
import '../../core/utils/quranic_text.dart';
import '../../providers/quran_providers.dart';

class BookmarksScreen extends ConsumerStatefulWidget {
  const BookmarksScreen({super.key});

  @override
  ConsumerState<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends ConsumerState<BookmarksScreen> {
  @override
  Widget build(BuildContext context) {
    final bookmarksAsync = ref.watch(allBookmarksProvider);
    final typo = context.typography;
    final colors = context.colors;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                Locales.string(context, 'bookmarks'),
                style: typo.headlineMedium.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: bookmarksAsync.when(
                data: (bookmarks) {
                  if (bookmarks.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.bookmark_border,
                              size: 56,
                              color: colors.textTertiary
                                  .withValues(alpha: 0.3)),
                          const SizedBox(height: 16),
                          LocaleText(
                            'no_bookmarks_yet',
                            style: typo.titleMedium
                                .copyWith(color: colors.textTertiary),
                          ),
                          const SizedBox(height: 6),
                          LocaleText(
                            'tap_bookmark_hint',
                            style: typo.bodySmall.copyWith(
                              color: colors.textTertiary
                                  .withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 8),
                    children: [
                      _SectionHeader(
                        titleKey: 'bookmarks_section',
                        count: bookmarks.length,
                      ),
                      for (int i = 0; i < bookmarks.length; i++) ...[
                        _BookmarkCard(
                          bookmark: bookmarks[i],
                          onTap: () {
                            ref
                                .read(readerNavigationProvider.notifier)
                                .state = ReaderNavigationRequest(
                              surahNumber:
                                  bookmarks[i]['surah_number'] as int,
                              ayahNumber:
                                  bookmarks[i]['ayah_number'] as int,
                              highlight: true,
                            );
                          },
                          onDismissed: () =>
                              _removeBookmark(bookmarks[i]),
                        ),
                        if (i < bookmarks.length - 1)
                          const SizedBox(height: 10),
                      ],
                      const SizedBox(height: 32),
                    ],
                  );
                },
                loading: () => Center(
                  child: CircularProgressIndicator(color: colors.gold),
                ),
                error: (_, __) => Center(
                  child: LocaleText('error_loading_bookmarks',
                      style: typo.bodyLarge),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _removeBookmark(Map<String, dynamic> bookmark) {
    final surahNumber = bookmark['surah_number'] as int;
    final ayahNumber = bookmark['ayah_number'] as int;

    ref.read(quranRepositoryProvider).removeBookmark(surahNumber, ayahNumber);
    ref.invalidate(allBookmarksProvider);
    ref.invalidate(bookmarkKeysProvider);

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

class _SectionHeader extends StatelessWidget {
  final String titleKey;
  final int count;

  const _SectionHeader({required this.titleKey, required this.count});

  @override
  Widget build(BuildContext context) {
    final typo = context.typography;
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 4, bottom: 8),
      child: Row(
        children: [
          Text(
            Locales.string(context, titleKey).toUpperCase(),
            style: typo.bodySmall.copyWith(
              color: colors.goldDim,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: colors.goldDim.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$count',
              style: typo.bodySmall.copyWith(
                color: colors.goldDim,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BookmarkCard extends StatelessWidget {
  final Map<String, dynamic> bookmark;
  final VoidCallback onTap;
  final VoidCallback onDismissed;

  const _BookmarkCard({
    required this.bookmark,
    required this.onTap,
    required this.onDismissed,
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
                // Header row: badge + surah name + Arabic corner
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
                // Arabic text (stripped of quranic marks)
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
                // Translation preview
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
