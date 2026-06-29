import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Pluggable backdrop shader for the glass nav bar surface.
///
/// The glass [TermosNavBarStyle] composes a fragment shader *after* a gaussian
/// blur inside the bar's `BackdropFilter`, so the shader runs over the blurred
/// content scrolling beneath the bar. Implement this to swap in a different
/// surface look (the built-in [TermosReflectiveDotsShader] paints a dot-matrix
/// reflection of whatever moves below).
///
/// Implementations must be immutable and provide value equality so they can
/// live on [TermosThemeData] and participate in theme lerp/equality.
abstract class TermosNavBarSurfaceShader {
  const TermosNavBarSurfaceShader();

  /// Fragment program asset key, e.g.
  /// `'packages/termos_ui/shaders/glass_nav_dots.frag'`. Loaded once and cached
  /// by [TermosNavBar]; a load failure falls the bar back to a plain blur.
  String get assetKey;

  /// Builds the composed backdrop [ui.ImageFilter].
  ///
  /// [program] is the loaded fragment program, [inner] the gaussian blur to
  /// compose beneath the shader. All length values are in physical pixels
  /// (already multiplied by [devicePixelRatio]); [originPhysical] is the bar's
  /// top-left in the frag-coord space so a dot lattice can phase-lock to the
  /// widget's own grid. Return [inner] unchanged if the shader cannot run.
  ui.ImageFilter buildBackdropFilter({
    required ui.FragmentProgram program,
    required ui.ImageFilter inner,
    required Size size,
    required double devicePixelRatio,
    required Color tint,
    required Offset originPhysical,
    required double dotSize,
    required double gridSpacing,
    required double reflectBoost,
  });
}

/// Built-in glass surface shader: a dot-matrix lattice where each dot reflects
/// the blurred content beneath the bar, phase-locked to termos' dot grid.
///
/// Backed by `packages/termos_ui/shaders/glass_nav_dots.frag`.
class TermosReflectiveDotsShader extends TermosNavBarSurfaceShader {
  const TermosReflectiveDotsShader();

  @override
  String get assetKey => 'packages/termos_ui/shaders/glass_nav_dots.frag';

  @override
  ui.ImageFilter buildBackdropFilter({
    required ui.FragmentProgram program,
    required ui.ImageFilter inner,
    required Size size,
    required double devicePixelRatio,
    required Color tint,
    required Offset originPhysical,
    required double dotSize,
    required double gridSpacing,
    required double reflectBoost,
  }) {
    final dpr = devicePixelRatio;
    try {
      // FlutterFragCoord in an ImageFilter.shader runs over the backdrop
      // texture in physical pixels, so every length uniform is premultiplied by
      // the device pixel ratio. The frag coord's origin is the backdrop layer
      // (the bar's on-screen position), so [originPhysical] rebases the lattice
      // to the bar's own top-left to stay phase-locked with the logical-pixel
      // grid DotGridPainter draws.
      final shader = program.fragmentShader()
        ..setFloat(0, size.width * dpr)
        ..setFloat(1, size.height * dpr)
        ..setFloat(2, (dotSize + gridSpacing) * dpr)
        ..setFloat(3, dotSize * dpr)
        ..setFloat(4, tint.r)
        ..setFloat(5, tint.g)
        ..setFloat(6, tint.b)
        ..setFloat(7, tint.a)
        ..setFloat(8, reflectBoost)
        ..setFloat(9, originPhysical.dx)
        ..setFloat(10, originPhysical.dy);
      return ui.ImageFilter.compose(
        outer: ui.ImageFilter.shader(shader),
        inner: inner,
      );
    } on UnsupportedError {
      // Backend without runtime-effect backdrop support — keep the plain blur.
      return inner;
    }
  }

  @override
  bool operator ==(Object other) => other is TermosReflectiveDotsShader;

  @override
  int get hashCode => (TermosReflectiveDotsShader).hashCode;
}

/// Visual treatment for [TermosNavBar]'s shell.
///
/// A value object carried on [TermosThemeData.navBarStyle]. Two built-ins:
/// [TermosNavBarStyle.solid] (the default opaque shell) and
/// [TermosNavBarStyle.glass] (a translucent blurred shell with a surface tint,
/// specular sheen, gradient rim, and an optional backdrop [shader]). Switching
/// the style re-paints the shell only — the dot grid, tap ripples, reactive
/// starfield, and sliding top-edge glow are shared by both.
sealed class TermosNavBarStyle {
  const TermosNavBarStyle();

