import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../providers/quran_providers.dart';

class LastReadCard extends ConsumerWidget {
  const LastReadCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(readingProgressProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1F1A0E), Color(0xFF0D0D0D)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.2)),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              final progress = progressAsync.valueOrNull;
              if (progress != null) {
                context.push(AppRouter.readerPath(progress['surah_number']!));
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: progressAsync.when(
                data: (progress) {
                  final surahData = ref.watch(surahProvider(progress['surah_number']!));
                  return Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Last Read',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.goldDim,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            surahData.when(
                              data: (surah) => Text(
                                surah?.nameEnglish ?? 'Al-Fatiha',
                                style: AppTypography.headlineMedium,
                              ),
                              loading: () => const SizedBox(height: 28),
                              error: (_, __) => Text('Al-Fatiha', style: AppTypography.headlineMedium),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Ayah ${progress['ayah_number']}',
                              style: AppTypography.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.play_circle_filled,
                        color: AppColors.gold,
                        size: 48,
                      ),
                    ],
                  );
                },
                loading: () => const SizedBox(
                  height: 80,
                  child: Center(child: CircularProgressIndicator(color: AppColors.gold)),
                ),
                error: (_, __) => const SizedBox(height: 80),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
