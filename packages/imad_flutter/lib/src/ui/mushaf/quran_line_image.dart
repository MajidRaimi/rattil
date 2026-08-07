import 'package:flutter/material.dart';

import '../../data/quran/quran_data_provider.dart';
import '../../data/quran/verse_data_provider.dart';
import 'surah_frame.dart';
import 'verse_fasel.dart';

/// Displays a single Quran line image loaded from assets.
///
/// Images are stored in assets/quran-images/{page}/{line}.png
/// Original dimensions: 1440 x 232 pixels
/// Each page has 15 lines (1-15).
///
/// Supports verse-level highlighting and renders VerseFasel markers
/// at positions where verse separators appear.
class QuranLineImage extends StatelessWidget {
  final int page;
  final int line;
  final List<VerseHighlightData> audioHighlights;

  final Color? audioHighlightsColor;

  final List<VerseHighlightData> selectionHighlights;

  final VoidCallback? onTap;

  /// Optional highlight color — defaults to gold if not provided.
  final Color? highlightColor;

  /// Optional text color — when provided, tints the line image so text
  /// contrasts against dark backgrounds (uses BlendMode.srcIn).
  final Color? textColor;
  final void Function(double tapRatio)? onTapUpExact;

  /// Called on long press with the tap position ratio.
  final void Function(double tapRatio)? onLongPressExact;

  /// Verse markers that end on this line (for rendering VerseFasel).
  final List<PageVerseData> markers;

  final bool isSurahHeader;

  final Color? frameColor;

  static const double aspectRatio = 1440.0 / 232.0;

  const QuranLineImage({
    super.key,
    required this.page,
    required this.line,
    this.audioHighlights = const [],
    this.audioHighlightsColor,
    this.selectionHighlights = const [],
    this.onTap,
    this.onTapUpExact,
    this.onLongPressExact,
    this.markers = const [],
    this.highlightColor,
    this.textColor,
    this.isSurahHeader = false,
    this.frameColor,
  });

  @override
  Widget build(BuildContext context) {
    final assetPath = QuranDataProvider.getLineImagePath(page, line);

    final hasGestures = onTap != null || onTapUpExact != null || onLongPressExact != null;

    Widget content = LayoutBuilder(
        builder: (context, constraints) {
          final lineWidth = constraints.maxWidth;
          final lineHeight = constraints.maxHeight;

          return ClipRect(
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (isSurahHeader)
                  CustomPaint(
                    painter: SurahFramePainter(
                      color: frameColor ?? const Color(0xFFD4A843),
                    ),
                  ),

                // 👆 Selection Highlight background (precise bounding boxes)
                ..._buildSelectionHighlights(lineWidth),

                // 🎧 Audio Highlight background for the ayah being recited
                if (!isSurahHeader) ..._buildAudioHighlights(lineWidth),

                if (isSurahHeader)
                  Transform.scale(
                    scale: 0.8,
                    child: baseImage(assetPath: assetPath),
                  ),

                if (!isSurahHeader) baseImage(assetPath: assetPath),

                // Verse separators (VerseFasel markers)
                if (markers.isNotEmpty) _buildMarkers(lineWidth, lineHeight),
              ],
            ),
          );
        },
      );

    if (!hasGestures) return content;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapUp: onTapUpExact != null
          ? (details) {
              final box = context.findRenderObject() as RenderBox;
              final localPosition = box.globalToLocal(details.globalPosition);
              final tapRatio = localPosition.dx / box.size.width;
              onTapUpExact!(tapRatio);
            }
          : null,
      onTap: onTap,
      onLongPressStart: onLongPressExact != null
          ? (details) {
              final box = context.findRenderObject() as RenderBox;
              final localPosition = box.globalToLocal(details.globalPosition);
              final tapRatio = localPosition.dx / box.size.width;
              onLongPressExact!(tapRatio);
            }
          : null,
      child: content,
    );
  }

  Widget baseImage({
    required final String assetPath,
    final Color? color,
    final BlendMode? colorBlendMode,
  }) => Image.asset(
    assetPath,
    package: 'imad_flutter',
    fit: BoxFit.fitWidth,
    color: color ?? textColor,
    colorBlendMode:
        colorBlendMode ?? (textColor != null ? BlendMode.srcIn : null),
    errorBuilder: (context, error, stackTrace) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '⚠️ Missing quran-images/\n'
            'Download from: github.com/Itqan-community/mushaf-imad-flutter',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 9,
              color: Theme.of(context).colorScheme.error.withValues(alpha: 0.7),
            ),
          ),
        ),
      );
    },
  );

  List<Widget> _buildHighlightBands(
    double lineWidth,
    List<VerseHighlightData> highlights,
    Color color, {
    required double fillAlpha,
    required double borderAlpha,
  }) {
    if (highlights.isEmpty) return const [];

    return highlights.map((h) {
      // `h.left` and `h.right` are physical coordinates (0.0 = left edge, 1.0 = right edge)
      final leftPos = lineWidth * h.left;
      final width = lineWidth * (h.right - h.left);

      return Positioned(
        left: leftPos,
        width: width,
        top: 0,
        bottom: 0,
        child: Container(
          decoration: BoxDecoration(
            color: color.withValues(alpha: fillAlpha),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: color.withValues(alpha: borderAlpha),
              width: 0.5,
            ),
          ),
        ),
      );
    }).toList();
  }

  List<Widget> _buildAudioHighlights(double lineWidth) => _buildHighlightBands(
    lineWidth,
    audioHighlights,
    audioHighlightsColor ?? const Color(0xFFD4A843),
    fillAlpha: 0.20,
    borderAlpha: 0.38,
  );

  List<Widget> _buildSelectionHighlights(double lineWidth) =>
      _buildHighlightBands(
        lineWidth,
        selectionHighlights,
        const Color(0xFFD4A843),
        fillAlpha: 0.12,
        borderAlpha: 0.25,
      );

  /// Build verse separator markers positioned on this line.
  Widget _buildMarkers(double lineWidth, double lineHeight) {
    return Stack(
      children: markers.asMap().entries.map((entry) {
        final verse = entry.value;
        final markerNode = verse.marker1441;

        if (markerNode == null) return const SizedBox.shrink();

        final markerX = lineWidth * (markerNode.centerX);
        final markerY = lineHeight * markerNode.centerY;

        // Size the marker (Android uses 3.5% of total width * 2)
        // 0.035 * 2 = 0.07 of container width. That's approx the right size.
        final markerSize = lineWidth * 0.055;

        // Center the marker at (markerX, markerY)
        final adjustedX = markerX - (markerSize / 2);
        final adjustedY = markerY - (markerSize / 2);

        return Positioned(
          left: adjustedX,
          top: adjustedY,
          child: VerseFasel(number: verse.number, size: markerSize),
        );
      }).toList(),
    );
  }
}
