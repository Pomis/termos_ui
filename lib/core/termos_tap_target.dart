import 'package:flutter/material.dart';

import 'dot_grid/dot_grid_controller.dart';
import 'dot_grid/dot_grid_widget.dart';
import '../theme/termos_theme.dart';

/// Tap target with dot_grid mesh gradient feedback instead of Material ripple.
class TermosTapTarget extends StatefulWidget {
  const TermosTapTarget({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius,
    this.enabled = true,
    this.controller,
    this.primaryColor,
    this.blobRadius,
    this.idleMeshColor,
    this.dotSize,
    this.gridSpacing,
    this.shrinkWrapWidth = false,
  });

  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;
  final bool enabled;
  final DotGridController? controller;
  final Color? primaryColor;
  final double? blobRadius;
  final Color? idleMeshColor;
  final double? dotSize;
  final double? gridSpacing;
  /// When true, width follows [child] instead of expanding to the incoming max width.
  final bool shrinkWrapWidth;

  @override
  State<TermosTapTarget> createState() => _TermosTapTargetState();
}

class _TermosTapTargetState extends State<TermosTapTarget> {
  DotGridController? _localController;

  DotGridController get _effectiveController =>
      widget.controller ?? (_localController ??= DotGridController());

  @override
  void dispose() {
    _localController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final termos = TermosTheme.of(context);
    final useHeavy = termos.heavyEffectsEnabled;
    final colors = termos.colors;
    final dg = termos.dotGrid;
    final metrics = termos.metrics;
    final radius =
        widget.borderRadius ?? BorderRadius.circular(metrics.tapTargetDefaultBorderRadius);
    final color = widget.primaryColor ?? colors.primary;
    final radiusValue = widget.blobRadius ?? dg.blobRadius;
    final meshColor = widget.idleMeshColor ?? colors.dotGridIdleMesh;
    final dotSizeValue = widget.dotSize ?? dg.dotSize;
    final gridSpacingValue = widget.gridSpacing ?? dg.spacing;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final blobColor = isLight
        ? (Color.lerp(color, Colors.white, 0.5) ?? color).withValues(alpha: 0.55)
        : color.withValues(alpha: 0.5);

    if (!useHeavy) {
      final child = widget.shrinkWrapWidth
          ? IntrinsicWidth(child: widget.child)
          : widget.child;
      return ClipRRect(
        borderRadius: radius,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.enabled ? widget.onTap : null,
            borderRadius: radius,
            child: child,
          ),
        ),
      );
    }

    final dotGrid = DotGridWidget(
      controller: _effectiveController,
      enableHoverEffect: false,
      dotSize: dotSizeValue,
      gridSpacing: gridSpacingValue,
      primaryColor: blobColor,
      backgroundColor: meshColor,
      expansionDuration: const Duration(milliseconds: 200),
      decayDuration: const Duration(milliseconds: 400),
      blobRadius: radiusValue,
      hoverOpacity: 0.8,
      enabled: widget.enabled,
      child: widget.child,
    );

    if (widget.shrinkWrapWidth) {
      return ClipRRect(
        borderRadius: radius,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.enabled ? widget.onTap : null,
            borderRadius: radius,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
            overlayColor: const WidgetStatePropertyAll<Color>(Colors.transparent),
            child: dotGrid,
          ),
        ),
      );
    }

    final Widget content = ClipRRect(
      borderRadius: radius,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.enabled ? widget.onTap : null,
          borderRadius: radius,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          overlayColor: const WidgetStatePropertyAll<Color>(Colors.transparent),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth.isFinite ? constraints.maxWidth : 400.0;
              final h = constraints.maxHeight.isFinite ? constraints.maxHeight : null;
              if (h != null) {
                return ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: w, maxHeight: h),
                  child: dotGrid,
                );
              }
              return ConstrainedBox(
                constraints: BoxConstraints(maxWidth: w),
                child: dotGrid,
              );
            },
          ),
        ),
      ),
    );

    return content;
  }
}
