import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/termos_colors.dart';
import '../theme/termos_text_styles.dart';
import '../theme/termos_theme.dart';

/// Particle-style ON/OFF switch with dot field and edge glow (falls back to simple track when heavy effects off).
class TermosSwitch extends StatefulWidget {
  const TermosSwitch({
    super.key,
    required this.value,
    this.onChanged,
    this.blobRadius = 21.5,
    this.edgeSharpness = 5,
    this.glowIntensity = 0.5,
    /// When null, uses [TermosThemeData.dotGrid.dotSize].
    this.dotSize,
    /// When null, uses [TermosThemeData.dotGrid.spacing].
    this.gridSpacing,
    this.blobInset = 8,
    this.onAlpha = 1,
    this.offAlpha = 0.23,
    this.idleAlpha = 0.05,
    this.sweepWeight = 0,
    this.blobWeight = 1,
    this.trackWidth = 82,
    this.trackHeight = 33.5,
    this.trackRadius,
    this.borderWidth = 1,
    this.glowStrokeWidth = 1,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;

  final double blobRadius;
  final double edgeSharpness;
  final double glowIntensity;
  final double? dotSize;
  final double? gridSpacing;
  final double blobInset;
  final double onAlpha;
  final double offAlpha;
  final double idleAlpha;
  final double sweepWeight;
  final double blobWeight;
  final double trackWidth;
  final double trackHeight;
  /// When null, uses [TermosThemeData.metrics.borderRadius].
  final double? trackRadius;
  final double borderWidth;
  final double glowStrokeWidth;

  @override
  State<TermosSwitch> createState() => _TermosSwitchState();
}

class _TermosSwitchState extends State<TermosSwitch> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const _slideDuration = Duration(milliseconds: 300);
  static const _slideCurve = Curves.easeInOutCubic;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _slideDuration,
      value: widget.value ? 1.0 : 0.0,
    );
  }

  bool _isDragging = false;

  @override
  void didUpdateWidget(TermosSwitch old) {
    super.didUpdateWidget(old);
    if (widget.value != old.value && !_isDragging) {
      widget.value ? _controller.forward() : _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() => widget.onChanged?.call(!widget.value);

  void _onDragUpdate(DragUpdateDetails details) {
    _isDragging = true;
    final delta = details.primaryDelta ?? 0;
    final travel = widget.trackWidth - widget.blobInset * 2;
    if (travel > 0) {
      _controller.value = (_controller.value + delta / travel).clamp(0.0, 1.0);
    }
  }

  void _onDragEnd(DragEndDetails details) {
    _isDragging = false;
    final velocity = details.primaryVelocity ?? 0;
    final bool newValue;
    if (velocity.abs() > 200) {
      newValue = velocity > 0;
    } else {
      newValue = _controller.value > 0.5;
    }
    if (newValue != widget.value) {
      widget.onChanged?.call(newValue);
    } else {
      newValue ? _controller.forward() : _controller.reverse();
    }
  }

  double _controlX(double t) {
    final inset = widget.blobInset;
    return inset + t * (widget.trackWidth - inset * 2);
  }

  Widget _buildLabel(
    double t,
    TermosColors colors,
    TermosTextStyles textStyles, {
    required bool isLight,
  }) {
    final onColor = isLight ? colors.primary : Colors.white;
    final labelColor = Color.lerp(colors.textMuted, onColor, t)!;
    final labelText = t < 0.5 ? 'OFF' : 'ON';
    final alignment =
        Alignment.lerp(const Alignment(-0.5, 0), const Alignment(0.5, 0), t)!;

    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(
          labelText,
          style: textStyles.switchLabel(labelColor),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final termos = TermosTheme.of(context);
    final colors = termos.colors;
    final textStyles = termos.textStyles;
    final dotGrid = termos.dotGrid;
    final effectiveDotSize = widget.dotSize ?? dotGrid.dotSize;
    final effectiveGridSpacing = widget.gridSpacing ?? dotGrid.spacing;
    final useHeavy = termos.heavyEffectsEnabled;
    final trackRadius = widget.trackRadius ?? termos.metrics.borderRadius;
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Semantics(
      toggled: widget.value,
      label: 'Toggle switch',
      child: AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _isDragging ? _controller.value : _slideCurve.transform(_controller.value);
        final accent = Color.lerp(colors.textMuted, colors.primary, t)!;
        final activeAlpha = lerpDouble(widget.offAlpha, widget.onAlpha, t)!;

        if (!useHeavy) {
          return _buildSimpleTrack(
            context,
            colors,
            textStyles,
            trackRadius: trackRadius,
            t: t,
          );
        }

        final glowColor = isLight ? Color.lerp(accent, Colors.white, 0.4)! : accent;
        final activeColor =
            isLight ? Color.lerp(colors.primary, Colors.white, 0.3)! : colors.primary;
        final blobColor = Color.lerp(colors.textMuted, activeColor, t)!;
        final trackBg = Color.lerp(colors.surface, colors.primary, t * (isLight ? 0.04 : 0.075))!;
        final borderColor = Color.lerp(colors.dotGridButtonBorder, accent, t * 0.5)!;
        final controlX = _controlX(t);

        return GestureDetector(
          onTap: _toggle,
          onHorizontalDragUpdate: _onDragUpdate,
          onHorizontalDragEnd: _onDragEnd,
          child: SizedBox(
            width: widget.trackWidth,
            height: widget.trackHeight,
            child: CustomPaint(
              foregroundPainter: t > 0.01
                  ? _RightEdgeGlowPainter(
                      glowColor: glowColor,
                      baseColor: glowColor.withValues(alpha: isLight ? 0.1 : 0.05),
                      strokeWidth: widget.glowStrokeWidth,
                      radius: trackRadius,
                      opacity: t,
                    )
                  : null,
              child: Container(
                decoration: BoxDecoration(
                  color: trackBg,
                  borderRadius: BorderRadius.circular(trackRadius),
                  border: Border.all(color: borderColor, width: widget.borderWidth),
                ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(
                        (trackRadius - widget.borderWidth).clamp(0, double.infinity),
                      ),
                      child: CustomPaint(
                        painter: _CombinedDotsPainter(
                          activationT: t,
                          blobCenter: Offset(controlX, widget.trackHeight / 2),
                          blobRadius: widget.blobRadius,
                          edgeSharpness: widget.edgeSharpness,
                          intensity: widget.glowIntensity,
                          activeColor: activeColor,
                          blobColor: blobColor,
                          idleColor: colors.dotGridIdleMesh,
                          dotSize: effectiveDotSize,
                          gridSpacing: effectiveGridSpacing,
                          activeAlpha: activeAlpha,
                          idleAlpha: widget.idleAlpha,
                          sweepWeight: widget.sweepWeight,
                          blobWeight: widget.blobWeight,
                        ),
                        child: const SizedBox.expand(),
                      ),
                    ),
                    _buildLabel(t, colors, textStyles, isLight: isLight),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    ));
  }

  Widget _buildSimpleTrack(
    BuildContext context,
    TermosColors colors,
    TermosTextStyles textStyles, {
    required double trackRadius,
    required double t,
  }) {
    final accent = Color.lerp(colors.textMuted, colors.primary, t)!;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final trackBg = Color.lerp(colors.surface, colors.primary, t * (isLight ? 0.04 : 0.075))!;

    return GestureDetector(
      onTap: _toggle,
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      child: SizedBox(
        width: widget.trackWidth,
        height: widget.trackHeight,
        child: Container(
          decoration: BoxDecoration(
            color: trackBg,
            borderRadius: BorderRadius.circular(trackRadius),
            border: Border.all(
              color: Color.lerp(colors.dotGridButtonBorder, accent, t * 0.3)!,
              width: widget.borderWidth,
            ),
          ),
          child: _buildLabel(t, colors, textStyles, isLight: isLight),
        ),
      ),
    );
  }
}

class _RightEdgeGlowPainter extends CustomPainter {
  _RightEdgeGlowPainter({
    required this.glowColor,
    required this.baseColor,
    required this.strokeWidth,
    required this.radius,
    this.opacity = 1.0,
  });

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
      ..moveTo(size.width - r, 0)
      ..arcToPoint(Offset(size.width, r), radius: Radius.circular(r))
      ..lineTo(size.width, size.height - r)
      ..arcToPoint(Offset(size.width - r, size.height), radius: Radius.circular(r));

    final effGlow = glowColor.withValues(alpha: glowColor.a * opacity * 0.7);
    final effBase = baseColor.withValues(alpha: baseColor.a * opacity * 0.7);

    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [effBase, effGlow, effGlow, effBase],
      stops: const [0.18, 0.42, 0.58, 0.82],
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
          glowColor.withValues(alpha: 0.245 * opacity),
          glowColor.withValues(alpha: 0.245 * opacity),
          glowColor.withValues(alpha: 0),
        ],
        stops: const [0.12, 0.38, 0.62, 0.88],
      ).createShader(shaderRect);
    canvas.drawPath(path, shadowPaint);

    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..shader = gradient.createShader(shaderRect);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(_RightEdgeGlowPainter old) =>
      glowColor != old.glowColor ||
      baseColor != old.baseColor ||
      opacity != old.opacity ||
      strokeWidth != old.strokeWidth ||
      radius != old.radius;
}

class _CombinedDotsPainter extends CustomPainter {
  _CombinedDotsPainter({
    required this.activationT,
    required this.blobCenter,
    required this.blobRadius,
    required this.edgeSharpness,
    required this.intensity,
    required this.activeColor,
    required this.blobColor,
    required this.idleColor,
    required this.dotSize,
    required this.gridSpacing,
    required this.activeAlpha,
    required this.idleAlpha,
    required this.sweepWeight,
    required this.blobWeight,
  });

  final double activationT;
  final Offset blobCenter;
  final double blobRadius;
  final double edgeSharpness;
  final double intensity;
  final Color activeColor;
  final Color blobColor;
  final Color idleColor;
  final double dotSize;
  final double gridSpacing;
  final double activeAlpha;
  final double idleAlpha;
  final double sweepWeight;
  final double blobWeight;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final totalSpacing = dotSize + gridSpacing;
    final paint = Paint();
    final idleWithAlpha = idleColor.withValues(alpha: idleAlpha);
    final activeWithAlpha = activeColor.withValues(alpha: activeAlpha);
    final blobWithAlpha = blobColor.withValues(alpha: activeAlpha);

    for (double y = totalSpacing / 2; y < size.height; y += totalSpacing) {
      for (double x = totalSpacing / 2; x < size.width; x += totalSpacing) {
        final normalizedX = size.width > 0 ? x / size.width : 0.0;

        final sweepEdge = edgeSharpness * (normalizedX - activationT);
        final sweepAmt =
            (1.0 / (1.0 + exp(sweepEdge)) * sweepWeight * intensity).clamp(0.0, 1.0);

        final dist = (Offset(x, y) - blobCenter).distance;
        final blobNorm = (dist / blobRadius).clamp(0.0, 1.0);
        final blobLinear = 1.0 - blobNorm;
        final blobProximity = blobLinear * blobLinear * (3.0 - 2.0 * blobLinear);
        final blobAmt = (blobProximity * blobWeight * intensity).clamp(0.0, 1.0);

        final totalAmt = (sweepAmt + blobAmt).clamp(0.0, 1.0);
        if (totalAmt <= 0 && idleAlpha <= 0) continue;

        final alpha = totalAmt * activeAlpha + (1.0 - totalAmt) * idleAlpha;

        final totalNonZero = sweepAmt + blobAmt;
        final Color effectColor;
        if (totalNonZero > 0) {
          final blobRatio = blobAmt / totalNonZero;
          effectColor = Color.lerp(activeWithAlpha, blobWithAlpha, blobRatio)!;
        } else {
          effectColor = idleWithAlpha;
        }

        paint.color = Color.lerp(idleWithAlpha, effectColor, totalAmt)!.withValues(alpha: alpha);

        canvas.drawRect(
          Rect.fromCenter(center: Offset(x, y), width: dotSize, height: dotSize),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_CombinedDotsPainter old) =>
      activationT != old.activationT ||
      blobCenter != old.blobCenter ||
      blobRadius != old.blobRadius ||
      edgeSharpness != old.edgeSharpness ||
      intensity != old.intensity ||
      activeColor != old.activeColor ||
      blobColor != old.blobColor ||
      idleColor != old.idleColor ||
      dotSize != old.dotSize ||
      gridSpacing != old.gridSpacing ||
      activeAlpha != old.activeAlpha ||
      idleAlpha != old.idleAlpha ||
      sweepWeight != old.sweepWeight ||
      blobWeight != old.blobWeight;
}
