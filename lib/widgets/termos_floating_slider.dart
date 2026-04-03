import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/termos_theme.dart';
import 'termos_slider.dart';

/// Tick-strip slider that looks identical to [TermosSlider] at rest but supports
/// continuous horizontal dragging. While dragging, the selected notch detaches
/// and morphs into a circle; as it approaches another notch it morphs back into
/// a tick. On release, the indicator snaps to the nearest discrete position.
///
/// First and last notches are inset by [edgePad] so that labels are centred
/// under them regardless of notch count.
class TermosFloatingSlider extends StatefulWidget {
  const TermosFloatingSlider({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.divisions,
    this.compact = true,
    this.formatValue,
    this.minLabel,
    this.maxLabel,
  });

  /// Horizontal inset for the first and last notch so edge labels stay visible.
  static const double edgePad = 8.0;

  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  /// Number of equal intervals between [min] and [max] (positions = divisions + 1).
  final int? divisions;

  final bool compact;

  /// Display string for each position (defaults to [TermosSlider.defaultFormatValue]).
  final String Function(double value)? formatValue;

  /// Override label for the first position.
  final String? minLabel;

  /// Override label for the last position.
  final String? maxLabel;

  /// Snaps [value] to the nearest discrete step when using [Slider] with [divisions] intervals.
  static double snapToDivisions(double value, double min, double max, int divisions) {
    assert(divisions >= 1);
    if (max <= min) return min;
    final step = (max - min) / divisions;
    final k = ((value - min) / step).round().clamp(0, divisions);
    return min + k * step;
  }

  @override
  State<TermosFloatingSlider> createState() => _TermosFloatingSliderState();
}

