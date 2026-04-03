import 'dart:typed_data';
import 'dart:ui' show PointMode;

import 'package:flutter/material.dart';

import 'selection_point.dart';

/// A custom painter that renders a grid of dots with mesh gradient effects.
class DotGridPainter extends CustomPainter {
  /// Size of each dot in pixels
  final double dotSize;

  /// Spacing between dots in pixels
  final double gridSpacing;

  /// Primary color for active dots (colored dots)
  final Color primaryColor;

  /// Background color for inactive dots
  final Color backgroundColor;

  /// List of colors for mesh gradient (interpolated based on distance)
  final List<Color> gradientColors;

  /// Opacity multiplier for hover effects (0.0 to 1.0)
  final double hoverOpacity;

  /// Pattern: number of colored dots, then number of background dots
  /// For example: [1, 5] means 1 colored dot, 5 background dots, repeat
  final List<int> dotPattern;

  /// List of active touch points with their current animation values
  final List<TouchPoint> touchPoints;

  /// Static selection points (e.g. selected tab) - drawn as filled mesh gradient
  final List<SelectionPoint> selectionPoints;

  /// Maximum radius of the blob effect
  final double blobRadius;

  /// Map of pointer IDs to whether they are hover events
  final Map<int, bool> hoverStates;

  /// Pre-allocated buffer for dot coordinates (x, y pairs).
  /// Created once in the widget state, reused across paints.
  final Float32List pointsBuffer;

  /// Offset of this widget relative to its [DotGridGroup] origin.
  /// Dots are shifted so the grid aligns across the group. Touch/selection
  /// are in canvas (same as dot positions).
  final Offset gridOffset;

