import 'dart:math';

import 'package:flutter/material.dart';

/// Named presets for the comet loader animation.
enum LoaderPersona {
  calm,
  energetic,
  energeticRush,
  energeticDance,
  cosmic,
  minimal,
  liked,
}

class _PersonaRanges {
  const _PersonaRanges({
    required this.objectCount,
    required this.dotSize,
    required this.trailLength,
    required this.trailSpacing,
    required this.perturbAmplitude,
    required this.perturbFrequency,
    required this.velocityMultiplier,
    required this.glowBlurRadius,
    required this.glowOpacity,
    required this.reactiveRadius,
    required this.orbitEccentricity,
    required this.perihelionGlow,
    required this.tailCurvature,
    required this.velocityWarp,
    required this.precessionRate,
    required this.orbitalInclination,
    required this.intensityTransitionMs,
    required this.colorIndices,
  });

  final RangeValues objectCount;
  final RangeValues dotSize;
  final RangeValues trailLength;
  final RangeValues trailSpacing;
  final RangeValues perturbAmplitude;
  final RangeValues perturbFrequency;
  final RangeValues velocityMultiplier;
  final RangeValues glowBlurRadius;
  final RangeValues glowOpacity;
  final RangeValues reactiveRadius;
  final RangeValues orbitEccentricity;
  final RangeValues perihelionGlow;
  final RangeValues tailCurvature;
  final RangeValues velocityWarp;
  final RangeValues precessionRate;
  final RangeValues orbitalInclination;
  final RangeValues intensityTransitionMs;
  final RangeValues colorIndices;
}

