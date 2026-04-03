import 'dart:math';

import 'package:flutter/material.dart';

/// Dot-grid starfield that brightens toward [glowCenterY] on the right edge.
///
/// Produces a vertical glow band of reactive dots — complementary to
/// [TermosEdgeGlowPainter] which draws the crisp edge line.
class TermosVerticalStarfieldPainter extends CustomPainter {
  TermosVerticalStarfieldPainter({
    required this.dotSize,
    required this.gridSpacing,
    required this.glowCenterY,
    required this.glowColor,
    double? reactiveFraction,
    double? maxAlpha,
    this.highlightRadiusYFactor = 1.0,
    this.highlightRadiusXFactor = 1.0,
  })  : reactiveFraction = reactiveFraction ?? reactiveFractionDefault,
        maxAlpha = maxAlpha ?? maxAlphaDefault;

  final double dotSize;
  final double gridSpacing;
  final double glowCenterY;
  final Color glowColor;
  final double reactiveFraction;
  final double maxAlpha;
  final double highlightRadiusYFactor;
  final double highlightRadiusXFactor;

  static const reactiveFractionDefault = 0.30;
  static const maxAlphaDefault = 0.24;
  static const _alphaThreshold = 0.01;
  static const _seed = 42;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final random = Random(_seed);
    final totalSpacing = dotSize + gridSpacing;
    final columns = (size.width / totalSpacing).floor() + 1;
    final rows = (size.height / totalSpacing).floor() + 1;

    final radiusY = size.height * 0.34 * highlightRadiusYFactor;
    final radiusX = size.width * 0.70 * highlightRadiusXFactor;

    final paint = Paint()..strokeCap = StrokeCap.square;

    for (int row = 0; row < rows; row++) {
      final y = row * totalSpacing + dotSize / 2;
      for (int col = 0; col < columns; col++) {
        final x = col * totalSpacing + dotSize / 2;
        final reactivity = random.nextDouble() < reactiveFraction
            ? random.nextDouble()
            : 0.0;

        final dy = (y - glowCenterY).abs();
        final dx = (size.width - x).abs();

        final ty = radiusY > 0
            ? (1.0 - (dy / radiusY).clamp(0.0, 1.0)).clamp(0.0, 1.0)
            : 0.0;
        final tx = radiusX > 0
            ? (1.0 - (dx / radiusX).clamp(0.0, 1.0)).clamp(0.0, 1.0)
            : 0.0;

        final proximityY = ty * ty * (3.0 - 2.0 * ty);
        final proximityX = tx * tx * (3.0 - 2.0 * tx);
        final alpha = reactivity * proximityY * proximityX * maxAlpha;

        if (alpha > _alphaThreshold) {
          paint.color = glowColor.withValues(alpha: alpha);
          canvas.drawRect(
            Rect.fromCenter(
                center: Offset(x, y), width: dotSize, height: dotSize),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(TermosVerticalStarfieldPainter oldDelegate) =>
      dotSize != oldDelegate.dotSize ||
      gridSpacing != oldDelegate.gridSpacing ||
      glowCenterY != oldDelegate.glowCenterY ||
      glowColor != oldDelegate.glowColor ||
      reactiveFraction != oldDelegate.reactiveFraction ||
      maxAlpha != oldDelegate.maxAlpha ||
      highlightRadiusYFactor != oldDelegate.highlightRadiusYFactor ||
      highlightRadiusXFactor != oldDelegate.highlightRadiusXFactor;
}
