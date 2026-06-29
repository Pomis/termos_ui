import 'package:flutter/material.dart';

import '../theme/termos_theme.dart';

/// Small tinted pill badge — a colored label chip with a translucent fill, a
/// matching hairline border, and an optional leading [icon].
///
/// The recurring "status pill" recipe: `color.withAlpha(fillAlpha)` fill over a
/// `color.withAlpha(borderAlpha)` border. Defaults to a fully rounded pill in
/// the theme's [TermosColors.primary]; pass [color] for other accents (e.g.
/// `TermosTheme.of(context).colors.info` for a "NEW" tag) and a smaller
/// [borderRadius] for a rectangular chip.
///
/// Purely decorative — tapping is owned by whatever surrounds it.
class TermosBadge extends StatelessWidget {
  const TermosBadge({
    super.key,
    required this.label,
    this.color,
    this.icon,
    this.borderRadius = 999,
    this.fillAlpha = 28,
    this.borderAlpha = 110,
    this.fontSize = 10,
    this.fontWeight = FontWeight.w800,
    this.letterSpacing = 1.4,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    this.iconGap = 4,
  });

  /// Badge text. Rendered in [color].
  final String label;

  /// Accent color for the fill, border, icon tint, and label. Defaults to the
  /// theme's [TermosColors.primary].
  final Color? color;

  /// Optional leading widget (e.g. a small icon). Tint it in [color] yourself —
  /// the badge does not recolor arbitrary children.
  final Widget? icon;

  final double borderRadius;

  /// Opacity (0–255) of the fill, applied to [color].
  final int fillAlpha;

  /// Opacity (0–255) of the border, applied to [color].
  final int borderAlpha;

  final double fontSize;
  final FontWeight fontWeight;
  final double letterSpacing;
  final EdgeInsetsGeometry padding;

  /// Gap between [icon] and [label].
  final double iconGap;

  @override
  Widget build(BuildContext context) {
    final accent = color ?? TermosTheme.of(context).colors.primary;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: accent.withAlpha(fillAlpha),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: accent.withAlpha(borderAlpha)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[icon!, SizedBox(width: iconGap)],
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: fontWeight,
              letterSpacing: letterSpacing,
              height: 1.0,
              color: accent,
            ),
          ),
        ],
      ),
    );
  }
}

/// A small glowing dot indicator — a filled circle with a soft halo, for
/// "unseen / new" affordances next to a label.
///
/// Defaults to the theme's [TermosColors.info].
class TermosBadgeDot extends StatelessWidget {
  const TermosBadgeDot({
    super.key,
    this.color,
    this.size = 7,
    this.glowAlpha = 120,
    this.glowBlur = 8,
  });

  /// Dot and halo color. Defaults to the theme's [TermosColors.info].
  final Color? color;
  final double size;

  /// Opacity (0–255) of the surrounding glow, applied to [color].
  final int glowAlpha;
  final double glowBlur;

  @override
  Widget build(BuildContext context) {
    final accent = color ?? TermosTheme.of(context).colors.info;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: accent,
        borderRadius: BorderRadius.circular(size / 2),
        boxShadow: [
          BoxShadow(color: accent.withAlpha(glowAlpha), blurRadius: glowBlur),
        ],
      ),
    );
  }
}
