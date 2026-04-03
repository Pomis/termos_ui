import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Defaults matching [DotGridConfig] for grid-aligned comet animation.
const double kDefaultDotGridDotSize = 2.0;
const double kDefaultDotGridSpacing = 6.0;

enum _DotPhase { enter, idle, exit }

class TermosCometCircularProgress extends StatefulWidget {
  final Color? color;
  final Color? backgroundColor;
  final double strokeWidth;
  final int objectCount;
  final double gridSpacing;
  final double dotSize;

  // Comet physics parameters
  final int trailLength;
  final double trailSpacing;
  final double perturbAmplitude;
  final double perturbFrequency;
  final double velocityMultiplier;
  final double glowBlurRadius;
  final double glowOpacity;
  final double reactiveRadius;

  // Astrophysical orbit parameters
  /// 0=circle, 0.4=elliptical (Kepler)
  final double orbitEccentricity;
  /// Head brighter when closer to center (perihelion)
  final double perihelionGlow;
  /// 0=curved trail, 1=tail points radially away from center
  final double tailCurvature;
  /// Speed varies with distance (angular momentum)
  final double velocityWarp;
  /// Orbit precession per revolution (radians)
  final double precessionRate;
  /// Tilt effect for depth (0=none, 0.3=edge-on)
  final double orbitalInclination;

  /// Time constant for brightness/intensity lerp (ms). 100=snappy, 500=smooth.
  final int intensityTransitionDurationMs;

  /// Scale factor for velocity (0..1). 1=normal, 0.2=slow. Used for exit slowdown.
  final double velocityScale;

  /// When true, comet heads emit no light; grid dots play [exit] then clear. Used to
  /// chain a full exit before swapping to a new loader identity.
  final bool suppressCometTargets;

  const TermosCometCircularProgress({
    super.key,
    this.color,
    this.backgroundColor,
    this.strokeWidth = 4.0,
    this.objectCount = 3,
    this.gridSpacing = kDefaultDotGridSpacing,
    this.dotSize = kDefaultDotGridDotSize,
    this.trailLength = 12,
    this.trailSpacing = 0.15,
    this.perturbAmplitude = 6.0,
    this.perturbFrequency = 3.0,
    this.velocityMultiplier = 1.0,
    this.glowBlurRadius = 2.0,
    this.glowOpacity = 0.8,
    this.reactiveRadius = 0.0,
    this.orbitEccentricity = 0.0,
    this.perihelionGlow = 0.0,
    this.tailCurvature = 0.0,
    this.velocityWarp = 0.0,
    this.precessionRate = 0.0,
    this.orbitalInclination = 0.0,
    this.intensityTransitionDurationMs = 500,
    this.velocityScale = 1.0,
    this.suppressCometTargets = false,
  });

  @override
  State<TermosCometCircularProgress> createState() =>
      _TermosCometCircularProgressState();
}

