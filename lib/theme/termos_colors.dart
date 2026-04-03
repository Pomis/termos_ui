import 'package:flutter/material.dart';

/// Semantic color tokens for Termos widgets (brightness-aware).
class TermosColors {
  const TermosColors({
    required this.primary,
    required this.background,
    required this.surface,
    required this.card,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
    required this.dotGridButtonBorder,
    required this.dotGridIdleMesh,
    required this.syntaxOperator,
  });

  final Color primary;
  final Color background;
  final Color surface;
  final Color card;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color success;
  final Color warning;
  final Color error;
  final Color info;

  /// Border for dot-grid buttons (back, action, etc.).
  final Color dotGridButtonBorder;

  /// Idle mesh/background for dot grid.
  final Color dotGridIdleMesh;

  /// Accent for operators in command syntax (optional use).
  final Color syntaxOperator;

  static const TermosColors dark = TermosColors(
    primary: Color(0xFF4ADE80),
    background: Color(0xFF0A0A0A),
    surface: Color(0xFF141414),
    card: Color(0xFF1A1A1A),
    border: Color(0xFF2A2A2A),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFF888888),
    textMuted: Color(0xFF555555),
    success: Color(0xFF4ADE80),
    warning: Color(0xFFF59E0B),
    error: Color(0xFFEF4444),
    info: Color(0xFF3B82F6),
    dotGridButtonBorder: Color(0xFF2A2A2A),
    dotGridIdleMesh: Color(0x0AFFFFFF),
    syntaxOperator: Color(0xFFFB923C),
  );

  static const TermosColors light = TermosColors(
    primary: Color(0xFF16A34A),
    background: Color(0xFFFAFAFA),
    surface: Color(0xFFF5F5F5),
    card: Color(0xFFFFFFFF),
    border: Color(0xFFE5E5E5),
    textPrimary: Color(0xFF1A1A1A),
    textSecondary: Color(0xFF424242),
    textMuted: Color(0xFF525252),
    success: Color(0xFF16A34A),
    warning: Color(0xFFEA580C),
    error: Color(0xFFDC2626),
    info: Color(0xFF2563EB),
    dotGridButtonBorder: Color(0xFFBDBDBD),
    dotGridIdleMesh: Color(0x0D000000),
    syntaxOperator: Color(0xFFEA580C),
  );

  static TermosColors forBrightness(Brightness brightness) =>
      brightness == Brightness.light ? light : dark;

  TermosColors copyWith({
    Color? primary,
    Color? background,
    Color? surface,
    Color? card,
    Color? border,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? success,
    Color? warning,
    Color? error,
    Color? info,
    Color? dotGridButtonBorder,
    Color? dotGridIdleMesh,
    Color? syntaxOperator,
  }) {
    return TermosColors(
      primary: primary ?? this.primary,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      card: card ?? this.card,
      border: border ?? this.border,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      info: info ?? this.info,
      dotGridButtonBorder: dotGridButtonBorder ?? this.dotGridButtonBorder,
      dotGridIdleMesh: dotGridIdleMesh ?? this.dotGridIdleMesh,
      syntaxOperator: syntaxOperator ?? this.syntaxOperator,
    );
  }

  TermosColors lerp(TermosColors other, double t) {
    return TermosColors(
      primary: Color.lerp(primary, other.primary, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      card: Color.lerp(card, other.card, t)!,
      border: Color.lerp(border, other.border, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      error: Color.lerp(error, other.error, t)!,
      info: Color.lerp(info, other.info, t)!,
      dotGridButtonBorder: Color.lerp(dotGridButtonBorder, other.dotGridButtonBorder, t)!,
      dotGridIdleMesh: Color.lerp(dotGridIdleMesh, other.dotGridIdleMesh, t)!,
      syntaxOperator: Color.lerp(syntaxOperator, other.syntaxOperator, t)!,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TermosColors &&
          runtimeType == other.runtimeType &&
          primary == other.primary &&
          background == other.background &&
          surface == other.surface &&
          card == other.card &&
          border == other.border &&
          textPrimary == other.textPrimary &&
          textSecondary == other.textSecondary &&
          textMuted == other.textMuted &&
          success == other.success &&
          warning == other.warning &&
          error == other.error &&
          info == other.info &&
          dotGridButtonBorder == other.dotGridButtonBorder &&
          dotGridIdleMesh == other.dotGridIdleMesh &&
          syntaxOperator == other.syntaxOperator;

  @override
  int get hashCode => Object.hashAll([
        primary,
        background,
        surface,
        card,
        border,
        textPrimary,
        textSecondary,
        textMuted,
        success,
        warning,
        error,
        info,
        dotGridButtonBorder,
        dotGridIdleMesh,
        syntaxOperator,
      ]);
}
