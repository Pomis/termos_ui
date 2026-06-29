import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../core/dot_grid/dot_grid_controller.dart';
import '../core/dot_grid/dot_grid_widget.dart';
import '../core/termos_icon_slot.dart';

import '../painters/glow_top_border_painter.dart';
import '../painters/reactive_starfield_painter.dart';
import '../theme/termos_colors.dart';
import '../theme/termos_metrics.dart';
import '../theme/termos_nav_bar_style.dart';
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

/// Rounded bottom bar with dot grid, starfield, and animated top-edge glow.
///
/// Layout and color blending come from [TermosThemeData.metrics] and
/// [TermosThemeData.navBar]. The shell treatment — opaque or translucent glass —
/// is chosen by [TermosThemeData.navBarStyle]: the glass style adds a backdrop
/// blur over the content scrolling beneath (`extendBody: true`), a surface tint
/// instead of an opaque fill, a specular rim that brightens toward the active
/// tab, a soft top sheen, and (optionally) a reflective backdrop shader.
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

class _TermosNavBarState extends State<TermosNavBar>
    with SingleTickerProviderStateMixin {
  final DotGridController _dotController = DotGridController();
  late final AnimationController _borderController;

  // Glass-only: loaded backdrop shader programs, keyed by asset. Shared across
  // instances so a second glass bar reuses the first's compiled program.
  static final Map<String, ui.FragmentProgram> _programCache = {};
  String? _loadingAssetKey;

  // Glass-only: the shell's top-left in physical pixels, used to phase-lock the
  // shader lattice to the canvas dot grid. Measured after layout.
  final GlobalKey _shellKey = GlobalKey();
  Offset _phaseOriginPhysical = Offset.zero;

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
      duration: Duration(
        milliseconds: TermosMetrics.standard.navBarBorderAnimationMs,
      ),
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

  /// Kicks off a one-time async load of a glass backdrop shader program.
  void _ensureProgram(String assetKey) {
    if (_programCache.containsKey(assetKey) || _loadingAssetKey == assetKey) {
      return;
    }
    _loadingAssetKey = assetKey;
    ui.FragmentProgram.fromAsset(assetKey)
        .then((program) {
          _programCache[assetKey] = program;
          if (mounted) setState(() {});
        })
        .catchError((_) {
          // Shader unavailable (e.g. a backend without runtime-effect backdrop
          // support) — the glass bar falls back to a plain blur + idle mesh.
        });
  }

  void _updatePhaseOrigin(double dpr) {
    final box = _shellKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final origin = box.localToGlobal(Offset.zero) * dpr;
    if ((origin - _phaseOriginPhysical).distanceSquared < 0.01) return;
    setState(() => _phaseOriginPhysical = origin);
  }

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
    final metrics = termos.metrics;
    final navBar = termos.navBar;
    final style = termos.navBarStyle;

    final glassStyle = style is TermosNavBarGlassStyle ? style : null;
    final glassShader = glassStyle?.shader;

    final dpr = MediaQuery.devicePixelRatioOf(context);

    // Resolve the glass backdrop program (loading it once if needed).
    ui.FragmentProgram? program;
    if (glassShader != null) {
      program = _programCache[glassShader.assetKey];
      if (program == null) _ensureProgram(glassShader.assetKey);
    }

    final selectedIndex = widget.selectedIndex.clamp(0, _n - 1);
    final pc = widget.pageController;
    final usePageController = pc != null && pc.hasClients;

    if (!usePageController) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _animateBorderTo(selectedIndex);
        if (glassStyle != null) _updatePhaseOrigin(dpr);
      });
    } else if (glassStyle != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _updatePhaseOrigin(dpr);
      });
    }

    final isLight = Theme.of(context).brightness == Brightness.light;

    final selectionAlpha =
        isLight ? navBar.selectionAlphaLight : navBar.selectionAlphaDark;
    final glowIntensity =
        isLight ? navBar.starfieldIntensityLight : navBar.starfieldIntensityDark;

    Color glowColorFor(Color color) => isLight
        ? Color.lerp(color, Colors.white, navBar.glowColorMixWithWhite)!
        : color;

    Widget buildShell(double position, Color color, int selIdx, double page) {
      final glowColor = glowColorFor(color);
      final primaryColor = widget.items[selIdx.clamp(0, _n - 1)].color;

      // When the backdrop shader draws the idle lattice, the canvas grid paints
      // only ripples/selection so the reflective dots show through.
      final shaderDots = useHeavy && glassStyle != null && program != null;

      Widget content;
      if (!useHeavy) {
        content = _itemRow(metrics, textStyles, colors, selIdx, null);
      } else {
        content = DotGridWidget(
          controller: _dotController,
          dotSize: dg.dotSize,
          gridSpacing: dg.spacing,
          primaryColor:
              (isLight
                      ? Color.lerp(
                          primaryColor,
                          Colors.white,
                          navBar.dotGridPrimaryMixWithWhite,
                        )
                      : primaryColor)!
                  .withValues(
                    alpha: isLight
                        ? navBar.dotGridPrimaryAlphaLight
                        : navBar.dotGridPrimaryAlphaDark,
                  ),
          backgroundColor:
              shaderDots ? Colors.transparent : colors.dotGridIdleMesh,
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
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!mounted) return;
                    final tabColor = widget.items[selIdx.clamp(0, _n - 1)].color;
                    _dotController.setSelection(
                      Offset(w * (page + 0.5) / _n, h / 2),
                      (isLight
                              ? Color.lerp(
                                  tabColor,
                                  Colors.white,
                                  navBar.glowColorMixWithWhite,
                                )
                              : tabColor)!
                          .withValues(alpha: selectionAlpha),
                    );
                  });

                  return _itemRow(metrics, textStyles, colors, selIdx, (i) {
                    _dotController.triggerAt(
                      Offset(w * (i + 0.5) / _n, h / 2),
                      color:
                          (isLight
                                  ? Color.lerp(
                                      widget.items[i].color,
                                      Colors.white,
                                      navBar.glowColorMixWithWhite,
                                    )
                                  : widget.items[i].color)!
                              .withValues(alpha: selectionAlpha),
                    );
                  });
                },
              ),
            ],
          ),
        );
      }

      final glowBaseOpacity =
          isLight ? navBar.glowShellBaseOpacityLight : navBar.glowShellBaseOpacityDark;

      if (glassStyle != null) {
        return _GlassShell(
          shellKey: _shellKey,
          phaseOriginPhysical: _phaseOriginPhysical,
          style: glassStyle,
          dotsProgram: shaderDots ? program : null,
          dotSize: dg.dotSize,
          gridSpacing: dg.spacing,
          glowPosition: position,
          glowColor: glowColor,
          glowBaseOpacity: glowBaseOpacity,
          outerHorizontalPadding: metrics.navBarOuterHorizontalPadding,
          outerBottomPadding: metrics.navBarOuterBottomPadding,
          barHeight: metrics.navBarHeight,
          cornerRadius: metrics.navBarCornerRadius,
          glowStrokeWidth: metrics.glowTopBorderStrokeWidth,
          colors: colors,
          isLight: isLight,
          blurEnabled: useHeavy,
          child: content,
        );
      }

      return _NavBarShell(
        glowPosition: position,
        glowColor: glowColor,
        glowBaseOpacity: glowBaseOpacity,
        outerHorizontalPadding: metrics.navBarOuterHorizontalPadding,
        outerBottomPadding: metrics.navBarOuterBottomPadding,
        barHeight: metrics.navBarHeight,
        cornerRadius: metrics.navBarCornerRadius,
        glowStrokeWidth: metrics.glowTopBorderStrokeWidth,
        colors: colors,
        child: content,
      );
    }

    int effectiveSelectedIndex() {
      if (!usePageController) return selectedIndex;
      final controller = widget.pageController!;
      return (controller.page ?? selectedIndex.toDouble()).round().clamp(
        0,
        _n - 1,
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
                    final idx = (pc.page ?? selectedIndex.toDouble()).round().clamp(
                      0,
                      _n - 1,
                    );
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

  Widget _itemRow(
    TermosMetrics metrics,
    TermosTextStyles textStyles,
    TermosColors colors,
    int selIdx,
    void Function(int index)? onRipple,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: metrics.navBarHorizontalPadding,
      ),
      child: Center(
        child: Row(
          children: [
            for (int i = 0; i < _n; i++)
              _NavItem(
                icon: widget.items[i].icon,
                label: widget.items[i].label,
                selected: selIdx == i,
                textStyles: textStyles,
                colors: colors,
                metrics: metrics,
                onTap: () {
                  onRipple?.call(i);
                  widget.onItemSelected(i);
                },
              ),
          ],
        ),
      ),
    );
  }
}