class _TermosCometCircularProgressState
    extends State<TermosCometCircularProgress>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // Persistent smoothed intensities keyed by grid index (i,j) to avoid
  // floating-point Offset equality issues.
  final Map<int, double> _smoothed = {};

  // Per-dot phase: enter (grow in), idle, exit (shrink out)
  final Map<int, _DotPhase> _dotPhase = {};
  final Map<int, double> _phaseProgress = {}; // 0..1 within phase

  // Cached grid — rebuilt only when layout/params change.
  List<Offset> _gridDots = [];
  Map<int, Offset> _gridIndex = {}; // packedKey → Offset
  Size _lastSize = Size.zero;

  double? _lastFrameTimeMs;
  double? _lastProgress;
  int _cycleCount = 0; // Tracks completed orbits for continuous precession
  // Duration for enter/exit phase (grow in / shrink out)
  static const int _phaseDurationMs = 280;
  static const double _twoPi = math.pi * 2.0;
  static const double _startAngle = -math.pi / 2.0;

  @override
  void initState() {
    super.initState();
    _initController();
    _controller.addListener(_onTick);
  }

  void _initController() {
    final double effectiveVelocity =
        widget.velocityMultiplier * widget.velocityScale.clamp(0.1, 2.0);
    final int durationMs = (3000 / effectiveVelocity).round();
    _controller = AnimationController(
      duration: Duration(milliseconds: durationMs),
      vsync: this,
    );
    _controller.repeat();
  }

  @override
  void didUpdateWidget(TermosCometCircularProgress oldWidget) {
    super.didUpdateWidget(oldWidget);
    final double effectiveVelocity =
        widget.velocityMultiplier * widget.velocityScale.clamp(0.1, 2.0);
    if (oldWidget.velocityMultiplier != widget.velocityMultiplier ||
        oldWidget.velocityScale != widget.velocityScale) {
      final int durationMs = (3000 / effectiveVelocity).round();
      _controller.duration = Duration(milliseconds: durationMs);
      if (!_controller.isAnimating) {
        _controller.repeat();
      }
    }
    // Invalidate grid cache if shape params change
    if (oldWidget.gridSpacing != widget.gridSpacing ||
        oldWidget.perturbAmplitude != widget.perturbAmplitude ||
        oldWidget.strokeWidth != widget.strokeWidth ||
        oldWidget.orbitEccentricity != widget.orbitEccentricity) {
      _lastSize = Size.zero; // force rebuild
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTick);
    _controller.dispose();
    super.dispose();
  }

  /// Pack grid indices (i,j) into a single int key.
  /// Range: i,j ∈ [-500, 500] — more than enough for any grid.
  static int _packKey(int i, int j) => (i + 500) * 1001 + (j + 500);

  void _buildGrid(Size size) {
    if (size == _lastSize) return;
    _lastSize = size;

    final double baseRadius =
        (math.min(size.width, size.height) - widget.strokeWidth) / 2;
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double maxRadius = baseRadius * (1 + widget.orbitEccentricity) +
        widget.perturbAmplitude + widget.gridSpacing;
    final int gridExtent =
        (maxRadius * 2 / widget.gridSpacing).ceil();

    _gridDots = [];
    _gridIndex = {};

    for (int i = -gridExtent; i <= gridExtent; i++) {
      for (int j = -gridExtent; j <= gridExtent; j++) {
        final Offset dot =
            center + Offset(j * widget.gridSpacing, i * widget.gridSpacing);
        final double dist = (dot - center).distance;
        if (dist <= maxRadius) {
          final int key = _packKey(i, j);
          _gridDots.add(dot);
          _gridIndex[key] = dot;
        }
      }
    }
  }

  void _onTick() {
    // This runs every frame via the animation listener
    // We let setState in build handle the repaint
  }

  /// Soft-illuminate the 4 nearest grid cells around a world-space point.
  /// Uses bilinear weighting so intensity smoothly transfers between cells.
  void _softIlluminate(
      double x, double y, Offset center, double intensity, Map<int, double> targets) {
    final double fi = (y - center.dy) / widget.gridSpacing;
    final double fj = (x - center.dx) / widget.gridSpacing;

    final int i0 = fi.floor();
    final int i1 = i0 + 1;
    final int j0 = fj.floor();
    final int j1 = j0 + 1;

    final double fy = fi - i0; // 0..1 fractional position within cell
    final double fx = fj - j0;

    // Bilinear weights for the 4 neighbors
    final List<(int, int, double)> neighbors = [
      (i0, j0, (1 - fx) * (1 - fy)),
      (i0, j1, fx * (1 - fy)),
      (i1, j0, (1 - fx) * fy),
      (i1, j1, fx * fy),
    ];

    for (final (i, j, weight) in neighbors) {
      if (weight < 0.01) continue;
      final int key = _packKey(i, j);
      if (_gridIndex.containsKey(key)) {
        final double weighted = intensity * weight;
        targets[key] = math.max(targets[key] ?? 0.0, weighted);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = widget.color ?? Theme.of(context).colorScheme.primary;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final Size size = constraints.biggest;
            _buildGrid(size); // no-op if size unchanged

            final double baseRadius =
                (math.min(size.width, size.height) - widget.strokeWidth) / 2;
            final Offset center = Offset(size.width / 2, size.height / 2);
            final double progress = _controller.value;

            // Detect repeat boundary (progress 1->0) for continuous precession
            if (_lastProgress != null && progress < 0.5 && _lastProgress! > 0.5) {
              _cycleCount++;
            }
            _lastProgress = progress;

            // 1. Compute raw target intensities with soft snapping
            final Map<int, double> targets = {};
            // Use cycleCount + progress so precession is continuous across repeat boundary
            final double totalProgress = _cycleCount + progress;
            final double precession = totalProgress * widget.precessionRate * _twoPi;

            for (int c = 0; c < widget.objectCount; c++) {
              final double cometPhase = c * (_twoPi / widget.objectCount);
              // Velocity warp: spend more time near perihelion (Kepler)
              final double warpedProgress = progress +
                  widget.velocityWarp * math.sin(progress * _twoPi);
              final double headAngle = _startAngle +
                  warpedProgress * _twoPi +
                  cometPhase +
                  precession;

              // Elliptical orbit (eccentricity)
              final double headR = baseRadius *
                      (1 +
                          widget.orbitEccentricity *
                              math.cos(headAngle - cometPhase)) +
                  math.sin(headAngle * widget.perturbFrequency) *
                      widget.perturbAmplitude;

              // Orbital inclination (tilt / depth)
              final double inclinationScale = 1.0 -
                  widget.orbitalInclination *
                      math.pow(math.cos(headAngle), 2).toDouble();
              final double headRInclined = headR * inclinationScale;

              for (int t = 0; t <= widget.trailLength; t++) {
                double intensity = 1.0 - (t / (widget.trailLength + 1));

                // Tail curvature: 0=curved (orbit-following), 1=radially away
                final double curveAngle =
                    headAngle - (1 - widget.tailCurvature) * t * widget.trailSpacing;
                final double radialR = headRInclined +
                    t * widget.trailSpacing * baseRadius * 0.6;
                final double curveR = baseRadius *
                        (1 +
                            widget.orbitEccentricity *
                                math.cos(curveAngle - cometPhase)) +
                    math.sin(curveAngle * widget.perturbFrequency) *
                        widget.perturbAmplitude;
                final double r =
                    radialR * widget.tailCurvature + curveR * (1 - widget.tailCurvature);
                final double angle =
                    headAngle * widget.tailCurvature + curveAngle * (1 - widget.tailCurvature);

                // Perihelion glow: brighter when closer to center
                if (widget.perihelionGlow > 0 && r > 1) {
                  intensity *= 1 +
                      widget.perihelionGlow *
                          (baseRadius / r).clamp(0.0, 2.0);
                  intensity = intensity.clamp(0.0, 1.0);
                }

                final double tx = center.dx + math.cos(angle) * r;
                final double ty = center.dy + math.sin(angle) * r;

                _softIlluminate(tx, ty, center, intensity, targets);
              }
            }

            // Starfield reactivity
            if (widget.reactiveRadius > 0) {
              for (int c = 0; c < widget.objectCount; c++) {
                final double cometPhase = c * (_twoPi / widget.objectCount);
                final double warpedProgress = progress +
                    widget.velocityWarp * math.sin(progress * _twoPi);
                final double headAngle = _startAngle +
                    warpedProgress * _twoPi +
                    cometPhase +
                    precession;
                final double headR = baseRadius *
                        (1 +
                            widget.orbitEccentricity *
                                math.cos(headAngle - cometPhase)) +
                    math.sin(headAngle * widget.perturbFrequency) *
                        widget.perturbAmplitude;
                final double inclScale = 1.0 -
                    widget.orbitalInclination *
                        math.pow(math.cos(headAngle), 2).toDouble();
                final double headRIncl = headR * inclScale;
                final Offset headPos = Offset(
                  center.dx + math.cos(headAngle) * headRIncl,
                  center.dy + math.sin(headAngle) * headRIncl,
                );

                for (final entry in _gridIndex.entries) {
                  final Offset dot = entry.value;
                  final double dist = (dot - headPos).distance;
                  if (dist <= widget.reactiveRadius && dist > 0) {
                    final double sparkle =
                        (1.0 - dist / widget.reactiveRadius) * 0.5;
                    targets[entry.key] =
                        math.max(targets[entry.key] ?? 0.0, sparkle);
                  }
                }
              }
            }

            if (widget.suppressCometTargets) {
              targets.clear();
            }

            // 2. Lerp toward targets + update ENTER/IDLE/EXIT phases
            final now = DateTime.now().millisecondsSinceEpoch.toDouble();
            final rawDelta = _lastFrameTimeMs != null ? now - _lastFrameTimeMs! : 16.0;
            final deltaMs = rawDelta.clamp(8.0, 50.0);
            _lastFrameTimeMs = now;

            final durationMs = widget.intensityTransitionDurationMs.toDouble();
            final rate = (1.0 - math.exp(-deltaMs / durationMs)).clamp(0.0, 1.0);
            final phaseRate = (deltaMs / _phaseDurationMs).clamp(0.0, 1.0);
            final Map<int, double> renderIntensities = {};
            final Map<int, _DotPhase> renderPhases = {};
            final Map<int, double> renderPhaseProgress = {};
            final keysToRemove = <int>[];

            for (final key in targets.keys) {
              _smoothed.putIfAbsent(key, () => 0.0);
            }

            for (final key in _smoothed.keys.toList()) {
              final double target = targets[key] ?? 0.0;
              final double current = _smoothed[key]!;
              final double next = current + (target - current) * rate;
              _smoothed[key] = next;

              final phase = _dotPhase[key];
              double progress = _phaseProgress[key] ?? 0.0;

              if (target > 0) {
                if (phase == null || phase == _DotPhase.exit) {
                  _dotPhase[key] = _DotPhase.enter;
                  _phaseProgress[key] = 0.0;
                  progress = 0.0;
                } else if (phase == _DotPhase.enter) {
                  progress = (progress + phaseRate).clamp(0.0, 1.0);
                  _phaseProgress[key] = progress;
                  if (progress >= 1.0) {
                    _dotPhase[key] = _DotPhase.idle;
                    _phaseProgress[key] = 1.0;
                  }
                }
                // idle: no change
                renderIntensities[key] = next;
                renderPhases[key] = _dotPhase[key]!;
                renderPhaseProgress[key] = _phaseProgress[key] ?? 1.0;
              } else {
                // target == 0: EXIT phase
                if (phase == _DotPhase.enter || phase == _DotPhase.idle) {
                  _dotPhase[key] = _DotPhase.exit;
                  _phaseProgress[key] = 0.0;
                  progress = 0.0;
                } else if (phase == _DotPhase.exit) {
                  progress = (progress + phaseRate).clamp(0.0, 1.0);
                  _phaseProgress[key] = progress;
                }
                if (progress >= 1.0) {
                  keysToRemove.add(key);
                } else {
                  renderIntensities[key] = next;
                  renderPhases[key] = _DotPhase.exit;
                  renderPhaseProgress[key] = progress;
                }
              }
            }
            for (final k in keysToRemove) {
              _smoothed.remove(k);
              _dotPhase.remove(k);
              _phaseProgress.remove(k);
            }

            final bgColor = widget.backgroundColor ??
                Theme.of(context).scaffoldBackgroundColor;

            return CustomPaint(
              size: size,
              painter: _CometGridPainter(
                color: themeColor,
                backgroundColor: bgColor,
                gridIndex: _gridIndex,
                renderIntensities: renderIntensities,
                renderPhases: renderPhases,
                renderPhaseProgress: renderPhaseProgress,
                dotSize: widget.dotSize,
                glowBlurRadius: widget.glowBlurRadius,
                glowOpacity: widget.glowOpacity,
              ),
            );
          },
        );
      },
    );
  }
}

