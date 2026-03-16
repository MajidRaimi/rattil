import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/typography_ext.dart';
import '../../../core/utils/ordinal_formatter.dart';
import '../../../providers/quran_providers.dart';

class JuzPickerSheet extends ConsumerWidget {
  final int currentJuz;
  final ValueChanged<int> onJuzSelected;

  const JuzPickerSheet({
    super.key,
    required this.currentJuz,
    required this.onJuzSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typo = context.typography;
    final locale = Locales.currentLocale(context)?.languageCode ?? 'en';
    final rangesAsync = ref.watch(juzPageRangesProvider);

    // Auto-scroll to current juz
    const itemHeight = 64.0;
    final initialOffset =
        ((currentJuz - 1) * itemHeight - itemHeight).clamp(0.0, double.infinity);

    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
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
                  Locales.string(context, 'select_juz'),
                  style: typo.headlineMedium
                      .copyWith(color: colors.textPrimary),
                ),
              ],
            ),
          ),
          Expanded(
            child: rangesAsync.when(
              data: (ranges) => ListView.builder(
                controller:
                    ScrollController(initialScrollOffset: initialOffset),
                itemCount: ranges.length,
                itemBuilder: (context, index) {
                  final r = ranges[index];
                  final juz = r['juz']!;
                  final isCurrent = juz == currentJuz;
                  return InkWell(
                    onTap: () {
                      onJuzSelected(r['startPage']!);
                      Navigator.pop(context);
                    },
                    child: Container(
                      color: isCurrent
                          ? colors.gold.withValues(alpha: 0.08)
                          : null,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: colors.gold.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '$juz',
                              style: typo.bodyMedium.copyWith(
                                color: colors.gold,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${Locales.string(context, 'juz_label')} ${ordinal(juz, locale)}',
                                  style: typo.bodyLarge.copyWith(
                                    color: colors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${Locales.string(context, 'pages_range')} ${r['startPage']} - ${r['endPage']}',
                                  style: typo.bodySmall.copyWith(
                                      color: colors.textTertiary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
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
