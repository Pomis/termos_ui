import 'dart:math';

import 'package:flutter/material.dart';

import '../core/dot_grid/selection_point.dart';

/// Paints grid dots that react to the glow position (starfield background).
class ReactiveStarfieldPainter extends CustomPainter {
  ReactiveStarfieldPainter({
    required this.dotSize,
    required this.gridSpacing,
    required this.glowPosition,
    required this.glowColor,
    this.intensity = 1.0,
    this.gridOffset = Offset.zero,
    this.glowRadiusFraction,
    this.seed,
    this.selectionPoints,
    this.selectionBlobRadius,
  });

  final double dotSize;
  final double gridSpacing;
  final double glowPosition;
  final Color glowColor;
  final Offset gridOffset;
  final double intensity;
  final double? glowRadiusFraction;
  final int? seed;
  final List<SelectionPoint>? selectionPoints;
  final double? selectionBlobRadius;

  static const _baseMaxAlpha = 0.30;
  static const _glowRadiusFraction = 0.35;
  static const _alphaThreshold = 0.01;
  static const _baseReactiveFraction = 0.25;
  static const _defaultSeed = 42;

  bool get _useSelectionPoints =>
      selectionPoints != null &&
      selectionPoints!.isNotEmpty &&
      selectionBlobRadius != null &&
      selectionBlobRadius! > 0;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final random = Random(seed ?? _defaultSeed);
    final totalSpacing = dotSize + gridSpacing;
    // Match [DotGridPainter]: include dots whose square overlaps the canvas (partial clip).
    final startCol = ((gridOffset.dx - dotSize) / totalSpacing).ceil();
    final endCol = ((size.width + gridOffset.dx) / totalSpacing).ceil() - 1;
    final startRow = ((gridOffset.dy - dotSize) / totalSpacing).ceil();
    final endRow = ((size.height + gridOffset.dy) / totalSpacing).ceil() - 1;
    final paint = Paint()..strokeCap = StrokeCap.square;
    final reactiveFraction = (_baseReactiveFraction * intensity).clamp(0.0, 1.0);

    for (int row = startRow; row <= endRow; row++) {
      final y = row * totalSpacing + dotSize / 2 - gridOffset.dy;
      for (int col = startCol; col <= endCol; col++) {
        final x = col * totalSpacing + dotSize / 2 - gridOffset.dx;
        final dotPos = Offset(x, y);
        final reactivity =
            random.nextDouble() < reactiveFraction ? random.nextDouble() : 0.0;

        double proximity;
        Color glowColorForDot;
        if (_useSelectionPoints) {
          double maxProximity = 0.0;
          Color? dominantColor;
          for (final sp in selectionPoints!) {
            final effectiveRadius = selectionBlobRadius! * sp.radiusMultiplier;
            final distance = (dotPos - sp.position).distance;
            final normalizedDistance = (distance / effectiveRadius).clamp(0.0, 1.0);
            final p = 1.0 - normalizedDistance;
            final smoothP = p * p * (3.0 - 2.0 * p);
            if (smoothP > maxProximity) {
              maxProximity = smoothP;
              dominantColor = sp.color;
            }
          }
          proximity = maxProximity;
          glowColorForDot = dominantColor ?? glowColor;
        } else {
          final glowX = glowPosition * size.width;
          final radius = size.width * (glowRadiusFraction ?? _glowRadiusFraction);
          final distance = (x - glowX).abs();
          final t = radius > 0
              ? (1.0 - (distance / radius).clamp(0.0, 1.0)).clamp(0.0, 1.0)
              : 0.0;
          proximity = t * t * (3.0 - 2.0 * t);
          glowColorForDot = glowColor;
        }

        final alpha = reactivity * proximity * (_baseMaxAlpha * intensity);
        if (alpha > _alphaThreshold) {
          paint.color = glowColorForDot.withValues(alpha: alpha);
          canvas.drawRect(
            Rect.fromCenter(center: dotPos, width: dotSize, height: dotSize),
            paint,
          );
        }
      }
    }
  }

  bool _selectionPointsEqual(List<SelectionPoint>? a, List<SelectionPoint>? b) {
    if (a == b) return true;
    if (a == null || b == null || a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      final pa = a[i];
      final pb = b[i];
      if ((pa.position - pb.position).distance > 0.5 || pa.color != pb.color) {
        return false;
      }
    }
    return true;
  }

  @override
  bool shouldRepaint(ReactiveStarfieldPainter old) =>
      dotSize != old.dotSize ||
      gridSpacing != old.gridSpacing ||
      glowPosition != old.glowPosition ||
      glowColor != old.glowColor ||
      intensity != old.intensity ||
      gridOffset != old.gridOffset ||
      glowRadiusFraction != old.glowRadiusFraction ||
      seed != old.seed ||
      selectionBlobRadius != old.selectionBlobRadius ||
      !_selectionPointsEqual(selectionPoints, old.selectionPoints);
}
