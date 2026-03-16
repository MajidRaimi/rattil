import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/typography_ext.dart';
import '../../../data/models/surah.dart';
import '../../../providers/quran_providers.dart';

class SurahListTile extends ConsumerWidget {
  final Surah surah;

  const SurahListTile({super.key, required this.surah});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typo = context.typography;
    final colors = context.colors;
    return InkWell(
      onTap: () {
        ref.read(readerNavigationProvider.notifier).state =
            ReaderNavigationRequest(
          surahNumber: surah.number,
          ayahNumber: 1,
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            // Surah number ornament
            SizedBox(
              width: 40,
              height: 40,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Transform.rotate(
                    angle: 0.785398, // 45 degrees
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
            // English name and info
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
            // Arabic name
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
