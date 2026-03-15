import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/surah.dart';

class SurahListTile extends StatelessWidget {
  final Surah surah;

  const SurahListTile({super.key, required this.surah});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push(AppRouter.readerPath(surah.number)),
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
                        border: Border.all(color: AppColors.gold, width: 1.5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  Text(
                    '${surah.number}',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.gold,
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
                  Text(surah.nameEnglish, style: AppTypography.titleMedium),
                  const SizedBox(height: 2),
                  Text(
                    '${surah.revelationType.toUpperCase()} • ${surah.ayahCount} Ayahs',
                    style: AppTypography.bodySmall,
                  ),
                ],
              ),
            ),
            // Arabic name
            Text(
              surah.nameArabic,
              style: AppTypography.surahNameArabic.copyWith(
                color: AppColors.textPrimary,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
