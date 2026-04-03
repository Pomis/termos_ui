import 'package:flutter/material.dart';
import 'package:termos_ui/termos_ui.dart';

/// Bundled Material **Roboto** only (no `google_fonts` HTTP loads).
///
/// Explicit [fontFamily] is required in widget tests; otherwise glyphs can render
/// as placeholder squares.
TermosTextStyles galleryTestTextStyles(TermosColors colors) {
  final isLight = colors.background.computeLuminance() > 0.5;
  return TermosTextStyles(
    terminalHeader: (Color color) => TextStyle(
      fontFamily: 'Roboto',
      fontSize: 14,
      color: color,
      fontWeight: FontWeight.w500,
    ),
    navLabel: ({required bool selected, required Color color}) => TextStyle(
      fontFamily: 'Roboto',
      fontSize: 13,
      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
      color: color,
      letterSpacing: 0.5,
    ),
    sectionTitle: (Color color) => TextStyle(
      fontFamily: 'Roboto',
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: color,
    ),
    body: (Color color) => TextStyle(
      fontFamily: 'Roboto',
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.1,
      height: 1.5,
      color: color,
    ),
    codePrimary: (Color color) => TextStyle(
      fontFamily: 'Roboto',
      fontSize: 14,
      height: 1.4,
      letterSpacing: 0,
      color: color,
      fontWeight: isLight ? FontWeight.w600 : FontWeight.normal,
    ),
    switchLabel: (Color color) => TextStyle(
      fontFamily: 'Roboto',
      fontSize: 14,
      fontWeight: FontWeight.w700,
      color: color,
      height: 1,
    ),
    timePickerWheel: (Color color, {required double fontSize}) => TextStyle(
      fontFamily: 'Roboto',
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      color: color,
      height: 1,
    ),
    timePickerColon: (Color color, {required double fontSize}) => TextStyle(
      fontFamily: 'Roboto',
      fontSize: fontSize,
      fontWeight: FontWeight.bold,
      color: color,
      height: 1,
    ),
  );
}
