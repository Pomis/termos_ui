import 'package:flutter/material.dart';

/// Horizontal scanlines (CRT-style overlay).
class ScanlinesPainter extends CustomPainter {
  ScanlinesPainter({this.opacity = 0.06});

  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: opacity)
      ..strokeWidth = 1;

    for (var y = 0.0; y < size.height; y += 2) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(ScanlinesPainter old) => opacity != old.opacity;
}