class _CometGridPainter extends CustomPainter {
  final Color color;
  final Color backgroundColor;
  final Map<int, Offset> gridIndex;
  final Map<int, double> renderIntensities;
  final Map<int, _DotPhase> renderPhases;
  final Map<int, double> renderPhaseProgress;
  final double dotSize;
  final double glowBlurRadius;
  final double glowOpacity;

  _CometGridPainter({
    required this.color,
    required this.backgroundColor,
    required this.gridIndex,
    required this.renderIntensities,
    required this.renderPhases,
    required this.renderPhaseProgress,
    required this.dotSize,
    required this.glowBlurRadius,
    required this.glowOpacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.fill;

    if (glowBlurRadius > 0) {
      paint.maskFilter = MaskFilter.blur(BlurStyle.solid, glowBlurRadius);
    }

    for (final MapEntry<int, double> entry in renderIntensities.entries) {
      final int key = entry.key;
      final double intensity = entry.value;
      final phase = renderPhases[key] ?? _DotPhase.idle;
      final progress = renderPhaseProgress[key] ?? 1.0;

      double sizeScale;
      double colorBlend;
      switch (phase) {
        case _DotPhase.enter:
          sizeScale = progress;
          colorBlend = intensity * progress;
          break;
        case _DotPhase.idle:
          sizeScale = 1.0;
          colorBlend = intensity;
          break;
        case _DotPhase.exit:
          sizeScale = 1.0 - progress;
          colorBlend = intensity * (1.0 - progress);
          break;
      }

      if (colorBlend < 0.01) continue;
      final Offset? dot = gridIndex[key];
      if (dot == null) continue;

      final brightness = 2.5; // 80% brighter (50% + 30%)
      paint.color = Color.lerp(
        backgroundColor,
        color,
        (colorBlend * glowOpacity * brightness).clamp(0.0, 1.0),
      )!;
      final double sz = dotSize * (1.0 + intensity * 0.8) * sizeScale;
      canvas.drawCircle(dot, sz / 2, paint);
    }
  }

  @override
  bool shouldRepaint(_CometGridPainter oldPainter) => true;
}
