import 'package:flutter/material.dart';

import '../core/dot_grid/dot_grid_controller.dart';
import '../core/dot_grid/dot_grid_widget.dart';
import '../core/termos_icon_slot.dart';

import '../painters/glow_top_border_painter.dart';
import '../painters/reactive_starfield_painter.dart';
import '../theme/termos_colors.dart';
import '../theme/termos_metrics.dart';
import '../theme/termos_text_styles.dart';
import '../theme/termos_theme.dart';

/// One tab in [TermosNavBar].
class TermosNavBarItem {
  const TermosNavBarItem({
    required this.icon,
    required this.label,
    required this.color,
  });

  final Widget icon;
  final String label;
  final Color color;
}

/// Rounded glass bottom bar with dot grid, starfield, and animated top-edge glow.
///
/// Layout and color blending come from [TermosThemeData.metrics] and [TermosThemeData.navBar].
class TermosNavBar extends StatefulWidget {
  const TermosNavBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onItemSelected,
    this.pageController,
  });

  final List<TermosNavBarItem> items;
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  /// When set and attached, glow position interpolates with horizontal swipe.
  final PageController? pageController;

  @override
  State<TermosNavBar> createState() => _TermosNavBarState();
}

class _TermosNavBarState extends State<TermosNavBar> with SingleTickerProviderStateMixin {
  final DotGridController _dotController = DotGridController();
  late final AnimationController _borderController;

  double _fromPos = 0.125;
  double _toPos = 0.125;
  late Color _fromColor;
  late Color _toColor;
  int _activeIndex = 0;
  bool _initialized = false;
  bool? _dragStartedOnSelectedTab;

  int get _n => widget.items.length;

