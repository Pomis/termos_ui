import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/termos_theme.dart';
import 'termos_floating_slider.dart';
import 'termos_slider.dart';

/// Tick-strip slider with **major ticks** (labelled) and **mini dot notches**
/// between them. Combines the snap-and-morph behaviour of [TermosFloatingSlider]
/// with the floating value label of [TermosContinuousSlider].
///
/// The indicator snaps to every position (both major and mini). While dragging
/// it morphs from a tick/dot into a circle between snap points.
class TermosDetailedSlider extends StatefulWidget {
  const TermosDetailedSlider({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.divisions,
    this.subdivisions = 1,
    this.compact = true,
    this.formatValue,
    this.minLabel,
    this.maxLabel,
  });

  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  /// Major divisions (labelled tick count = divisions + 1).
  final int? divisions;

  /// Mini dot notches inserted between each pair of major ticks.
  /// Total snap positions = divisions × subdivisions + 1.
  final int subdivisions;

  final bool compact;
  final String Function(double value)? formatValue;
  final String? minLabel;
  final String? maxLabel;

  @override
  State<TermosDetailedSlider> createState() => _TermosDetailedSliderState();
}

class _TermosDetailedSliderState extends State<TermosDetailedSlider>
    with SingleTickerProviderStateMixin {
  late final AnimationController _snapController;

  bool _isDragging = false;
  double _dragFraction = 0.0;
  double _snapFromFraction = 0.0;
  double _snapToFraction = 0.0;
  double _snapFromMorphT = 0.0;
  int _lastHapticIndex = -1;
  double _totalWidth = 0.0;

  // ── Derived counts ──────────────────────────────────────────────────────

  int get _majorDiv => widget.divisions ?? 1;
  int get _subDiv => widget.subdivisions.clamp(1, 100);
  int get _totalSnaps => _majorDiv * _subDiv + 1;

  // ── Helpers ─────────────────────────────────────────────────────────────

  double _valueFraction(double value) {
    if (widget.max <= widget.min) return 0.0;
    return ((value - widget.min) / (widget.max - widget.min)).clamp(0.0, 1.0);
  }

  int _nearestSnapIndex(double fraction) {
    final total = _totalSnaps;
    if (total <= 1) return 0;
    return (fraction * (total - 1)).round().clamp(0, total - 1);
  }

  double _snapIndexFraction(int index) {
    final total = _totalSnaps;
    if (total <= 1) return 0.0;
    return index / (total - 1);
  }

  double _snapIndexToValue(int index) {
    final total = _totalSnaps;
    if (total <= 1) return widget.min;
    return widget.min + index * (widget.max - widget.min) / (total - 1);
  }

  double _computeMorphT(double fraction) {
    final total = _totalSnaps;
    if (total <= 1) return 0.0;
    final nearestIdx = _nearestSnapIndex(fraction);
    final nearestFrac = _snapIndexFraction(nearestIdx);
    final dist = (fraction - nearestFrac).abs();
    final halfSpacing = 0.5 / (total - 1);
    final rawT = (dist / halfSpacing).clamp(0.0, 1.0);
    return math.pow(rawT, 0.6).toDouble();
  }

  double _xToFraction(double x) {
    if (_totalSnaps <= 1 || _totalWidth <= 0) return 0.0;
    const pad = TermosFloatingSlider.edgePad;
    final usable = _totalWidth - 2 * pad;
    if (usable <= 0) return 0.0;
    return ((x - pad) / usable).clamp(0.0, 1.0);
  }

  // ── Gestures ────────────────────────────────────────────────────────────

  void _onDragStart(DragStartDetails details) {
    _snapController.stop();
    final frac = _xToFraction(details.localPosition.dx);
    setState(() {
      _isDragging = true;
      _dragFraction = frac;
      _lastHapticIndex = _nearestSnapIndex(frac);
    });
  }

  void _onDragUpdate(DragUpdateDetails details) {
    final frac = _xToFraction(details.localPosition.dx);
    final newIdx = _nearestSnapIndex(frac);
    if (newIdx != _lastHapticIndex) {
      HapticFeedback.selectionClick();
      _lastHapticIndex = newIdx;
    }
    setState(() => _dragFraction = frac);
  }

  void _onDragEnd(DragEndDetails details) {
    final nearestIdx = _nearestSnapIndex(_dragFraction);
    final nearestFrac = _snapIndexFraction(nearestIdx);

    _snapFromFraction = _dragFraction;
    _snapToFraction = nearestFrac;
    _snapFromMorphT = _computeMorphT(_dragFraction);

    setState(() => _isDragging = false);
    _snapController.forward(from: 0.0);

    final snappedValue = _snapIndexToValue(nearestIdx);
    if ((snappedValue - widget.value).abs() > 1e-9) {
      HapticFeedback.selectionClick();
      widget.onChanged(snappedValue);
    }
  }

  void _onTapUp(TapUpDetails details) {
    final frac = _xToFraction(details.localPosition.dx);
    final nearestIdx = _nearestSnapIndex(frac);
    final snappedValue = _snapIndexToValue(nearestIdx);
    if ((snappedValue - widget.value).abs() > 1e-9) {
      HapticFeedback.selectionClick();
      widget.onChanged(snappedValue);
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

    final majorDiv = _majorDiv;
    final subDiv = _subDiv;
    final majorStep = (widget.max - widget.min) / majorDiv;

    final majorLabels = <String>[
      for (int i = 0; i <= majorDiv; i++)
        if (i == 0 && widget.minLabel != null)
          widget.minLabel!
        else if (i == majorDiv && widget.maxLabel != null)
          widget.maxLabel!
        else
          format(widget.min + i * majorStep),
    ];

    // ── Display state ─────────────────────────────────────────────────────

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
      morphT = _computeMorphT(_dragFraction);
      showIndicator = true;
    } else {
      displayFraction = _valueFraction(widget.value);
      morphT = 0.0;
      showIndicator = false;
    }

    final highlightedSnapIndex = _nearestSnapIndex(displayFraction);
    final labelValue = _snapIndexToValue(highlightedSnapIndex);

    final rowHeight = compact ? 44.0 : 48.0;
    final labelSize = compact ? 10.0 : 11.0;

    final majorLabelStyle = textStyles
        .codePrimary(colors.textMuted)
        .copyWith(fontSize: labelSize, fontWeight: FontWeight.w500);
    final valueLabelStyle = textStyles
        .codePrimary(colors.primary)
        .copyWith(fontSize: labelSize, fontWeight: FontWeight.w600);

    return Semantics(
      slider: true,
      value: format(widget.value.clamp(widget.min, widget.max)),
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
                painter: _DetailedSliderPainter(
                  majorCount: majorDiv + 1,
                  subdivisions: subDiv,
                  majorLabels: majorLabels,
                  displayFraction: displayFraction,
                  morphT: morphT,
                  showIndicator: showIndicator,
                  highlightedSnapIndex: highlightedSnapIndex,
                  valueLabel: format(labelValue),
                  primaryColor: colors.primary,
                  inactiveColor: colors.border.withValues(alpha: 0.85),
                  majorLabelStyle: majorLabelStyle,
                  valueLabelStyle: valueLabelStyle,
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

class _DetailedSliderPainter extends CustomPainter {
  _DetailedSliderPainter({
    required this.majorCount,
    required this.subdivisions,
    required this.majorLabels,
    required this.displayFraction,
    required this.morphT,
    required this.showIndicator,
    required this.highlightedSnapIndex,
    required this.valueLabel,
    required this.primaryColor,
    required this.inactiveColor,
    required this.majorLabelStyle,
    required this.valueLabelStyle,
    required this.compact,
  });

  final int majorCount;
  final int subdivisions;
  final List<String> majorLabels;
  final double displayFraction; // 0..1
  final double morphT; // 0 = tick/dot, 1 = circle
  final bool showIndicator;
  final int highlightedSnapIndex;
  final String valueLabel;
  final Color primaryColor;
  final Color inactiveColor;
  final TextStyle majorLabelStyle;
  final TextStyle valueLabelStyle;
  final bool compact;

  @override
  void paint(Canvas canvas, Size size) {
    final totalSnaps = (majorCount - 1) * subdivisions + 1;
    if (totalSnaps == 0) return;

    final tickHeight = compact ? 8.0 : 10.0;
    const tickWidth = 2.0;
    final gap = compact ? 3.0 : 4.0;
    final circleD = compact ? 6.0 : 7.0;
    final dotD = compact ? 2.5 : 3.0;
    const pad = TermosFloatingSlider.edgePad;
    final usable = size.width - 2 * pad;

    // ── Measure text heights ─────────────────────────────────────────────

    final sampleTp = TextPainter(
      text: TextSpan(text: '0', style: majorLabelStyle),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    final majorLabelH = sampleTp.height;

    final valueTp = TextPainter(
      text: TextSpan(text: valueLabel, style: valueLabelStyle),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();

    // ── Y layout (bottom-up) ─────────────────────────────────────────────

    final majorLabelTop = size.height - majorLabelH;
    final tickBottom = majorLabelTop - gap;
    final tickCenterY = tickBottom - tickHeight / 2;
    final valueLabelY = tickCenterY - tickHeight / 2 - 2 - valueTp.height;

    // ── X helpers ────────────────────────────────────────────────────────

    double snapX(int i) {
      if (totalSnaps <= 1) return size.width / 2;
      return pad + i * usable / (totalSnaps - 1);
    }

    bool isMajor(int i) => i % subdivisions == 0;

    // ── Draw ticks and dots ──────────────────────────────────────────────

    final paint = Paint();

    for (int i = 0; i < totalSnaps; i++) {
      final cx = snapX(i);
      final isHighlighted = !showIndicator && i == highlightedSnapIndex;
      paint.color = isHighlighted ? primaryColor : inactiveColor;

      if (isMajor(i)) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset(cx, tickCenterY),
              width: tickWidth,
              height: tickHeight,
            ),
            const Radius.circular(1),
          ),
          paint,
        );
      } else {
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(cx, tickCenterY),
            width: dotD,
            height: dotD,
          ),
          paint,
        );
      }
    }

    // ── Draw morphing indicator ──────────────────────────────────────────

    final indicatorX = totalSnaps > 1
        ? pad + displayFraction * usable
        : size.width / 2;

    if (showIndicator) {
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

    // ── Draw floating value label ────────────────────────────────────────

    final labelRefX = showIndicator
        ? indicatorX
        : snapX(highlightedSnapIndex);

    var vlX = labelRefX - valueTp.width / 2;
    if (vlX < 0) vlX = 0;
    final maxVlX = size.width - valueTp.width;
    if (maxVlX > 0 && vlX > maxVlX) vlX = maxVlX;
    valueTp.paint(canvas, Offset(vlX, valueLabelY));

    // ── Draw major labels ────────────────────────────────────────────────

    for (int i = 0; i < majorCount; i++) {
      final snapIdx = i * subdivisions;
      final cx = snapX(snapIdx);
      final tp = TextPainter(
        text: TextSpan(text: majorLabels[i], style: majorLabelStyle),
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )..layout(maxWidth: size.width);

      var labelX = cx - tp.width / 2;
      if (labelX < 0) labelX = 0;
      final maxLabelX = size.width - tp.width;
      if (maxLabelX > 0 && labelX > maxLabelX) labelX = maxLabelX;
      tp.paint(canvas, Offset(labelX, majorLabelTop));
    }
  }

  @override
  bool shouldRepaint(covariant _DetailedSliderPainter old) {
    return displayFraction != old.displayFraction ||
        morphT != old.morphT ||
        showIndicator != old.showIndicator ||
        highlightedSnapIndex != old.highlightedSnapIndex ||
        valueLabel != old.valueLabel ||
        primaryColor != old.primaryColor ||
        majorLabels != old.majorLabels;
  }
}
