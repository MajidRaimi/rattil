import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/typography_ext.dart';
import '../../data/models/search_result.dart';
import '../../data/models/surah.dart';
import '../../providers/quran_providers.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  String _query = '';
  Timer? _debounce;

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      setState(() => _query = value.trim());
    });
  }

  @override
  Widget build(BuildContext context) {
    final typo = context.typography;
    final colors = context.colors;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: LocaleText('search', style: typo.headlineMedium),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: TextField(
                controller: _controller,
                onChanged: _onChanged,
                style: typo.bodyLarge.copyWith(color: colors.textPrimary),
                decoration: InputDecoration(
                  hintText: Locales.string(context, 'search_quran_hint'),
                  hintStyle: typo.bodyLarge,
                  prefixIcon: Icon(Icons.search, color: colors.textTertiary),
                  suffixIcon: _controller.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: colors.textTertiary, size: 18),
                          onPressed: () {
                            _controller.clear();
                            setState(() => _query = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: colors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
            if (_query.isNotEmpty) _buildModeChip(),
            Expanded(child: _buildResults()),
          ],
        ),
      ),
    );
  }

  Widget _buildModeChip() {
    final colors = context.colors;
    final typo = context.typography;
    final resultsAsync = ref.watch(searchResultsProvider(_query));

    return resultsAsync.when(
      data: (state) {
        final label = state.isArabicMode
            ? Locales.string(context, 'searching_arabic')
            : Locales.string(context, 'searching_translations');
        final icon = state.isArabicMode
            ? Icons.text_fields
            : Icons.translate;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: colors.surfaceVariant,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 14, color: colors.textSecondary),
                const SizedBox(width: 6),
                Text(label, style: typo.bodySmall.copyWith(color: colors.textSecondary)),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildResults() {
    final typo = context.typography;
    final colors = context.colors;
    if (_query.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search, size: 64, color: colors.textTertiary.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            LocaleText(
              'search_the_quran',
              style: typo.bodyLarge.copyWith(color: colors.textTertiary),
            ),
            const SizedBox(height: 4),
            LocaleText('search_hint', style: typo.bodySmall),
          ],
        ),
      );
    }

    final resultsAsync = ref.watch(searchResultsProvider(_query));

    return resultsAsync.when(
      data: (state) {
        if (state.isEmpty) {
          return Center(
            child: Text(
              '${Locales.string(context, 'no_results_for')} "$_query"',
              style: typo.bodyLarge,
            ),
          );
        }
        return CustomScrollView(
          slivers: [
            if (state.surahMatches.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: _SectionHeader(
                  title: Locales.string(context, 'surahs_section'),
                  count: state.surahMatches.length,
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final surah = state.surahMatches[index];
                    return _SurahSearchResultTile(
                      surah: surah,
                      onTap: () => context.push(AppRouter.readerPath(surah.number)),
                    );
                  },
                  childCount: state.surahMatches.length,
                ),
              ),
            ],
            if (state.ayahMatches.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: _SectionHeader(
                  title: Locales.string(context, 'ayahs_section'),
                  count: state.ayahMatches.length,
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final r = state.ayahMatches[index];
                    return _AyahSearchResultTile(
                      result: r,
                      isArabicMode: state.isArabicMode,
                      onTap: () => context.push(
                        AppRouter.readerPath(r.surahNumber, ayah: r.ayahNumber),
                      ),
                    );
                  },
                  childCount: state.ayahMatches.length,
                ),
              ),
            ],
          ],
        );
      },
      loading: () => Center(
        child: CircularProgressIndicator(color: colors.gold),
      ),
      error: (e, _) => Center(
        child: LocaleText('search_error', style: typo.bodyLarge),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;

  const _SectionHeader({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    final typo = context.typography;
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                title.toUpperCase(),
                style: typo.labelMedium.copyWith(color: colors.gold),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: colors.surfaceVariant,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: typo.bodySmall.copyWith(color: colors.textSecondary, fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Divider(height: 1, color: colors.divider),
        ],
      ),
    );
  }
}

class _SurahSearchResultTile extends StatelessWidget {
  final Surah surah;
  final VoidCallback onTap;

  const _SurahSearchResultTile({required this.surah, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final typo = context.typography;
    final colors = context.colors;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Transform.rotate(
                    angle: 0.785398,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        border: Border.all(color: colors.gold, width: 1.5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  Text(
                    '${surah.number}',
                    style: typo.bodySmall.copyWith(
                      color: colors.gold,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(surah.nameEnglish, style: typo.titleMedium),
                  const SizedBox(height: 2),
                  Text(
                    '${surah.revelationType.toUpperCase()} • ${surah.ayahCount} Ayahs',
                    style: typo.bodySmall,
                  ),
                ],
              ),
            ),
            Text(
              surah.nameArabic,
              style: typo.arabicDisplay.copyWith(
                color: colors.textPrimary,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AyahSearchResultTile extends StatelessWidget {
  final SearchResultItem result;
  final bool isArabicMode;
  final VoidCallback onTap;

  const _AyahSearchResultTile({
    required this.result,
    required this.isArabicMode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final typo = context.typography;
    final colors = context.colors;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: colors.surfaceVariant,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${result.surahNumber}:${result.ayahNumber}',
                    style: typo.bodySmall.copyWith(
                      color: colors.gold,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(result.nameEnglish, style: typo.titleMedium.copyWith(fontSize: 14)),
                const Spacer(),
                Text(
                  result.nameArabic,
                  style: typo.arabicDisplayBody.copyWith(fontSize: 14, color: colors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (isArabicMode) ...[
              Text(
                result.textUthmani,
                style: typo.quranArabic.copyWith(fontSize: 20, height: 1.8),
                textDirection: TextDirection.rtl,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (result.translation != null && result.translation!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  result.translation!,
                  style: typo.bodySmall.copyWith(height: 1.4),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ] else ...[
              if (result.translation != null && result.translation!.isNotEmpty)
                Text(
                  result.translation!,
                  style: typo.bodyMedium.copyWith(height: 1.5),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              if (result.textUthmani.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  result.textUthmani,
                  style: typo.quranArabic.copyWith(
                    fontSize: 14,
                    color: colors.textTertiary,
                    height: 1.6,
                  ),
                  textDirection: TextDirection.rtl,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
