import 'package:flutter/material.dart';

import '../core/termos_aligned_builder.dart';
import '../core/termos_tap_target.dart';
import '../painters/reactive_starfield_painter.dart';
import '../theme/termos_theme.dart';

/// Terminal-style back control for app bars (dot grid mesh + starfield when heavy effects on).
class TermosBackButton extends StatelessWidget {
  const TermosBackButton({super.key, required this.onTap, this.size, this.label});

  final VoidCallback onTap;

  /// Defaults to [TermosMetrics.backButtonDefaultSize].
  final double? size;

  /// Defaults to [TermosMetrics.backButtonGlyph] when null.
  final String? label;

  static const _seed = 0x6261636B; // "back"

  @override
  Widget build(BuildContext context) {
    final termos = TermosTheme.of(context);
    final useHeavy = termos.heavyEffectsEnabled;
    final colors = termos.colors;
    final dg = termos.dotGrid;
    final textStyles = termos.textStyles;
    final metrics = termos.metrics;
    final starfield = termos.starfield;
    final isLight = Theme.of(context).brightness == Brightness.light;

    final displayLabel = label ?? metrics.backButtonGlyph;
    final effectiveSize = size ?? metrics.backButtonDefaultSize;

    final content = Padding(
      padding: metrics.backButtonPadding,
      child: Align(
        alignment: Alignment.center,
        child: Text(
          displayLabel,
          style: textStyles
              .codePrimary(colors.primary)
              .copyWith(fontWeight: FontWeight.w600, height: 1),
        ),
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
      label: label ?? 'Back',
      child: SizedBox(width: effectiveSize, height: effectiveSize, child: decorated),
    );
  }
}
