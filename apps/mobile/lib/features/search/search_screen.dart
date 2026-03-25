import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/services/analytics_service.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/typography_ext.dart';
import '../../core/utils/quranic_text.dart';
import '../../data/models/search_result.dart';
import '../../providers/quran_providers.dart';
import '../home/widgets/surah_search_tile.dart';

// Characters to strip for matching: diacritics + tatweel.
final _matchStrip = RegExp(r'[\u064B-\u065F\u0610-\u061A\u0640\u0670]');

/// Normalize Uthmanic-specific base characters for matching.
/// Alef wasla (ٱ U+0671) → regular alef (ا U+0627).
String _normalizeForMatch(String s) {
  return s.replaceAll(_matchStrip, '').replaceAll('\u0671', '\u0627');
}

/// Builds highlighted [TextSpan]s for [text] where [query] matches,
/// accounting for Arabic diacritics and Uthmanic characters.
List<TextSpan> _highlightMatches(
  String text,
  String query,
  TextStyle baseStyle,
  Color highlightBg,
) {
  if (query.isEmpty) return [TextSpan(text: text, style: baseStyle)];

  final strippedText = _normalizeForMatch(text);
  final strippedQuery = _normalizeForMatch(
    query.replaceAll(quranicMarks, ''),
  );

  if (strippedQuery.isEmpty) return [TextSpan(text: text, style: baseStyle)];

  // Map each stripped-text index to its position in the original text.
  final posMap = <int>[];
  for (int i = 0; i < text.length; i++) {
    if (!_matchStrip.hasMatch(text[i])) {
      posMap.add(i);
    }
  }

  // Find all non-overlapping matches in stripped text.
  final highlightStyle = baseStyle.copyWith(backgroundColor: highlightBg);
  final spans = <TextSpan>[];
  int lastOrigEnd = 0;
  int searchFrom = 0;

  while (searchFrom <= strippedText.length - strippedQuery.length) {
    final idx = strippedText.indexOf(strippedQuery, searchFrom);
    if (idx == -1) break;

    final origStart = posMap[idx];
    final matchEnd = idx + strippedQuery.length;
    final origEnd = matchEnd < posMap.length ? posMap[matchEnd] : text.length;

    if (origStart > lastOrigEnd) {
      spans.add(TextSpan(text: text.substring(lastOrigEnd, origStart), style: baseStyle));
    }
    spans.add(TextSpan(text: text.substring(origStart, origEnd), style: highlightStyle));

    lastOrigEnd = origEnd;
    searchFrom = matchEnd;
  }

  if (lastOrigEnd < text.length) {
    spans.add(TextSpan(text: text.substring(lastOrigEnd), style: baseStyle));
  }

  return spans.isEmpty ? [TextSpan(text: text, style: baseStyle)] : spans;
}

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
      if (value.trim().isNotEmpty) {
        AnalyticsService.event('Search', props: {'query_length': '${value.trim().length}'});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
                Locales.string(context, 'search'),
                style: typo.headlineMedium.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _controller,
                onChanged: _onChanged,
                style: typo.bodyLarge.copyWith(color: colors.textPrimary),
                decoration: InputDecoration(
                  hintText: Locales.string(context, 'search_quran_hint'),
                  hintStyle: typo.bodyLarge.copyWith(color: colors.textTertiary),
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
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(child: _buildResults()),
          ],
        ),
      ),
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
            Icon(Icons.search, size: 56, color: colors.textTertiary.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            LocaleText(
              'search_the_quran',
              style: typo.titleMedium.copyWith(color: colors.textTertiary),
            ),
            const SizedBox(height: 6),
            LocaleText(
              'search_hint',
              style: typo.bodySmall.copyWith(color: colors.textTertiary.withValues(alpha: 0.6)),
            ),
          ],
        ),
      );
    }

    final resultsAsync = ref.watch(searchResultsProvider(_query));

    return resultsAsync.when(
      data: (state) {
        if (state.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.search_off, size: 56, color: colors.textTertiary.withValues(alpha: 0.3)),
                const SizedBox(height: 16),
                Text(
                  '${Locales.string(context, 'no_results_for')} "$_query"',
                  style: typo.titleMedium.copyWith(color: colors.textTertiary),
                ),
                const SizedBox(height: 6),
                LocaleText(
                  'try_different_search',
                  style: typo.bodySmall.copyWith(color: colors.textTertiary.withValues(alpha: 0.6)),
                ),
              ],
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          children: [
            // Surah matches section
            if (state.surahMatches.isNotEmpty) ...[
              _SectionHeader(
                titleKey: 'surahs_section',
                count: state.surahMatches.length,
              ),
              Container(
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    for (int i = 0; i < state.surahMatches.length; i++) ...[
                      SurahSearchTile(
                        surah: state.surahMatches[i],
                        onTap: () {
                          ref.read(readerNavigationProvider.notifier).state =
                              ReaderNavigationRequest(
                            surahNumber: state.surahMatches[i].number,
                            ayahNumber: 1,
                          );
                        },
                      ),
                      if (i < state.surahMatches.length - 1)
                        Divider(
                          height: 1,
                          indent: 56,
                          endIndent: 16,
                          color: colors.divider,
                        ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Ayah matches section
            if (state.ayahMatches.isNotEmpty) ...[
              _SectionHeader(
                titleKey: 'ayahs_section',
                count: state.ayahMatches.length,
              ),
              for (int i = 0; i < state.ayahMatches.length; i++) ...[
                Container(
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: _AyahSearchResultTile(
                    result: state.ayahMatches[i],
                    query: _query,
                    onTap: () {
                      ref.read(readerNavigationProvider.notifier).state =
                          ReaderNavigationRequest(
                        surahNumber: state.ayahMatches[i].surahNumber,
                        ayahNumber: state.ayahMatches[i].ayahNumber,
                        highlight: true,
                      );
                    },
                  ),
                ),
                if (i < state.ayahMatches.length - 1)
                  const SizedBox(height: 10),
              ],
            ],
            const SizedBox(height: 32),
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
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
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


class _AyahSearchResultTile extends StatelessWidget {
  final SearchResultItem result;
  final String query;
  final VoidCallback onTap;

  const _AyahSearchResultTile({
    required this.result,
    required this.query,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final typo = context.typography;
    final colors = context.colors;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Builder(builder: (context) {
              final isArabic =
                  Locales.currentLocale(context)?.languageCode == 'ar';
              return Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: colors.gold.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${result.surahNumber}:${result.ayahNumber}',
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
                      isArabic ? result.nameArabic : result.nameEnglish,
                      style: typo.bodyMedium.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (!isArabic)
                    Text(
                      result.nameArabic,
                      style: typo.arabicDisplayBody.copyWith(
                        fontSize: 14,
                        color: colors.textTertiary,
                      ),
                    ),
                ],
              );
            }),
            const SizedBox(height: 10),
            // Arabic text with query highlighting
            SizedBox(
              width: double.infinity,
              child: RichText(
                text: TextSpan(
                  children: _highlightMatches(
                    result.textUthmani.replaceAll(quranicMarks, ''),
                    query,
                    typo.quranArabic.copyWith(fontSize: 20, height: 1.8),
                    colors.gold.withValues(alpha: 0.15),
                  ),
                ),
                textDirection: TextDirection.rtl,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Translation
            if (result.translation != null && result.translation!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                result.translation!,
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
    );
  }
}
