import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/termos_metrics.dart';
import '../theme/termos_theme.dart';

/// Drum wheel time picker with CRT-style band and scanline overlay.
///
/// Layout from [TermosThemeData.metrics]; band, scanlines, and colon pulse from
/// [TermosThemeData.timePicker].
class TermosTimePicker extends StatefulWidget {
  const TermosTimePicker({
    super.key,
    required this.time,
    required this.onTimeChanged,
    this.commitDebounce,
    this.minuteStep = 15,
  });

  final TimeOfDay time;
  final ValueChanged<TimeOfDay> onTimeChanged;
  final Duration? commitDebounce;

  /// Minute increment (must divide 60). Default 15.
  final int minuteStep;

  @override
  State<TermosTimePicker> createState() => _TermosTimePickerState();
}

class _TermosTimePickerState extends State<TermosTimePicker>
    with SingleTickerProviderStateMixin {
  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;
  late AnimationController _pulseController;

  int _selectedHour = 0;
  int _selectedMinute = 0;
  Timer? _commitDebounceTimer;

  int get _minuteSlotCount => 60 ~/ widget.minuteStep;

  @override
  void initState() {
    super.initState();
    assert(
      widget.minuteStep > 0 && 60 % widget.minuteStep == 0,
      'minuteStep must be positive and divide 60 evenly',
    );
    _selectedHour = widget.time.hour;
    _selectedMinute = _roundToStep(widget.time.minute);
    _hourController = FixedExtentScrollController(initialItem: _selectedHour);
    _minuteController = FixedExtentScrollController(
      initialItem: _selectedMinute ~/ widget.minuteStep,
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: TermosMetrics.standard.timePickerPulseAnimationMs),
    )..repeat(reverse: true);
  }

  @override
  void didUpdateWidget(TermosTimePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.time != widget.time) {
      _selectedHour = widget.time.hour;
      _selectedMinute = _roundToStep(widget.time.minute);
      if (_hourController.selectedItem % 24 != _selectedHour) {
        _hourController.jumpToItem(_selectedHour);
      }
      final minuteSlot = _selectedMinute ~/ widget.minuteStep;
      if (_minuteController.selectedItem % _minuteSlotCount != minuteSlot) {
        _minuteController.jumpToItem(minuteSlot);
      }
    }
  }

  void _emitTimeChanged(TimeOfDay next) {
    final debounce = widget.commitDebounce;
    if (debounce == null) {
      widget.onTimeChanged(next);
      return;
    }
    _commitDebounceTimer?.cancel();
    _commitDebounceTimer = Timer(debounce, () {
      widget.onTimeChanged(next);
    });
  }

  @override
  void dispose() {
    _commitDebounceTimer?.cancel();
    _hourController.dispose();
    _minuteController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  int _roundToStep(int minute) =>
      (minute / widget.minuteStep).round() * widget.minuteStep % 60;

  Widget _buildWheel({
    required FixedExtentScrollController controller,
    required List<int> values,
    required ValueChanged<int> onChanged,
    required double width,
    required double itemExtent,
    required int visibleItems,
    required double wheelFontSize,
  }) {
    final termos = TermosTheme.of(context);
    final colors = termos.colors;
    final textStyles = termos.textStyles;
    return SizedBox(
      width: width,
      height: itemExtent * visibleItems,
      child: ListWheelScrollView.useDelegate(
        controller: controller,
        itemExtent: itemExtent,
        perspective: 0.003,
        diameterRatio: 1.5,
        overAndUnderCenterOpacity: 0.2,
        physics: const FixedExtentScrollPhysics(),
        onSelectedItemChanged: (index) {
          final normalized =
              ((index % values.length) + values.length) % values.length;
          onChanged(values[normalized]);
        },
        childDelegate: ListWheelChildLoopingListDelegate(
          children: values.map((v) {
            return Center(
              child: Text(
                v.toString().padLeft(2, '0'),
                style: textStyles.timePickerWheel(
                  colors.textPrimary,
                  fontSize: wheelFontSize,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final termos = TermosTheme.of(context);
    final colors = termos.colors;
    final metrics = termos.metrics;
    final tp = termos.timePicker;

    final itemExtent = metrics.timePickerItemExtent;
    final visibleItems = metrics.timePickerVisibleItems;
    final totalHeight = itemExtent * visibleItems;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final scanlineOpacity =
        isLight ? tp.scanlineOpacityLight : tp.scanlineOpacityDark;
    final borderRadius = metrics.borderRadius;
    final innerClipRadius = (metrics.borderRadius - 1).clamp(0.0, double.infinity);

    final semanticTime =
        '${_selectedHour.toString().padLeft(2, '0')}:${_selectedMinute.toString().padLeft(2, '0')}';
    return Semantics(
      label: 'Time picker',
      value: semanticTime,
      child: Container(
      height: totalHeight,
      decoration: BoxDecoration(
        color: isLight ? colors.card : colors.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: colors.border),
      ),
      child: Stack(
        children: [
          Center(
            child: SizedBox(
              height: itemExtent,
              width: double.infinity,
              child: CustomPaint(
                painter: _SelectionBandPainter(
                  glowColor: colors.primary,
                  isLight: isLight,
                  bgAlphaLight: tp.selectionBandBgAlphaLight,
                  bgAlphaDark: tp.selectionBandBgAlphaDark,
                  glowAlphaLight: tp.selectionBandGlowAlphaLight,
                  glowAlphaDark: tp.selectionBandGlowAlphaDark,
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildWheel(
                controller: _hourController,
                values: List.generate(24, (i) => i),
                onChanged: (hour) {
                  _selectedHour = hour;
                  _emitTimeChanged(
                    TimeOfDay(hour: hour, minute: _selectedMinute),
                  );
                },
                width: metrics.timePickerWheelWidth,
                itemExtent: itemExtent,
                visibleItems: visibleItems,
                wheelFontSize: tp.wheelFontSize,
              ),
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, _) {
                  final opacity = tp.colonPulseOpacityMin +
                      _pulseController.value *
                          (tp.colonPulseOpacityMax - tp.colonPulseOpacityMin);
                  return Text(
                    ':',
                    style: termos.textStyles.timePickerColon(
                      colors.primary.withValues(alpha: opacity),
                      fontSize: tp.colonFontSize,
                    ),
                  );
                },
              ),
              _buildWheel(
                controller: _minuteController,
                values: List.generate(
                  _minuteSlotCount,
                  (i) => i * widget.minuteStep,
                ),
                onChanged: (minute) {
                  _selectedMinute = minute;
                  _emitTimeChanged(
                    TimeOfDay(hour: _selectedHour, minute: minute),
                  );
                },
                width: metrics.timePickerWheelWidth,
                itemExtent: itemExtent,
                visibleItems: visibleItems,
                wheelFontSize: tp.wheelFontSize,
              ),
            ],
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(innerClipRadius),
                child: CustomPaint(
                  painter: _ScanlineOverlayPainter(
                    opacity: scanlineOpacity,
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(innerClipRadius),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        (isLight ? colors.card : colors.surface),
                        (isLight ? colors.card : colors.surface).withValues(alpha: 0),
                        (isLight ? colors.card : colors.surface).withValues(alpha: 0),
                        (isLight ? colors.card : colors.surface),
                      ],
                      stops: const [0.0, 0.15, 0.85, 1.0],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ));
  }
}

class _SelectionBandPainter extends CustomPainter {
  _SelectionBandPainter({
    required this.glowColor,
    required this.isLight,
    required this.bgAlphaLight,
    required this.bgAlphaDark,
    required this.glowAlphaLight,
    required this.glowAlphaDark,
  });

  final Color glowColor;
  final bool isLight;
  final double bgAlphaLight;
  final double bgAlphaDark;
  final double glowAlphaLight;
  final double glowAlphaDark;

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()
      ..color = glowColor.withValues(alpha: isLight ? bgAlphaLight : bgAlphaDark);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final shaderRect = Rect.fromLTWH(0, 0, size.width, size.height);

    void drawGlowLine(double y) {
      final effGlow = glowColor.withValues(alpha: isLight ? glowAlphaLight : glowAlphaDark);
      final effBase = glowColor.withValues(alpha: 0);

      final glowPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3)
        ..shader = LinearGradient(
          colors: [effBase, effGlow, effGlow, effBase],
          stops: const [0.0, 0.3, 0.7, 1.0],
        ).createShader(shaderRect);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), glowPaint);

      final linePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5
        ..shader = LinearGradient(
          colors: [effBase, effGlow, effGlow, effBase],
          stops: const [0.1, 0.35, 0.65, 0.9],
        ).createShader(shaderRect);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    drawGlowLine(0);
    drawGlowLine(size.height);
  }

  @override
  bool shouldRepaint(_SelectionBandPainter old) =>
      glowColor != old.glowColor ||
      isLight != old.isLight ||
      bgAlphaLight != old.bgAlphaLight ||
      bgAlphaDark != old.bgAlphaDark ||
      glowAlphaLight != old.glowAlphaLight ||
      glowAlphaDark != old.glowAlphaDark;
}

class _ScanlineOverlayPainter extends CustomPainter {
  _ScanlineOverlayPainter({required this.opacity});
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0) return;
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: opacity)
      ..strokeWidth = 1;
    for (var y = 0.0; y < size.height; y += 2) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_ScanlineOverlayPainter old) => opacity != old.opacity;
}
