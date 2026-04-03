import 'dart:math';

import 'package:flutter/material.dart';

/// Vertical accent glow on the right edge, with a blurred spotlight at [glowCenterY].
///
/// Used by [TermosTextField] to show a focus-driven glow on the field's right border.
/// Can be applied to any widget via [CustomPaint.foregroundPainter].
class TermosEdgeGlowPainter extends CustomPainter {
  TermosEdgeGlowPainter({
    required this.glowCenterY,
    required this.glowColor,
    required this.baseColor,
    this.strokeWidth = 1.0,
    this.borderRadius = 0,
    this.spotlightIntensity = 1.0,
    this.spotlightSpread = 1.0,
    this.blurSigma = 6,
    this.haloStrokeExtra = 4,
  });

  final double glowCenterY;
  final Color glowColor;
  final Color baseColor;
  final double strokeWidth;

  /// Matches the host [ClipRRect] corners; 0 draws a straight vertical edge.
  final double borderRadius;

  /// Scales spotlight gradient alphas (1 = default).
  final double spotlightIntensity;

  /// Scales vertical gradient span from the hotspot (1 = default ~+-20% of height).
  final double spotlightSpread;

  /// Blur sigma for the soft edge halo.
  final double blurSigma;

  /// Added to [strokeWidth] for the blurred halo stroke.
  final double haloStrokeExtra;

  static Path rightEdgePath(Size size, double borderRadius) {
    final w = size.width;
    final h = size.height;
    if (w <= 0 || h <= 0) return Path();
    final r = min(borderRadius, min(w, h) / 2);
    if (r <= 0) {
      final x = w - 0.5;
      return Path()
        ..moveTo(x, 0)
        ..lineTo(x, h);
    }
    return Path()
      ..moveTo(w - r, 0)
      ..arcToPoint(Offset(w, r), radius: Radius.circular(r))
      ..lineTo(w, h - r)
      ..arcToPoint(Offset(w - r, h), radius: Radius.circular(r));
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final shaderRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final position =
        size.height > 0 ? (glowCenterY / size.height).clamp(0.0, 1.0) : 0.0;
    final path = rightEdgePath(size, borderRadius);
    final r = min(borderRadius, min(size.width, size.height) / 2);
    final roundedCorners = r > 0;

    if (roundedCorners) {
      canvas.saveLayer(shaderRect, Paint());
    }

    final baseLinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = baseColor;
    canvas.drawPath(path, baseLinePaint);

    final s = spotlightIntensity.clamp(0.35, 1.75);
    var aMid = (0.26 * s).clamp(0.0, 1.0);
    var aPeak = (0.88 * s).clamp(0.0, 1.0);

    final spread = spotlightSpread.clamp(0.35, 6.0);
    var outerSpan = 0.20 * spread;
    var innerSpan = 0.10 * spread;

    if (roundedCorners) {
      outerSpan *= 1.12;
      innerSpan *= 1.12;
      aMid *= 0.96;
      aPeak *= 0.96;
    }

    LinearGradient buildSpotlightGradient(
            double midScale, double peakScale) =>
        LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            glowColor.withValues(
                alpha: (aMid * midScale).clamp(0.0, 1.0)),
            glowColor.withValues(
                alpha: (aPeak * peakScale).clamp(0.0, 1.0)),
            glowColor.withValues(
                alpha: (aMid * midScale).clamp(0.0, 1.0)),
            Colors.transparent,
          ],
          stops: [
            (position - outerSpan).clamp(0.0, 1.0),
            (position - innerSpan).clamp(0.0, 1.0),
            position,
            (position + innerSpan).clamp(0.0, 1.0),
            (position + outerSpan).clamp(0.0, 1.0),
          ],
        );

    final blur = blurSigma.clamp(0.0, 48.0);
    final shadowExtra = haloStrokeExtra.clamp(0.0, 80.0);
    final effectiveBlur =
        roundedCorners ? min(blur * 1.1 + 1.0, 48.0) : blur;
    final effectiveShadowExtra =
        roundedCorners ? shadowExtra + 2 : shadowExtra;

    final softGradient = buildSpotlightGradient(1.0, 1.0);
    final shadowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + effectiveShadowExtra
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, effectiveBlur)
      ..shader = softGradient.createShader(shaderRect);
    canvas.drawPath(path, shadowPaint);

    final crispGradient = buildSpotlightGradient(
      roundedCorners ? 0.82 : 1.0,
      roundedCorners ? 0.76 : 1.0,
    );
    final spotlightPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..shader = crispGradient.createShader(shaderRect);
    canvas.drawPath(path, spotlightPaint);

    if (roundedCorners) {
      final cornerNorm = (r / size.height).clamp(0.0, 0.25);
      canvas.drawRect(
        shaderRect,
        Paint()
          ..blendMode = BlendMode.dstIn
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: const [
              Colors.transparent,
              Colors.white,
              Colors.white,
              Colors.transparent,
            ],
            stops: [0.0, cornerNorm, 1.0 - cornerNorm, 1.0],
          ).createShader(shaderRect),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(TermosEdgeGlowPainter oldDelegate) =>
      glowCenterY != oldDelegate.glowCenterY ||
      glowColor != oldDelegate.glowColor ||
      baseColor != oldDelegate.baseColor ||
      strokeWidth != oldDelegate.strokeWidth ||
      borderRadius != oldDelegate.borderRadius ||
      spotlightIntensity != oldDelegate.spotlightIntensity ||
      spotlightSpread != oldDelegate.spotlightSpread ||
      blurSigma != oldDelegate.blurSigma ||
      haloStrokeExtra != oldDelegate.haloStrokeExtra;
}
