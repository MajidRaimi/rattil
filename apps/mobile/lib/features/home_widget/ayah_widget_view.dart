import 'package:flutter/material.dart';
import '../../core/theme/app_color_scheme.dart';

enum WidgetSize { small, medium, large }

class AyahWidgetView extends StatelessWidget {
  final String ayahText;
  final String surahName;
  final int ayahNumber;
  final AppColorScheme colors;
  final WidgetSize widgetSize;

  const AyahWidgetView({
    super.key,
    required this.ayahText,
    required this.surahName,
    required this.ayahNumber,
    required this.colors,
    this.widgetSize = WidgetSize.medium,
  });

  Size get _logicalSize => switch (widgetSize) {
        WidgetSize.small => const Size(200, 200),
        WidgetSize.medium => const Size(400, 200),
        WidgetSize.large => const Size(400, 420),
      };

  double get _ayahFontSize => switch (widgetSize) {
        WidgetSize.small => 18,
        WidgetSize.medium => 22,
        WidgetSize.large => 24,
      };

  int get _maxLines => switch (widgetSize) {
        WidgetSize.small => 3,
        WidgetSize.medium => 3,
        WidgetSize.large => 8,
      };

  double get _lineHeight => switch (widgetSize) {
        WidgetSize.small => 1.7,
        WidgetSize.medium => 1.8,
        WidgetSize.large => 1.9,
      };

  double get _hPadding => switch (widgetSize) {
        WidgetSize.small => 16,
        WidgetSize.medium => 24,
        WidgetSize.large => 28,
      };

  double get _vPadding => switch (widgetSize) {
        WidgetSize.small => 12,
        WidgetSize.medium => 14,
        WidgetSize.large => 20,
      };

  double get _borderWidth => switch (widgetSize) {
        WidgetSize.small => 2,
        WidgetSize.medium => 2.5,
        WidgetSize.large => 2.5,
      };

  double get _surahFontSize => switch (widgetSize) {
        WidgetSize.small => 11,
        WidgetSize.medium => 13,
        WidgetSize.large => 14,
      };

  bool get _showOrnaments => widgetSize != WidgetSize.small;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        width: _logicalSize.width,
        height: _logicalSize.height,
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border(
            top: BorderSide(color: colors.gold, width: _borderWidth),
            bottom: BorderSide(color: colors.gold, width: _borderWidth),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: _hPadding, vertical: _vPadding),
          child: Column(
            children: [
              if (_showOrnaments) ...[
                const SizedBox(height: 4),
                _buildOrnament(),
                const SizedBox(height: 12),
              ],
              Expanded(
                child: Center(
                  child: Text(
                    ayahText,
                    textAlign: TextAlign.center,
                    maxLines: _maxLines,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'UthmanicHafs',
                      fontSize: _ayahFontSize,
                      height: _lineHeight,
                      color: colors.textArabic,
                    ),
                  ),
                ),
              ),
              if (_showOrnaments) ...[
                const SizedBox(height: 8),
                _buildOrnament(),
              ],
              const SizedBox(height: 8),
              Text(
                '$surahName · $ayahNumber',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'NeueFrutigerWorld',
                  fontSize: _surahFontSize,
                  fontWeight: FontWeight.w500,
                  color: colors.gold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
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
