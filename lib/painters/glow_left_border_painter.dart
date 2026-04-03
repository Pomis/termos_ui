import 'package:flutter/material.dart';

/// Draws the left edge glow with a colour spotlight at [position] (0–1 along the edge).
class GlowLeftBorderPainter extends CustomPainter {
  GlowLeftBorderPainter({
    required this.position,
    required this.glowColor,
    required this.baseColor,
    required this.strokeWidth,
    required this.radius,
    this.opacity = 1.0,
  });

  final double position;
  final Color glowColor;
  final Color baseColor;
  final double strokeWidth;
  final double radius;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0 || size.isEmpty) return;

    final r = radius.clamp(0.0, size.height / 2);
    final shaderRect = Rect.fromLTWH(0, 0, size.width, size.height);

    final path = Path()
      ..moveTo(r, 0)
      ..arcToPoint(Offset(0, r), radius: Radius.circular(r), clockwise: false)
      ..lineTo(0, size.height - r)
      ..arcToPoint(Offset(r, size.height),
          radius: Radius.circular(r), clockwise: false);

    final effGlow = glowColor.withValues(alpha: glowColor.a * opacity);
    final effBase = baseColor.withValues(alpha: baseColor.a * opacity);

    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [effBase, effGlow, effGlow, effBase],
      stops: [
        (position - 0.35).clamp(0.0, 1.0),
        (position - 0.08).clamp(0.0, 1.0),
        (position + 0.08).clamp(0.0, 1.0),
        (position + 0.35).clamp(0.0, 1.0),
      ],
    );

    final shadowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 10
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6)
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          glowColor.withValues(alpha: 0),
          glowColor.withValues(alpha: 0.35 * opacity),
          glowColor.withValues(alpha: 0.35 * opacity),
          glowColor.withValues(alpha: 0),
        ],
        stops: [
          (position - 0.38).clamp(0.0, 1.0),
          (position - 0.10).clamp(0.0, 1.0),
          (position + 0.10).clamp(0.0, 1.0),
          (position + 0.38).clamp(0.0, 1.0),
        ],
      ).createShader(shaderRect);
    canvas.drawPath(path, shadowPaint);

    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..shader = gradient.createShader(shaderRect);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(GlowLeftBorderPainter old) =>
      position != old.position ||
      glowColor != old.glowColor ||
      baseColor != old.baseColor ||
      opacity != old.opacity ||
      strokeWidth != old.strokeWidth ||
      radius != old.radius;
}
