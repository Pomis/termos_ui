import 'package:flutter/material.dart';

import '../core/dot_grid/dot_grid_controller.dart';
import '../core/dot_grid/dot_grid_widget.dart';
import '../core/termos_tap_target.dart';
import '../painters/glow_top_border_painter.dart';
import '../theme/termos_effects.dart';
import '../theme/termos_theme.dart';

/// One tab in [TermosTabBar].
class TermosTabBarItem {
  const TermosTabBarItem({required this.label, this.accentColor});

  final String label;

  /// Reserved for future per-tab accent (currently unused; kept so the public
  /// shape doesn't change once accent-aware glow lands).
  final Color? accentColor;
}

/// Top, horizontally scrollable tab strip with a glow indicator that tracks
/// the active [TabController] (including swipe progress on a [TabBarView]).
///
/// Tabs are sized to their own label widths (variable-width, not equal-flex).
/// When the combined tab width exceeds the available viewport, the strip
/// becomes horizontally scrollable and animates the active tab into view.
///
/// Visuals come from [TermosThemeData.tabBar] (effects) and
/// [TermosThemeData.metrics] (layout). Heavy effects (dot grid, glow halo)
/// follow [TermosThemeData.heavyEffectsEnabled] unless overridden via
/// [heavyEffectsEnabled] on the widget.
///
/// A [TabController] must be available — pass one explicitly via [controller],
/// or rely on a [DefaultTabController] ancestor.
class TermosTabBar extends StatefulWidget {
  const TermosTabBar({
    super.key,
    required this.items,
    this.controller,
    this.onTabChanged,
    this.height,
    this.heavyEffectsEnabled,
  }) : assert(items.length > 0, 'TermosTabBar requires at least one item');

  final List<TermosTabBarItem> items;

  /// Optional override; falls back to [DefaultTabController.of] when null.
  final TabController? controller;

  /// Called with the new index whenever the active tab changes (after the
  /// controller settles). Fires alongside any controller listeners.
  final ValueChanged<int>? onTabChanged;

  /// Override [TermosMetrics.tabBarStripHeight].
  final double? height;

  /// Per-instance override of [TermosThemeData.heavyEffectsEnabled].
  final bool? heavyEffectsEnabled;

  @override
  State<TermosTabBar> createState() => _TermosTabBarState();
}

class _TermosTabBarState extends State<TermosTabBar> {
  TabController? _controller;
  final ScrollController _scroller = ScrollController();
  final DotGridController _dotController = DotGridController();

