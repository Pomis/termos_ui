import 'package:flutter/material.dart';

import 'termos_floating_slider.dart';

/// Discrete tick strip with drag support: equal-spaced notches with labels.
/// At most [kMaxDiscreteSteps] positions — use [evenStep] when you want evenly
/// spaced values from [start] to [end].
///
/// Delegates rendering to [TermosFloatingSlider] so all sliders share the same
/// draggable tick-strip appearance with morphing indicator.
class TermosSlider extends StatelessWidget {
  const TermosSlider({
    super.key,
    required this.value,
    required this.start,
    required this.end,
    required this.step,
    required this.onChanged,
    this.compact = true,
    this.formatValue,
  });

  /// Maximum number of discrete positions (inclusive of endpoints when step fits).
  static const int kMaxDiscreteSteps = 10;

  final double value;
  final double start;
  final double end;
  final double step;
  final ValueChanged<double> onChanged;
  final bool compact;

  /// Override label under each tick (defaults to [defaultFormatValue]).
  final String Function(double value)? formatValue;

  /// Step size for exactly [maxSteps] evenly spaced values from [start] to [end] inclusive.
  /// [maxSteps] is the number of discrete **positions** (including both endpoints).
  /// For the tick-strip [TermosSlider], positions are capped by [kMaxDiscreteSteps];
  /// [evenStep] itself allows larger [maxSteps] for computing step size used elsewhere.
  static double evenStep(
    double start,
    double end, {
    int maxSteps = kMaxDiscreteSteps,
  }) {
    assert(maxSteps >= 2);
    assert(end >= start);
    if (start == end) return 1.0;
    return (end - start) / (maxSteps - 1);
  }

  /// Snaps [value] to the nearest discrete position for the given range.
  static double snap(double value, double start, double end, double step) {
    final positions = discreteValues(start: start, end: end, step: step);
    if (positions.isEmpty) return value.clamp(start, end);
    double nearest = positions.first;
    double bestDist = (value - nearest).abs();
    for (final candidate in positions) {
      final dist = (value - candidate).abs();
      if (dist < bestDist) {
        bestDist = dist;
        nearest = candidate;
      }
    }
    return nearest;
  }

  /// Values that [TermosSlider] will render (length ≤ [kMaxDiscreteSteps]).
  static List<double> discreteValues({
    required double start,
    required double end,
    required double step,
  }) {
    return _discreteValues(start: start, end: end, step: step);
  }

  static String defaultFormatValue(double value) {
    if (!value.isFinite) return '';
    if ((value - value.round()).abs() < 1e-6) return value.round().toString();
    if ((value * 10 - (value * 10).round()).abs() < 1e-5) {
      return value.toStringAsFixed(1);
    }
    return value.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final positions = _discreteValues(start: start, end: end, step: step);
    final n = positions.length;
    final snapped = snap(value, start, end, step);

    return TermosFloatingSlider(
      value: snapped,
      min: positions.first,
      max: n > 1 ? positions.last : positions.first,
      divisions: n > 1 ? n - 1 : null,
      compact: compact,
      formatValue: formatValue,
      onChanged: onChanged,
    );
  }
}

List<double> _discreteValues({
  required double start,
  required double end,
  required double step,
}) {
  if (start == end) {
    return [start];
  }
  assert(step > 0, 'TermosSlider: step must be positive when start != end');
  assert(end >= start);

  final values = <double>[];
  for (int i = 0; i < TermosSlider.kMaxDiscreteSteps; i++) {
    final next = start + i * step;
    if (next > end + 1e-9) break;
    values.add(next);
  }
  assert(values.isNotEmpty, 'TermosSlider: no discrete values');

  assert(
    values.length <= TermosSlider.kMaxDiscreteSteps,
    'TermosSlider: step too small — more than ${TermosSlider.kMaxDiscreteSteps} values before end',
  );

  return values;
}
