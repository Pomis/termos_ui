import 'package:flutter/material.dart';

/// Draws the top edge glow with a colour spotlight at [position] (0–1 along the top).
class GlowTopBorderPainter extends CustomPainter {
  GlowTopBorderPainter({
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
    if (opacity <= 0) return;
    final r = radius;
    final shaderRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final path = Path()
      ..moveTo(0, r)
      ..arcToPoint(Offset(r, 0), radius: Radius.circular(r))
      ..lineTo(size.width - r, 0)
      ..arcToPoint(Offset(size.width, r), radius: Radius.circular(r));

    final effGlow = glowColor.withValues(alpha: glowColor.a * opacity);
    final effBase = baseColor.withValues(alpha: baseColor.a * opacity);
    final gradient = LinearGradient(
      colors: [effBase, effGlow, effGlow, effBase],
      stops: [
        (position - 0.14).clamp(0.0, 1.0),
        (position - 0.03).clamp(0.0, 1.0),
        (position + 0.03).clamp(0.0, 1.0),
        (position + 0.14).clamp(0.0, 1.0),
      ],
    );

    final shadowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 10
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6)
      ..shader = LinearGradient(
        colors: [
          glowColor.withValues(alpha: 0),
          glowColor.withValues(alpha: 0.35 * opacity),
          glowColor.withValues(alpha: 0.35 * opacity),
          glowColor.withValues(alpha: 0),
        ],
        stops: [
          (position - 0.16).clamp(0.0, 1.0),
          (position - 0.04).clamp(0.0, 1.0),
          (position + 0.04).clamp(0.0, 1.0),
          (position + 0.16).clamp(0.0, 1.0),
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
  bool shouldRepaint(GlowTopBorderPainter old) =>
      position != old.position ||
      glowColor != old.glowColor ||
      baseColor != old.baseColor ||
      opacity != old.opacity ||
      strokeWidth != old.strokeWidth;
}
