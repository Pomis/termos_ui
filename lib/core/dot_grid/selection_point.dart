import 'package:flutter/material.dart';

/// A colored influence point for mesh / starfield glow (e.g. flags, placeholders).
class SelectionPoint {
  const SelectionPoint({
    required this.position,
    required this.color,
    this.radiusMultiplier = 1.0,
  });

  final Offset position;
  final Color color;
  final double radiusMultiplier;
}
