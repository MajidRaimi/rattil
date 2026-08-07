import 'dart:math' as math;

import 'package:flutter/material.dart';

class SurahFramePainter extends CustomPainter {
  final Color color;

  const SurahFramePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    if (w <= 0 || h <= 0) return;

    final bandH = h * 0.82;
    const horizontalMargin = 12.0;
    final outerStroke = math.max(1.0, h * 0.020);
    final bandW = w - horizontalMargin * 2 - outerStroke;
    final midY = h / 2;
    final outerLeft = (w - bandW) / 2;
    const cornerRadius = Radius.circular(2);

    Path frame(double inset) {
      final l = outerLeft + inset;
      final r = w - l;
      final t = midY - bandH / 2 + inset * 0.62;
      final b = midY + bandH / 2 - inset * 0.62;
      return Path()..addRRect(RRect.fromLTRBR(l, t, r, b, cornerRadius));
    }

    final outer = frame(0);

    canvas.drawPath(
      outer,
      Paint()
        ..color = color.withValues(alpha: 0.05)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      outer,
      Paint()
        ..color = color.withValues(alpha: 0.52)
        ..style = PaintingStyle.stroke
        ..strokeWidth = outerStroke
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      frame(h * 0.085),
      Paint()
        ..color = color.withValues(alpha: 0.30)
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(0.6, h * 0.012)
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      frame(h * 0.145),
      Paint()
        ..color = color.withValues(alpha: 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(0.5, h * 0.008)
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );

    final rulePaint = Paint()
      ..color = color.withValues(alpha: 0.34)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(0.6, h * 0.011)
      ..strokeCap = StrokeCap.round;
    final ringPaint = Paint()
      ..color = color.withValues(alpha: 0.46)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(0.6, h * 0.011);
    final dotPaint = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    final ring = h * 0.062;
    final clearance = w * 0.31;
    final flankStart = outerLeft + h * 0.34;
    final flankEnd = clearance - ring * 2.6;

    if (flankEnd > flankStart) {
      canvas.drawLine(
          Offset(flankStart, midY), Offset(flankEnd, midY), rulePaint);
      _rosette(
          canvas, Offset(flankEnd + ring * 1.4, midY), ring, ringPaint, dotPaint);

      canvas.drawLine(Offset(w - flankEnd, midY), Offset(w - flankStart, midY),
          rulePaint);
      _rosette(canvas, Offset(w - flankEnd - ring * 1.4, midY), ring, ringPaint,
          dotPaint);
    }
  }

  void _rosette(
      Canvas canvas, Offset center, double radius, Paint ring, Paint dot) {
    canvas.drawCircle(center, radius, ring);
    canvas.drawCircle(center, radius * 0.40, dot);
  }

  @override
  bool shouldRepaint(SurahFramePainter oldDelegate) =>
      oldDelegate.color != color;
}