  @override
  void initState() {
    super.initState();
    _borderController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: TermosMetrics.standard.navBarBorderAnimationMs),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized && widget.items.isNotEmpty) {
      final idx = widget.selectedIndex.clamp(0, _n - 1);
      final p = _positionForIndex(idx);
      _fromPos = p;
      _toPos = p;
      _fromColor = widget.items[idx].color;
      _toColor = widget.items[idx].color;
      _activeIndex = idx;
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _borderController.dispose();
    _dotController.dispose();
    super.dispose();
  }

  double _positionForIndex(int index) => (index + 0.5) / _n;

  void _animateBorderTo(int index) {
    if (index == _activeIndex) return;
    final t = Curves.easeOutCubic.transform(_borderController.value);
    _fromPos = _fromPos + (_toPos - _fromPos) * t;
    _fromColor = _lerpHSV(_fromColor, _toColor, t);
    _toPos = _positionForIndex(index);
    _toColor = widget.items[index.clamp(0, _n - 1)].color;
    _activeIndex = index;
    _borderController.forward(from: 0);
  }

  double get _animatedPosition {
    final t = Curves.easeOutCubic.transform(_borderController.value);
    return _fromPos + (_toPos - _fromPos) * t;
  }

  Color get _animatedColor {
    final t = Curves.easeOutCubic.transform(_borderController.value);
    return _lerpHSV(_fromColor, _toColor, t);
  }

  double _positionFromPage(double page) {
    final p = page.clamp(0.0, _n - 1.0);
    final i = p.floor().clamp(0, _n - 2);
    final frac = p - i;
    return _positionForIndex(i) +
        (_positionForIndex(i + 1) - _positionForIndex(i)) * frac;
  }

  Color _colorFromPage(double page) {
    final p = page.clamp(0.0, _n - 1.0);
    final i = p.floor().clamp(0, _n - 2);
    final frac = (p - i).clamp(0.0, 1.0);
    return Color.lerp(
          widget.items[i.clamp(0, _n - 1)].color,
          widget.items[(i + 1).clamp(0, _n - 1)].color,
          frac,
        ) ??
        widget.items[0].color;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();

    final termos = TermosTheme.of(context);
    final useHeavy = termos.heavyEffectsEnabled;
    final colors = termos.colors;
    final dg = termos.dotGrid;
    final textStyles = termos.textStyles;

    final selectedIndex = widget.selectedIndex.clamp(0, _n - 1);
    final pc = widget.pageController;
    final usePageController = pc != null && pc.hasClients;

    if (!usePageController) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _animateBorderTo(selectedIndex);
      });
    }

    final isLight = Theme.of(context).brightness == Brightness.light;
    final metrics = termos.metrics;
    final navBar = termos.navBar;

    final selectionAlpha =
        isLight ? navBar.selectionAlphaLight : navBar.selectionAlphaDark;
    final glowIntensity =
        isLight ? navBar.starfieldIntensityLight : navBar.starfieldIntensityDark;

    Color glowColorFor(Color color) => isLight
        ? Color.lerp(color, Colors.white, navBar.glowColorMixWithWhite)!
        : color;

    void onNavTap(int index) {
      widget.onItemSelected(index);
    }

    int effectiveSelectedIndex() {
      if (!usePageController) return selectedIndex;
      final controller = widget.pageController!;
      return (controller.page ?? selectedIndex.toDouble()).round().clamp(0, _n - 1);
    }

    Widget buildShell(double position, Color color, int selIdx, double pageForDot) {
      final glowColor = glowColorFor(color);
      final primaryColor = widget.items[selIdx.clamp(0, _n - 1)].color;

      final row = Padding(
        padding: EdgeInsets.symmetric(horizontal: metrics.navBarHorizontalPadding),
        child: Center(
          child: Row(
            children: [
              for (int i = 0; i < _n; i++)
                _NavItem(
                  icon: widget.items[i].icon,
                  label: widget.items[i].label,
                  color: widget.items[i].color,
                  selected: selIdx == i,
                  textStyles: textStyles,
                  colors: colors,
                  metrics: metrics,
                  onTap: () => onNavTap(i),
                ),
            ],
          ),
        ),
      );

      if (!useHeavy) {
        return _NavBarShell(
          glowPosition: position,
          glowColor: glowColor,
          glowBaseOpacity:
              isLight ? navBar.glowShellBaseOpacityLight : navBar.glowShellBaseOpacityDark,
          outerHorizontalPadding: metrics.navBarOuterHorizontalPadding,
          outerBottomPadding: metrics.navBarOuterBottomPadding,
          barHeight: metrics.navBarHeight,
          cornerRadius: metrics.navBarCornerRadius,
          glowStrokeWidth: metrics.glowTopBorderStrokeWidth,
          colors: colors,
          child: row,
        );
      }

      return _NavBarShell(
        glowPosition: position,
        glowColor: glowColor,
        glowBaseOpacity:
            isLight ? navBar.glowShellBaseOpacityLight : navBar.glowShellBaseOpacityDark,
        outerHorizontalPadding: metrics.navBarOuterHorizontalPadding,
        outerBottomPadding: metrics.navBarOuterBottomPadding,
        barHeight: metrics.navBarHeight,
        cornerRadius: metrics.navBarCornerRadius,
        glowStrokeWidth: metrics.glowTopBorderStrokeWidth,
        colors: colors,
        child: DotGridWidget(
          controller: _dotController,
          dotSize: dg.dotSize,
          gridSpacing: dg.spacing,
          primaryColor: (isLight
                  ? Color.lerp(primaryColor, Colors.white, navBar.dotGridPrimaryMixWithWhite)
                  : primaryColor)!
              .withValues(
            alpha: isLight ? navBar.dotGridPrimaryAlphaLight : navBar.dotGridPrimaryAlphaDark,
          ),
          backgroundColor: colors.dotGridIdleMesh,
          enableHoverEffect: false,
          blobRadius: dg.blobRadius,
          expansionDuration: Duration(milliseconds: navBar.dotGridExpansionMs),
          decayDuration: Duration(milliseconds: navBar.dotGridDecayMs),
          child: Stack(
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: ReactiveStarfieldPainter(
                      dotSize: dg.dotSize,
                      gridSpacing: dg.spacing,
                      glowPosition: position,
                      glowColor: glowColor,
                      intensity: glowIntensity,
                      seed: hashCode,
                    ),
                  ),
                ),
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  final w = constraints.maxWidth;
                  final h = constraints.maxHeight;
                  final page = pageForDot;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!mounted) return;
                    final tabColor = widget.items[selIdx.clamp(0, _n - 1)].color;
                    _dotController.setSelection(
                      Offset(w * (page + 0.5) / _n, h / 2),
                      (isLight
                              ? Color.lerp(tabColor, Colors.white, navBar.glowColorMixWithWhite)
                              : tabColor)!
                          .withValues(alpha: selectionAlpha),
                    );
                  });

                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: metrics.navBarHorizontalPadding),
                    child: Center(
                      child: Row(
                        children: [
                          for (int i = 0; i < _n; i++)
                            _NavItem(
                              icon: widget.items[i].icon,
                              label: widget.items[i].label,
                              color: widget.items[i].color,
                              selected: selIdx == i,
                              textStyles: textStyles,
                              colors: colors,
                              metrics: metrics,
                              onTap: () {
                                final xPos = (i + 0.5) / _n;
                                _dotController.triggerAt(
                                  Offset(w * xPos, h / 2),
                                  color: (isLight
                                          ? Color.lerp(
                                              widget.items[i].color,
                                              Colors.white,
                                              navBar.glowColorMixWithWhite,
                                            )
                                          : widget.items[i].color)!
                                      .withValues(alpha: selectionAlpha),
                                );
                                onNavTap(i);
                              },
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      );
    }

    if (usePageController) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final navBarWidth = constraints.maxWidth;
          return ListenableBuilder(
            listenable: widget.pageController!,
            builder: (context, _) {
              final page = pc.page ?? selectedIndex.toDouble();
              final selIdx = effectiveSelectedIndex();
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onHorizontalDragStart: (details) {
                  final x = details.localPosition.dx;
                  final tabWidth = navBarWidth / _n;
                  final tabLeft = selIdx * tabWidth;
                  final tabRight = (selIdx + 1) * tabWidth;
                  _dragStartedOnSelectedTab = x >= tabLeft && x < tabRight;
                },
                onHorizontalDragUpdate: (details) {
                  if (_dragStartedOnSelectedTab != true) return;
                  if (pc.hasClients && navBarWidth > 0) {
                    final pos = pc.position;
                    final scrollRatio = _n * pos.viewportDimension / navBarWidth;
                    final newPixels =
                        (pos.pixels + details.delta.dx * scrollRatio).clamp(
                      0.0,
                      pos.maxScrollExtent,
                    );
                    pos.jumpTo(newPixels);
                  }
                },
                onHorizontalDragEnd: (_) {
                  if (_dragStartedOnSelectedTab == true) {
                    final idx =
                        (pc.page ?? selectedIndex.toDouble()).round().clamp(0, _n - 1);
                    widget.onItemSelected(idx);
                  }
                  _dragStartedOnSelectedTab = null;
                },
                onHorizontalDragCancel: () {
                  _dragStartedOnSelectedTab = null;
                },
                child: buildShell(
                  _positionFromPage(page),
                  _colorFromPage(page),
                  effectiveSelectedIndex(),
                  page,
                ),
              );
            },
          );
        },
      );
    }

    return AnimatedBuilder(
      animation: _borderController,
      builder: (context, _) => buildShell(
        _animatedPosition,
        _animatedColor,
        selectedIndex,
        selectedIndex.toDouble(),
      ),
    );
  }
}

