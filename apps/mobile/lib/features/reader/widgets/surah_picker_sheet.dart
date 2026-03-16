import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/typography_ext.dart';
import '../../../providers/quran_providers.dart';
import '../../home/widgets/surah_search_tile.dart';

class SurahPickerSheet extends ConsumerStatefulWidget {
  final int currentSurahNumber;
  final ValueChanged<int> onSurahSelected;

  const SurahPickerSheet({
    super.key,
    required this.currentSurahNumber,
    required this.onSurahSelected,
  });

  @override
  ConsumerState<SurahPickerSheet> createState() => _SurahPickerSheetState();
}

class _SurahPickerSheetState extends ConsumerState<SurahPickerSheet> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typography;
    final surahsAsync = ref.watch(allSurahsProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Column(
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
                  Locales.string(context, 'select_surah'),
                  style: typo.headlineMedium
                      .copyWith(color: colors.textPrimary),
                ),
                const SizedBox(height: 16),
                TextField(
                  onChanged: (v) => setState(() => _searchQuery = v),
                  style: typo.bodyMedium.copyWith(color: colors.textPrimary),
                  decoration: InputDecoration(
                    hintText: Locales.string(context, 'tikrar_search_surah'),
                    hintStyle:
                        typo.bodyMedium.copyWith(color: colors.textTertiary),
                    prefixIcon: Icon(Icons.search_rounded,
                        color: colors.textTertiary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colors.divider),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colors.divider),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colors.gold),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          Expanded(
            child: surahsAsync.when(
              data: (surahs) {
                final filtered = _searchQuery.isEmpty
                    ? surahs
                    : surahs.where((s) {
                        final q = _searchQuery.toLowerCase();
                        return s.nameEnglish.toLowerCase().contains(q) ||
                            s.nameArabic.contains(_searchQuery) ||
                            s.nameTranslation.toLowerCase().contains(q);
                      }).toList();

                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final surah = filtered[index];
                    final isCurrent =
                        surah.number == widget.currentSurahNumber;
                    return Container(
                      color: isCurrent
                          ? colors.gold.withValues(alpha: 0.08)
                          : null,
                      child: SurahSearchTile(
                        surah: surah,
                        onTap: () {
                          widget.onSurahSelected(surah.number);
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                );
              },
              loading: () => Center(
                child: CircularProgressIndicator(color: colors.gold),
              ),
              error: (_, _) => const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}