class _TermosFloatingSliderState extends State<TermosFloatingSlider>
    with SingleTickerProviderStateMixin {
  late final AnimationController _snapController;

  bool _isDragging = false;
  double _dragFraction = 0.0; // 0..1, first notch to last notch
  double _snapFromFraction = 0.0;
  double _snapToFraction = 0.0;
  double _snapFromMorphT = 0.0;
  int _lastHapticIndex = -1;
  double _totalWidth = 0.0;

  // ── Discrete positions ──────────────────────────────────────────────────

  List<double> _computePositions() {
    if (widget.max <= widget.min) return [widget.min];
    final div = widget.divisions ?? 1;
    final step = (widget.max - widget.min) / div;
    return List.generate(div + 1, (i) => widget.min + i * step);
  }

  double _valueFraction(double value) {
    if (widget.max <= widget.min) return 0.0;
    return ((value - widget.min) / (widget.max - widget.min)).clamp(0.0, 1.0);
  }

  int _nearestIndex(double fraction, int count) {
    if (count <= 1) return 0;
    return (fraction * (count - 1)).round().clamp(0, count - 1);
  }

  double _indexFraction(int index, int count) {
    if (count <= 1) return 0.0;
    return index / (count - 1);
  }

  // ── Morph geometry ──────────────────────────────────────────────────────

  /// Returns 0 when exactly on a notch (tick shape) and 1 when halfway between
  /// notches (circle shape). Uses pow(0.6) for a snappy feel near notches.
  double _computeMorphT(double fraction, int count) {
    if (count <= 1) return 0.0;
    final nearestIdx = _nearestIndex(fraction, count);
    final nearestFrac = _indexFraction(nearestIdx, count);
    final dist = (fraction - nearestFrac).abs();
    final halfSpacing = 0.5 / (count - 1);
    final rawT = (dist / halfSpacing).clamp(0.0, 1.0);
    return math.pow(rawT, 0.6).toDouble();
  }

  // ── Pixel ↔ fraction conversion ─────────────────────────────────────────

  /// Maps a pixel X to a 0..1 fraction across the padded notch range.
  double _xToFraction(double x, int count) {
    if (count <= 1 || _totalWidth <= 0) return 0.0;
    const pad = TermosFloatingSlider.edgePad;
    final usable = _totalWidth - 2 * pad;
    if (usable <= 0) return 0.0;
    return ((x - pad) / usable).clamp(0.0, 1.0);
  }

  // ── Gesture handlers ────────────────────────────────────────────────────

  void _onDragStart(DragStartDetails details) {
    final n = _computePositions().length;
    _snapController.stop();
    setState(() {
      _isDragging = true;
      _dragFraction = _xToFraction(details.localPosition.dx, n);
      _lastHapticIndex = _nearestIndex(_dragFraction, n);
    });
  }

  void _onDragUpdate(DragUpdateDetails details) {
    final n = _computePositions().length;
    final newFraction = _xToFraction(details.localPosition.dx, n);
    final newIdx = _nearestIndex(newFraction, n);

    if (newIdx != _lastHapticIndex) {
      HapticFeedback.selectionClick();
      _lastHapticIndex = newIdx;
    }

    setState(() {
      _dragFraction = newFraction;
    });
  }

  void _onDragEnd(DragEndDetails details) {
    final positions = _computePositions();
    final n = positions.length;
    final nearestIdx = _nearestIndex(_dragFraction, n);
    final nearestFrac = _indexFraction(nearestIdx, n);

    _snapFromFraction = _dragFraction;
    _snapToFraction = nearestFrac;
    _snapFromMorphT = _computeMorphT(_dragFraction, n);

    setState(() => _isDragging = false);
    _snapController.forward(from: 0.0);

    final snappedValue = positions[nearestIdx];
    if ((snappedValue - widget.value).abs() > 1e-9) {
      HapticFeedback.selectionClick();
      widget.onChanged(snappedValue);
    }
  }

  void _onTapUp(TapUpDetails details) {
    final positions = _computePositions();
    final fraction = _xToFraction(details.localPosition.dx, positions.length);
    final nearestIdx = _nearestIndex(fraction, positions.length);
    final snapped = positions[nearestIdx];
    if ((snapped - widget.value).abs() > 1e-9) {
      HapticFeedback.selectionClick();
      widget.onChanged(snapped);
    }
  }

  // ── Lifecycle ───────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _snapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    )..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _snapController.dispose();
    super.dispose();
  }

  // ── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final termos = TermosTheme.of(context);
    final colors = termos.colors;
    final textStyles = termos.textStyles;
    final compact = widget.compact;
    final format = widget.formatValue ?? TermosSlider.defaultFormatValue;

    final positions = _computePositions();
    final n = positions.length;
    final labels = <String>[
      for (int i = 0; i < n; i++)
        if (i == 0 && widget.minLabel != null)
          widget.minLabel!
        else if (i == n - 1 && widget.maxLabel != null)
          widget.maxLabel!
        else
          format(positions[i]),
    ];

    // Tight height: content is painted from the bottom; extra space only widens
    // the gap between an external label and the tick strip.
    final rowHeight = compact ? 28.0 : 44.0;
    final labelSize = compact ? 10.0 : 11.0;

    // ── Determine display state ───────────────────────────────────────────

    double displayFraction;
    double morphT;
    bool showIndicator;

    if (_snapController.isAnimating) {
      final t = Curves.easeOut.transform(_snapController.value);
      displayFraction = lerpDouble(_snapFromFraction, _snapToFraction, t)!;
      morphT = lerpDouble(_snapFromMorphT, 0.0, t)!.clamp(0.0, 1.0);
      showIndicator = true;
    } else if (_isDragging) {
      displayFraction = _dragFraction;
      morphT = _computeMorphT(_dragFraction, n);
      showIndicator = true;
    } else {
      displayFraction = _valueFraction(widget.value);
      morphT = 0.0;
      showIndicator = false;
    }

    final highlightedIndex = _nearestIndex(displayFraction, n);

    final labelStyle = textStyles
        .codePrimary(colors.textMuted)
        .copyWith(fontSize: labelSize, fontWeight: FontWeight.w500);
    final activeLabelStyle = textStyles
        .codePrimary(colors.primary)
        .copyWith(fontSize: labelSize, fontWeight: FontWeight.w600);

    final semanticValue = format(widget.value);
    return Semantics(
      slider: true,
      value: semanticValue,
      child: GestureDetector(
        onHorizontalDragStart: _onDragStart,
        onHorizontalDragUpdate: _onDragUpdate,
        onHorizontalDragEnd: _onDragEnd,
        onTapUp: _onTapUp,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          height: rowHeight,
          child: LayoutBuilder(
            builder: (context, constraints) {
              _totalWidth = constraints.maxWidth;
              return CustomPaint(
                size: Size(constraints.maxWidth, rowHeight),
                painter: _FloatingSliderPainter(
                  labels: labels,
                  highlightedIndex: highlightedIndex,
                  displayFraction: displayFraction,
                  morphT: morphT,
                  showIndicator: showIndicator,
                  primaryColor: colors.primary,
                  inactiveColor: colors.border.withValues(alpha: 0.85),
                  labelStyle: labelStyle,
                  activeLabelStyle: activeLabelStyle,
                  compact: compact,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Painter
// ═══════════════════════════════════════════════════════════════════════════════

class _FloatingSliderPainter extends CustomPainter {
  _FloatingSliderPainter({
    required this.labels,
    required this.highlightedIndex,
    required this.displayFraction,
    required this.morphT,
    required this.showIndicator,
    required this.primaryColor,
    required this.inactiveColor,
    required this.labelStyle,
    required this.activeLabelStyle,
    required this.compact,
  });

  final List<String> labels;
  final int highlightedIndex;
  final double displayFraction;
  final double morphT; // 0 = tick, 1 = circle
  final bool showIndicator;
  final Color primaryColor;
  final Color inactiveColor;
  final TextStyle labelStyle;
  final TextStyle activeLabelStyle;
  final bool compact;

  @override
  void paint(Canvas canvas, Size size) {
    final n = labels.length;
    if (n == 0) return;

    final tickHeight = compact ? 8.0 : 10.0;
    const tickWidth = 2.0;
    final gap = compact ? 3.0 : 4.0;
    const pad = TermosFloatingSlider.edgePad;

    // Measure label height to anchor layout from the bottom.
    final sampleTp = TextPainter(
      text: TextSpan(text: '0', style: labelStyle),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    final labelHeight = sampleTp.height;

    final labelTop = size.height - labelHeight;
    final tickBottom = labelTop - gap;
    final tickCenterY = tickBottom - tickHeight / 2;

    final usable = size.width - 2 * pad;

    // ── Notch X positions: edge-padded ──────────────────────────────────

    double notchX(int i) {
      if (n <= 1) return size.width / 2;
      return pad + i * usable / (n - 1);
    }

    // ── Draw notch ticks ────────────────────────────────────────────────

    final tickPaint = Paint();

    for (int i = 0; i < n; i++) {
      final cx = notchX(i);
      final isActive = !showIndicator && i == highlightedIndex;
      tickPaint.color = isActive ? primaryColor : inactiveColor;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(cx, tickCenterY),
            width: tickWidth,
            height: tickHeight,
          ),
          const Radius.circular(1),
        ),
        tickPaint,
      );
    }

    // ── Draw morphing indicator ─────────────────────────────────────────

    if (showIndicator) {
      final indicatorX = n > 1 ? pad + displayFraction * usable : size.width / 2;

      // Interpolate between tick (2 × tickHeight) and circle (circleD × circleD).
      final circleD = compact ? 6.0 : 7.0;
      final w = lerpDouble(tickWidth, circleD, morphT)!;
      final h = lerpDouble(tickHeight, circleD, morphT)!;
      final r = lerpDouble(1.0, circleD / 2, morphT)!;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(indicatorX, tickCenterY),
            width: w,
            height: h,
          ),
          Radius.circular(r),
        ),
        Paint()..color = primaryColor,
      );
    }

    // ── Draw labels ─────────────────────────────────────────────────────

    for (int i = 0; i < n; i++) {
      final cx = notchX(i);
      final isHighlighted = i == highlightedIndex;
      final tp = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: isHighlighted ? activeLabelStyle : labelStyle,
        ),
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )..layout(maxWidth: size.width);

      // Center under notch, clamped to stay within widget bounds.
      var labelX = cx - tp.width / 2;
      if (labelX < 0) labelX = 0;
      final maxLabelX = size.width - tp.width;
      if (maxLabelX > 0 && labelX > maxLabelX) labelX = maxLabelX;
      tp.paint(canvas, Offset(labelX, labelTop));
    }
  }

  @override
  bool shouldRepaint(covariant _FloatingSliderPainter old) {
    return highlightedIndex != old.highlightedIndex ||
        displayFraction != old.displayFraction ||
        morphT != old.morphT ||
        showIndicator != old.showIndicator ||
        primaryColor != old.primaryColor ||
        labels != old.labels;
  }
}
