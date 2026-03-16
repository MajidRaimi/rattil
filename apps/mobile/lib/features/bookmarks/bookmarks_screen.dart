import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/typography_ext.dart';
import '../../providers/quran_providers.dart';

class BookmarksScreen extends ConsumerWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarksAsync = ref.watch(allBookmarksProvider);
    final typo = context.typography;
    final colors = context.colors;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: LocaleText('bookmarks', style: typo.headlineMedium),
            ),
            Expanded(
              child: bookmarksAsync.when(
                data: (bookmarks) {
                  if (bookmarks.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.bookmark_border,
                              size: 64,
                              color: colors.textTertiary.withValues(alpha: 0.3)),
                          const SizedBox(height: 16),
                          LocaleText(
                            'no_bookmarks_yet',
                            style: typo.bodyLarge
                                .copyWith(color: colors.textTertiary),
                          ),
                          const SizedBox(height: 4),
                          LocaleText('tap_bookmark_hint', style: typo.bodySmall),
                        ],
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: bookmarks.length,
                    separatorBuilder: (_, __) =>
                        Divider(height: 1, indent: 20, endIndent: 20, color: colors.divider),
                    itemBuilder: (context, index) {
                      final b = bookmarks[index];
                      return _BookmarkTile(
                        surahNumber: b['surah_number'] as int,
                        ayahNumber: b['ayah_number'] as int,
                        nameEnglish: b['name_english'] as String,
                        nameArabic: b['name_arabic'] as String,
                        textUthmani: b['text_uthmani'] as String,
                        onTap: () => context.push(
                          AppRouter.readerPath(
                            b['surah_number'] as int,
                            ayah: b['ayah_number'] as int,
                          ),
                        ),
                        onDismissed: () async {
                          await ref
                              .read(quranRepositoryProvider)
                              .removeBookmark(
                                b['surah_number'] as int,
                                b['ayah_number'] as int,
                              );
                          ref.invalidate(allBookmarksProvider);
                          ref.invalidate(bookmarkKeysProvider);
                        },
                      );
                    },
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
}

class _BookmarkTile extends StatelessWidget {
  final int surahNumber;
  final int ayahNumber;
  final String nameEnglish;
  final String nameArabic;
  final String textUthmani;
  final VoidCallback onTap;
  final VoidCallback onDismissed;

  const _BookmarkTile({
    required this.surahNumber,
    required this.ayahNumber,
    required this.nameEnglish,
    required this.nameArabic,
    required this.textUthmani,
    required this.onTap,
    required this.onDismissed,
  });

  @override
  Widget build(BuildContext context) {
    final typo = context.typography;
    final colors = context.colors;
    return Dismissible(
      key: ValueKey('$surahNumber:$ayahNumber'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismissed(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: colors.error.withValues(alpha: 0.2),
        child: Icon(Icons.delete_outline, color: colors.error),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.bookmark, color: colors.gold, size: 18),
                  const SizedBox(width: 8),
                  Text(nameEnglish, style: typo.titleMedium.copyWith(fontSize: 14)),
                  const SizedBox(width: 6),
                  Text(
                    '${Locales.string(context, 'ayah')} $ayahNumber',
                    style: typo.bodySmall.copyWith(color: colors.goldDim),
                  ),
                  const Spacer(),
                  Text(
                    nameArabic,
                    style: typo.arabicDisplayBody.copyWith(fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                textUthmani,
                style: typo.quranArabic.copyWith(fontSize: 18, height: 1.6),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textDirection: TextDirection.rtl,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