const List<_PersonaRanges> _personas = [
  _PersonaRanges(
    objectCount: RangeValues(1, 2),
    dotSize: RangeValues(4.0, 6.5),
    trailLength: RangeValues(2, 3),
    trailSpacing: RangeValues(0.14, 0.30),
    perturbAmplitude: RangeValues(0.0, 10.0),
    perturbFrequency: RangeValues(2.0, 5.0),
    velocityMultiplier: RangeValues(1.4, 2.2),
    glowBlurRadius: RangeValues(3.0, 6.0),
    glowOpacity: RangeValues(0.50, 0.85),
    reactiveRadius: RangeValues(0.0, 8.0),
    orbitEccentricity: RangeValues(0.0, 0.20),
    perihelionGlow: RangeValues(0.0, 0.40),
    tailCurvature: RangeValues(0.0, 0.50),
    velocityWarp: RangeValues(0.0, 0.08),
    precessionRate: RangeValues(0.0, 0.06),
    orbitalInclination: RangeValues(0.0, 0.12),
    intensityTransitionMs: RangeValues(100, 200),
    colorIndices: RangeValues(0, 9),
  ),
  _PersonaRanges(
    objectCount: RangeValues(3, 4),
    dotSize: RangeValues(5.0, 7.5),
    trailLength: RangeValues(3, 4),
    trailSpacing: RangeValues(0.20, 0.40),
    perturbAmplitude: RangeValues(5.0, 20.0),
    perturbFrequency: RangeValues(5.0, 7.5),
    velocityMultiplier: RangeValues(2.4, 3.2),
    glowBlurRadius: RangeValues(4.0, 8.0),
    glowOpacity: RangeValues(0.60, 1.00),
    reactiveRadius: RangeValues(10.0, 20.0),
    orbitEccentricity: RangeValues(0.10, 0.30),
    perihelionGlow: RangeValues(0.20, 0.60),
    tailCurvature: RangeValues(0.10, 0.50),
    velocityWarp: RangeValues(0.10, 0.17),
    precessionRate: RangeValues(0.08, 0.14),
    orbitalInclination: RangeValues(0.08, 0.17),
    intensityTransitionMs: RangeValues(120, 250),
    colorIndices: RangeValues(0, 9),
  ),
  _PersonaRanges(
    objectCount: RangeValues(3, 4),
    dotSize: RangeValues(5.0, 6.5),
    trailLength: RangeValues(2, 3),
    trailSpacing: RangeValues(0.14, 0.25),
    perturbAmplitude: RangeValues(8.0, 18.0),
    perturbFrequency: RangeValues(6.0, 7.5),
    velocityMultiplier: RangeValues(2.8, 3.2),
    glowBlurRadius: RangeValues(5.0, 8.0),
    glowOpacity: RangeValues(0.75, 1.00),
    reactiveRadius: RangeValues(12.0, 20.0),
    orbitEccentricity: RangeValues(0.15, 0.30),
    perihelionGlow: RangeValues(0.30, 0.60),
    tailCurvature: RangeValues(0.0, 0.30),
    velocityWarp: RangeValues(0.12, 0.17),
    precessionRate: RangeValues(0.0, 0.06),
    orbitalInclination: RangeValues(0.0, 0.08),
    intensityTransitionMs: RangeValues(100, 150),
    colorIndices: RangeValues(0, 9),
  ),
  _PersonaRanges(
    objectCount: RangeValues(3, 4),
    dotSize: RangeValues(5.5, 7.5),
    trailLength: RangeValues(4, 5),
    trailSpacing: RangeValues(0.22, 0.40),
    perturbAmplitude: RangeValues(10.0, 20.0),
    perturbFrequency: RangeValues(5.0, 7.5),
    velocityMultiplier: RangeValues(2.4, 3.0),
    glowBlurRadius: RangeValues(5.0, 8.0),
    glowOpacity: RangeValues(0.70, 1.00),
    reactiveRadius: RangeValues(14.0, 20.0),
    orbitEccentricity: RangeValues(0.12, 0.28),
    perihelionGlow: RangeValues(0.25, 0.60),
    tailCurvature: RangeValues(0.20, 0.60),
    velocityWarp: RangeValues(0.10, 0.17),
    precessionRate: RangeValues(0.10, 0.14),
    orbitalInclination: RangeValues(0.10, 0.17),
    intensityTransitionMs: RangeValues(150, 280),
    colorIndices: RangeValues(0, 9),
  ),
  _PersonaRanges(
    objectCount: RangeValues(1, 4),
    dotSize: RangeValues(4.0, 7.5),
    trailLength: RangeValues(2, 4),
    trailSpacing: RangeValues(0.14, 0.40),
    perturbAmplitude: RangeValues(0.0, 20.0),
    perturbFrequency: RangeValues(0.0, 7.5),
    velocityMultiplier: RangeValues(1.40, 3.20),
    glowBlurRadius: RangeValues(3.0, 8.0),
    glowOpacity: RangeValues(0.50, 1.00),
    reactiveRadius: RangeValues(0.0, 20.0),
    orbitEccentricity: RangeValues(0.15, 0.30),
    perihelionGlow: RangeValues(0.30, 0.60),
    tailCurvature: RangeValues(0.0, 1.0),
    velocityWarp: RangeValues(0.08, 0.17),
    precessionRate: RangeValues(0.06, 0.14),
    orbitalInclination: RangeValues(0.0, 0.17),
    intensityTransitionMs: RangeValues(100, 300),
    colorIndices: RangeValues(0, 9),
  ),
  _PersonaRanges(
    objectCount: RangeValues(1, 2),
    dotSize: RangeValues(4.0, 7.5),
    trailLength: RangeValues(2, 3),
    trailSpacing: RangeValues(0.14, 0.28),
    perturbAmplitude: RangeValues(0.0, 8.0),
    perturbFrequency: RangeValues(3.0, 6.0),
    velocityMultiplier: RangeValues(1.6, 2.5),
    glowBlurRadius: RangeValues(3.0, 8.0),
    glowOpacity: RangeValues(0.50, 1.00),
    reactiveRadius: RangeValues(0.0, 20.0),
    orbitEccentricity: RangeValues(0.0, 0.30),
    perihelionGlow: RangeValues(0.0, 0.60),
    tailCurvature: RangeValues(0.0, 1.0),
    velocityWarp: RangeValues(0.0, 0.17),
    precessionRate: RangeValues(0.0, 0.14),
    orbitalInclination: RangeValues(0.0, 0.17),
    intensityTransitionMs: RangeValues(100, 300),
    colorIndices: RangeValues(0, 9),
  ),
  _PersonaRanges(
    objectCount: RangeValues(1, 4),
    dotSize: RangeValues(4.0, 7.5),
    trailLength: RangeValues(2, 4),
    trailSpacing: RangeValues(0.15, 0.40),
    perturbAmplitude: RangeValues(0.25, 20.0),
    perturbFrequency: RangeValues(0.07, 7.5),
    velocityMultiplier: RangeValues(1.40, 3.17),
    glowBlurRadius: RangeValues(3.0, 8.0),
    glowOpacity: RangeValues(0.50, 1.00),
    reactiveRadius: RangeValues(0.0, 20.0),
    orbitEccentricity: RangeValues(0.0, 0.30),
    perihelionGlow: RangeValues(0.05, 0.60),
    tailCurvature: RangeValues(0.07, 1.00),
    velocityWarp: RangeValues(0.01, 0.17),
    precessionRate: RangeValues(0.0, 0.14),
    orbitalInclination: RangeValues(0.0, 0.17),
    intensityTransitionMs: RangeValues(100, 300),
    colorIndices: RangeValues(0, 9),
  ),
];