/// Opaque nav bar shell: drop shadow, rounded surface fill, top-edge glow.
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
      padding: EdgeInsets.fromLTRB(
        outerHorizontalPadding,
        0,
        outerHorizontalPadding,
        outerBottomPadding,
      ),
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
            border: Border(
              top: BorderSide(color: colors.dotGridButtonBorder, width: 1),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Translucent blurred shell: backdrop blur → surface tint → content →
/// specular sheen → gradient rim → (outside) accent edge glow.
class _GlassShell extends StatelessWidget {
  const _GlassShell({
    required this.shellKey,
    required this.phaseOriginPhysical,
    required this.style,
    required this.child,
    required this.glowPosition,
    required this.glowColor,
    required this.glowBaseOpacity,
    required this.outerHorizontalPadding,
    required this.outerBottomPadding,
    required this.barHeight,
    required this.cornerRadius,
    required this.glowStrokeWidth,
    required this.colors,
    required this.isLight,
    required this.blurEnabled,
    this.dotsProgram,
    this.dotSize = 2,
    this.gridSpacing = 6,
  });

  final GlobalKey shellKey;
  final Offset phaseOriginPhysical;
  final TermosNavBarGlassStyle style;
  final Widget child;
  final double glowPosition;
  final Color glowColor;
  final double glowBaseOpacity;
  final double outerHorizontalPadding;
  final double outerBottomPadding;
  final double barHeight;
  final double cornerRadius;
  final double glowStrokeWidth;
  final TermosColors colors;
  final bool isLight;
  final bool blurEnabled;

  /// When set, the style's backdrop shader draws the surface tint and the idle
  /// dot lattice, each dot reflecting the (blurred) content beneath.
  final ui.FragmentProgram? dotsProgram;
  final double dotSize;
  final double gridSpacing;

  ui.ImageFilter _backdropFilter(
    Size size,
    double dpr,
    Color tint,
    Offset originPhysical,
  ) {
    final blur = ui.ImageFilter.blur(
      sigmaX: style.blurSigma,
      sigmaY: style.blurSigma,
    );
    final program = dotsProgram;
    final shader = style.shader;
    if (program == null || shader == null) return blur;
    return shader.buildBackdropFilter(
      program: program,
      inner: blur,
      size: size,
      devicePixelRatio: dpr,
      tint: tint,
      originPhysical: originPhysical,
      dotSize: dotSize,
      gridSpacing: gridSpacing,
      reflectBoost: style.reflectBoost,
    );
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(cornerRadius);
    final shadowColor = isLight ? colors.textPrimary : Colors.black;

    // Lower tint than the opaque termos shell so the blurred content reads
    // through; light mode needs more body or text contrast suffers.
    final surfaceTint = colors.surface.withValues(
      alpha: isLight ? style.surfaceTintAlphaLight : style.surfaceTintAlphaDark,
    );

    // On the shader path the tint is applied inside the backdrop shader so the
    // reflective dots punch through it untinted.
    Widget inner = dotsProgram != null
        ? child
        : Container(color: surfaceTint, child: child);

    inner = Stack(
      fit: StackFit.passthrough,
      children: [
        inner,
        // Specular sheen: curved-glass highlight hugging the top edge.
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.35, 1.0],
                  colors: [
                    Colors.white.withValues(alpha: isLight ? 0.30 : 0.07),
                    Colors.white.withValues(alpha: 0.0),
                    Colors.white.withValues(alpha: isLight ? 0.06 : 0.02),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Rim light: gradient stroke, brightest along the top edge and tinted
        // toward the active tab near the glow.
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _GlassRimPainter(
                radius: cornerRadius,
                tint: glowColor,
                isLight: isLight,
              ),
            ),
          ),
        ),
      ],
    );

    if (blurEnabled) {
      final filtered = inner;
      inner = LayoutBuilder(
        builder: (context, constraints) => BackdropFilter(
          filter: _backdropFilter(
            Size(constraints.maxWidth, constraints.maxHeight),
            MediaQuery.devicePixelRatioOf(context),
            surfaceTint,
            phaseOriginPhysical,
          ),
          child: filtered,
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(
        outerHorizontalPadding,
        0,
        outerHorizontalPadding,
        outerBottomPadding,
      ),
      child: SizedBox(
        key: shellKey,
        height: barHeight,
        child: CustomPaint(
          foregroundPainter: GlowTopBorderPainter(
            position: glowPosition,
            glowColor: glowColor,
            baseColor: glowColor.withValues(alpha: glowBaseOpacity),
            strokeWidth: glowStrokeWidth,
            radius: cornerRadius,
            opacity: 1.0,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: radius,
              boxShadow: [
                // Deeper ambient drop than the opaque shell — glass floats.
                BoxShadow(
                  color: shadowColor.withValues(alpha: isLight ? 0.14 : 0.50),
                  blurRadius: 30,
                  spreadRadius: -6,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: shadowColor.withValues(alpha: isLight ? 0.06 : 0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(borderRadius: radius, child: inner),
          ),
        ),
      ),
    );
  }
}

/// Strokes the glass rim: a 1px rounded-rect border whose brightness fades from
/// a specular top edge down to a barely-there bottom, with a faint accent tint
/// mixed in so the rim picks up the active tab's glow.
class _GlassRimPainter extends CustomPainter {
  _GlassRimPainter({
    required this.radius,
    required this.tint,
    required this.isLight,
  });

  final double radius;
  final Color tint;
  final bool isLight;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(
      rect.deflate(0.5),
      Radius.circular(radius),
    );

    final topColor = Color.lerp(
      Colors.white,
      tint,
      0.35,
    )!.withValues(alpha: isLight ? 0.85 : 0.45);
    final sideColor = Colors.white.withValues(alpha: isLight ? 0.35 : 0.14);
    final bottomColor = Colors.white.withValues(alpha: isLight ? 0.18 : 0.05);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: const [0.0, 0.45, 1.0],
        colors: [topColor, sideColor, bottomColor],
      ).createShader(rect);

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(_GlassRimPainter oldDelegate) =>
      radius != oldDelegate.radius ||
      tint != oldDelegate.tint ||
      isLight != oldDelegate.isLight;
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.textStyles,
    required this.colors,
    required this.metrics,
  });

  final Widget icon;
  final String label;
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
              padding: EdgeInsets.symmetric(
                vertical: metrics.navBarItemVerticalPadding,
              ),
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
                      style: textStyles.navLabel(
                        selected: selected,
                        color: iconColor,
                      ),
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
