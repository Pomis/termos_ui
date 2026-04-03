import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../core/termos_icon_slot.dart';
import '../core/termos_aligned_builder.dart';
import '../core/termos_tap_target.dart';
import '../painters/glow_top_border_painter.dart';
import '../painters/reactive_starfield_painter.dart';
import '../theme/termos_metrics.dart';
import '../theme/termos_theme.dart';
import 'termos_group.dart';

/// One segment in [TermosSegmentedSelector].
class TermosSegmentedItem {
  const TermosSegmentedItem({
    required this.label,
    this.icon,
  });

  final String label;
  final Widget? icon;
}

/// Horizontal segmented control with shared top-edge glow and [TermosGroup] alignment.
///
/// Layout and glow blending come from [TermosThemeData.metrics] and [TermosThemeData.segmented].
class TermosSegmentedSelector extends StatefulWidget {
  const TermosSegmentedSelector({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelectionChanged,
  });

  final List<TermosSegmentedItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelectionChanged;

  @override
  State<TermosSegmentedSelector> createState() => _TermosSegmentedSelectorState();
}

class _TermosSegmentedSelectorState extends State<TermosSegmentedSelector>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late final int _starfieldSeed;
  double _fromGlow = 0.5;
  double _toGlow = 0.5;

  int get _n => widget.items.length;

  @override
  void initState() {
    super.initState();
    _starfieldSeed = Random().nextInt(0x7FFFFFFF);
    final idx = widget.selectedIndex.clamp(0, _n > 0 ? _n - 1 : 0);
    _fromGlow = _toGlow = _glowPositionForIndex(idx);
    _glowController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: TermosMetrics.standard.segmentedGlowAnimationMs),
    );
  }

  @override
  void didUpdateWidget(TermosSegmentedSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _fromGlow = _glowPositionForIndex(oldWidget.selectedIndex.clamp(0, _n - 1));
      _toGlow = _glowPositionForIndex(widget.selectedIndex.clamp(0, _n - 1));
      _glowController.forward(from: 0);
    }
  }

  double _glowPositionForIndex(int index) =>
      _n <= 0 ? 0.5 : (index + 0.5) / _n;

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();

    final termos = TermosTheme.of(context);
    final useHeavy = termos.heavyEffectsEnabled;
    final colors = termos.colors;
    final dg = termos.dotGrid;
    final metrics = termos.metrics;
    final textStyles = termos.textStyles;
    final segmented = termos.segmented;
    final starfield = termos.starfield;
    final buttonEffects = termos.button;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final glowColor = isLight
        ? Color.lerp(colors.primary, Colors.white, segmented.glowColorMixWithWhite)!
        : colors.primary;
    final glowBaseOpacity =
        isLight ? segmented.glowBaseOpacityLight : segmented.glowBaseOpacityDark;
    final sel = widget.selectedIndex.clamp(0, _n - 1);
    final borderRadius = BorderRadius.circular(metrics.borderRadius);
    final cardBlend = Color.lerp(
      colors.background,
      colors.card,
      isLight ? buttonEffects.cardBlendLight : buttonEffects.cardBlendDark,
    )!;

    return TermosGroup(
      child: AnimatedBuilder(
        animation: _glowController,
        builder: (context, _) {
          final t = Curves.easeOutCubic.transform(_glowController.value);
          final glowPos = _fromGlow + (_toGlow - _fromGlow) * t;
          final centerColor = Color.lerp(
            colors.dotGridButtonBorder,
            colors.primary,
            buttonEffects.borderHoveredMix,
          )!;

          final segmentRow = Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (int i = 0; i < _n; i++)
                Expanded(
                  child: Semantics(
                    label: widget.items[i].label,
                    selected: i == sel,
                    button: true,
                    child: GestureDetector(
                      onTap: () => widget.onSelectionChanged(i),
                      behavior: HitTestBehavior.opaque,
                      child: Center(
                        child: DefaultTextStyle.merge(
                          style: textStyles.terminalHeader(
                            i == sel ? colors.primary : colors.textMuted,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (widget.items[i].icon != null) ...[
                                TermosIconSlot(
                                  icon: widget.items[i].icon!,
                                  tintColor: i == sel ? colors.primary : colors.textMuted,
                                  slotSize: metrics.buttonIconSize,
                                ),
                                SizedBox(width: metrics.buttonIconSpacing),
                              ],
                              Text(widget.items[i].label),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );

          final Widget body;
          if (useHeavy) {
            final glowIntensity = isLight
                ? starfield.intensityButtonLight
                : starfield.intensityButtonDark;

            body = Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: borderRadius,
                  child: TermosAlignedBuilder(
                    builder: (gridOffset) => CustomPaint(
                      painter: ReactiveStarfieldPainter(
                        dotSize: dg.dotSize,
                        gridSpacing: dg.spacing,
                        glowPosition: glowPos,
                        glowColor: glowColor,
                        intensity: glowIntensity,
                        gridOffset: gridOffset,
                        seed: _starfieldSeed,
                        glowRadiusFraction: starfield.glowRadiusFraction,
                      ),
                    ),
                  ),
                ),
                TermosTapTarget(
                  borderRadius: borderRadius,
                  primaryColor: colors.primary,
                  child: segmentRow,
                ),
              ],
            );
          } else {
            body = segmentRow;
          }

          return CustomPaint(
            foregroundPainter: GlowTopBorderPainter(
              position: glowPos,
              glowColor: glowColor,
              baseColor: glowColor.withValues(alpha: glowBaseOpacity),
              strokeWidth: metrics.glowTopBorderStrokeWidth,
              radius: metrics.borderRadius,
              opacity: 1.0,
            ),
            child: ClipRRect(
              borderRadius: borderRadius,
              child: SizedBox(
                height: metrics.segmentedHeight,
                child: CustomPaint(
                  foregroundPainter: _SegmentedBorderPainter(
                    glowPosition: glowPos,
                    segmentCount: _n,
                    centerColor: centerColor,
                    edgeColor: colors.dotGridButtonBorder,
                    borderRadius: metrics.borderRadius,
                  ),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: cardBlend,
                      borderRadius: borderRadius,
                    ),
                    child: body,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SegmentedBorderPainter extends CustomPainter {
  _SegmentedBorderPainter({
    required this.glowPosition,
    required this.segmentCount,
    required this.centerColor,
    required this.edgeColor,
    required this.borderRadius,
    this.strokeWidth = 1.0, // ignore: unused_element_parameter
  });

  final double glowPosition;
  final int segmentCount;
  final Color centerColor;
  final Color edgeColor;
  final double borderRadius;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(glowPosition * size.width, size.height / 2);
    final gradientRadius = size.width / segmentCount * 1.5;

    final paint = Paint()
      ..shader = ui.Gradient.radial(center, gradientRadius, [centerColor, edgeColor])
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final rrect = RRect.fromRectAndRadius(
      (Offset.zero & size).deflate(strokeWidth / 2),
      Radius.circular(borderRadius),
    );

    canvas.drawRRect(rrect, paint);

    canvas.save();
    canvas.clipRRect(rrect);
    for (int i = 1; i < segmentCount; i++) {
      final x = (i / segmentCount) * size.width;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_SegmentedBorderPainter old) =>
      glowPosition != old.glowPosition ||
      segmentCount != old.segmentCount ||
      centerColor != old.centerColor ||
      edgeColor != old.edgeColor ||
      borderRadius != old.borderRadius ||
      strokeWidth != old.strokeWidth;
}
