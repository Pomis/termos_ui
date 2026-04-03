import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'termos_colors.dart';

/// Text styles for code (FiraCode) and prose. Built from [TermosColors].
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

  /// Primary button / label (FiraCode 14, w500).
  final TextStyle Function(Color color) terminalHeader;

  /// Bottom nav labels (FiraCode 13).
  final TextStyle Function({required bool selected, required Color color}) navLabel;

  /// Section titles (Outfit 18).
  final TextStyle Function(Color color) sectionTitle;

  /// Body text (Inter 14).
  final TextStyle Function(Color color) body;

  /// Code primary (FiraCode 14).
  final TextStyle Function(Color color) codePrimary;

  /// ON/OFF label inside [TermosSwitch] (FiraCode 14, w700).
  final TextStyle Function(Color color) switchLabel;

  /// Drum wheel digits inside [TermosTimePicker] (FiraCode, w600).
  final TextStyle Function(Color color, {required double fontSize}) timePickerWheel;

  /// Colon separator inside [TermosTimePicker] (FiraCode, bold).
  final TextStyle Function(Color color, {required double fontSize}) timePickerColon;

  static TermosTextStyles fromColors(TermosColors colors) {
    final isLight = colors.background.computeLuminance() > 0.5;
    return TermosTextStyles(
      terminalHeader: (Color color) => GoogleFonts.firaCode(
            fontSize: 14,
            color: color,
            fontWeight: FontWeight.w500,
          ),
      navLabel: ({required bool selected, required Color color}) =>
          GoogleFonts.firaCode(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: color,
            letterSpacing: 0.5,
          ),
      sectionTitle: (Color color) => GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: color,
          ),
      body: (Color color) => GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: color,
            letterSpacing: 0.1,
            height: 1.5,
          ),
      codePrimary: (Color color) => GoogleFonts.firaCode(
            fontSize: 14,
            height: 1.4,
            letterSpacing: 0,
            color: color,
            fontWeight: isLight ? FontWeight.w600 : FontWeight.normal,
          ),
      switchLabel: (Color color) => GoogleFonts.firaCode(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: color,
            height: 1,
          ),
      timePickerWheel: (Color color, {required double fontSize}) =>
          GoogleFonts.firaCode(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            color: color,
            height: 1,
          ),
      timePickerColon: (Color color, {required double fontSize}) =>
          GoogleFonts.firaCode(
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
