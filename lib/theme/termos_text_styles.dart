import 'package:flutter/material.dart';

import 'termos_colors.dart';

/// Default font family names used by [TermosTextStyles.fromColors].
///
/// The library does **not** bundle or fetch these fonts. The consuming app must
/// make them available — either via `google_fonts`, bundled assets, or system
/// fonts. Override individual styles with [TermosTextStyles] constructor if you
/// use different family names.
abstract final class TermosFontFamilies {
  static const String code = 'Fira Code';
  static const String heading = 'Outfit';
  static const String body = 'Inter';
}

/// Text styles for code (Fira Code) and prose. Built from [TermosColors].
///
/// Fonts are referenced by family name only — the consuming app is responsible
/// for providing them (e.g. via `google_fonts` or bundled assets).
class TermosTextStyles {
  const TermosTextStyles({
    required this.terminalHeader,
    required this.navLabel,
    required this.sectionTitle,
    required this.body,
    required this.codePrimary,
    required this.switchLabel,
    required this.timePickerWheel,
    required this.timePickerColon,
  });

  /// Primary button / label (Fira Code 14, w500).
  final TextStyle Function(Color color) terminalHeader;

  /// Bottom nav labels (Fira Code 13).
  final TextStyle Function({required bool selected, required Color color}) navLabel;

  /// Section titles (Outfit 18).
  final TextStyle Function(Color color) sectionTitle;

  /// Body text (Inter 14).
  final TextStyle Function(Color color) body;

  /// Code primary (Fira Code 14).
  final TextStyle Function(Color color) codePrimary;

  /// ON/OFF label inside [TermosSwitch] (Fira Code 14, w700).
  final TextStyle Function(Color color) switchLabel;

  /// Drum wheel digits inside [TermosTimePicker] (Fira Code, w600).
  final TextStyle Function(Color color, {required double fontSize}) timePickerWheel;

  /// Colon separator inside [TermosTimePicker] (Fira Code, bold).
  final TextStyle Function(Color color, {required double fontSize}) timePickerColon;

  static TermosTextStyles fromColors(TermosColors colors) {
    final isLight = colors.background.computeLuminance() > 0.5;
    return TermosTextStyles(
      terminalHeader: (Color color) => TextStyle(
            fontFamily: TermosFontFamilies.code,
            fontSize: 14,
            color: color,
            fontWeight: FontWeight.w500,
          ),
      navLabel: ({required bool selected, required Color color}) => TextStyle(
            fontFamily: TermosFontFamilies.code,
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: color,
            letterSpacing: 0.5,
          ),
      sectionTitle: (Color color) => TextStyle(
            fontFamily: TermosFontFamilies.heading,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: color,
          ),
      body: (Color color) => TextStyle(
            fontFamily: TermosFontFamilies.body,
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: color,
            letterSpacing: 0.1,
            height: 1.5,
          ),
      codePrimary: (Color color) => TextStyle(
            fontFamily: TermosFontFamilies.code,
            fontSize: 14,
            height: 1.4,
            letterSpacing: 0,
            color: color,
            fontWeight: isLight ? FontWeight.w600 : FontWeight.normal,
          ),
      switchLabel: (Color color) => TextStyle(
            fontFamily: TermosFontFamilies.code,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: color,
            height: 1,
          ),
      timePickerWheel: (Color color, {required double fontSize}) => TextStyle(
            fontFamily: TermosFontFamilies.code,
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            color: color,
            height: 1,
          ),
      timePickerColon: (Color color, {required double fontSize}) => TextStyle(
            fontFamily: TermosFontFamilies.code,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: color,
            height: 1,
          ),
    );
  }

  TermosTextStyles lerp(TermosTextStyles other, double t) {
    if (t < 0.5) return this;
    return other;
  }
}
