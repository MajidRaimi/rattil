import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:imad_flutter/imad_flutter.dart' as imad;
import 'package:shimmer/shimmer.dart';

import '../../../core/theme/app_color_scheme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/typography_ext.dart';
import '../../../data/services/mp3quran_service.dart';

const _kReciterTileHeight = 67.0;
const _kSkeletonRowCount = 4;

class ReciterPickerSheet extends ConsumerStatefulWidget {
  final int currentReciterId;
  final String surahName;
  final ValueChanged<imad.ReciterInfo> onReciterSelected;

  const ReciterPickerSheet({
    super.key,
    required this.currentReciterId,
    required this.surahName,
    required this.onReciterSelected,
  });

  @override
  ConsumerState<ReciterPickerSheet> createState() => _ReciterPickerSheetState();
}

class _ReciterPickerSheetState extends ConsumerState<ReciterPickerSheet> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  String _query = '';
  List<imad.ReciterInfo> _remoteResults = const [];
  Set<int> _timedIds = const {};
  bool _searching = false;

  @override
  void initState() {
    super.initState();
    _loadTimedIds();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTimedIds() async {
    final ids = await Mp3QuranService.instance.timedReadIds();
    if (mounted) setState(() => _timedIds = ids);
  }

  void _onQueryChanged(String value) {
    setState(() => _query = value);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () => _search(value));
  }

  Future<void> _search(String value) async {
    final query = value.trim();
    if (query.isEmpty) {
      if (mounted) {
        setState(() {
          _remoteResults = const [];
          _searching = false;
        });
      }
      return;
    }
    setState(() => _searching = true);
    final language =
        Locales.currentLocale(context)?.languageCode == 'ar' ? 'ar' : 'eng';
    try {
      final results = await Mp3QuranService.instance.searchCatalogue(
        query,
        language: language,
      );
      if (mounted) {
        setState(() {
          _remoteResults = results;
          _searching = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _remoteResults = const [];
          _searching = false;
        });
      }
    }
  }

  bool _hasTiming(imad.ReciterInfo reciter) {
    if (imad.ReciterDataProvider.bundledTimingIds.contains(reciter.id)) {
      return true;
    }
    return _timedIds.isEmpty || _timedIds.contains(reciter.id);
  }

  void _select(imad.ReciterInfo reciter) {
    imad.ReciterDataProvider.registerRemote(reciter);
    widget.onReciterSelected(reciter);
    Navigator.pop(context);
  }

  Widget _buildResults(
    AppColorScheme colors,
    AppTypography typo,
    List<imad.ReciterInfo> bundled,
    bool isArabic,
  ) {
    final hasQuery = _query.trim().isNotEmpty;

    if (hasQuery &&
        bundled.isEmpty &&
        _remoteResults.isEmpty &&
        !_searching) {
      return _EmptyResults(query: _query.trim());
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        for (final reciter in bundled)
          _ReciterTile(
            reciter: reciter,
            isArabic: isArabic,
            isCurrent: reciter.id == widget.currentReciterId,
            hasTiming: _hasTiming(reciter),
            onTap: () => _select(reciter),
          ),
        if (_searching || _remoteResults.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              Locales.string(context, 'more_reciters'),
              style: typo.bodySmall.copyWith(
                color: colors.goldDim,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        if (_searching)
          for (var i = 0; i < _kSkeletonRowCount; i++)
            const _ReciterTileSkeleton()
        else
          for (final reciter in _remoteResults)
            _ReciterTile(
              reciter: reciter,
              isArabic: isArabic,
              isCurrent: reciter.id == widget.currentReciterId,
              hasTiming: _hasTiming(reciter),
              onTap: () => _select(reciter),
            ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typography;
    final isArabic = Locales.currentLocale(context)?.languageCode == 'ar';

    final bundled = imad.ReciterDataProvider.searchReciters(_query);

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
                  Locales.string(context, 'select_reciter'),
                  style: typo.headlineMedium.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${Locales.string(context, 'listen_full_surah')} · ${widget.surahName}',
                  textAlign: TextAlign.center,
                  style: typo.bodySmall.copyWith(color: colors.textSecondary),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _searchController,
                  onChanged: _onQueryChanged,
                  style: typo.bodyMedium.copyWith(color: colors.textPrimary),
                  decoration: InputDecoration(
                    hintText: Locales.string(context, 'search_reciter'),
                    hintStyle: typo.bodyMedium.copyWith(
                      color: colors.textTertiary,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: colors.textTertiary,
                    ),
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
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          Expanded(child: _buildResults(colors, typo, bundled, isArabic)),
        ],
      ),
    );
  }
}

class _ReciterTileSkeleton extends StatelessWidget {
  const _ReciterTileSkeleton();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    Widget bar(double widthFactor, double height) => FractionallySizedBox(
      alignment: AlignmentDirectional.centerStart,
      widthFactor: widthFactor,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: colors.surfaceVariant,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );

    return SizedBox(
      height: _kReciterTileHeight,
      child: Shimmer.fromColors(
        baseColor: colors.surfaceVariant,
        highlightColor: colors.surfaceHigh,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: colors.surfaceVariant,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    bar(0.45, 13),
                    const SizedBox(height: 6),
                    bar(0.66, 11),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyResults extends StatelessWidget {
  final String query;

  const _EmptyResults({required this.query});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typography;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.person_search_rounded,
              size: 56,
              color: colors.textTertiary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              '${Locales.string(context, 'no_results_for')} "$query"',
              textAlign: TextAlign.center,
              style: typo.titleMedium.copyWith(color: colors.textTertiary),
            ),
            const SizedBox(height: 6),
            Text(
              Locales.string(context, 'try_different_search'),
              textAlign: TextAlign.center,
              style: typo.bodySmall.copyWith(
                color: colors.textTertiary.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReciterTile extends StatelessWidget {
  final imad.ReciterInfo reciter;
  final bool isArabic;
  final bool isCurrent;
  final bool hasTiming;
  final VoidCallback onTap;

  const _ReciterTile({
    required this.reciter,
    required this.isArabic,
    required this.isCurrent,
    required this.hasTiming,
    required this.onTap,
  });

  String _rewaya(BuildContext context) {
    final raw = reciter.rewaya;
    if (raw.contains('مجود') || raw.toLowerCase().contains('mujawwad')) {
      return Locales.string(context, 'rewaya_mujawwad');
    }
    if (reciter.isHafs) return Locales.string(context, 'rewaya_hafs');
    return raw;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typo = context.typography;

    return Material(
      color: isCurrent ? colors.gold.withValues(alpha: 0.08) : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              Icon(
                isCurrent ? Icons.graphic_eq_rounded : Icons.person_outline_rounded,
                size: 20,
                color: isCurrent ? colors.gold : colors.textTertiary,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reciter.getDisplayName(
                        languageCode: isArabic ? 'ar' : 'en',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: typo.bodyMedium.copyWith(
                        color: isCurrent ? colors.gold : colors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            _rewaya(context),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: typo.bodySmall.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          hasTiming
                              ? Icons.auto_stories_rounded
                              : Icons.headphones_rounded,
                          size: 12,
                          color: colors.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          Locales.string(
                            context,
                            hasTiming ? 'follows_mushaf' : 'audio_only',
                          ),
                          style: typo.bodySmall.copyWith(
                            color: colors.textTertiary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (isCurrent)
                Icon(Icons.check_circle, size: 20, color: colors.gold),
            ],
          ),
        ),
      ),
    );
  }
}
