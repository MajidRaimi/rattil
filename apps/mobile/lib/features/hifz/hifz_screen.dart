import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import '../../core/theme/typography_ext.dart';

class HifzScreen extends StatelessWidget {
  const HifzScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final typo = context.typography;
    final colors = context.colors;

    return ColoredBox(
      color: colors.background,
      child: SafeArea(
        child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Title row ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LocaleText(
                        'memorization',
                        style: typo.headlineLarge.copyWith(
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      LocaleText(
                        'hifz',
                        style: typo.arabicDisplay.copyWith(
                          fontSize: 16,
                          color: colors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: colors.gold.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: colors.gold.withValues(alpha: 0.15),
                    ),
                  ),
                  child: LocaleText(
                    'coming_soon',
                    style: typo.bodySmall.copyWith(
                      color: colors.gold,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // ── Hero card ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colors.gold.withValues(alpha: 0.08),
                    colors.surface,
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: colors.gold.withValues(alpha: 0.1),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: colors.gold.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.psychology_rounded,
                      size: 32,
                      color: colors.gold.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 20),
                  LocaleText(
                    'hifz_description',
                    textAlign: TextAlign.center,
                    style: typo.bodyLarge.copyWith(
                      color: colors.textSecondary,
                      height: 1.7,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Feature cards ──
            _FeatureCard(
              icon: Icons.trending_up_rounded,
              titleKey: 'hifz_track_title',
              subtitleKey: 'hifz_track_subtitle',
            ),
            const SizedBox(height: 10),
            _FeatureCard(
              icon: Icons.replay_circle_filled_rounded,
              titleKey: 'hifz_review_title',
              subtitleKey: 'hifz_review_subtitle',
            ),
            const SizedBox(height: 10),
            _FeatureCard(
              icon: Icons.flag_rounded,
              titleKey: 'hifz_goals_title',
              subtitleKey: 'hifz_goals_subtitle',
            ),
          ],
        ),
      ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String titleKey;
  final String subtitleKey;

  const _FeatureCard({
    required this.icon,
    required this.titleKey,
    required this.subtitleKey,
  });

  @override
  Widget build(BuildContext context) {
    final typo = context.typography;
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: colors.gold.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: colors.gold, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LocaleText(
                  titleKey,
                  style: typo.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                LocaleText(
                  subtitleKey,
                  style: typo.bodySmall.copyWith(
                    color: colors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
