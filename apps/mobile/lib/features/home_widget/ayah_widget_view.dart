import 'package:flutter/material.dart';
import '../../core/theme/app_color_scheme.dart';

class AyahWidgetView extends StatelessWidget {
  final String ayahText;
  final String surahName;
  final int ayahNumber;
  final AppColorScheme colors;

  const AyahWidgetView({
    super.key,
    required this.ayahText,
    required this.surahName,
    required this.ayahNumber,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        width: 400,
        height: 200,
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Container(height: 2.5, color: colors.gold),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                child: Column(
                  children: [
                    const SizedBox(height: 4),
                    _buildOrnament(),
                    const SizedBox(height: 12),
                    Expanded(
                      child: Center(
                        child: Text(
                          ayahText,
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'UthmanicHafs',
                            fontSize: 22,
                            height: 1.8,
                            color: colors.textArabic,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildOrnament(),
                    const SizedBox(height: 8),
                    Text(
                      '$surahName · $ayahNumber',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'NeueFrutigerWorld',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: colors.gold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(height: 2.5, color: colors.gold),
          ],
        ),
      ),
    );
  }

  Widget _buildOrnament() {
    return Row(
      children: [
        Expanded(
          child: Container(height: 0.5, color: colors.gold.withValues(alpha: 0.35)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            '◆',
            style: TextStyle(fontSize: 6, color: colors.gold.withValues(alpha: 0.6)),
          ),
        ),
        Expanded(
          child: Container(height: 0.5, color: colors.gold.withValues(alpha: 0.35)),
        ),
      ],
    );
  }
}
