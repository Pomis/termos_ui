import 'package:flutter/material.dart';

import '../core/termos_aligned_builder.dart';
import '../core/termos_tap_target.dart';
import '../painters/reactive_starfield_painter.dart';
import '../theme/termos_theme.dart';

/// Reusable expandable card with a header and an optional expanded body.
///
/// - [header] is always visible.
/// - [contentBetween] is optional content shown between the header and the
///   expanded body (always visible).
/// - [expandedChild] animates open/closed when the card is tapped. When null,
///   no expand arrow is shown and the card is not tappable.
///
/// Background uses [ReactiveStarfieldPainter] aligned to the surrounding
/// dot-grid group (if any). When [useOverlayTapTarget] is true, an overlay
/// [TermosTapTarget] provides dot-grid mesh feedback on tap.
class TermosExpandableSection extends StatefulWidget {
  const TermosExpandableSection({
    super.key,
    required this.header,
    this.expandedChild,
    this.contentBetween,
    this.accentColor,
    this.isExpanded,
    this.initialExpanded = false,
    this.onToggle,
    this.useOverlayTapTarget = true,
    this.showExpandIcon = true,
    this.padding = const EdgeInsets.fromLTRB(12, 10, 12, 12),
    this.contentBetweenPadding =
        const EdgeInsets.symmetric(horizontal: 12),
    this.expandedPadding = const EdgeInsets.fromLTRB(12, 8, 12, 12),
    this.contentBetweenSpacing = 10,
    this.borderRadius,
    this.expandIcon,
    this.expandDuration = const Duration(milliseconds: 300),
    this.starfieldSeed,
  });

  /// Always visible. The expand arrow (if any) is appended on the right.
  final Widget header;

  /// Animates open/closed. When null the card is not tappable and no arrow
  /// is shown.
  final Widget? expandedChild;

  /// Always visible content between [header] and [expandedChild].
  final Widget? contentBetween;

  /// Accent for tap mesh and starfield glow. Defaults to theme primary.
  final Color? accentColor;

  /// External expansion control. When set, [onToggle] should drive changes.
  final bool? isExpanded;

  /// Initial state when uncontrolled. Ignored if [isExpanded] is set.
  final bool initialExpanded;

  /// Called when the user taps the card (controlled or uncontrolled mode).
  final VoidCallback? onToggle;

  /// When true (default) places a [TermosTapTarget] above the content so the
  /// dot-grid mesh feedback paints over the whole card. When false, taps are
  /// captured on the header row only via a [GestureDetector].
  final bool useOverlayTapTarget;

  /// Show the rotating arrow at the end of the header row.
  final bool showExpandIcon;

  /// Padding around the header row.
  final EdgeInsets padding;

  /// Padding around [contentBetween].
  final EdgeInsets contentBetweenPadding;

  /// Padding around [expandedChild].
  final EdgeInsets expandedPadding;

  /// Vertical spacing below [contentBetween] (above [expandedChild]).
  final double contentBetweenSpacing;

  /// Outer corner radius. Defaults to `theme.metrics.borderRadius * 1.75`.
  final BorderRadius? borderRadius;

  /// Custom icon for the expand affordance. Defaults to [Icons.expand_more].
  final Widget? expandIcon;

  /// Duration of the open/close animation.
  final Duration expandDuration;

  /// Seed for the [ReactiveStarfieldPainter] background. Pass a stable value
  /// (e.g. `'hand out'.hashCode`) so each instance has a unique-but-stable
  /// star pattern tied to its content. Defaults to the state's `hashCode`.
  final int? starfieldSeed;

  @override
  State<TermosExpandableSection> createState() =>
      _TermosExpandableSectionState();
}

class _TermosExpandableSectionState extends State<TermosExpandableSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;

  bool get _isControlled => widget.isExpanded != null;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.expandDuration,
      vsync: this,
      value: _isControlled
          ? (widget.isExpanded! ? 1.0 : 0.0)
          : (widget.initialExpanded ? 1.0 : 0.0),
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
      reverseCurve: Curves.easeInOutCubic,
    );
  }

  @override
  void didUpdateWidget(covariant TermosExpandableSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.expandDuration != widget.expandDuration) {
      _controller.duration = widget.expandDuration;
    }
    if (_isControlled) {
      if (widget.isExpanded == true) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    if (widget.expandedChild == null) return;
    if (widget.onToggle != null) {
      widget.onToggle!();
      return;
    }
    setState(() {
      if (_controller.isCompleted) {
        _controller.reverse();
      } else {
        _controller.forward();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final termos = TermosTheme.of(context);
    final colors = termos.colors;
    final metrics = termos.metrics;
    final dg = termos.dotGrid;
    final hasExpanded = widget.expandedChild != null;
    final accentColor = widget.accentColor ?? colors.primary;
    final radius = widget.borderRadius ??
        BorderRadius.circular(metrics.borderRadius * 1.75);
    final isLight = Theme.of(context).brightness == Brightness.light;

    final headerRow = Row(
      children: [
        Expanded(child: widget.header),
        if (hasExpanded && widget.showExpandIcon) ...[
          const SizedBox(width: 8),
          RotationTransition(
            turns: Tween(begin: 0.0, end: 0.5).animate(_expandAnimation),
            child: widget.expandIcon ??
                Icon(
                  Icons.expand_more,
                  color: colors.textSecondary,
                  size: 20,
                ),
          ),
        ],
      ],
    );

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: widget.padding,
          child: widget.useOverlayTapTarget
              ? headerRow
              : GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: hasExpanded ? _toggleExpanded : null,
                  child: headerRow,
                ),
        ),
        if (widget.contentBetween != null) ...[
          Padding(
            padding: widget.contentBetweenPadding,
            child: widget.contentBetween!,
          ),
          SizedBox(height: widget.contentBetweenSpacing),
        ],
        if (hasExpanded)
          SizeTransition(
            sizeFactor: _expandAnimation,
            axisAlignment: -1,
            child: Padding(
              padding: widget.expandedPadding,
              child: widget.expandedChild!,
            ),
          ),
      ],
    );

    final tapOverlay = widget.useOverlayTapTarget
        ? Positioned.fill(
            child: TermosTapTarget(
              onTap: hasExpanded ? _toggleExpanded : null,
              enabled: hasExpanded,
              borderRadius: radius,
              primaryColor: accentColor,
              blobRadius: dg.blobRadius,
              dotSize: dg.dotSize,
              gridSpacing: dg.spacing,
              idleMeshColor: colors.dotGridIdleMesh,
              child: const SizedBox.expand(),
            ),
          )
        : const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: Color.lerp(
          colors.background,
          colors.card,
          isLight ? 0.4 : 0.6,
        )!,
        borderRadius: radius,
        border: Border.all(color: colors.dotGridButtonBorder),
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(
          children: [
            Positioned.fill(
              child: TermosAlignedBuilder(
                builder: (gridOffset) => CustomPaint(
                  painter: ReactiveStarfieldPainter(
                    dotSize: dg.dotSize,
                    gridSpacing: dg.spacing,
                    glowPosition: 0.5,
                    glowColor: accentColor,
                    intensity: isLight ? 1.8 : 1.2,
                    gridOffset: gridOffset,
                    seed: widget.starfieldSeed ?? hashCode,
                  ),
                ),
              ),
            ),
            content,
            if (widget.useOverlayTapTarget) tapOverlay,
          ],
        ),
      ),
    );
  }
}
