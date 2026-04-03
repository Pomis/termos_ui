import 'package:flutter/material.dart';

import '../painters/scanlines_painter.dart';
import '../theme/termos_theme.dart';

/// Wraps content with CRT-style visual effects: scanlines, vignette, rounded bezel.
///
/// Corner radius uses [TermosThemeData.metrics.borderRadius]; scanline strength from [TermosThemeData.metrics]; outer bezel and
/// shadows from [TermosThemeData.crt].
class TermosCrt extends StatelessWidget {
  const TermosCrt({
    super.key,
    required this.child,
    this.showOuterEffects = true,
  });

  final Widget child;

  /// When false, the outer border and box shadow are omitted.
  final bool showOuterEffects;

  @override
  Widget build(BuildContext context) {
    final termos = TermosTheme.of(context);
    final metrics = termos.metrics;
    final crt = termos.crt;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final cornerRadius = metrics.borderRadius;
    final scanlineOpacity = metrics.crtScanlineOpacity;
    final vignetteStrength = metrics.crtVignetteStrength;
    final borderWidth = metrics.crtOuterBorderWidth;

    final effectiveScanlines = isLight ? 0.0 : scanlineOpacity;
    final effectiveVignette = isLight ? 0.0 : vignetteStrength;

    return Container(
      decoration: showOuterEffects
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(cornerRadius),
              border: Border.all(
                color: (isLight ? Colors.black : Colors.white).withValues(
                  alpha: isLight ? crt.outerBorderAlphaLight : crt.outerBorderAlphaDark,
                ),
                width: borderWidth,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: isLight ? crt.shadowLightAlpha : crt.shadowDarkAlpha,
                  ),
                  blurRadius: isLight ? crt.shadowBlurLight : crt.shadowBlurDark,
                  spreadRadius: isLight ? crt.shadowSpreadLight : crt.shadowSpreadDark,
                ),
              ],
            )
          : null,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(cornerRadius),
        child: Stack(
          fit: StackFit.passthrough,
          children: [
            child,
            if (effectiveScanlines > 0)
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: ScanlinesPainter(opacity: effectiveScanlines),
                  ),
                ),
              ),
            if (effectiveVignette > 0)
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: crt.vignetteGradientRadius,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: effectiveVignette),
                        ],
                        stops: [
                          crt.vignetteGradientStopTransparent,
                          crt.vignetteGradientStopDark,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
