import 'package:flutter/material.dart';
import '../../data/quran/quran_data_provider.dart';

/// VerseFasel — renders a verse number marker with an elegant gold design.
class VerseFasel extends StatelessWidget {
  final int number;
  final double size;
  final Color? numberColor;

  const VerseFasel({super.key, required this.number, this.size = 28, this.numberColor});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const gold = Color(0xFFD4A843);

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _FaselPainter(gold: gold),
        child: Center(
          child: Padding(
            padding: EdgeInsets.only(top: size * 0.02),
            child: Text(
              QuranDataProvider.toArabicNumerals(number),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: size * 0.38,
                fontWeight: FontWeight.w700,
                color: numberColor ?? (isDark ? Colors.white : const Color(0xFF3A3A3A)),
                fontFamily: 'QuranNumbers',
                height: 1.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FaselPainter extends CustomPainter {
  final Color gold;

  _FaselPainter({required this.gold});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.42;

    // Outer circle
    final outerPaint = Paint()
      ..color = gold.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.06;
    canvas.drawCircle(center, radius, outerPaint);

    // Inner circle
    final innerPaint = Paint()
      ..color = gold.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.03;
    canvas.drawCircle(center, radius * 0.78, innerPaint);

    // Four small dots at cardinal points
    final dotPaint = Paint()
      ..color = gold.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;
    final dotRadius = size.width * 0.04;
    final dotOffset = radius + size.width * 0.03;

    canvas.drawCircle(Offset(center.dx, center.dy - dotOffset), dotRadius, dotPaint);
    canvas.drawCircle(Offset(center.dx, center.dy + dotOffset), dotRadius, dotPaint);
    canvas.drawCircle(Offset(center.dx - dotOffset, center.dy), dotRadius, dotPaint);
    canvas.drawCircle(Offset(center.dx + dotOffset, center.dy), dotRadius, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