  /// Opaque shell (the classic termos nav bar).
  const factory TermosNavBarStyle.solid() = TermosNavBarSolidStyle;

  /// Translucent glass shell: backdrop blur, surface tint, sheen, rim, and an
  /// optional reflective backdrop [shader].
  const factory TermosNavBarStyle.glass({
    double blurSigma,
    double surfaceTintAlphaLight,
    double surfaceTintAlphaDark,
    double reflectBoost,
    TermosNavBarSurfaceShader? shader,
  }) = TermosNavBarGlassStyle;

  /// Interpolates between two styles. Same concrete type interpolates field by
  /// field; otherwise snaps at the half-way point (mirrors `ShapeBorder.lerp`).
  static TermosNavBarStyle? lerp(
    TermosNavBarStyle? a,
    TermosNavBarStyle? b,
    double t,
  ) {
    if (identical(a, b)) return a;
    if (a is TermosNavBarGlassStyle && b is TermosNavBarGlassStyle) {
      return a.lerpTo(b, t);
    }
    return t < 0.5 ? a : b;
  }
}

/// Opaque nav bar shell. See [TermosNavBarStyle.solid].
class TermosNavBarSolidStyle extends TermosNavBarStyle {
  const TermosNavBarSolidStyle();

  @override
  bool operator ==(Object other) => other is TermosNavBarSolidStyle;

  @override
  int get hashCode => (TermosNavBarSolidStyle).hashCode;
}

/// Translucent glass nav bar shell. See [TermosNavBarStyle.glass].
class TermosNavBarGlassStyle extends TermosNavBarStyle {
  const TermosNavBarGlassStyle({
    this.blurSigma = 7,
    this.surfaceTintAlphaLight = 0.72,
    this.surfaceTintAlphaDark = 0.55,
    this.reflectBoost = 0.6,
    this.shader = const TermosReflectiveDotsShader(),
  });

  /// Gaussian blur sigma for the backdrop. Lighter than classic frosted glass
  /// so the [shader] dots keep enough detail to read as reflections.
  final double blurSigma;

  /// Surface tint alpha over the blurred backdrop. Light mode needs more body
  /// or text contrast suffers.
  final double surfaceTintAlphaLight;
  final double surfaceTintAlphaDark;

  /// Luminance ceiling for the reflective shader dots (passed to [shader]).
  final double reflectBoost;

  /// Backdrop surface shader, or null for a plain blur with no reflections.
  final TermosNavBarSurfaceShader? shader;

  TermosNavBarGlassStyle copyWith({
    double? blurSigma,
    double? surfaceTintAlphaLight,
    double? surfaceTintAlphaDark,
    double? reflectBoost,
    TermosNavBarSurfaceShader? shader,
    bool clearShader = false,
  }) {
    return TermosNavBarGlassStyle(
      blurSigma: blurSigma ?? this.blurSigma,
      surfaceTintAlphaLight: surfaceTintAlphaLight ?? this.surfaceTintAlphaLight,
      surfaceTintAlphaDark: surfaceTintAlphaDark ?? this.surfaceTintAlphaDark,
      reflectBoost: reflectBoost ?? this.reflectBoost,
      shader: clearShader ? null : (shader ?? this.shader),
    );
  }

  TermosNavBarGlassStyle lerpTo(TermosNavBarGlassStyle other, double t) {
    return TermosNavBarGlassStyle(
      blurSigma: ui.lerpDouble(blurSigma, other.blurSigma, t)!,
      surfaceTintAlphaLight:
          ui.lerpDouble(surfaceTintAlphaLight, other.surfaceTintAlphaLight, t)!,
      surfaceTintAlphaDark:
          ui.lerpDouble(surfaceTintAlphaDark, other.surfaceTintAlphaDark, t)!,
      reflectBoost: ui.lerpDouble(reflectBoost, other.reflectBoost, t)!,
      // Shaders can't interpolate — snap at the half-way point.
      shader: t < 0.5 ? shader : other.shader,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TermosNavBarGlassStyle &&
          blurSigma == other.blurSigma &&
          surfaceTintAlphaLight == other.surfaceTintAlphaLight &&
          surfaceTintAlphaDark == other.surfaceTintAlphaDark &&
          reflectBoost == other.reflectBoost &&
          shader == other.shader;

  @override
  int get hashCode => Object.hash(
    blurSigma,
    surfaceTintAlphaLight,
    surfaceTintAlphaDark,
    reflectBoost,
    shader,
  );
}