class _NavBarShell extends StatelessWidget {
  const _NavBarShell({
    required this.child,
    this.glowPosition,
    this.glowColor,
    this.glowBaseOpacity = 0.05,
    required this.outerHorizontalPadding,
    required this.outerBottomPadding,
    required this.barHeight,
    required this.cornerRadius,
    required this.glowStrokeWidth,
    required this.colors,
  });

  final Widget child;
  final double? glowPosition;
  final Color? glowColor;
  final double glowBaseOpacity;
  final double outerHorizontalPadding;
  final double outerBottomPadding;
  final double barHeight;
  final double cornerRadius;
  final double glowStrokeWidth;
  final TermosColors colors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(outerHorizontalPadding, 0, outerHorizontalPadding, outerBottomPadding),
      child: SizedBox(
        height: barHeight,
        child: CustomPaint(
          foregroundPainter: glowPosition != null && glowColor != null
              ? GlowTopBorderPainter(
                  position: glowPosition!,
                  glowColor: glowColor!,
                  baseColor: glowColor!.withValues(alpha: glowBaseOpacity),
                  strokeWidth: glowStrokeWidth,
                  radius: cornerRadius,
                  opacity: 1.0,
                )
              : null,
          child: _buildInner(context, child),
        ),
      ),
    );
  }

  Widget _buildInner(BuildContext context, Widget child) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final shadowColor = isLight ? colors.textPrimary : Colors.black;
    final shadowAlpha = isLight ? 0.12 : 0.45;
    final shadowAlpha2 = isLight ? 0.06 : 0.25;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(cornerRadius),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withValues(alpha: shadowAlpha),
            blurRadius: 24,
            spreadRadius: -4,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: shadowColor.withValues(alpha: shadowAlpha2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(cornerRadius),
        child: Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(cornerRadius),
            border: Border(top: BorderSide(color: colors.dotGridButtonBorder, width: 1)),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
    required this.textStyles,
    required this.colors,
    required this.metrics,
  });

  final Widget icon;
  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;
  final TermosTextStyles textStyles;
  final TermosColors colors;
  final TermosMetrics metrics;

  @override
  Widget build(BuildContext context) {
    final iconColor = selected ? colors.textPrimary : colors.textMuted;
    return Expanded(
      child: Semantics(
        label: label,
        selected: selected,
        button: true,
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: selected ? 1 : 0.6,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: metrics.navBarItemVerticalPadding),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TermosIconSlot(
                      icon: icon,
                      tintColor: iconColor,
                      slotSize: metrics.navBarIconSize,
                    ),
                    SizedBox(height: metrics.navBarIconLabelGap),
                    Text(
                      label,
                      style: textStyles.navLabel(selected: selected, color: iconColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Color _lerpHSV(Color a, Color b, double t) {
  final hsvA = HSVColor.fromColor(a);
  final hsvB = HSVColor.fromColor(b);
  var hueDiff = hsvB.hue - hsvA.hue;
  if (hueDiff > 180) hueDiff -= 360;
  if (hueDiff < -180) hueDiff += 360;
  var hue = (hsvA.hue + hueDiff * t) % 360;
  if (hue < 0) hue += 360;
  return HSVColor.fromAHSV(
    hsvA.alpha + (hsvB.alpha - hsvA.alpha) * t,
    hue,
    hsvA.saturation + (hsvB.saturation - hsvA.saturation) * t,
    hsvA.value + (hsvB.value - hsvA.value) * t,
  ).toColor();
}
