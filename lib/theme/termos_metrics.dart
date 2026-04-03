import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// Layout tokens: radii, paddings, sizes — set once per theme, applied by Termos widgets.
class TermosMetrics {
  const TermosMetrics({
    // ── Shared chrome ──
    /// Rounded corners for [TermosButton], [TermosBackButton], [TermosSegmentedSelector],
    /// [TermosTimePicker], [TermosSwitch], [TermosCrt], and related clips.
    this.borderRadius = 8,
    this.buttonHeight = 44,
    this.buttonIconSize = 20,
    this.buttonIconSpacing = 8,
    this.buttonLoadingSpinnerSize = 16,
    this.buttonLoadingSpinnerSlotSize = 20,
    this.buttonDisabledTransitionMs = 200,
    /// Left/right inset for label + icon when the button shrink-wraps ([TermosButton.expandWidth] false).
    this.buttonHorizontalPadding = 16,
    // ── Back button ──
    this.backButtonDefaultSize = 54,
    this.backButtonPadding = const EdgeInsets.fromLTRB(12, 18, 12, 18),
    this.backButtonBackgroundBlend = 0.5,
    this.backButtonGlyph = '<-',
    // ── Tap target fallback ──
    this.tapTargetDefaultBorderRadius = 8,
    // ── Nav bar ──
    this.navBarHorizontalPadding = 8,
    this.navBarOuterHorizontalPadding = 32,
    this.navBarOuterBottomPadding = 20,
    this.navBarHeight = 72,
    this.navBarCornerRadius = 28,
    this.navBarItemVerticalPadding = 6,
    this.navBarIconSize = 24,
    this.navBarIconLabelGap = 4,
    this.navBarBorderAnimationMs = 400,
    // ── Segmented selector ──
    this.segmentedHeight = 44,
    this.segmentedGlowAnimationMs = 320,
    // ── Time picker ──
    this.timePickerWheelWidth = 72,
    this.timePickerItemExtent = 40,
    this.timePickerVisibleItems = 3,
    this.timePickerPulseAnimationMs = 1200,
    // ── CRT ──
    this.crtScanlineOpacity = 0.06,
    this.crtVignetteStrength = 0.5,
    this.crtOuterBorderWidth = 1,
    // ── Glow painter (shared) ──
    this.glowTopBorderStrokeWidth = 2,
  });

  final double borderRadius;
  final double buttonHeight;
  final double buttonIconSize;
  final double buttonIconSpacing;
  final double buttonLoadingSpinnerSize;
  final double buttonLoadingSpinnerSlotSize;
  final int buttonDisabledTransitionMs;
  final double buttonHorizontalPadding;

  final double backButtonDefaultSize;
  final EdgeInsets backButtonPadding;

  /// [Color.lerp](background, card, this) for back button fill.
  final double backButtonBackgroundBlend;

  /// Shown when [TermosBackButton.label] is null.
  final String backButtonGlyph;

  final double tapTargetDefaultBorderRadius;

  final double navBarHorizontalPadding;
  final double navBarOuterHorizontalPadding;
  final double navBarOuterBottomPadding;
  final double navBarHeight;
  final double navBarCornerRadius;
  final double navBarItemVerticalPadding;
  final double navBarIconSize;
  final double navBarIconLabelGap;
  final int navBarBorderAnimationMs;

  final double segmentedHeight;
  final int segmentedGlowAnimationMs;

  final double timePickerWheelWidth;
  final double timePickerItemExtent;
  final int timePickerVisibleItems;
  final int timePickerPulseAnimationMs;

  final double crtScanlineOpacity;
  final double crtVignetteStrength;
  final double crtOuterBorderWidth;

  final double glowTopBorderStrokeWidth;

  static const TermosMetrics standard = TermosMetrics();

  Duration get buttonDisabledTransitionDuration =>
      Duration(milliseconds: buttonDisabledTransitionMs);

  Duration get navBarBorderAnimationDuration => Duration(milliseconds: navBarBorderAnimationMs);

  Duration get segmentedGlowAnimationDuration => Duration(milliseconds: segmentedGlowAnimationMs);

  Duration get timePickerPulseAnimationDuration =>
      Duration(milliseconds: timePickerPulseAnimationMs);

