import 'package:flutter/material.dart';

import '../core/termos_aligned_builder.dart';
import '../core/termos_tap_target.dart';
import '../painters/reactive_starfield_painter.dart';
import '../theme/termos_theme.dart';

/// Terminal-style back control for app bars (dot grid mesh + starfield when heavy effects on).
class TermosBackButton extends StatelessWidget {
  const TermosBackButton({
    super.key,
    required this.onTap,
    this.size,
    this.child,
    this.padding,
  });

  final VoidCallback onTap;

  /// Defaults to [TermosMetrics.backButtonDefaultSize].
  final double? size;

  /// Visual content. When null, uses the platform-adaptive [BackButtonIcon]
  /// (Material arrow on Android, Cupertino chevron on iOS) with
  /// [TermosMetrics.backButtonIconSize] and theme primary color.
  final Widget? child;

  /// Inner padding around the glyph. Defaults to
  /// [TermosMetrics.backButtonPadding] when null.
  final EdgeInsetsGeometry? padding;

  static const _seed = 0x6261636B; // "back"

  @override
  Widget build(BuildContext context) {
    final termos = TermosTheme.of(context);
    final useHeavy = termos.heavyEffectsEnabled;
    final colors = termos.colors;
    final dg = termos.dotGrid;
    final metrics = termos.metrics;
    final starfield = termos.starfield;
    final isLight = Theme.of(context).brightness == Brightness.light;

    final effectiveSize = size ?? metrics.backButtonDefaultSize;

    final Widget glyph = child ??
        IconTheme(
          data: IconThemeData(color: colors.primary, size: metrics.backButtonIconSize),
          child: const BackButtonIcon(),
        );

    final content = Padding(
      padding: padding ?? metrics.backButtonPadding,
      child: Align(
        alignment: Alignment.center,
        child: glyph,
      ),
    );

    final tapTarget = TermosTapTarget(
      onTap: onTap,
      borderRadius: BorderRadius.circular(metrics.borderRadius),
      blobRadius: dg.blobRadius,
      primaryColor: colors.primary,
      idleMeshColor: colors.dotGridIdleMesh,
      dotSize: dg.dotSize,
      gridSpacing: dg.spacing,
      child: content,
    );

    final decorated = Container(
      decoration: BoxDecoration(
        color: Color.lerp(colors.background, colors.card, metrics.backButtonBackgroundBlend)!,
        borderRadius: BorderRadius.circular(metrics.borderRadius),
        border: Border.all(color: colors.dotGridButtonBorder),
      ),
      child: useHeavy
          ? Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(metrics.borderRadius),
                  child: TermosAlignedBuilder(
                    builder: (gridOffset) => CustomPaint(
                      painter: ReactiveStarfieldPainter(
                        dotSize: dg.dotSize,
                        gridSpacing: dg.spacing,
                        glowPosition: starfield.glowPositionBackButton,
                        glowColor: colors.primary,
                        intensity: isLight
                            ? starfield.intensityBackButtonLight
                            : starfield.intensityBackButtonDark,
                        gridOffset: gridOffset,
                        seed: _seed,
                        glowRadiusFraction: starfield.glowRadiusFraction,
                      ),
                    ),
                  ),
                ),
                tapTarget,
              ],
            )
          : tapTarget,
    );

    return Semantics(
      button: true,
      label: 'Back',
      child: SizedBox(width: effectiveSize, height: effectiveSize, child: decorated),
    );
  }
}
