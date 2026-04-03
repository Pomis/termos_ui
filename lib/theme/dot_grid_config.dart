import 'dart:ui' show lerpDouble;

/// Dot grid mesh / starfield parameters shared by all Termos widgets.
class DotGridConfig {
  const DotGridConfig({
    this.dotSize = 2.0,
    this.spacing = 6.0,
    this.blobRadius = 100.0,
  });

  /// Size of each dot in logical pixels.
  final double dotSize;

  /// Gap between dot centers (grid spacing).
  final double spacing;

  /// Blob radius for mesh gradient feedback (tap/hover).
  final double blobRadius;

  /// Total cell size: [dotSize] + [spacing] (aligned to 4/8/16 grid when using defaults).
  double get totalSpacing => dotSize + spacing;

  DotGridConfig copyWith({
    double? dotSize,
    double? spacing,
    double? blobRadius,
  }) {
    return DotGridConfig(
      dotSize: dotSize ?? this.dotSize,
      spacing: spacing ?? this.spacing,
      blobRadius: blobRadius ?? this.blobRadius,
    );
  }

  DotGridConfig lerp(DotGridConfig other, double t) {
    return DotGridConfig(
      dotSize: lerpDouble(dotSize, other.dotSize, t)!,
      spacing: lerpDouble(spacing, other.spacing, t)!,
      blobRadius: lerpDouble(blobRadius, other.blobRadius, t)!,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DotGridConfig &&
          runtimeType == other.runtimeType &&
          dotSize == other.dotSize &&
          spacing == other.spacing &&
          blobRadius == other.blobRadius;

  @override
  int get hashCode => Object.hash(dotSize, spacing, blobRadius);
}
