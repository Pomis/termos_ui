import 'dart:ui' show lerpDouble;

/// [ReactiveStarfieldPainter] and related effect defaults (per theme).
class TermosStarfieldConfig {
  const TermosStarfieldConfig({
    this.glowPositionButton = 0.5,
    this.glowPositionBackButton = 0.5,
    this.glowRadiusFraction,
    this.intensityButtonLight = 1.8,
    this.intensityButtonDark = 1.5,
    this.intensityButtonDisabledBlend = 0.5,
    this.intensityBackButtonLight = 2,
    this.intensityBackButtonDark = 1.5,
  });

  /// Horizontal glow center for button starfield (0–1).
  final double glowPositionButton;
  final double glowPositionBackButton;
  final double? glowRadiusFraction;
  final double intensityButtonLight;
  final double intensityButtonDark;
  /// Multiplier on disabled state when lerping starfield intensity.
  final double intensityButtonDisabledBlend;
  final double intensityBackButtonLight;
  final double intensityBackButtonDark;

  TermosStarfieldConfig copyWith({
    double? glowPositionButton,
    double? glowPositionBackButton,
    double? glowRadiusFraction,
    double? intensityButtonLight,
    double? intensityButtonDark,
    double? intensityButtonDisabledBlend,
    double? intensityBackButtonLight,
    double? intensityBackButtonDark,
    bool clearGlowRadiusFraction = false,
  }) {
    return TermosStarfieldConfig(
      glowPositionButton: glowPositionButton ?? this.glowPositionButton,
      glowPositionBackButton: glowPositionBackButton ?? this.glowPositionBackButton,
      glowRadiusFraction:
          clearGlowRadiusFraction ? null : (glowRadiusFraction ?? this.glowRadiusFraction),
      intensityButtonLight: intensityButtonLight ?? this.intensityButtonLight,
      intensityButtonDark: intensityButtonDark ?? this.intensityButtonDark,
      intensityButtonDisabledBlend:
          intensityButtonDisabledBlend ?? this.intensityButtonDisabledBlend,
      intensityBackButtonLight: intensityBackButtonLight ?? this.intensityBackButtonLight,
      intensityBackButtonDark: intensityBackButtonDark ?? this.intensityBackButtonDark,
    );
  }