  DotGridPainter({
    required this.dotSize,
    required this.gridSpacing,
    required this.primaryColor,
    required this.backgroundColor,
    required this.pointsBuffer,
    this.dotPattern = const [1, 5],
    this.touchPoints = const [],
    this.selectionPoints = const [],
    this.blobRadius = 100.0,
    this.gradientColors = const [],
    this.hoverOpacity = 1.0,
    this.hoverStates = const {},
    this.gridOffset = Offset.zero,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Guard against invalid size
    if (!size.width.isFinite ||
        !size.height.isFinite ||
        size.width <= 0 ||
        size.height <= 0 ||
        size.width.isNaN ||
        size.height.isNaN) {
      return;
    }

    // Guard against invalid spacing
    if (!dotSize.isFinite ||
        !gridSpacing.isFinite ||
        dotSize <= 0 ||
        gridSpacing < 0 ||
        dotSize.isNaN ||
        gridSpacing.isNaN) {
      return;
    }

    // Calculate grid dimensions
    final double totalSpacing = dotSize + gridSpacing;
    if (!totalSpacing.isFinite || totalSpacing <= 0) {
      return;
    }

    // Dot positions align to group origin: x = col * totalSpacing + dotSize/2 - gridOffset.dx
    // Include dots whose square overlaps the canvas (partially clipped), not only dots whose
    // center lies inside — otherwise top/left edge dots disappear when gridOffset shifts the grid.
    final int startCol = ((gridOffset.dx - dotSize) / totalSpacing).ceil();
    final int endCol = ((size.width + gridOffset.dx) / totalSpacing).ceil() - 1;
    final int startRow = ((gridOffset.dy - dotSize) / totalSpacing).ceil();
    final int endRow = ((size.height + gridOffset.dy) / totalSpacing).ceil() - 1;

    if (startCol > endCol || startRow > endRow) return;

    final int columns = (endCol - startCol + 1).clamp(0, 999999);
    final int rows = (endRow - startRow + 1).clamp(0, 999999);
    final int requiredFloats = rows * columns * 2;

    // Skip if pre-allocated buffer is too small
    if (requiredFloats > pointsBuffer.length || requiredFloats <= 0) return;

    // Fill all dot coordinates into the pre-allocated buffer
    int offset = 0;
    for (int row = startRow; row <= endRow; row++) {
      final double y = row * totalSpacing + dotSize / 2 - gridOffset.dy;
      for (int col = startCol; col <= endCol; col++) {
        pointsBuffer[offset] = col * totalSpacing + dotSize / 2 - gridOffset.dx;
        pointsBuffer[offset + 1] = y;
        offset += 2;
      }
    }

    // Draw all background dots in a single call
    final bgPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = dotSize
      ..strokeCap = StrokeCap.square;

    canvas.drawRawPoints(
      PointMode.points,
      Float32List.sublistView(pointsBuffer, 0, offset),
      bgPaint,
    );

    // Overdraw only the dots influenced by touch points and selection points
    if (touchPoints.isNotEmpty || selectionPoints.isNotEmpty) {
      _drawTouchInfluencedDots(
        canvas,
        startCol,
        endCol,
        startRow,
        endRow,
        totalSpacing,
        size,
      );
    }
  }

  /// Draws only the dots affected by touch points with their computed
  /// gradient colors on top of the already-drawn background grid.
  /// Limits iteration to the bounding box of touch influences.
  void _drawTouchInfluencedDots(
    Canvas canvas,
    int gridStartCol,
    int gridEndCol,
    int gridStartRow,
    int gridEndRow,
    double totalSpacing,
    Size size,
  ) {
    final dotPaint = Paint()
      ..strokeWidth = dotSize
      ..strokeCap = StrokeCap.square;

    // Compute bounding box of all touch and selection influences to limit iteration
    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = double.negativeInfinity;
    double maxY = double.negativeInfinity;

    for (final tp in touchPoints) {
      final double r = blobRadius * tp.animationValue;
      if (r <= 0 || !r.isFinite) continue;
      final double px = tp.position.dx;
      final double py = tp.position.dy;
      if (px - r < minX) minX = px - r;
      if (py - r < minY) minY = py - r;
      if (px + r > maxX) maxX = px + r;
      if (py + r > maxY) maxY = py + r;
    }

    for (final sp in selectionPoints) {
      final double r = blobRadius * sp.radiusMultiplier;
      if (r <= 0 || !r.isFinite) continue;
      final double px = sp.position.dx;
      final double py = sp.position.dy;
      if (px - r < minX) minX = px - r;
      if (py - r < minY) minY = py - r;
      if (px + r > maxX) maxX = px + r;
      if (py + r > maxY) maxY = py + r;
    }

    if (minX == double.infinity) return;

    // Bounding box is in canvas. Grid col from canvas x: col = (canvasX + gridOffset.dx - dotSize/2) / totalSpacing
    final int influenceStartCol =
        ((minX + gridOffset.dx - dotSize / 2) / totalSpacing).floor().clamp(gridStartCol, gridEndCol);
    final int influenceEndCol =
        ((maxX + gridOffset.dx - dotSize / 2) / totalSpacing).ceil().clamp(gridStartCol, gridEndCol);
    final int influenceStartRow =
        ((minY + gridOffset.dy - dotSize / 2) / totalSpacing).floor().clamp(gridStartRow, gridEndRow);
    final int influenceEndRow =
        ((maxY + gridOffset.dy - dotSize / 2) / totalSpacing).ceil().clamp(gridStartRow, gridEndRow);

    for (int row = influenceStartRow; row <= influenceEndRow; row++) {
      final double y = row * totalSpacing + dotSize / 2 - gridOffset.dy;
      for (int col = influenceStartCol; col <= influenceEndCol; col++) {
        final double x = col * totalSpacing + dotSize / 2 - gridOffset.dx;
        final Offset dotPos = Offset(x, y);
        final Color dotColor = _calculateMeshGradientColor(dotPos, backgroundColor);

        if (dotColor != backgroundColor) {
          dotPaint.color = dotColor;
          canvas.drawRect(
            Rect.fromCenter(center: dotPos, width: dotSize, height: dotSize),
            dotPaint,
          );
        }
      }
    }
  }

  /// Calculates the color of a dot based on its distance from touch points
  /// Improved mesh gradient with smooth blending and multiple color support
  Color _calculateMeshGradientColor(
    Offset dotPosition,
    Color baseColor,
  ) {
    if (touchPoints.isEmpty && selectionPoints.isEmpty) {
      return baseColor;
    }

    // Touch/selection and dotPosition are all in canvas. Single coordinate system.
    final List<({double influence, Color color, bool isHover})> influences = [];

    // Selection points: filled, smooth falloff (like animationValue 0.3)
    for (final sp in selectionPoints) {
      final double effectiveRadius = blobRadius * sp.radiusMultiplier;
      if (effectiveRadius <= 0 || !effectiveRadius.isFinite) continue;
      final double distance = (dotPosition - sp.position).distance;
      final double normalizedDistance = (distance / effectiveRadius).clamp(0.0, 1.0);
      double influence = 1.0 - normalizedDistance;
      influence = influence * influence * (3.0 - 2.0 * influence); // Smoothstep
      if (influence > 0) {
        influences.add((influence: influence.clamp(0.0, 1.0), color: sp.color, isHover: false));
      }
    }

    for (final touchPoint in touchPoints) {
      final double distance = (dotPosition - touchPoint.position).distance;
      final double effectiveRadius = blobRadius * touchPoint.animationValue;

      // Guard against invalid radius
      if (effectiveRadius <= 0 || !effectiveRadius.isFinite || effectiveRadius.isNaN) {
        continue;
      }

      // Guard against invalid animation value
      if (!touchPoint.animationValue.isFinite || touchPoint.animationValue.isNaN) {
        continue;
      }

      // Initial state: filled circle when pressed (animationValue ~0.3)
      // Transition to ring when expanding (animationValue > 0.3)
      // Animation value can go up to 1.5 for continuous expansion

      double influence = 0.0;

      if (touchPoint.animationValue <= 0.35) {
        // Initial state: filled circle (animationValue ~0.3)
        // Show a filled circle with smooth falloff
        if (effectiveRadius > 0 && effectiveRadius.isFinite && !effectiveRadius.isNaN) {
          final double normalizedDistance = (distance / effectiveRadius).clamp(0.0, 1.0);
          if (normalizedDistance.isFinite && !normalizedDistance.isNaN) {
            influence = 1.0 - normalizedDistance;
            // Apply smooth falloff curve
            influence = influence * influence * (3.0 - 2.0 * influence); // Smoothstep
            // Guard against invalid result
            if (!influence.isFinite || influence.isNaN) {
              influence = 0.0;
            }
          }
        }
      } else {
        // Ring state: expanding ring with decreasing stroke width
        // Calculate normalized progress: 0.35 -> 0.0, 1.5 -> 1.0
        final double normalizedAnimation =
            ((touchPoint.animationValue - 0.35) / 1.15).clamp(0.0, 1.0);

        // Calculate ring radius (expands outward continuously)
        final double ringRadius = effectiveRadius * 0.75; // Ring is at 75% of effective radius

        // Calculate stroke width that decreases as ring expands
        // Stroke width decreases from max to min as normalizedAnimation goes from 0.0 to 1.0
        const double maxStrokeWidth = 12.0;
        const double minStrokeWidth = 2.0;
        final double currentStrokeWidth =
            maxStrokeWidth * (1.0 - normalizedAnimation) + minStrokeWidth * normalizedAnimation;

        // Calculate distance from ring edge
        final double distanceFromRing = (distance - ringRadius).abs();
        final double halfStrokeWidth = currentStrokeWidth * 0.5;

        // Only color dots that are within the ring stroke width
        if (distanceFromRing <= halfStrokeWidth &&
            halfStrokeWidth > 0 &&
            halfStrokeWidth.isFinite) {
          // Calculate influence: strongest at ring center, fades towards edges
          final double normalizedDistanceFromRing =
              (distanceFromRing / halfStrokeWidth).clamp(0.0, 1.0);
          if (normalizedDistanceFromRing.isFinite) {
            influence = 1.0 - normalizedDistanceFromRing;
          } else {
            influence = 0.0;
          }

          // Apply smooth fade as ring expands (starts fading after 70% expansion)
          // This creates the fade-out effect while continuing to expand outward
          if (normalizedAnimation > 0.7) {
            final double fadeProgress = ((normalizedAnimation - 0.7) / 0.3).clamp(0.0, 1.0);
            influence *= (1.0 - fadeProgress * fadeProgress); // Quadratic fade for smoothness
          }
        } else {
          // Outside ring stroke width
          continue;
        }
      }

      // Guard against invalid influence values
      if (!influence.isFinite || influence <= 0 || influence.isNaN) {
        continue;
      }

      // Ensure influence is in valid range
      final double clampedInfluence = influence.clamp(0.0, 1.0);
      if (!clampedInfluence.isFinite || clampedInfluence <= 0 || clampedInfluence.isNaN) {
        continue;
      }

      // Determine color for this touch point
      final Color touchColor = touchPoint.color ??
          (gradientColors.isEmpty
              ? primaryColor
              : gradientColors[touchPoint.pointerId % gradientColors.length]);

      // Check if this is a hover event
      final bool isHover = hoverStates[touchPoint.pointerId] ?? false;
      final double opacity = (isHover ? hoverOpacity : 1.0).clamp(0.0, 1.0);

      // Guard against invalid color values
      Color finalColor = touchColor;
      if (opacity < 1.0 && touchColor.a.isFinite && opacity.isFinite && !touchColor.a.isNaN) {
        final double alphaValue = (touchColor.a * opacity).clamp(0.0, 1.0);
        if (alphaValue.isFinite && !alphaValue.isNaN) {
          finalColor = touchColor.withValues(alpha: alphaValue);
        }
      }

      influences.add((
        influence: clampedInfluence,
        color: finalColor,
        isHover: isHover,
      ));
    }

    if (influences.isEmpty) {
      return baseColor;
    }

    // Use the strongest influence to keep touch points independent
    // This prevents weird synchronization when multiple touch points overlap
    // Find the touch point with maximum influence
    double maxInfluence = 0.0;
    Color? dominantColor;

    for (final influence in influences) {
      if (influence.influence > maxInfluence) {
        maxInfluence = influence.influence;
        dominantColor = influence.color;
      }
    }

    if (dominantColor != null && maxInfluence > 0) {
      // Blend with base color based on the strongest influence
      final double blendFactor = maxInfluence.clamp(0.0, 1.0);
      // If base color is transparent, only show the animated color with influence-based alpha
      if (baseColor == Colors.transparent) {
        return dominantColor.withValues(
          alpha: (dominantColor.a * blendFactor).clamp(0.0, 1.0),
        );
      }
      return Color.lerp(baseColor, dominantColor, blendFactor) ?? baseColor;
    }

    return baseColor;
  }

  @override
  bool shouldRepaint(DotGridPainter oldDelegate) {
    return dotSize != oldDelegate.dotSize ||
        gridSpacing != oldDelegate.gridSpacing ||
        primaryColor != oldDelegate.primaryColor ||
        backgroundColor != oldDelegate.backgroundColor ||
        dotPattern != oldDelegate.dotPattern ||
        touchPoints.length != oldDelegate.touchPoints.length ||
        selectionPoints.length != oldDelegate.selectionPoints.length ||
        blobRadius != oldDelegate.blobRadius ||
        gradientColors != oldDelegate.gradientColors ||
        hoverOpacity != oldDelegate.hoverOpacity ||
        hoverStates != oldDelegate.hoverStates ||
        gridOffset != oldDelegate.gridOffset ||
        _touchPointsChanged(oldDelegate.touchPoints) ||
        _selectionPointsChanged(oldDelegate.selectionPoints);
  }

  /// Checks if touch points have changed significantly
  bool _touchPointsChanged(List<TouchPoint> oldTouchPoints) {
    if (touchPoints.length != oldTouchPoints.length) {
      return true;
    }

    for (int i = 0; i < touchPoints.length; i++) {
      final current = touchPoints[i];
      final old = oldTouchPoints[i];

      // Check if position or animation value changed significantly
      if ((current.position - old.position).distance > 1.0 ||
          (current.animationValue - old.animationValue).abs() > 0.01) {
        return true;
      }
    }

    return false;
  }

  bool _selectionPointsChanged(List<SelectionPoint> old) {
    if (selectionPoints.length != old.length) return true;
    for (int i = 0; i < selectionPoints.length; i++) {
      final a = selectionPoints[i];
      final b = old[i];
      if ((a.position - b.position).distance > 1.0 || a.color != b.color) return true;
    }
    return false;
  }
}

/// Represents a touch point with its position and animation state
class TouchPoint {
  /// Unique pointer ID
  final int pointerId;

  /// Position of the touch point
  final Offset position;

  /// Animation value (0.0 to 1.0) for blob expansion
  final double animationValue;

  /// Optional custom color for this touch point
  final Color? color;

  TouchPoint({
    required this.pointerId,
    required this.position,
    this.animationValue = 1.0,
    this.color,
  });

  TouchPoint copyWith({
    int? pointerId,
    Offset? position,
    double? animationValue,
    Color? color,
  }) {
    return TouchPoint(
      pointerId: pointerId ?? this.pointerId,
      position: position ?? this.position,
      animationValue: animationValue ?? this.animationValue,
      color: color ?? this.color,
    );
  }
}
