import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/dot_grid/dot_grid_widget.dart';
import '../painters/edge_glow_painter.dart';
import '../painters/vertical_starfield_painter.dart';
import '../theme/termos_theme.dart';

/// Text style variant for [TermosTextField]: monospace ([code]) or proportional ([prose]).
enum TermosTextFieldStyle { code, prose }

/// Themed text field with dot-grid mesh background, right-edge glow, and
/// reactive starfield on focus. Reads colors / dot grid config / metrics from
/// [TermosTheme].
///
/// When [TermosThemeData.heavyEffectsEnabled] is false the field falls back to
/// a simpler bordered container with a dim overlay.
///
/// ```dart
/// TermosTextField(
///   label: 'Command',
///   controller: _ctrl,
///   hintText: 'ls -la',
/// )
/// ```
class TermosTextField extends StatefulWidget {
  const TermosTextField({
    super.key,
    this.label,
    required this.controller,
    this.focusNode,
    this.hintText,
    this.textFieldStyle = TermosTextFieldStyle.code,
    this.style,
    this.hintStyle,
    this.maxLines = 1,
    this.minLines,
    this.autofocus = false,
    this.enabled = true,
    this.readOnly = false,
    this.obscureText = false,
    this.onChanged,
    this.onSubmitted,
    this.textInputAction,
    this.keyboardType,
    this.inputFormatters,
    this.suffixIcon,
    this.labelSpacing = 8,
  });

  /// Optional label shown above the field.
  final String? label;

  final TextEditingController controller;
  final FocusNode? focusNode;
  final String? hintText;

  /// Selects the default text style: [TermosTextFieldStyle.code] (FiraCode) or
  /// [TermosTextFieldStyle.prose] (Inter). Ignored when [style] is provided.
  final TermosTextFieldStyle textFieldStyle;

  /// Explicit text style override.
  final TextStyle? style;

  /// Explicit hint style override.
  final TextStyle? hintStyle;

  final int maxLines;
  final int? minLines;
  final bool autofocus;
  final bool enabled;
  final bool readOnly;
  final bool obscureText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? suffixIcon;

  /// Vertical gap between [label] and the text field (default 8).
  final double labelSpacing;

  @override
  State<TermosTextField> createState() => _TermosTextFieldState();
}

class _TermosTextFieldState extends State<TermosTextField> {
  late FocusNode _focusNode;
  var _ownsFocusNode = false;

  @override
  void initState() {
    super.initState();
    if (widget.focusNode != null) {
      _focusNode = widget.focusNode!;
    } else {
      _focusNode = FocusNode();
      _ownsFocusNode = true;
    }
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(TermosTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      oldWidget.focusNode?.removeListener(_onFocusChanged);
      if (_ownsFocusNode) {
        _focusNode.removeListener(_onFocusChanged);
        _focusNode.dispose();
      }
      _ownsFocusNode = widget.focusNode == null;
      _focusNode = widget.focusNode ?? FocusNode();
      _focusNode.addListener(_onFocusChanged);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    if (_ownsFocusNode) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChanged() => setState(() {});

  int? _effectiveMaxLines() {
    if (widget.maxLines != 1) return widget.maxLines;
    final minLines = widget.minLines;
    if (minLines != null && minLines > 1) return null;
    return 1;
  }

  double _resolvedGlowY() {
    final ml = widget.minLines ?? 1;
    if (ml >= 4) return 52;
    if (ml >= 2) return 34;
    return 26;
  }

  @override
  Widget build(BuildContext context) {
    final termos = TermosTheme.of(context);
    final colors = termos.colors;
    final textStyles = termos.textStyles;
    final metrics = termos.metrics;
    final dotGrid = termos.dotGrid;
    final isLight = colors.background.computeLuminance() > 0.5;
    final focused = _focusNode.hasFocus;

    final resolvedStyle = widget.style ??
        (widget.textFieldStyle == TermosTextFieldStyle.code
            ? textStyles.codePrimary(colors.textPrimary)
            : textStyles.body(colors.textPrimary).copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ));

    final resolvedHintStyle = widget.hintStyle ??
        (widget.textFieldStyle == TermosTextFieldStyle.code
            ? textStyles.codePrimary(colors.textMuted)
            : textStyles.body(colors.textMuted).copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ));

    final borderRadius = BorderRadius.circular(metrics.borderRadius);
    final meshPrimaryAlpha = isLight ? 0.65 : 0.45;

    final textField = TextField(
      controller: widget.controller,
      focusNode: _focusNode,
      autofocus: widget.autofocus,
      minLines: widget.minLines,
      maxLines: _effectiveMaxLines(),
      style: resolvedStyle,
      cursorColor: colors.primary,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      obscureText: widget.obscureText,
      textInputAction: widget.textInputAction,
      keyboardType: widget.keyboardType,
      inputFormatters: widget.inputFormatters,
      onSubmitted: widget.onSubmitted,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: Colors.transparent,
        hoverColor: Colors.transparent,
        hintText: widget.hintText,
        hintStyle: resolvedHintStyle,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
        contentPadding: EdgeInsets.zero,
        suffixIcon: widget.suffixIcon,
        suffixIconConstraints: widget.suffixIcon != null
            ? const BoxConstraints(minHeight: 40, minWidth: 40)
            : null,
      ),
    );