  TermosStarfieldConfig lerp(TermosStarfieldConfig other, double t) {
    return TermosStarfieldConfig(
      glowPositionButton: lerpDouble(glowPositionButton, other.glowPositionButton, t)!,
      glowPositionBackButton:
          lerpDouble(glowPositionBackButton, other.glowPositionBackButton, t)!,
      glowRadiusFraction: t < 0.5 ? glowRadiusFraction : other.glowRadiusFraction,
      intensityButtonLight: lerpDouble(intensityButtonLight, other.intensityButtonLight, t)!,
      intensityButtonDark: lerpDouble(intensityButtonDark, other.intensityButtonDark, t)!,
      intensityButtonDisabledBlend:
          lerpDouble(intensityButtonDisabledBlend, other.intensityButtonDisabledBlend, t)!,
      intensityBackButtonLight:
          lerpDouble(intensityBackButtonLight, other.intensityBackButtonLight, t)!,
      intensityBackButtonDark:
          lerpDouble(intensityBackButtonDark, other.intensityBackButtonDark, t)!,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TermosStarfieldConfig &&
          glowPositionButton == other.glowPositionButton &&
          glowPositionBackButton == other.glowPositionBackButton &&
          glowRadiusFraction == other.glowRadiusFraction &&
          intensityButtonLight == other.intensityButtonLight &&
          intensityButtonDark == other.intensityButtonDark &&
          intensityButtonDisabledBlend == other.intensityButtonDisabledBlend &&
          intensityBackButtonLight == other.intensityBackButtonLight &&
          intensityBackButtonDark == other.intensityBackButtonDark;

  @override
  int get hashCode => Object.hash(
        glowPositionButton,
        glowPositionBackButton,
        glowRadiusFraction,
        intensityButtonLight,
        intensityButtonDark,
        intensityButtonDisabledBlend,
        intensityBackButtonLight,
        intensityBackButtonDark,
      );
}

/// Nav bar dot grid / starfield / glow shell (per theme).
class TermosNavBarEffects {
  const TermosNavBarEffects({
    this.glowColorMixWithWhite = 0.5,
    this.dotGridPrimaryMixWithWhite = 0.5,
    this.dotGridPrimaryAlphaLight = 0.5,
    this.dotGridPrimaryAlphaDark = 1,
    this.selectionAlphaLight = 0.35,
    this.selectionAlphaDark = 0.25,
    this.starfieldIntensityLight = 1.5,
    this.starfieldIntensityDark = 1,
    this.glowShellBaseOpacityLight = 0.1,
    this.glowShellBaseOpacityDark = 0.05,
    this.dotGridExpansionMs = 100,
    this.dotGridDecayMs = 280,
  });

  /// [Color.lerp](tabColor, white, this) for top glow color in light mode.
  final double glowColorMixWithWhite;
  final double dotGridPrimaryMixWithWhite;
  final double dotGridPrimaryAlphaLight;
  final double dotGridPrimaryAlphaDark;
  final double selectionAlphaLight;
  final double selectionAlphaDark;
  final double starfieldIntensityLight;
  final double starfieldIntensityDark;
  final double glowShellBaseOpacityLight;
  final double glowShellBaseOpacityDark;
  final int dotGridExpansionMs;
  final int dotGridDecayMs;

  TermosNavBarEffects copyWith({
    double? glowColorMixWithWhite,
    double? dotGridPrimaryMixWithWhite,
    double? dotGridPrimaryAlphaLight,
    double? dotGridPrimaryAlphaDark,
    double? selectionAlphaLight,
    double? selectionAlphaDark,
    double? starfieldIntensityLight,
    double? starfieldIntensityDark,
    double? glowShellBaseOpacityLight,
    double? glowShellBaseOpacityDark,
    int? dotGridExpansionMs,
    int? dotGridDecayMs,
  }) {
    return TermosNavBarEffects(
      glowColorMixWithWhite: glowColorMixWithWhite ?? this.glowColorMixWithWhite,
      dotGridPrimaryMixWithWhite:
          dotGridPrimaryMixWithWhite ?? this.dotGridPrimaryMixWithWhite,
      dotGridPrimaryAlphaLight: dotGridPrimaryAlphaLight ?? this.dotGridPrimaryAlphaLight,
      dotGridPrimaryAlphaDark: dotGridPrimaryAlphaDark ?? this.dotGridPrimaryAlphaDark,
      selectionAlphaLight: selectionAlphaLight ?? this.selectionAlphaLight,
      selectionAlphaDark: selectionAlphaDark ?? this.selectionAlphaDark,
      starfieldIntensityLight: starfieldIntensityLight ?? this.starfieldIntensityLight,
      starfieldIntensityDark: starfieldIntensityDark ?? this.starfieldIntensityDark,
      glowShellBaseOpacityLight: glowShellBaseOpacityLight ?? this.glowShellBaseOpacityLight,
      glowShellBaseOpacityDark: glowShellBaseOpacityDark ?? this.glowShellBaseOpacityDark,
      dotGridExpansionMs: dotGridExpansionMs ?? this.dotGridExpansionMs,
      dotGridDecayMs: dotGridDecayMs ?? this.dotGridDecayMs,
    );
  }

  TermosNavBarEffects lerp(TermosNavBarEffects other, double t) {
    return TermosNavBarEffects(
      glowColorMixWithWhite: lerpDouble(glowColorMixWithWhite, other.glowColorMixWithWhite, t)!,
      dotGridPrimaryMixWithWhite:
          lerpDouble(dotGridPrimaryMixWithWhite, other.dotGridPrimaryMixWithWhite, t)!,
      dotGridPrimaryAlphaLight:
          lerpDouble(dotGridPrimaryAlphaLight, other.dotGridPrimaryAlphaLight, t)!,
      dotGridPrimaryAlphaDark:
          lerpDouble(dotGridPrimaryAlphaDark, other.dotGridPrimaryAlphaDark, t)!,
      selectionAlphaLight: lerpDouble(selectionAlphaLight, other.selectionAlphaLight, t)!,
      selectionAlphaDark: lerpDouble(selectionAlphaDark, other.selectionAlphaDark, t)!,
      starfieldIntensityLight:
          lerpDouble(starfieldIntensityLight, other.starfieldIntensityLight, t)!,
      starfieldIntensityDark:
          lerpDouble(starfieldIntensityDark, other.starfieldIntensityDark, t)!,
      glowShellBaseOpacityLight:
          lerpDouble(glowShellBaseOpacityLight, other.glowShellBaseOpacityLight, t)!,
      glowShellBaseOpacityDark:
          lerpDouble(glowShellBaseOpacityDark, other.glowShellBaseOpacityDark, t)!,
      dotGridExpansionMs: lerpDouble(
        dotGridExpansionMs.toDouble(),
        other.dotGridExpansionMs.toDouble(),
        t,
      )!.round(),
      dotGridDecayMs: lerpDouble(
        dotGridDecayMs.toDouble(),
        other.dotGridDecayMs.toDouble(),
        t,
      )!.round(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TermosNavBarEffects &&
          glowColorMixWithWhite == other.glowColorMixWithWhite &&
          dotGridPrimaryMixWithWhite == other.dotGridPrimaryMixWithWhite &&
          dotGridPrimaryAlphaLight == other.dotGridPrimaryAlphaLight &&
          dotGridPrimaryAlphaDark == other.dotGridPrimaryAlphaDark &&
          selectionAlphaLight == other.selectionAlphaLight &&
          selectionAlphaDark == other.selectionAlphaDark &&
          starfieldIntensityLight == other.starfieldIntensityLight &&
          starfieldIntensityDark == other.starfieldIntensityDark &&
          glowShellBaseOpacityLight == other.glowShellBaseOpacityLight &&
          glowShellBaseOpacityDark == other.glowShellBaseOpacityDark &&
          dotGridExpansionMs == other.dotGridExpansionMs &&
          dotGridDecayMs == other.dotGridDecayMs;

  @override
  int get hashCode => Object.hashAll([
        glowColorMixWithWhite,
        dotGridPrimaryMixWithWhite,
        dotGridPrimaryAlphaLight,
        dotGridPrimaryAlphaDark,
        selectionAlphaLight,
        selectionAlphaDark,
        starfieldIntensityLight,
        starfieldIntensityDark,
        glowShellBaseOpacityLight,
        glowShellBaseOpacityDark,
        dotGridExpansionMs,
        dotGridDecayMs,
      ]);
}

/// Time picker drum styling (per theme).
class TermosTimePickerEffects {
  const TermosTimePickerEffects({
    this.scanlineOpacityLight = 0.015,
    this.scanlineOpacityDark = 0.03,
    this.selectionBandBgAlphaLight = 0.03,
    this.selectionBandBgAlphaDark = 0.04,
    this.selectionBandGlowAlphaLight = 0.2,
    this.selectionBandGlowAlphaDark = 0.3,
    this.colonPulseOpacityMin = 0.4,
    this.colonPulseOpacityMax = 1.0,
    this.colonFontSize = 26,
    this.wheelFontSize = 24,
  });

  final double scanlineOpacityLight;
  final double scanlineOpacityDark;
  final double selectionBandBgAlphaLight;
  final double selectionBandBgAlphaDark;
  final double selectionBandGlowAlphaLight;
  final double selectionBandGlowAlphaDark;
  final double colonPulseOpacityMin;
  final double colonPulseOpacityMax;
  final double colonFontSize;
  final double wheelFontSize;

  TermosTimePickerEffects copyWith({
    double? scanlineOpacityLight,
    double? scanlineOpacityDark,
    double? selectionBandBgAlphaLight,
    double? selectionBandBgAlphaDark,
    double? selectionBandGlowAlphaLight,
    double? selectionBandGlowAlphaDark,
    double? colonPulseOpacityMin,
    double? colonPulseOpacityMax,
    double? colonFontSize,
    double? wheelFontSize,
  }) {
    return TermosTimePickerEffects(
      scanlineOpacityLight: scanlineOpacityLight ?? this.scanlineOpacityLight,
      scanlineOpacityDark: scanlineOpacityDark ?? this.scanlineOpacityDark,
      selectionBandBgAlphaLight:
          selectionBandBgAlphaLight ?? this.selectionBandBgAlphaLight,
      selectionBandBgAlphaDark:
          selectionBandBgAlphaDark ?? this.selectionBandBgAlphaDark,
      selectionBandGlowAlphaLight:
          selectionBandGlowAlphaLight ?? this.selectionBandGlowAlphaLight,
      selectionBandGlowAlphaDark:
          selectionBandGlowAlphaDark ?? this.selectionBandGlowAlphaDark,
      colonPulseOpacityMin: colonPulseOpacityMin ?? this.colonPulseOpacityMin,
      colonPulseOpacityMax: colonPulseOpacityMax ?? this.colonPulseOpacityMax,
      colonFontSize: colonFontSize ?? this.colonFontSize,
      wheelFontSize: wheelFontSize ?? this.wheelFontSize,
    );
  }

  TermosTimePickerEffects lerp(TermosTimePickerEffects other, double t) {
    return TermosTimePickerEffects(
      scanlineOpacityLight:
          lerpDouble(scanlineOpacityLight, other.scanlineOpacityLight, t)!,
      scanlineOpacityDark:
          lerpDouble(scanlineOpacityDark, other.scanlineOpacityDark, t)!,
      selectionBandBgAlphaLight:
          lerpDouble(selectionBandBgAlphaLight, other.selectionBandBgAlphaLight, t)!,
      selectionBandBgAlphaDark:
          lerpDouble(selectionBandBgAlphaDark, other.selectionBandBgAlphaDark, t)!,
      selectionBandGlowAlphaLight:
          lerpDouble(selectionBandGlowAlphaLight, other.selectionBandGlowAlphaLight, t)!,
      selectionBandGlowAlphaDark:
          lerpDouble(selectionBandGlowAlphaDark, other.selectionBandGlowAlphaDark, t)!,
      colonPulseOpacityMin:
          lerpDouble(colonPulseOpacityMin, other.colonPulseOpacityMin, t)!,
      colonPulseOpacityMax:
          lerpDouble(colonPulseOpacityMax, other.colonPulseOpacityMax, t)!,
      colonFontSize: lerpDouble(colonFontSize, other.colonFontSize, t)!,
      wheelFontSize: lerpDouble(wheelFontSize, other.wheelFontSize, t)!,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TermosTimePickerEffects &&
          scanlineOpacityLight == other.scanlineOpacityLight &&
          scanlineOpacityDark == other.scanlineOpacityDark &&
          selectionBandBgAlphaLight == other.selectionBandBgAlphaLight &&
          selectionBandBgAlphaDark == other.selectionBandBgAlphaDark &&
          selectionBandGlowAlphaLight == other.selectionBandGlowAlphaLight &&
          selectionBandGlowAlphaDark == other.selectionBandGlowAlphaDark &&
          colonPulseOpacityMin == other.colonPulseOpacityMin &&
          colonPulseOpacityMax == other.colonPulseOpacityMax &&
          colonFontSize == other.colonFontSize &&
          wheelFontSize == other.wheelFontSize;

  @override
  int get hashCode => Object.hashAll([
        scanlineOpacityLight,
        scanlineOpacityDark,
        selectionBandBgAlphaLight,
        selectionBandBgAlphaDark,
        selectionBandGlowAlphaLight,
        selectionBandGlowAlphaDark,
        colonPulseOpacityMin,
        colonPulseOpacityMax,
        colonFontSize,
        wheelFontSize,
      ]);
}

/// Segmented selector top glow (per theme).
class TermosSegmentedEffects {
  const TermosSegmentedEffects({
    this.glowColorMixWithWhite = 0.5,
    this.glowBaseOpacityLight = 0.15,
    this.glowBaseOpacityDark = 0.05,
  });

  final double glowColorMixWithWhite;
  final double glowBaseOpacityLight;
  final double glowBaseOpacityDark;

  TermosSegmentedEffects copyWith({
    double? glowColorMixWithWhite,
    double? glowBaseOpacityLight,
    double? glowBaseOpacityDark,
  }) {
    return TermosSegmentedEffects(
      glowColorMixWithWhite: glowColorMixWithWhite ?? this.glowColorMixWithWhite,
      glowBaseOpacityLight: glowBaseOpacityLight ?? this.glowBaseOpacityLight,
      glowBaseOpacityDark: glowBaseOpacityDark ?? this.glowBaseOpacityDark,
    );
  }

  TermosSegmentedEffects lerp(TermosSegmentedEffects other, double t) {
    return TermosSegmentedEffects(
      glowColorMixWithWhite:
          lerpDouble(glowColorMixWithWhite, other.glowColorMixWithWhite, t)!,
      glowBaseOpacityLight: lerpDouble(glowBaseOpacityLight, other.glowBaseOpacityLight, t)!,
      glowBaseOpacityDark: lerpDouble(glowBaseOpacityDark, other.glowBaseOpacityDark, t)!,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TermosSegmentedEffects &&
          glowColorMixWithWhite == other.glowColorMixWithWhite &&
          glowBaseOpacityLight == other.glowBaseOpacityLight &&
          glowBaseOpacityDark == other.glowBaseOpacityDark;

  @override
  int get hashCode =>
      Object.hash(glowColorMixWithWhite, glowBaseOpacityLight, glowBaseOpacityDark);
}

/// Button card background blend and border (per theme).
class TermosButtonEffects {
  const TermosButtonEffects({
    this.cardBlendLight = 0.4,
    this.cardBlendDark = 0.6,
    this.borderHoverMix = 0.2,
    this.borderPressedMix = 0.8,
    this.borderHoveredMix = 0.5,
    this.contentMutedAlpha = 0.5,
  });

  /// [Color.lerp](background, card, this) for button fill.
  final double cardBlendLight;
  final double cardBlendDark;
  final double borderHoverMix;
  final double borderPressedMix;
  final double borderHoveredMix;
  final double contentMutedAlpha;

  TermosButtonEffects copyWith({
    double? cardBlendLight,
    double? cardBlendDark,
    double? borderHoverMix,
    double? borderPressedMix,
    double? borderHoveredMix,
    double? contentMutedAlpha,
  }) {
    return TermosButtonEffects(
      cardBlendLight: cardBlendLight ?? this.cardBlendLight,
      cardBlendDark: cardBlendDark ?? this.cardBlendDark,
      borderHoverMix: borderHoverMix ?? this.borderHoverMix,
      borderPressedMix: borderPressedMix ?? this.borderPressedMix,
      borderHoveredMix: borderHoveredMix ?? this.borderHoveredMix,
      contentMutedAlpha: contentMutedAlpha ?? this.contentMutedAlpha,
    );
  }

  TermosButtonEffects lerp(TermosButtonEffects other, double t) {
    return TermosButtonEffects(
      cardBlendLight: lerpDouble(cardBlendLight, other.cardBlendLight, t)!,
      cardBlendDark: lerpDouble(cardBlendDark, other.cardBlendDark, t)!,
      borderHoverMix: lerpDouble(borderHoverMix, other.borderHoverMix, t)!,
      borderPressedMix: lerpDouble(borderPressedMix, other.borderPressedMix, t)!,
      borderHoveredMix: lerpDouble(borderHoveredMix, other.borderHoveredMix, t)!,
      contentMutedAlpha: lerpDouble(contentMutedAlpha, other.contentMutedAlpha, t)!,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TermosButtonEffects &&
          cardBlendLight == other.cardBlendLight &&
          cardBlendDark == other.cardBlendDark &&
          borderHoverMix == other.borderHoverMix &&
          borderPressedMix == other.borderPressedMix &&
          borderHoveredMix == other.borderHoveredMix &&
          contentMutedAlpha == other.contentMutedAlpha;

  @override
  int get hashCode => Object.hash(
        cardBlendLight,
        cardBlendDark,
        borderHoverMix,
        borderPressedMix,
        borderHoveredMix,
        contentMutedAlpha,
      );
}

/// CRT outer bezel / shadows (per theme).
class TermosCrtEffects {
  const TermosCrtEffects({
    this.outerBorderAlphaLight = 0.08,
    this.outerBorderAlphaDark = 0.06,
    this.shadowLightAlpha = 0.08,
    this.shadowDarkAlpha = 0.5,
    this.shadowBlurLight = 8,
    this.shadowBlurDark = 20,
    this.shadowSpreadLight = 0,
    this.shadowSpreadDark = 2,
    this.vignetteGradientRadius = 1.5,
    this.vignetteGradientStopTransparent = 0.5,
    this.vignetteGradientStopDark = 1.0,
  });

  final double outerBorderAlphaLight;
  final double outerBorderAlphaDark;
  final double shadowLightAlpha;
  final double shadowDarkAlpha;
  final double shadowBlurLight;
  final double shadowBlurDark;
  final double shadowSpreadLight;
  final double shadowSpreadDark;
  final double vignetteGradientRadius;
  final double vignetteGradientStopTransparent;
  final double vignetteGradientStopDark;

  TermosCrtEffects copyWith({
    double? outerBorderAlphaLight,
    double? outerBorderAlphaDark,
    double? shadowLightAlpha,
    double? shadowDarkAlpha,
    double? shadowBlurLight,
    double? shadowBlurDark,
    double? shadowSpreadLight,
    double? shadowSpreadDark,
    double? vignetteGradientRadius,
    double? vignetteGradientStopTransparent,
    double? vignetteGradientStopDark,
  }) {
    return TermosCrtEffects(
      outerBorderAlphaLight: outerBorderAlphaLight ?? this.outerBorderAlphaLight,
      outerBorderAlphaDark: outerBorderAlphaDark ?? this.outerBorderAlphaDark,
      shadowLightAlpha: shadowLightAlpha ?? this.shadowLightAlpha,
      shadowDarkAlpha: shadowDarkAlpha ?? this.shadowDarkAlpha,
      shadowBlurLight: shadowBlurLight ?? this.shadowBlurLight,
      shadowBlurDark: shadowBlurDark ?? this.shadowBlurDark,
      shadowSpreadLight: shadowSpreadLight ?? this.shadowSpreadLight,
      shadowSpreadDark: shadowSpreadDark ?? this.shadowSpreadDark,
      vignetteGradientRadius: vignetteGradientRadius ?? this.vignetteGradientRadius,
      vignetteGradientStopTransparent:
          vignetteGradientStopTransparent ?? this.vignetteGradientStopTransparent,
      vignetteGradientStopDark: vignetteGradientStopDark ?? this.vignetteGradientStopDark,
    );
  }

  TermosCrtEffects lerp(TermosCrtEffects other, double t) {
    return TermosCrtEffects(
      outerBorderAlphaLight:
          lerpDouble(outerBorderAlphaLight, other.outerBorderAlphaLight, t)!,
      outerBorderAlphaDark:
          lerpDouble(outerBorderAlphaDark, other.outerBorderAlphaDark, t)!,
      shadowLightAlpha: lerpDouble(shadowLightAlpha, other.shadowLightAlpha, t)!,
      shadowDarkAlpha: lerpDouble(shadowDarkAlpha, other.shadowDarkAlpha, t)!,
      shadowBlurLight: lerpDouble(shadowBlurLight, other.shadowBlurLight, t)!,
      shadowBlurDark: lerpDouble(shadowBlurDark, other.shadowBlurDark, t)!,
      shadowSpreadLight: lerpDouble(shadowSpreadLight, other.shadowSpreadLight, t)!,
      shadowSpreadDark: lerpDouble(shadowSpreadDark, other.shadowSpreadDark, t)!,
      vignetteGradientRadius:
          lerpDouble(vignetteGradientRadius, other.vignetteGradientRadius, t)!,
      vignetteGradientStopTransparent:
          lerpDouble(vignetteGradientStopTransparent, other.vignetteGradientStopTransparent, t)!,
      vignetteGradientStopDark:
          lerpDouble(vignetteGradientStopDark, other.vignetteGradientStopDark, t)!,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TermosCrtEffects &&
          outerBorderAlphaLight == other.outerBorderAlphaLight &&
          outerBorderAlphaDark == other.outerBorderAlphaDark &&
          shadowLightAlpha == other.shadowLightAlpha &&
          shadowDarkAlpha == other.shadowDarkAlpha &&
          shadowBlurLight == other.shadowBlurLight &&
          shadowBlurDark == other.shadowBlurDark &&
          shadowSpreadLight == other.shadowSpreadLight &&
          shadowSpreadDark == other.shadowSpreadDark &&
          vignetteGradientRadius == other.vignetteGradientRadius &&
          vignetteGradientStopTransparent == other.vignetteGradientStopTransparent &&
          vignetteGradientStopDark == other.vignetteGradientStopDark;

  @override
  int get hashCode => Object.hashAll([
        outerBorderAlphaLight,
        outerBorderAlphaDark,
        shadowLightAlpha,
        shadowDarkAlpha,
        shadowBlurLight,
        shadowBlurDark,
        shadowSpreadLight,
        shadowSpreadDark,
        vignetteGradientRadius,
        vignetteGradientStopTransparent,
        vignetteGradientStopDark,
      ]);
}