  TermosMetrics copyWith({
    double? borderRadius,
    double? buttonHeight,
    double? buttonIconSize,
    double? buttonIconSpacing,
    double? buttonLoadingSpinnerSize,
    double? buttonLoadingSpinnerSlotSize,
    int? buttonDisabledTransitionMs,
    double? buttonHorizontalPadding,
    double? backButtonDefaultSize,
    EdgeInsets? backButtonPadding,
    double? backButtonBackgroundBlend,
    String? backButtonGlyph,
    double? tapTargetDefaultBorderRadius,
    double? navBarHorizontalPadding,
    double? navBarOuterHorizontalPadding,
    double? navBarOuterBottomPadding,
    double? navBarHeight,
    double? navBarCornerRadius,
    double? navBarItemVerticalPadding,
    double? navBarIconSize,
    double? navBarIconLabelGap,
    int? navBarBorderAnimationMs,
    double? segmentedHeight,
    int? segmentedGlowAnimationMs,
    double? timePickerWheelWidth,
    double? timePickerItemExtent,
    int? timePickerVisibleItems,
    int? timePickerPulseAnimationMs,
    double? crtScanlineOpacity,
    double? crtVignetteStrength,
    double? crtOuterBorderWidth,
    double? glowTopBorderStrokeWidth,
  }) {
    return TermosMetrics(
      borderRadius: borderRadius ?? this.borderRadius,
      buttonHeight: buttonHeight ?? this.buttonHeight,
      buttonIconSize: buttonIconSize ?? this.buttonIconSize,
      buttonIconSpacing: buttonIconSpacing ?? this.buttonIconSpacing,
      buttonLoadingSpinnerSize: buttonLoadingSpinnerSize ?? this.buttonLoadingSpinnerSize,
      buttonLoadingSpinnerSlotSize:
          buttonLoadingSpinnerSlotSize ?? this.buttonLoadingSpinnerSlotSize,
      buttonDisabledTransitionMs: buttonDisabledTransitionMs ?? this.buttonDisabledTransitionMs,
      buttonHorizontalPadding: buttonHorizontalPadding ?? this.buttonHorizontalPadding,
      backButtonDefaultSize: backButtonDefaultSize ?? this.backButtonDefaultSize,
      backButtonPadding: backButtonPadding ?? this.backButtonPadding,
      backButtonBackgroundBlend: backButtonBackgroundBlend ?? this.backButtonBackgroundBlend,
      backButtonGlyph: backButtonGlyph ?? this.backButtonGlyph,
      tapTargetDefaultBorderRadius:
          tapTargetDefaultBorderRadius ?? this.tapTargetDefaultBorderRadius,
      navBarHorizontalPadding: navBarHorizontalPadding ?? this.navBarHorizontalPadding,
      navBarOuterHorizontalPadding:
          navBarOuterHorizontalPadding ?? this.navBarOuterHorizontalPadding,
      navBarOuterBottomPadding: navBarOuterBottomPadding ?? this.navBarOuterBottomPadding,
      navBarHeight: navBarHeight ?? this.navBarHeight,
      navBarCornerRadius: navBarCornerRadius ?? this.navBarCornerRadius,
      navBarItemVerticalPadding: navBarItemVerticalPadding ?? this.navBarItemVerticalPadding,
      navBarIconSize: navBarIconSize ?? this.navBarIconSize,
      navBarIconLabelGap: navBarIconLabelGap ?? this.navBarIconLabelGap,
      navBarBorderAnimationMs: navBarBorderAnimationMs ?? this.navBarBorderAnimationMs,
      segmentedHeight: segmentedHeight ?? this.segmentedHeight,
      segmentedGlowAnimationMs: segmentedGlowAnimationMs ?? this.segmentedGlowAnimationMs,
      timePickerWheelWidth: timePickerWheelWidth ?? this.timePickerWheelWidth,
      timePickerItemExtent: timePickerItemExtent ?? this.timePickerItemExtent,
      timePickerVisibleItems: timePickerVisibleItems ?? this.timePickerVisibleItems,
      timePickerPulseAnimationMs: timePickerPulseAnimationMs ?? this.timePickerPulseAnimationMs,
      crtScanlineOpacity: crtScanlineOpacity ?? this.crtScanlineOpacity,
      crtVignetteStrength: crtVignetteStrength ?? this.crtVignetteStrength,
      crtOuterBorderWidth: crtOuterBorderWidth ?? this.crtOuterBorderWidth,
      glowTopBorderStrokeWidth: glowTopBorderStrokeWidth ?? this.glowTopBorderStrokeWidth,
    );
  }