const List<Color> _presetColors = [
  Color(0xFF00FF00),
  Color(0xFF3B82F6),
  Color(0xFFEF4444),
  Color(0xFFF59E0B),
  Color(0xFF8B5CF6),
  Color(0xFF06B6D4),
  Color(0xFFEC4899),
  Color(0xFF10B981),
  Color(0xFFF97316),
  Color(0xFFFFFFFF),
];

const List<Color> _lightPresetColors = [
  Color(0xFF16A34A),
  Color(0xFF0D9488),
  Color(0xFF2563EB),
  Color(0xFFDC2626),
  Color(0xFFEA580C),
  Color(0xFF7C3AED),
  Color(0xFFDB2777),
  Color(0xFF15803D),
];

/// Configuration for [TermosCometCircularProgress].
class LoaderRandomConfig {
  const LoaderRandomConfig({
    required this.objectCount,
    required this.dotSize,
    required this.trailLength,
    required this.trailSpacing,
    required this.perturbAmplitude,
    required this.perturbFrequency,
    required this.velocityMultiplier,
    required this.glowBlurRadius,
    required this.glowOpacity,
    required this.reactiveRadius,
    required this.orbitEccentricity,
    required this.perihelionGlow,
    required this.tailCurvature,
    required this.velocityWarp,
    required this.precessionRate,
    required this.orbitalInclination,
    required this.intensityTransitionDurationMs,
    required this.color,
  });

  final int objectCount;
  final double dotSize;
  final int trailLength;
  final double trailSpacing;
  final double perturbAmplitude;
  final double perturbFrequency;
  final double velocityMultiplier;
  final double glowBlurRadius;
  final double glowOpacity;
  final double reactiveRadius;
  final double orbitEccentricity;
  final double perihelionGlow;
  final double tailCurvature;
  final double velocityWarp;
  final double precessionRate;
  final double orbitalInclination;
  final int intensityTransitionDurationMs;
  final Color color;
}

final Random _random = Random();

double _inRange(RangeValues r) =>
    r.start + _random.nextDouble() * (r.end - r.start);

int _inRangeInt(RangeValues r) =>
    r.start.toInt() + _random.nextInt((r.end - r.start).toInt() + 1);

/// Generates a random loader config for the comet animation.
LoaderRandomConfig generateRandomLoaderConfig({
  Color? preferredColor,
  Set<LoaderPersona>? excludedPersonas,
  bool isLightBackground = false,
}) {
  final excluded = excludedPersonas;
  final allowedIndices = excluded != null && excluded.isNotEmpty
      ? List.generate(_personas.length, (i) => i)
          .where((i) => !excluded.contains(LoaderPersona.values[i]))
          .toList()
      : null;
  final personaIndex = allowedIndices != null && allowedIndices.isNotEmpty
      ? allowedIndices[_random.nextInt(allowedIndices.length)]
      : _random.nextInt(_personas.length);
  final persona = _personas[personaIndex];

  final palette = isLightBackground ? _lightPresetColors : _presetColors;
  final colorIdx = _inRangeInt(persona.colorIndices).clamp(0, palette.length - 1);
  final color = preferredColor ?? palette[colorIdx];

  return LoaderRandomConfig(
    objectCount: _inRangeInt(persona.objectCount).clamp(1, 4),
    dotSize: _inRange(persona.dotSize).clamp(1.0, 8.0),
    trailLength: _inRangeInt(persona.trailLength).clamp(1, 5),
    trailSpacing: _inRange(persona.trailSpacing).clamp(0.02, 0.5),
    perturbAmplitude: _inRange(persona.perturbAmplitude).clamp(0.0, 20.0),
    perturbFrequency: _inRange(persona.perturbFrequency).clamp(0.0, 10.0),
    velocityMultiplier: _inRange(persona.velocityMultiplier).clamp(0.2, 5.0),
    glowBlurRadius: _inRange(persona.glowBlurRadius).clamp(0.0, 8.0),
    glowOpacity: _inRange(persona.glowOpacity).clamp(0.1, 1.0),
    reactiveRadius: _inRange(persona.reactiveRadius).clamp(0.0, 50.0),
    orbitEccentricity: _inRange(persona.orbitEccentricity).clamp(0.0, 0.4),
    perihelionGlow: _inRange(persona.perihelionGlow).clamp(0.0, 0.6),
    tailCurvature: _inRange(persona.tailCurvature).clamp(0.0, 1.0),
    velocityWarp: _inRange(persona.velocityWarp).clamp(0.0, 0.25),
    precessionRate: _inRange(persona.precessionRate).clamp(0.0, 0.15),
    orbitalInclination: _inRange(persona.orbitalInclination).clamp(0.0, 0.25),
    intensityTransitionDurationMs:
        _inRangeInt(persona.intensityTransitionMs).clamp(100, 500),
    color: color,
  );
}
