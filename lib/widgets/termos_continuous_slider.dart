import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/termos_theme.dart';
import 'termos_floating_slider.dart';
import 'termos_slider.dart';

/// Continuous tick-strip slider: same visual language as [TermosFloatingSlider]
/// but the indicator can rest at **any** position — it does not snap to notches.
///
/// A circle indicator sits at the current value, and a primary-coloured floating
/// label follows it. Reference tick marks (controlled by [divisions]) remain
/// visible in muted colour so the user can judge scale.
class TermosContinuousSlider extends StatefulWidget {
  const TermosContinuousSlider({
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

  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  /// Number of reference tick intervals (tick count = divisions + 1).
  /// When null only min / max ticks are shown.
  final int? divisions;

  final bool compact;

  /// Formats the floating value label and reference tick labels.
  final String Function(double value)? formatValue;

  /// Override the first reference label.
  final String? minLabel;

  /// Override the last reference label.
  final String? maxLabel;

  @override
  State<TermosContinuousSlider> createState() => _TermosContinuousSliderState();
}

class _TermosContinuousSliderState extends State<TermosContinuousSlider> {
  bool _isDragging = false;
  double _dragFraction = 0.0;
  double _totalWidth = 0.0;

  // ── Helpers ─────────────────────────────────────────────────────────────

  double _valueFraction(double value) {
    if (widget.max <= widget.min) return 0.0;
    return ((value - widget.min) / (widget.max - widget.min)).clamp(0.0, 1.0);
  }

  double _fractionToValue(double f) {
    return widget.min + f * (widget.max - widget.min);
  }

  double _xToFraction(double x) {
    const pad = TermosFloatingSlider.edgePad;
    final usable = _totalWidth - 2 * pad;
    if (usable <= 0) return 0.0;
    return ((x - pad) / usable).clamp(0.0, 1.0);
  }

  // ── Gestures ────────────────────────────────────────────────────────────

  void _onDragStart(DragStartDetails details) {
    final frac = _xToFraction(details.localPosition.dx);
    setState(() {
      _isDragging = true;
      _dragFraction = frac;
    });
    widget.onChanged(_fractionToValue(frac));
  }

  void _onDragUpdate(DragUpdateDetails details) {
    final frac = _xToFraction(details.localPosition.dx);
    setState(() => _dragFraction = frac);
    widget.onChanged(_fractionToValue(frac));
  }

  void _onDragEnd(DragEndDetails details) {
    setState(() => _isDragging = false);
    // No snapping — value stays where it is.
  }

  void _onTapUp(TapUpDetails details) {
    final frac = _xToFraction(details.localPosition.dx);
    HapticFeedback.selectionClick();
    widget.onChanged(_fractionToValue(frac));
  }

  // ── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final termos = TermosTheme.of(context);
    final colors = termos.colors;
    final textStyles = termos.textStyles;
    final compact = widget.compact;
    final format = widget.formatValue ?? TermosSlider.defaultFormatValue;

    final div = widget.divisions ?? 1;
    final tickCount = div + 1;
    final step = (widget.max - widget.min) / div;
    final tickLabels = <String>[
      for (int i = 0; i < tickCount; i++)
        if (i == 0 && widget.minLabel != null)
          widget.minLabel!
        else if (i == tickCount - 1 && widget.maxLabel != null)
          widget.maxLabel!
        else
          format(widget.min + i * step),
    ];

    final displayFraction =
        _isDragging ? _dragFraction : _valueFraction(widget.value);
    final displayValue = _isDragging
        ? _fractionToValue(_dragFraction)
        : widget.value.clamp(widget.min, widget.max);

    final labelSize = compact ? 10.0 : 11.0;
    final rowHeight = compact ? 44.0 : 48.0;

    final refLabelStyle = textStyles
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
                painter: _ContinuousSliderPainter(
                  tickCount: tickCount,
                  tickLabels: tickLabels,
                  displayFraction: displayFraction,
                  valueLabel: format(displayValue),
                  primaryColor: colors.primary,
                  inactiveColor: colors.border.withValues(alpha: 0.85),
                  refLabelStyle: refLabelStyle,
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

class _ContinuousSliderPainter extends CustomPainter {
  _ContinuousSliderPainter({
    required this.tickCount,
    required this.tickLabels,
    required this.displayFraction,
    required this.valueLabel,
    required this.primaryColor,
    required this.inactiveColor,
    required this.refLabelStyle,
    required this.valueLabelStyle,
    required this.compact,
  });

  final int tickCount;
  final List<String> tickLabels;
  final double displayFraction; // 0..1
  final String valueLabel;
  final Color primaryColor;
  final Color inactiveColor;
  final TextStyle refLabelStyle;
  final TextStyle valueLabelStyle;
  final bool compact;

  @override
  void paint(Canvas canvas, Size size) {
    final n = tickCount;
    if (n == 0) return;

    final tickHeight = compact ? 8.0 : 10.0;
    const tickWidth = 2.0;
    final gap = compact ? 3.0 : 4.0;
    final circleD = compact ? 6.0 : 7.0;
    const pad = TermosFloatingSlider.edgePad;
    final usable = size.width - 2 * pad;

    // ── Measure text heights ────────────────────────────────────────────

    final sampleRef = TextPainter(
      text: TextSpan(text: '0', style: refLabelStyle),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    final refLabelH = sampleRef.height;

    final valueTp = TextPainter(
      text: TextSpan(text: valueLabel, style: valueLabelStyle),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    final valueLabelH = valueTp.height;

    // ── Y layout (bottom-up) ────────────────────────────────────────────

    final refLabelTop = size.height - refLabelH;
    final tickBottom = refLabelTop - gap;
    final tickCenterY = tickBottom - tickHeight / 2;
    final valueLabelBottom = tickBottom - tickHeight - 2;

    // ── Notch / indicator X ─────────────────────────────────────────────

    double notchX(int i) {
      if (n <= 1) return size.width / 2;
      return pad + i * usable / (n - 1);
    }

    final indicatorX = n > 1 ? pad + displayFraction * usable : size.width / 2;

    // ── Draw reference ticks (all muted) ────────────────────────────────

    final tickPaint = Paint()..color = inactiveColor;

    for (int i = 0; i < n; i++) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(notchX(i), tickCenterY),
            width: tickWidth,
            height: tickHeight,
          ),
          const Radius.circular(1),
        ),
        tickPaint,
      );
    }

    // ── Draw circle indicator ───────────────────────────────────────────

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(indicatorX, tickCenterY),
        width: circleD,
        height: circleD,
      ),
      Paint()..color = primaryColor,
    );

    // ── Draw floating value label ───────────────────────────────────────

    valueTp.layout();
    var vlX = indicatorX - valueTp.width / 2;
    if (vlX < 0) vlX = 0;
    final maxVlX = size.width - valueTp.width;
    if (maxVlX > 0 && vlX > maxVlX) vlX = maxVlX;
    valueTp.paint(canvas, Offset(vlX, valueLabelBottom - valueLabelH));

    // ── Draw reference labels (all muted) ───────────────────────────────

    for (int i = 0; i < n; i++) {
      final cx = notchX(i);
      final tp = TextPainter(
        text: TextSpan(text: tickLabels[i], style: refLabelStyle),
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )..layout(maxWidth: size.width);

      var labelX = cx - tp.width / 2;
      if (labelX < 0) labelX = 0;
      final maxLabelX = size.width - tp.width;
      if (maxLabelX > 0 && labelX > maxLabelX) labelX = maxLabelX;
      tp.paint(canvas, Offset(labelX, refLabelTop));
    }
  }

  @override
  bool shouldRepaint(covariant _ContinuousSliderPainter old) {
    return displayFraction != old.displayFraction ||
        valueLabel != old.valueLabel ||
        primaryColor != old.primaryColor ||
        tickLabels != old.tickLabels;
  }
}
