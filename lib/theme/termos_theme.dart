import 'package:flutter/material.dart';

import 'dot_grid_config.dart';
import 'termos_colors.dart';
import 'termos_effects.dart';
import 'termos_metrics.dart';
import 'termos_text_styles.dart';

/// Central theme for all Termos widgets: layout, dot grid, colors, typography, effects.
///
/// Can be provided via [TermosTheme] (InheritedWidget) or registered as a
/// [ThemeExtension] on Material's [ThemeData]. [TermosTheme.of] checks both.
class TermosThemeData extends ThemeExtension<TermosThemeData> {
  const TermosThemeData({
    required this.colors,
    required this.dotGrid,
    required this.textStyles,
    this.metrics = TermosMetrics.standard,
    this.starfield = const TermosStarfieldConfig(),
    this.navBar = const TermosNavBarEffects(),
    this.tabBar = const TermosTabBarEffects(),
    this.segmented = const TermosSegmentedEffects(),
    this.button = const TermosButtonEffects(),
    this.crt = const TermosCrtEffects(),
    this.timePicker = const TermosTimePickerEffects(),
    this.heavyEffectsEnabled = true,
  });

  final TermosColors colors;
  final DotGridConfig dotGrid;
  final TermosTextStyles textStyles;
  final TermosMetrics metrics;

  final TermosStarfieldConfig starfield;
  final TermosNavBarEffects navBar;
  final TermosTabBarEffects tabBar;
  final TermosSegmentedEffects segmented;
  final TermosButtonEffects button;
  final TermosCrtEffects crt;
  final TermosTimePickerEffects timePicker;

  /// When false, dot grid mesh and starfields are skipped (Material fallbacks).
  final bool heavyEffectsEnabled;

  factory TermosThemeData.dark() => TermosThemeData(
    colors: TermosColors.dark,
    dotGrid: const DotGridConfig(),
    textStyles: TermosTextStyles.fromColors(TermosColors.dark),
  );

  factory TermosThemeData.light() => TermosThemeData(
    colors: TermosColors.light,
    dotGrid: const DotGridConfig(),
    textStyles: TermosTextStyles.fromColors(TermosColors.light),
  );

  factory TermosThemeData.fallbackBrightness(Brightness brightness) =>
      brightness == Brightness.light
      ? TermosThemeData.light()
      : TermosThemeData.dark();

  @override
  TermosThemeData copyWith({
    TermosColors? colors,
    DotGridConfig? dotGrid,
    TermosTextStyles? textStyles,
    TermosMetrics? metrics,
    TermosStarfieldConfig? starfield,
    TermosNavBarEffects? navBar,
    TermosTabBarEffects? tabBar,
    TermosSegmentedEffects? segmented,
    TermosButtonEffects? button,
    TermosCrtEffects? crt,
    TermosTimePickerEffects? timePicker,
    bool? heavyEffectsEnabled,
  }) {
    return TermosThemeData(
      colors: colors ?? this.colors,
      dotGrid: dotGrid ?? this.dotGrid,
      textStyles: textStyles ?? this.textStyles,
      metrics: metrics ?? this.metrics,
      starfield: starfield ?? this.starfield,
      navBar: navBar ?? this.navBar,
      tabBar: tabBar ?? this.tabBar,
      segmented: segmented ?? this.segmented,
      button: button ?? this.button,
      crt: crt ?? this.crt,
      timePicker: timePicker ?? this.timePicker,
      heavyEffectsEnabled: heavyEffectsEnabled ?? this.heavyEffectsEnabled,
    );
  }

  @override
  TermosThemeData lerp(covariant TermosThemeData? other, double t) {
    if (other == null) return this;
    return TermosThemeData(
      colors: colors.lerp(other.colors, t),
      dotGrid: dotGrid.lerp(other.dotGrid, t),
      textStyles: textStyles.lerp(other.textStyles, t),
      metrics: metrics.lerp(other.metrics, t),
      starfield: starfield.lerp(other.starfield, t),
      navBar: navBar.lerp(other.navBar, t),
      tabBar: tabBar.lerp(other.tabBar, t),
      segmented: segmented.lerp(other.segmented, t),
      button: button.lerp(other.button, t),
      crt: crt.lerp(other.crt, t),
      timePicker: timePicker.lerp(other.timePicker, t),
      heavyEffectsEnabled: t < 0.5
          ? heavyEffectsEnabled
          : other.heavyEffectsEnabled,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TermosThemeData &&
          colors == other.colors &&
          dotGrid == other.dotGrid &&
          textStyles == other.textStyles &&
          metrics == other.metrics &&
          starfield == other.starfield &&
          navBar == other.navBar &&
          tabBar == other.tabBar &&
          segmented == other.segmented &&
          button == other.button &&
          crt == other.crt &&
          timePicker == other.timePicker &&
          heavyEffectsEnabled == other.heavyEffectsEnabled;

  @override
  int get hashCode => Object.hash(
    colors,
    dotGrid,
    textStyles,
    metrics,
    starfield,
    navBar,
    tabBar,
    segmented,
    button,
    crt,
    timePicker,
    heavyEffectsEnabled,
  );
}

/// Provides [TermosThemeData] to descendant widgets (Flutter-style inherited theme).
class TermosTheme extends InheritedWidget {
  const TermosTheme({super.key, required this.data, required super.child});

  final TermosThemeData data;

  static TermosThemeData of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<TermosTheme>();
    if (scope != null) return scope.data;
    final ext = Theme.of(context).extension<TermosThemeData>();
    if (ext != null) return ext;
    return TermosThemeData.fallbackBrightness(Theme.of(context).brightness);
  }

  /// Does not register a dependency (use when you only need a one-time read).
  static TermosThemeData? maybeOf(BuildContext context) {
    return context.getInheritedWidgetOfExactType<TermosTheme>()?.data;
  }

  @override
  bool updateShouldNotify(TermosTheme oldWidget) => data != oldWidget.data;
}
