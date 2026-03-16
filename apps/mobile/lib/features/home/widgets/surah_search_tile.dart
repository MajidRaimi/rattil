import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import '../../../core/theme/typography_ext.dart';
import '../../../data/models/surah.dart';

class SurahSearchTile extends StatelessWidget {
  final Surah surah;
  final VoidCallback onTap;

  const SurahSearchTile({super.key, required this.surah, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final typo = context.typography;
    final colors = context.colors;
    final isArabic =
        Locales.currentLocale(context)?.languageCode == 'ar';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Number badge
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: colors.gold.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${surah.number}',
                style: typo.bodyMedium.copyWith(
                  color: colors.gold,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Name and meta
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isArabic ? surah.nameArabic : surah.nameEnglish,
                    style: typo.bodyLarge.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${Locales.string(context, surah.revelationType)} \u2022 ${surah.ayahCount} ${Locales.string(context, 'ayahs')}',
                    style: typo.bodySmall.copyWith(color: colors.textTertiary),
                  ),
                ],
              ),
            ),
            // Arabic name (only in non-Arabic locales)
            if (!isArabic)
              Text(
                surah.nameArabic,
                style: typo.arabicDisplayBody.copyWith(
                  fontSize: 14,
                  color: colors.textTertiary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
