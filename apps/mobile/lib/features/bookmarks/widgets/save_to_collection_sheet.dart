import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/typography_ext.dart';
import '../../../core/utils/collection_icons.dart';
import '../../../providers/quran_providers.dart';
import 'create_collection_sheet.dart';

class SaveToCollectionSheet extends ConsumerStatefulWidget {
  final int surahNumber;
  final int ayahNumber;

  const SaveToCollectionSheet({
    super.key,
    required this.surahNumber,
    required this.ayahNumber,
  });

  @override
  ConsumerState<SaveToCollectionSheet> createState() =>
      _SaveToCollectionSheetState();
}

class _SaveToCollectionSheetState extends ConsumerState<SaveToCollectionSheet> {
  Set<int> _selectedIds = {};
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadSelectedIds();
  }

  Future<void> _loadSelectedIds() async {
    final ids = await ref
        .read(quranRepositoryProvider)
        .getCollectionIdsForBookmark(widget.surahNumber, widget.ayahNumber);
    if (mounted) {
      setState(() {
        _selectedIds = ids;
        _loaded = true;
      });
    }
  }

  Future<void> _toggle(int collectionId) async {
    final repo = ref.read(quranRepositoryProvider);
    final isSelected = _selectedIds.contains(collectionId);

    if (isSelected) {
      await repo.removeBookmarkFromCollection(
          collectionId, widget.surahNumber, widget.ayahNumber);
      setState(() => _selectedIds.remove(collectionId));
    } else {
      // Ensure bookmark exists in the bookmarks table
      await repo.addBookmark(widget.surahNumber, widget.ayahNumber);
      await repo.addBookmarkToCollection(
          collectionId, widget.surahNumber, widget.ayahNumber);
      setState(() => _selectedIds.add(collectionId));
    }
  }

  Future<void> _createNew() async {
    final result = await showModalBottomSheet<(String, String)>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CreateCollectionSheet(),
    );
    if (result == null || !mounted) return;

    final repo = ref.read(quranRepositoryProvider);
    final newId = await repo.createCollection(result.$1, result.$2);
    ref.invalidate(allCollectionsProvider);

    // Auto-add current bookmark to the new collection
    await repo.addBookmark(widget.surahNumber, widget.ayahNumber);
    await repo.addBookmarkToCollection(
        newId, widget.surahNumber, widget.ayahNumber);
    setState(() => _selectedIds.add(newId));
  }

  @override
  Widget build(BuildContext context) {
    final typo = context.typography;
    final colors = context.colors;
    final collectionsAsync = ref.watch(allCollectionsProvider);

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
          20, 12, 20, MediaQuery.of(context).viewInsets.bottom + 20),
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
          Text(
            Locales.string(context, 'save_to_collection'),
            style: typo.headlineMedium.copyWith(
              color: colors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          collectionsAsync.when(
            data: (collections) {
              if (collections.isEmpty && _loaded) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    children: [
                      Icon(Icons.folder_open_rounded,
                          size: 40,
                          color: colors.textTertiary.withValues(alpha: 0.4)),
                      const SizedBox(height: 12),
                      Text(
                        Locales.string(context, 'no_collections_yet'),
                        style: typo.bodyMedium
                            .copyWith(color: colors.textTertiary),
                      ),
                    ],
                  ),
                );
              }

              return ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.4,
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: collections.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 2),
                  itemBuilder: (_, i) {
                    final c = collections[i];
                    final id = c['id'] as int;
                    final title = c['title'] as String;
                    final iconName = c['icon_name'] as String;
                    final isSelected = _selectedIds.contains(id);

                    return InkWell(
                      onTap: () => _toggle(id),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 12),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? colors.gold.withValues(alpha: 0.15)
                                    : colors.background,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                getCollectionIcon(iconName),
                                color: isSelected
                                    ? colors.gold
                                    : colors.textSecondary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                title,
                                style: typo.bodyLarge.copyWith(
                                  color: colors.textPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: Icon(
                                isSelected
                                    ? Icons.check_circle_rounded
                                    : Icons.circle_outlined,
                                key: ValueKey(isSelected),
                                color: isSelected
                                    ? colors.gold
                                    : colors.textTertiary,
                                size: 24,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
            loading: () => Padding(
              padding: const EdgeInsets.all(24),
              child: CircularProgressIndicator(color: colors.gold),
            ),
            error: (_, __) => const SizedBox.shrink(),
          ),

          const SizedBox(height: 12),

          // New Collection + Done row
          Row(
            children: [
              TextButton.icon(
                onPressed: _createNew,
                icon: Icon(Icons.add_rounded, color: colors.gold, size: 20),
                label: Text(
                  Locales.string(context, 'new_collection'),
                  style: typo.bodyMedium.copyWith(
                    color: colors.gold,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              FilledButton(
                onPressed: () {
                  ref.invalidate(allCollectionsProvider);
                  ref.invalidate(bookmarkKeysProvider);
                  ref.invalidate(allBookmarksProvider);
                  ref.invalidate(bookmarkCollectionIconsProvider);
                  Navigator.pop(context);
                },
                style: FilledButton.styleFrom(
                  backgroundColor: colors.gold,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                ),
                child: Text(
                  Locales.string(context, 'done'),
                  style: typo.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
