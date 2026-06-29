import 'package:flutter/material.dart';
import 'package:termos_ui/termos_ui.dart';

/// Holds every tunable knob for the example app and rebuilds the
/// [TermosThemeData] from them. Shared by the paged docs view and the classic
/// all-in-one gallery so edits stay in sync across both.
///
/// Also carries the small bits of *demo* interaction state (selected nav tab,
/// switch value, etc.) so a demo keeps its state when you navigate away and
/// back.
class DocsController extends ChangeNotifier {
  DocsController() {
    _applyPalette(TermosColors.dark);
  }

  // ── Theme / brightness ──────────────────────────────────────────────────
  bool useLightTheme = false;
  bool heavyEffects = true;

  late Color primary;
  late Color background;
  late Color surface;
  late Color card;

  // ── Dot grid ────────────────────────────────────────────────────────────
  double dotSize = 2;
  double gridSpacing = 6;
  double blobRadius = 112;

  // ── Metrics ─────────────────────────────────────────────────────────────
  double borderRadius = 6;
  double buttonHeight = 44;
  double navBarCornerRadius = 28;
  double navBarHeight = 72;
  double glowStrokeWidth = 2;
  double backButtonIconSize = 20;

  // ── Effects ─────────────────────────────────────────────────────────────
  double starfieldIntensityLight = 1.8;
  double starfieldIntensityDark = 1.5;
  double navGlowMix = 0.5;
  double navStarfieldIntensity = 1.5;
  double segmentedGlowMix = 0.5;
  double segmentedUnselectedLabelMix = 0.32;
  double crtScanlineOpacity = 0.06;
  double crtVignette = 0.5;
  double tpScanLight = 0.015;
  double tpScanDark = 0.03;

  // ── Nav bar style (solid vs glass) ──────────────────────────────────────
  bool navBarGlass = false;
  double glassBlurSigma = 7;
  double glassReflectBoost = 0.6;

  // ── Demo interaction state ──────────────────────────────────────────────
  int navIndex = 1;
  int segmentIndex = 0;
  bool switchOn = true;
  TimeOfDay time = const TimeOfDay(hour: 14, minute: 30);
  int loaderSeed = 0;
  final TextEditingController proseField = TextEditingController();

  void _applyPalette(TermosColors source) {
    primary = source.primary;
    background = source.background;
    surface = source.surface;
    card = source.card;
  }

  /// Mutates one or more fields then notifies listeners.
  void update(VoidCallback fn) {
    fn();
    notifyListeners();
  }

  void setLightTheme(bool value) {
    update(() {
      useLightTheme = value;
      _applyPalette(value ? TermosColors.light : TermosColors.dark);
    });
  }

  /// Builds the live theme from the current knobs.
  TermosThemeData themeData() {
    final base = useLightTheme ? TermosThemeData.light() : TermosThemeData.dark();
    final customColors = base.colors.copyWith(
      primary: primary,
      background: background,
      surface: surface,
      card: card,
    );
    return base.copyWith(
      colors: customColors,
      textStyles: TermosTextStyles.fromColors(customColors),
      dotGrid: base.dotGrid.copyWith(
        dotSize: dotSize,
        spacing: gridSpacing,
        blobRadius: blobRadius,
      ),
      metrics: base.metrics.copyWith(
        borderRadius: borderRadius,
        buttonHeight: buttonHeight,
        navBarCornerRadius: navBarCornerRadius,
        navBarHeight: navBarHeight,
        glowTopBorderStrokeWidth: glowStrokeWidth,
        crtScanlineOpacity: crtScanlineOpacity,
        crtVignetteStrength: crtVignette,
        backButtonIconSize: backButtonIconSize,
      ),
      starfield: base.starfield.copyWith(
        intensityButtonLight: starfieldIntensityLight,
        intensityButtonDark: starfieldIntensityDark,
      ),
      navBar: base.navBar.copyWith(
        glowColorMixWithWhite: navGlowMix,
        starfieldIntensityLight: navStarfieldIntensity,
      ),
      navBarStyle: navBarGlass
          ? TermosNavBarStyle.glass(
              blurSigma: glassBlurSigma,
              reflectBoost: glassReflectBoost,
            )
          : const TermosNavBarStyle.solid(),
      segmented: base.segmented.copyWith(
        glowColorMixWithWhite: segmentedGlowMix,
        unselectedLabelMixWithWhiteLight: segmentedUnselectedLabelMix,
      ),
      timePicker: base.timePicker.copyWith(
        scanlineOpacityLight: tpScanLight,
        scanlineOpacityDark: tpScanDark,
      ),
      heavyEffectsEnabled: heavyEffects,
    );
  }

  @override
  void dispose() {
    proseField.dispose();
    super.dispose();
  }
}
