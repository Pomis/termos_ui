import 'dart:async';

import 'package:flutter/material.dart';

import '../theme/termos_theme.dart';
import 'loader_random_config.dart';
import 'termos_comet_circular_progress.dart';

/// Minimum size to use the comet animation. Below this, uses [CircularProgressIndicator].
const double _cometMinSize = 80;

/// Matches comet per-dot exit phase (~280ms) plus a small buffer before remount.
const int _cometExitSwapDelayMs = 320;

/// Loading spinner: small sizes use Material circular progress; large sizes use comet animation.
///
/// When [transitionKey] changes, the comet clears its heads so dots run their **exit** phase,
/// then a new comet instance mounts and plays **enter** — no cross-fade overlay.
class TermosLoadingIndicator extends StatefulWidget {
  const TermosLoadingIndicator({
    super.key,
    this.size = 24,
    this.color,
    this.backgroundColor,
    this.excludedPersonas,
    this.transitionKey,
  });

  final double size;
  final Color? color;
  final Color? backgroundColor;
  final Set<LoaderPersona>? excludedPersonas;

  /// Bump when the loader identity should change (exit animation, then new enter).
  final Object? transitionKey;

  @override
  State<TermosLoadingIndicator> createState() => _TermosLoadingIndicatorState();
}

class _TermosLoadingIndicatorState extends State<TermosLoadingIndicator> {
  LoaderRandomConfig? _config;
  bool? _configIsLight;

  Object? _displayedTransitionKey;
  bool _suppressCometTargets = false;
  Timer? _swapTimer;

  @override
  void initState() {
    super.initState();
    _displayedTransitionKey = widget.transitionKey;
  }

  @override
  void didUpdateWidget(TermosLoadingIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.transitionKey == null) {
      if (oldWidget.transitionKey != null) {
        _swapTimer?.cancel();
        _swapTimer = null;
        _suppressCometTargets = false;
        _displayedTransitionKey = null;
      }
      if (oldWidget.transitionKey != widget.transitionKey) {
        _config = null;
      }
      return;
    }

    if (widget.size >= _cometMinSize &&
        oldWidget.transitionKey == null &&
        widget.transitionKey != null) {
      _displayedTransitionKey = widget.transitionKey;
      _config = null;
      return;
    }

    if (widget.size < _cometMinSize) {
      if (oldWidget.transitionKey != widget.transitionKey) {
        _config = null;
      }
      return;
    }

    if (oldWidget.transitionKey != null &&
        widget.transitionKey != null &&
        oldWidget.transitionKey != widget.transitionKey) {
      _swapTimer?.cancel();
      _suppressCometTargets = true;
      _swapTimer = Timer(const Duration(milliseconds: _cometExitSwapDelayMs), () {
        if (!mounted) return;
        setState(() {
          _displayedTransitionKey = widget.transitionKey;
          _config = null;
          _suppressCometTargets = false;
          _swapTimer = null;
        });
      });
    }
  }

  @override
  void dispose() {
    _swapTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryFallback = TermosTheme.of(context).colors.primary;

    if (widget.size < _cometMinSize) {
      final indicator = SizedBox(
        width: widget.size,
        height: widget.size,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: widget.color ?? primaryFallback,
        ),
      );
      if (widget.transitionKey != null) {
        return KeyedSubtree(
          key: ValueKey(widget.transitionKey),
          child: indicator,
        );
      }
      return indicator;
    }

    final comet = _buildComet(context, primaryFallback);

    if (widget.transitionKey == null) {
      return comet;
    }

    return KeyedSubtree(
      key: ValueKey(_displayedTransitionKey),
      child: comet,
    );
  }

  Widget _buildComet(BuildContext context, Color primaryFallback) {
    final isLightBackground = Theme.of(context).brightness == Brightness.light;
    if (_config == null || _configIsLight != isLightBackground) {
      _configIsLight = isLightBackground;
      _config = generateRandomLoaderConfig(
        preferredColor: widget.color,
        excludedPersonas: widget.excludedPersonas,
        isLightBackground: isLightBackground,
      );
    }
    final config = _config!;
    final scale = widget.size / 100;
    final gridSpacing = (12.0 * scale).clamp(4.0, 16.0);

    final bgColor =
        widget.backgroundColor ?? Theme.of(context).scaffoldBackgroundColor;
    final velocityScale = isLightBackground ? 0.7 : 1.0;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: TermosCometCircularProgress(
        color: config.color,
        backgroundColor: bgColor,
        strokeWidth: 4.0,
        gridSpacing: gridSpacing,
        objectCount: config.objectCount,
        dotSize: config.dotSize * scale,
        trailLength: config.trailLength,
        trailSpacing: config.trailSpacing,
        perturbAmplitude: config.perturbAmplitude * scale,
        perturbFrequency: config.perturbFrequency,
        velocityMultiplier: config.velocityMultiplier,
        velocityScale: velocityScale,
        glowBlurRadius: config.glowBlurRadius * scale,
        glowOpacity: config.glowOpacity,
        reactiveRadius: config.reactiveRadius * scale,
        orbitEccentricity: config.orbitEccentricity,
        perihelionGlow: config.perihelionGlow,
        tailCurvature: config.tailCurvature,
        velocityWarp: config.velocityWarp,
        precessionRate: config.precessionRate,
        orbitalInclination: config.orbitalInclination,
        intensityTransitionDurationMs: config.intensityTransitionDurationMs,
        suppressCometTargets: _suppressCometTargets,
      ),
    );
  }
}
