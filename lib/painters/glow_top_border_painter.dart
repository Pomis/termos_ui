import 'package:flutter/material.dart';

/// Draws the top edge glow with a colour spotlight at [position] (0–1 along the top).
///
/// Spotlight extent is configurable via [glowSpread] / [glowCore] (the visible
/// gradient stroke) and [haloSpread] / [haloCore] (the wider blurred halo
/// underneath). All four are expressed as fractions of width and represent the
/// half-width of the falloff (`spread`) and the half-width of the bright core
/// (`core`).
class GlowTopBorderPainter extends CustomPainter {
  GlowTopBorderPainter({
    required this.position,
    required this.glowColor,
    required this.baseColor,
    required this.strokeWidth,
    required this.radius,
    this.opacity = 1.0,
    this.glowSpread = 0.14,
    this.glowCore = 0.03,
    this.haloSpread = 0.16,
    this.haloCore = 0.04,
    this.haloAlpha = 0.35,
    this.haloStrokeBoost = 10,
    this.haloBlurSigma = 6,
  });

  final double position;
  final Color glowColor;
  final Color baseColor;
  final double strokeWidth;
  final double radius;
  final double opacity;

  /// Outer falloff of the visible gradient stroke (fraction of width).
  final double glowSpread;

  /// Bright-core half-width of the visible gradient stroke (fraction of width).
  final double glowCore;

  /// Outer falloff of the blurred halo pass (fraction of width).
  final double haloSpread;

  /// Bright-core half-width of the blurred halo pass (fraction of width).
  final double haloCore;

  /// Peak alpha of the halo pass.
  final double haloAlpha;

  /// Pixels added to [strokeWidth] when drawing the halo pass.
  final double haloStrokeBoost;

  /// Blur sigma used by the halo pass mask filter.
  final double haloBlurSigma;

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
        (position - glowSpread).clamp(0.0, 1.0),
        (position - glowCore).clamp(0.0, 1.0),
        (position + glowCore).clamp(0.0, 1.0),
        (position + glowSpread).clamp(0.0, 1.0),
      ],
    );

    final shadowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + haloStrokeBoost
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, haloBlurSigma)
      ..shader = LinearGradient(
        colors: [
          glowColor.withValues(alpha: 0),
          glowColor.withValues(alpha: haloAlpha * opacity),
          glowColor.withValues(alpha: haloAlpha * opacity),
          glowColor.withValues(alpha: 0),
        ],
        stops: [
          (position - haloSpread).clamp(0.0, 1.0),
          (position - haloCore).clamp(0.0, 1.0),
          (position + haloCore).clamp(0.0, 1.0),
          (position + haloSpread).clamp(0.0, 1.0),
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
      strokeWidth != old.strokeWidth ||
      radius != old.radius ||
      glowSpread != old.glowSpread ||
      glowCore != old.glowCore ||
      haloSpread != old.haloSpread ||
      haloCore != old.haloCore ||
      haloAlpha != old.haloAlpha ||
      haloStrokeBoost != old.haloStrokeBoost ||
      haloBlurSigma != old.haloBlurSigma;
}
