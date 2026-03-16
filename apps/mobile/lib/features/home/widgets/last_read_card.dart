import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/typography_ext.dart';
import '../../../providers/quran_providers.dart';

class LastReadCard extends ConsumerWidget {
  const LastReadCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(readingProgressProvider);
    final typo = context.typography;
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.lerp(colors.surface, colors.gold, 0.08)!,
              colors.background,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colors.gold.withValues(alpha: 0.2)),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              final progress = progressAsync.valueOrNull;
              if (progress != null) {
                ref.read(readerNavigationProvider.notifier).state =
                    ReaderNavigationRequest(
                  surahNumber: progress['surah_number']!,
                  ayahNumber: progress['ayah_number']!,
                );
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
                              style: typo.bodySmall.copyWith(
                                color: colors.goldDim,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            surahData.when(
                              data: (surah) => Text(
                                surah?.nameEnglish ?? 'Al-Fatiha',
                                style: typo.headlineMedium,
                              ),
                              loading: () => const SizedBox(height: 28),
                              error: (_, __) => Text('Al-Fatiha', style: typo.headlineMedium),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Ayah ${progress['ayah_number']}',
                              style: typo.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.play_circle_filled,
                        color: colors.gold,
                        size: 48,
                      ),
                    ],
                  );
                },
                loading: () => SizedBox(
                  height: 80,
                  child: Center(child: CircularProgressIndicator(color: colors.gold)),
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