    Widget panel;

    if (termos.heavyEffectsEnabled) {
      panel = CustomPaint(
        foregroundPainter: focused
            ? TermosEdgeGlowPainter(
                glowCenterY: _resolvedGlowY(),
                glowColor: colors.primary,
                baseColor: colors.primary.withValues(alpha: 0.06),
                strokeWidth: metrics.glowTopBorderStrokeWidth,
                borderRadius: metrics.borderRadius,
                spotlightIntensity: 0.6,
                spotlightSpread: 5.0,
                blurSigma: 7,
                haloStrokeExtra: 4,
              )
            : null,
        child: ClipRRect(
          borderRadius: borderRadius,
          child: DotGridWidget(
            dotSize: dotGrid.dotSize,
            gridSpacing: dotGrid.spacing,
            primaryColor:
                colors.primary.withValues(alpha: meshPrimaryAlpha),
            backgroundColor: colors.dotGridIdleMesh,
            blobRadius: dotGrid.blobRadius,
            enableHoverEffect: false,
            expansionDuration: const Duration(milliseconds: 100),
            decayDuration: const Duration(milliseconds: 280),
            child: Stack(
              children: [
                Positioned.fill(
                  child: ColoredBox(
                    color: isLight
                        ? Colors.black.withValues(alpha: 0.04)
                        : Colors.black.withValues(alpha: 0.35),
                  ),
                ),
                if (focused)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: CustomPaint(
                        painter: TermosVerticalStarfieldPainter(
                          dotSize: dotGrid.dotSize,
                          gridSpacing: dotGrid.spacing,
                          glowCenterY: _resolvedGlowY(),
                          glowColor: colors.primary,
                          reactiveFraction: 0.24,
                          maxAlpha: 0.20,
                          highlightRadiusXFactor: 2.35,
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 14),
                  child: textField,
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      panel = ClipRRect(
        borderRadius: borderRadius,
        child: Stack(
          children: [
            Positioned.fill(
              child: ColoredBox(
                color: isLight
                    ? Colors.black.withValues(alpha: 0.04)
                    : Colors.black.withValues(alpha: 0.35),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: textField,
            ),
          ],
        ),
      );
    }

    final field = Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        border: Border.all(color: colors.dotGridButtonBorder),
      ),
      child: panel,
    );

    if (widget.label == null) return field;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.label!,
          style: textStyles.body(colors.textPrimary).copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
        ),
        SizedBox(height: widget.labelSpacing),
        field,
      ],
    );
  }
}