  TermosMetrics lerp(TermosMetrics other, double t) {
    return TermosMetrics(
      borderRadius: lerpDouble(borderRadius, other.borderRadius, t)!,
      buttonHeight: lerpDouble(buttonHeight, other.buttonHeight, t)!,
      buttonIconSize: lerpDouble(buttonIconSize, other.buttonIconSize, t)!,
      buttonIconSpacing: lerpDouble(buttonIconSpacing, other.buttonIconSpacing, t)!,
      buttonLoadingSpinnerSize: lerpDouble(
        buttonLoadingSpinnerSize,
        other.buttonLoadingSpinnerSize,
        t,
      )!,
      buttonLoadingSpinnerSlotSize: lerpDouble(
        buttonLoadingSpinnerSlotSize,
        other.buttonLoadingSpinnerSlotSize,
        t,
      )!,
      buttonDisabledTransitionMs: lerpDouble(
        buttonDisabledTransitionMs.toDouble(),
        other.buttonDisabledTransitionMs.toDouble(),
        t,
      )!.round(),
      buttonHorizontalPadding: lerpDouble(
        buttonHorizontalPadding,
        other.buttonHorizontalPadding,
        t,
      )!,
      backButtonDefaultSize: lerpDouble(backButtonDefaultSize, other.backButtonDefaultSize, t)!,
      backButtonPadding: EdgeInsets.lerp(backButtonPadding, other.backButtonPadding, t)!,
      backButtonBackgroundBlend: lerpDouble(
        backButtonBackgroundBlend,
        other.backButtonBackgroundBlend,
        t,
      )!,
      backButtonGlyph: t < 0.5 ? backButtonGlyph : other.backButtonGlyph,
      tapTargetDefaultBorderRadius: lerpDouble(
        tapTargetDefaultBorderRadius,
        other.tapTargetDefaultBorderRadius,
        t,
      )!,
      navBarHorizontalPadding: lerpDouble(
        navBarHorizontalPadding,
        other.navBarHorizontalPadding,
        t,
      )!,
      navBarOuterHorizontalPadding: lerpDouble(
        navBarOuterHorizontalPadding,
        other.navBarOuterHorizontalPadding,
        t,
      )!,
      navBarOuterBottomPadding: lerpDouble(
        navBarOuterBottomPadding,
        other.navBarOuterBottomPadding,
        t,
      )!,
      navBarHeight: lerpDouble(navBarHeight, other.navBarHeight, t)!,
      navBarCornerRadius: lerpDouble(navBarCornerRadius, other.navBarCornerRadius, t)!,
      navBarItemVerticalPadding: lerpDouble(
        navBarItemVerticalPadding,
        other.navBarItemVerticalPadding,
        t,
      )!,
      navBarIconSize: lerpDouble(navBarIconSize, other.navBarIconSize, t)!,
      navBarIconLabelGap: lerpDouble(navBarIconLabelGap, other.navBarIconLabelGap, t)!,
      navBarBorderAnimationMs: lerpDouble(
        navBarBorderAnimationMs.toDouble(),
        other.navBarBorderAnimationMs.toDouble(),
        t,
      )!.round(),
      segmentedHeight: lerpDouble(segmentedHeight, other.segmentedHeight, t)!,
      segmentedGlowAnimationMs: lerpDouble(
        segmentedGlowAnimationMs.toDouble(),
        other.segmentedGlowAnimationMs.toDouble(),
        t,
      )!.round(),
      timePickerWheelWidth: lerpDouble(timePickerWheelWidth, other.timePickerWheelWidth, t)!,
      timePickerItemExtent: lerpDouble(timePickerItemExtent, other.timePickerItemExtent, t)!,
      timePickerVisibleItems: lerpDouble(
        timePickerVisibleItems.toDouble(),
        other.timePickerVisibleItems.toDouble(),
        t,
      )!.round(),
      timePickerPulseAnimationMs: lerpDouble(
        timePickerPulseAnimationMs.toDouble(),
        other.timePickerPulseAnimationMs.toDouble(),
        t,
      )!.round(),
      crtScanlineOpacity: lerpDouble(crtScanlineOpacity, other.crtScanlineOpacity, t)!,
      crtVignetteStrength: lerpDouble(crtVignetteStrength, other.crtVignetteStrength, t)!,
      crtOuterBorderWidth: lerpDouble(crtOuterBorderWidth, other.crtOuterBorderWidth, t)!,
      glowTopBorderStrokeWidth: lerpDouble(
        glowTopBorderStrokeWidth,
        other.glowTopBorderStrokeWidth,
        t,
      )!,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TermosMetrics &&
          runtimeType == other.runtimeType &&
          borderRadius == other.borderRadius &&
          buttonHeight == other.buttonHeight &&
          buttonIconSize == other.buttonIconSize &&
          buttonIconSpacing == other.buttonIconSpacing &&
          buttonLoadingSpinnerSize == other.buttonLoadingSpinnerSize &&
          buttonLoadingSpinnerSlotSize == other.buttonLoadingSpinnerSlotSize &&
          buttonDisabledTransitionMs == other.buttonDisabledTransitionMs &&
          buttonHorizontalPadding == other.buttonHorizontalPadding &&
          backButtonDefaultSize == other.backButtonDefaultSize &&
          backButtonPadding == other.backButtonPadding &&
          backButtonBackgroundBlend == other.backButtonBackgroundBlend &&
          backButtonGlyph == other.backButtonGlyph &&
          tapTargetDefaultBorderRadius == other.tapTargetDefaultBorderRadius &&
          navBarHorizontalPadding == other.navBarHorizontalPadding &&
          navBarOuterHorizontalPadding == other.navBarOuterHorizontalPadding &&
          navBarOuterBottomPadding == other.navBarOuterBottomPadding &&
          navBarHeight == other.navBarHeight &&
          navBarCornerRadius == other.navBarCornerRadius &&
          navBarItemVerticalPadding == other.navBarItemVerticalPadding &&
          navBarIconSize == other.navBarIconSize &&
          navBarIconLabelGap == other.navBarIconLabelGap &&
          navBarBorderAnimationMs == other.navBarBorderAnimationMs &&
          segmentedHeight == other.segmentedHeight &&
          segmentedGlowAnimationMs == other.segmentedGlowAnimationMs &&
          timePickerWheelWidth == other.timePickerWheelWidth &&
          timePickerItemExtent == other.timePickerItemExtent &&
          timePickerVisibleItems == other.timePickerVisibleItems &&
          timePickerPulseAnimationMs == other.timePickerPulseAnimationMs &&
          crtScanlineOpacity == other.crtScanlineOpacity &&
          crtVignetteStrength == other.crtVignetteStrength &&
          crtOuterBorderWidth == other.crtOuterBorderWidth &&
          glowTopBorderStrokeWidth == other.glowTopBorderStrokeWidth;

  @override
  int get hashCode => Object.hashAll([
    borderRadius,
    buttonHeight,
    buttonIconSize,
    buttonIconSpacing,
    buttonLoadingSpinnerSize,
    buttonLoadingSpinnerSlotSize,
    buttonDisabledTransitionMs,
    buttonHorizontalPadding,
    backButtonDefaultSize,
    backButtonPadding,
    backButtonBackgroundBlend,
    backButtonGlyph,
    tapTargetDefaultBorderRadius,
    navBarHorizontalPadding,
    navBarOuterHorizontalPadding,
    navBarOuterBottomPadding,
    navBarHeight,
    navBarCornerRadius,
    navBarItemVerticalPadding,
    navBarIconSize,
    navBarIconLabelGap,
    navBarBorderAnimationMs,
    segmentedHeight,
    segmentedGlowAnimationMs,
    timePickerWheelWidth,
    timePickerItemExtent,
    timePickerVisibleItems,
    timePickerPulseAnimationMs,
    crtScanlineOpacity,
    crtVignetteStrength,
    crtOuterBorderWidth,
    glowTopBorderStrokeWidth,
  ]);
}