  /// Cached label widths, recomputed when [items], the text scaler, or the
  /// label TextStyle change. Indexed by item position.
  List<double> _tabWidths = const [];
  Object? _measurementCacheKey;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _attachController(widget.controller ?? DefaultTabController.maybeOf(context));
  }

  @override
  void didUpdateWidget(covariant TermosTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newController =
        widget.controller ?? DefaultTabController.maybeOf(context);
    if (!identical(_controller, newController)) {
      _attachController(newController);
    }
    if (!_sameItemLabels(oldWidget.items, widget.items)) {
      _measurementCacheKey = null;
    }
  }

  bool _sameItemLabels(List<TermosTabBarItem> a, List<TermosTabBarItem> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].label != b[i].label) return false;
    }
    return true;
  }

  void _attachController(TabController? next) {
    assert(
      next != null,
      'TermosTabBar requires a TabController, either passed via `controller` '
      'or supplied by an ancestor DefaultTabController.',
    );
    _controller?.removeListener(_onIndexChanged);
    _controller = next;
    _controller?.addListener(_onIndexChanged);
  }

  void _onIndexChanged() {
    if (!mounted) return;
    final controller = _controller;
    if (controller != null && !controller.indexIsChanging) {
      widget.onTabChanged?.call(controller.index);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollActiveIntoView());
  }

  void _scrollActiveIntoView() {
    final controller = _controller;
    if (controller == null || !_scroller.hasClients || _tabWidths.isEmpty) {
      return;
    }
    final viewport = _scroller.position.viewportDimension;
    final maxScroll = _scroller.position.maxScrollExtent;
    if (maxScroll <= 0) return;
    final outerPadding = TermosTheme.of(context).metrics.tabBarOuterPadding;
    final i = controller.index.clamp(0, _tabWidths.length - 1);
    var center = outerPadding;
    for (var j = 0; j < i; j++) {
      center += _tabWidths[j];
    }
    center += _tabWidths[i] / 2;
    final desired = (center - viewport / 2).clamp(0.0, maxScroll);
    _scroller.animateTo(
      desired,
      duration: Duration(
        milliseconds: TermosTheme.of(context).tabBar.scrollAnimationMs,
      ),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _controller?.removeListener(_onIndexChanged);
    _scroller.dispose();
    _dotController.dispose();
    super.dispose();
  }

  /// Pre-measure each label so cells size to their own text width. Cells use
  /// the *selected* (bolder) style so widths stay stable through the
  /// selection animation and the row doesn't reflow.
  List<double> _measureCellWidths(
    BuildContext context, {
    required TextStyle labelStyle,
    required double horizontalPadding,
  }) {
    final scaler = MediaQuery.textScalerOf(context);
    final cacheKey = _CacheKey(
      labelsHash: Object.hashAll(widget.items.map((e) => e.label)),
      styleHash: labelStyle.hashCode,
      scalerHash: scaler.hashCode,
      padding: horizontalPadding,
    );
    if (cacheKey == _measurementCacheKey) return _tabWidths;
    final widths = <double>[
      for (final item in widget.items)
        () {
          final tp = TextPainter(
            text: TextSpan(text: item.label, style: labelStyle),
            textDirection: TextDirection.ltr,
            maxLines: 1,
            textScaler: scaler,
          )..layout();
          return horizontalPadding * 2 + tp.size.width;
        }(),
    ];
    _measurementCacheKey = cacheKey;
    _tabWidths = widths;
    return widths;
  }

  @override
  Widget build(BuildContext context) {
    final termos = TermosTheme.of(context);
    final colors = termos.colors;
    final metrics = termos.metrics;
    final tabBar = termos.tabBar;
    final dg = termos.dotGrid;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final useHeavy = widget.heavyEffectsEnabled ?? termos.heavyEffectsEnabled;

    final stripHeight = widget.height ?? metrics.tabBarStripHeight;
    final outerPadding = metrics.tabBarOuterPadding;
    final tabPadding = metrics.tabBarTabHorizontalPadding;

    final glowMixedColor = isLight
        ? Color.lerp(colors.primary, Colors.white, tabBar.glowColorMixWithWhite)!
        : colors.primary;
    final glowBaseOpacity = isLight
        ? tabBar.glowShellBaseOpacityLight
        : tabBar.glowShellBaseOpacityDark;
    final dotPrimaryAlpha = isLight
        ? tabBar.dotGridPrimaryAlphaLight
        : tabBar.dotGridPrimaryAlphaDark;
    final dotPrimaryColor = (isLight
            ? Color.lerp(
                colors.primary,
                Colors.white,
                tabBar.dotGridPrimaryMixWithWhite,
              )
            : colors.primary)!
        .withValues(alpha: dotPrimaryAlpha);

    final controller = _controller;
    final items = widget.items;
    final labelStyle = termos.textStyles.navLabel(
      selected: true,
      color: colors.textPrimary,
    );

    return SizedBox(
      height: stripHeight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final viewport = constraints.maxWidth;
          final tabWidths = _measureCellWidths(
            context,
            labelStyle: labelStyle,
            horizontalPadding: tabPadding,
          );
          final tabsTotal = tabWidths.fold<double>(0, (a, b) => a + b);
          final fits = outerPadding * 2 + tabsTotal <= viewport;
          // Stretch the strip to the viewport when tabs fit so the glow and
          // dot grid feel edge-to-edge; otherwise let it scroll horizontally.
          final stripWidth =
              fits ? viewport : outerPadding * 2 + tabsTotal;

          final tabLefts = <double>[];
          var cursor = outerPadding;
          for (final w in tabWidths) {
            tabLefts.add(cursor);
            cursor += w;
          }

          final stripContent = SizedBox(
            width: stripWidth,
            height: stripHeight,
            child: Stack(
              children: [
                if (useHeavy)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: _buildDotsBand(
                        dotPrimaryColor: dotPrimaryColor,
                        idleMesh: colors.dotGridIdleMesh,
                        dotSize: dg.dotSize,
                        gridSpacing: dg.spacing,
                        blobRadius: dg.blobRadius,
                        expansionMs: tabBar.dotGridExpansionMs,
                        decayMs: tabBar.dotGridDecayMs,
                        heightFraction: tabBar.dotsHeightFraction,
                      ),
                    ),
                  ),
                if (useHeavy)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: _buildDotsFeather(colors.background),
                    ),
                  ),
                Positioned.fill(
                  child: _buildTabsRow(
                    items: items,
                    controller: controller,
                    tabWidths: tabWidths,
                    outerPadding: outerPadding,
                    tabPadding: tabPadding,
                    stripHeight: stripHeight,
                  ),
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: _buildGlowLayer(
                      controller: controller,
                      tabWidths: tabWidths,
                      tabLefts: tabLefts,
                      stripWidth: stripWidth,
                      glowColor: glowMixedColor,
                      glowBaseOpacity: glowBaseOpacity,
                      crispStrokeWidth: metrics.tabBarGlowStrokeWidth,
                      tabBar: tabBar,
                    ),
                  ),
                ),
              ],
            ),
          );

          return SingleChildScrollView(
            controller: _scroller,
            scrollDirection: Axis.horizontal,
            physics: fits
                ? const NeverScrollableScrollPhysics()
                : const BouncingScrollPhysics(),
            child: stripContent,
          );
        },
      ),
    );
  }

  Widget _buildTabsRow({
    required List<TermosTabBarItem> items,
    required TabController? controller,
    required List<double> tabWidths,
    required double outerPadding,
    required double tabPadding,
    required double stripHeight,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: outerPadding),
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++)
            SizedBox(
              width: tabWidths[i],
              child: _TermosTabBarTab(
                index: i,
                label: items[i].label,
                controller: controller,
                height: stripHeight,
                horizontalPadding: tabPadding,
                onTap: () => controller?.animateTo(i),
              ),
            ),
        ],
      ),
    );
  }

  /// Dot grid via [DotGridWidget]. Only the bottom band is filled (controlled
  /// by [heightFraction]) so the dots fade out toward the top of the strip.
  /// Wrap the whole screen in `TermosGroup` to keep multiple grids in phase.
  Widget _buildDotsBand({
    required Color dotPrimaryColor,
    required Color idleMesh,
    required double dotSize,
    required double gridSpacing,
    required double blobRadius,
    required int expansionMs,
    required int decayMs,
    required double heightFraction,
  }) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: FractionallySizedBox(
        heightFactor: heightFraction,
        child: DotGridWidget(
          controller: _dotController,
          dotSize: dotSize,
          gridSpacing: gridSpacing,
          primaryColor: dotPrimaryColor,
          backgroundColor: idleMesh,
          enableHoverEffect: false,
          interactiveMesh: false,
          blobRadius: blobRadius,
          expansionDuration: Duration(milliseconds: expansionMs),
          decayDuration: Duration(milliseconds: decayMs),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }

  /// Top-down full-strip fade: keeps the upper half opaque against the
  /// background, then transitions through a long gradient so the dot grid
  /// progressively appears toward the bottom edge.
  Widget _buildDotsFeather(Color background) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [background, background.withValues(alpha: 0)],
        ),
      ),
    );
  }

  /// Two stacked passes of [GlowTopBorderPainter] — wide-stroke halo + crisp
  /// bright line — both flipped so the glow lands on the strip's *bottom*
  /// edge. Position interpolates from `TabController.animation` so it tracks
  /// the [TabBarView] swipe in real time.
  Widget _buildGlowLayer({
    required TabController? controller,
    required List<double> tabWidths,
    required List<double> tabLefts,
    required double stripWidth,
    required Color glowColor,
    required double glowBaseOpacity,
    required double crispStrokeWidth,
    required TermosTabBarEffects tabBar,
  }) {
    final animation = controller?.animation;
    final listenables = <Listenable>[
      if (controller != null) controller,
      if (animation != null) animation,
    ];
    final listenable = listenables.isEmpty
        ? const AlwaysStoppedAnimation<double>(0)
        : Listenable.merge(listenables);

    return AnimatedBuilder(
      animation: listenable,
      builder: (context, _) {
        final raw = animation?.value ?? controller?.index.toDouble() ?? 0;
        final maxIndex = (widget.items.length - 1).toDouble();
        final value = raw.clamp(0.0, maxIndex);
        // Tabs have variable widths, so interpolate the glow center linearly
        // between the two adjacent tab centers and express it as a fraction
        // of stripWidth (the painter's coordinate space).
        final lo = value.floor();
        final hi = (lo + 1).clamp(0, widget.items.length - 1);
        final f = value - lo;
        final loCenter = tabLefts[lo] + tabWidths[lo] / 2;
        final hiCenter = tabLefts[hi] + tabWidths[hi] / 2;
        final position = (loCenter + (hiCenter - loCenter) * f) / stripWidth;

        Widget flippedPaint(GlowTopBorderPainter painter) {
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.diagonal3Values(1, -1, 1),
            child: CustomPaint(
              painter: painter,
              child: const SizedBox.expand(),
            ),
          );
        }

        return Stack(
          children: [
            Positioned.fill(
              child: flippedPaint(
                GlowTopBorderPainter(
                  position: position,
                  glowColor: glowColor,
                  baseColor: const Color(0x00000000),
                  strokeWidth: crispStrokeWidth + tabBar.glowHaloStrokeBoost,
                  radius: tabBar.glowHaloCornerRadius,
                  glowSpread: tabBar.glowHaloSpread,
                  glowCore: tabBar.glowHaloCore,
                  haloSpread: tabBar.glowHaloSpread,
                  haloCore: tabBar.glowHaloCore,
                  haloAlpha: tabBar.glowHaloAlpha,
                  haloStrokeBoost: 0,
                  haloBlurSigma: tabBar.glowHaloBlurSigma,
                ),
              ),
            ),
            Positioned.fill(
              child: flippedPaint(
                GlowTopBorderPainter(
                  position: position,
                  glowColor: glowColor,
                  baseColor: glowColor.withValues(alpha: glowBaseOpacity),
                  strokeWidth: crispStrokeWidth,
                  radius: tabBar.glowHaloCornerRadius,
                  glowSpread: tabBar.glowSpread,
                  glowCore: tabBar.glowCore,
                  haloSpread: tabBar.glowHaloSpread,
                  haloCore: tabBar.glowHaloCore,
                  haloAlpha: tabBar.glowHaloAlpha,
                  haloStrokeBoost: tabBar.glowHaloStrokeBoost,
                  haloBlurSigma: tabBar.glowHaloBlurSigma,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TermosTabBarTab extends StatelessWidget {
  const _TermosTabBarTab({
    required this.index,
    required this.label,
    required this.controller,
    required this.height,
    required this.horizontalPadding,
    required this.onTap,
  });

  final int index;
  final String label;
  final TabController? controller;
  final double height;
  final double horizontalPadding;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final termos = TermosTheme.of(context);
    final colors = termos.colors;
    final textStyles = termos.textStyles;
    final ctrl = controller;
    final animation = ctrl?.animation;
    final listenables = <Listenable>[
      if (ctrl != null) ctrl,
      if (animation != null) animation,
    ];
    final listenable = listenables.isEmpty
        ? const AlwaysStoppedAnimation<double>(0)
        : Listenable.merge(listenables);
    final selectedIndex = ctrl?.index ?? 0;

    return Semantics(
      button: true,
      selected: selectedIndex == index,
      label: label,
      child: TermosTapTarget(
        onTap: onTap,
        borderRadius: BorderRadius.zero,
        child: SizedBox(
          height: height,
          child: AnimatedBuilder(
            animation: listenable,
            builder: (context, _) {
              final raw = animation?.value ?? ctrl?.index.toDouble() ?? 0;
              // Selection weight: 1 at this tab, fades linearly to 0 at neighbours.
              final t = (1.0 - (raw - index).abs()).clamp(0.0, 1.0);
              final labelColor = Color.lerp(
                colors.textSecondary,
                colors.textPrimary,
                t,
              )!;

              return Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textStyles.navLabel(
                      selected: t > 0.5,
                      color: labelColor,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CacheKey {
  const _CacheKey({
    required this.labelsHash,
    required this.styleHash,
    required this.scalerHash,
    required this.padding,
  });

  final int labelsHash;
  final int styleHash;
  final int scalerHash;
  final double padding;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _CacheKey &&
          labelsHash == other.labelsHash &&
          styleHash == other.styleHash &&
          scalerHash == other.scalerHash &&
          padding == other.padding;

  @override
  int get hashCode => Object.hash(labelsHash, styleHash, scalerHash, padding);
}
