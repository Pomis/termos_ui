import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:termos_ui/termos_ui.dart';

/// Primary CTA — same setup as the theme configurator gallery.
class GalleryButtonDemo extends StatelessWidget {
  const GalleryButtonDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final metrics = TermosTheme.of(context).metrics;
    return TermosButton(
      label: const Text('Action'),
      icon: HugeIcon(
        icon: HugeIcons.strokeRoundedTick01,
        color: Colors.white,
        size: metrics.buttonIconSize,
      ),
      onTap: () {},
    );
  }
}

/// Compact back control (default platform-adaptive back icon).
class GalleryBackButtonDemo extends StatelessWidget {
  const GalleryBackButtonDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TermosBackButton(onTap: () {}),
    );
  }
}

/// Large comet loader. When [interactive] is true, [onBump] is called on tap
/// (parent should increment [transitionKey]).
class GalleryLoaderDemo extends StatelessWidget {
  const GalleryLoaderDemo({
    super.key,
    this.transitionKey = 0,
    this.interactive = true,
    this.onBump,
  });

  final int transitionKey;
  final bool interactive;
  final VoidCallback? onBump;

  @override
  Widget build(BuildContext context) {
    final indicator = TermosLoadingIndicator(
      size: 100,
      transitionKey: transitionKey,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: interactive && onBump != null
            ? GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onBump,
                child: indicator,
              )
            : indicator,
      ),
    );
  }
}

/// Two draggable squares sharing a [TermosGroup] grid origin.
class GalleryDraggableSquaresDemo extends StatefulWidget {
  const GalleryDraggableSquaresDemo({super.key});

  @override
  State<GalleryDraggableSquaresDemo> createState() => _GalleryDraggableSquaresDemoState();
}

class _GalleryDraggableSquaresDemoState extends State<GalleryDraggableSquaresDemo> {
  Offset _offsetA = const Offset(20, 30);
  Offset _offsetB = const Offset(160, 30);

  static const double _squareSize = 100;

  @override
  Widget build(BuildContext context) {
    final termos = TermosTheme.of(context);
    final termosColors = termos.colors;
    final dotGridConfig = termos.dotGrid;
    final metrics = termos.metrics;

    return SizedBox(
      height: 180,
      child: TermosGroup(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            _buildSquare(
              termosColors,
              dotGridConfig,
              metrics,
              _offsetA,
              'A',
              (d) => setState(() => _offsetA += d),
            ),
            _buildSquare(
              termosColors,
              dotGridConfig,
              metrics,
              _offsetB,
              'B',
              (d) => setState(() => _offsetB += d),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSquare(
    TermosColors termosiColors,
    DotGridConfig dotGridConfig,
    TermosMetrics metrics,
    Offset offset,
    String label,
    ValueChanged<Offset> onDrag,
  ) {
    final radius = BorderRadius.circular(metrics.borderRadius);

    return Positioned(
      left: offset.dx,
      top: offset.dy,
      child: GestureDetector(
        onPanUpdate: (details) => onDrag(details.delta),
        child: Container(
          width: _squareSize,
          height: _squareSize,
          decoration: BoxDecoration(
            border: Border.all(
              color: termosiColors.primary.withValues(alpha: 0.3),
            ),
            borderRadius: radius,
          ),
          child: ClipRRect(
            borderRadius: radius,
            child: DotGridWidget(
              dotSize: dotGridConfig.dotSize,
              gridSpacing: dotGridConfig.spacing,
              primaryColor: termosiColors.primary.withValues(alpha: 0.45),
              backgroundColor: termosiColors.dotGridIdleMesh,
              blobRadius: dotGridConfig.blobRadius,
              interactiveMesh: false,
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    color: termosiColors.primary.withValues(alpha: 0.4),
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Horizontal segments with local selection state.
class GallerySegmentedDemo extends StatefulWidget {
  const GallerySegmentedDemo({super.key});

  @override
  State<GallerySegmentedDemo> createState() => _GallerySegmentedDemoState();
}

class _GallerySegmentedDemoState extends State<GallerySegmentedDemo> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return TermosSegmentedSelector(
      items: const [
        TermosSegmentedItem(label: 'A'),
        TermosSegmentedItem(label: 'B'),
        TermosSegmentedItem(label: 'C'),
      ],
      selectedIndex: _selectedIndex,
      onSelectionChanged: (i) => setState(() => _selectedIndex = i),
    );
  }
}

/// Toggle with local state.
class GallerySwitchDemo extends StatefulWidget {
  const GallerySwitchDemo({super.key});

  @override
  State<GallerySwitchDemo> createState() => _GallerySwitchDemoState();
}

class _GallerySwitchDemoState extends State<GallerySwitchDemo> {
  bool _on = true;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TermosSwitch(
        value: _on,
        onChanged: (v) => setState(() => _on = v),
      ),
    );
  }
}

/// Drum time picker with local state.
class GalleryTimePickerDemo extends StatefulWidget {
  const GalleryTimePickerDemo({super.key});

  @override
  State<GalleryTimePickerDemo> createState() => _GalleryTimePickerDemoState();
}

class _GalleryTimePickerDemoState extends State<GalleryTimePickerDemo> {
  TimeOfDay _time = const TimeOfDay(hour: 14, minute: 30);

  @override
  Widget build(BuildContext context) {
    return TermosTimePicker(
      time: _time,
      onTimeChanged: (t) => setState(() => _time = t),
      minuteStep: 15,
    );
  }
}

/// Prose-style field with owned controller.
class GalleryTextFieldDemo extends StatefulWidget {
  const GalleryTextFieldDemo({super.key});

  @override
  State<GalleryTextFieldDemo> createState() => _GalleryTextFieldDemoState();
}

class _GalleryTextFieldDemoState extends State<GalleryTextFieldDemo> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TermosTextField(
      label: 'Label',
      controller: _controller,
      hintText: 'Describe your feedback…',
      textFieldStyle: TermosTextFieldStyle.prose,
      minLines: 4,
    );
  }
}

/// Bottom nav with local selection (second tab selected, matching main gallery default).
class GalleryNavBarDemo extends StatefulWidget {
  const GalleryNavBarDemo({super.key});

  @override
  State<GalleryNavBarDemo> createState() => _GalleryNavBarDemoState();
}

class _GalleryNavBarDemoState extends State<GalleryNavBarDemo> {
  int _navIndex = 1;

  @override
  Widget build(BuildContext context) {
    final termos = TermosTheme.of(context);
    final termosColors = termos.colors;
    final navIconSize = termos.metrics.navBarIconSize;

    return TermosNavBar(
      items: [
        TermosNavBarItem(
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedMenu01,
            color: Colors.white,
            size: navIconSize,
          ),
          label: 'Item A',
          color: termosColors.primary,
        ),
        TermosNavBarItem(
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedLayers01,
            color: Colors.white,
            size: navIconSize,
          ),
          label: 'Item B',
          color: termosColors.info,
        ),
        TermosNavBarItem(
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedGridView,
            color: Colors.white,
            size: navIconSize,
          ),
          label: 'Item C',
          color: termosColors.warning,
        ),
        TermosNavBarItem(
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedMoreHorizontal,
            color: Colors.white,
            size: navIconSize,
          ),
          label: 'Item D',
          color: termosColors.error,
        ),
      ],
      selectedIndex: _navIndex,
      onItemSelected: (i) => setState(() => _navIndex = i),
    );
  }
}

/// Top scrollable tab bar wired to a [TabBarView] so the swipe-tracking glow
/// is demonstrable. Owns its [TabController] via [TickerProviderStateMixin].
class GalleryTabBarDemo extends StatefulWidget {
  const GalleryTabBarDemo({super.key});

  @override
  State<GalleryTabBarDemo> createState() => _GalleryTabBarDemoState();
}

class _GalleryTabBarDemoState extends State<GalleryTabBarDemo>
    with TickerProviderStateMixin {
  static const _tabs = [
    TermosTabBarItem(label: 'Overview'),
    TermosTabBarItem(label: 'Activity'),
    TermosTabBarItem(label: 'Devices'),
    TermosTabBarItem(label: 'Notifications'),
    TermosTabBarItem(label: 'Audit log'),
  ];

  late final TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final termos = TermosTheme.of(context);
    final colors = termos.colors;
    final textStyles = termos.textStyles;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TermosTabBar(
          items: _tabs,
          controller: _controller,
        ),
        SizedBox(
          height: 220,
          child: TabBarView(
            controller: _controller,
            children: [
              for (final tab in _tabs)
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  decoration: BoxDecoration(
                    color: colors.card,
                    borderRadius:
                        BorderRadius.circular(termos.metrics.borderRadius),
                    border: Border.all(color: colors.border),
                  ),
                  child: Center(
                    child: Text(
                      tab.label,
                      style: textStyles.sectionTitle(colors.textPrimary),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// CRT viewport block with sample copy (reads theme from context).
class GalleryCrtDemo extends StatelessWidget {
  const GalleryCrtDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final termos = TermosTheme.of(context);
    final termosColors = termos.colors;
    final textStyles = termos.textStyles;

    return TermosCrt(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'viewport // abstract buffer',
              style: textStyles.codePrimary(termosColors.primary),
            ),
            const SizedBox(height: 12),
            Text(
              r'$ sync --verbose',
              style: textStyles.codePrimary(termosColors.textSecondary),
            ),
            Text(
              r'> frame 0x7f2a · checksum ok',
              style: textStyles.codePrimary(termosColors.textMuted),
            ),
            Text(
              r'> raster: 1920×1080 · interlaced off',
              style: textStyles.codePrimary(termosColors.textMuted),
            ),
            const SizedBox(height: 16),
            Text(
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
              'Scanlines and vignette are driven by metrics + CRT effects on the theme.',
              style: textStyles.body(termosColors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}

/// All four slider variants from the gallery.
class GallerySliderShowcase extends StatefulWidget {
  const GallerySliderShowcase({super.key});

  @override
  State<GallerySliderShowcase> createState() => _GallerySliderShowcaseState();
}

class _GallerySliderShowcaseState extends State<GallerySliderShowcase> {
  double _basic = 2;
  double _floating = 5;
  double _continuous = 0.5;
  double _detailed = 96;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TermosSlider(
          value: _basic,
          start: 0,
          end: 4,
          step: 1,
          compact: true,
          onChanged: (v) => setState(() => _basic = v),
        ),
        const SizedBox(height: 8),
        TermosFloatingSlider(
          value: _floating,
          min: 0,
          max: 10,
          divisions: 10,
          compact: true,
          onChanged: (v) => setState(() => _floating = v),
        ),
        const SizedBox(height: 8),
        TermosContinuousSlider(
          value: _continuous,
          min: 0,
          max: 1,
          divisions: 4,
          compact: true,
          onChanged: (v) => setState(() => _continuous = v),
        ),
        const SizedBox(height: 8),
        TermosDetailedSlider(
          value: _detailed,
          min: 0,
          max: 240,
          divisions: 5,
          subdivisions: 3,
          compact: true,
          onChanged: (v) => setState(() => _detailed = v),
        ),
      ],
    );
  }
}

/// [GlowTopBorderPainter] sample strip.
class GalleryGlowTopBorderDemo extends StatelessWidget {
  const GalleryGlowTopBorderDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final termos = TermosTheme.of(context);
    final termosColors = termos.colors;

    return SizedBox(
      height: 48,
      child: CustomPaint(
        painter: GlowTopBorderPainter(
          position: 0.45,
          glowColor: termosColors.primary,
          baseColor: termosColors.primary.withValues(alpha: 0.08),
          strokeWidth: termos.metrics.glowTopBorderStrokeWidth,
          radius: termos.metrics.navBarCornerRadius,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

/// [ReactiveStarfieldPainter] sample block.
class GalleryReactiveStarfieldDemo extends StatelessWidget {
  const GalleryReactiveStarfieldDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final termos = TermosTheme.of(context);
    final termosColors = termos.colors;

    return SizedBox(
      height: 100,
      child: CustomPaint(
        painter: ReactiveStarfieldPainter(
          dotSize: termos.dotGrid.dotSize,
          gridSpacing: termos.dotGrid.spacing,
          glowPosition: 0.5,
          glowColor: termosColors.primary,
          intensity: termos.starfield.intensityButtonLight,
          seed: 42,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

/// Two stacked [TermosExpandableSection]s with independent local state.
///
/// Demonstrates header-only, header + content-between, and the expanded body
/// animation driven by tapping anywhere on the card.
class GalleryExpandableSectionDemo extends StatefulWidget {
  const GalleryExpandableSectionDemo({super.key});

  @override
  State<GalleryExpandableSectionDemo> createState() =>
      _GalleryExpandableSectionDemoState();
}

class _GalleryExpandableSectionDemoState
    extends State<GalleryExpandableSectionDemo> {
  bool _firstExpanded = true;
  bool _secondExpanded = false;

  @override
  Widget build(BuildContext context) {
    final termos = TermosTheme.of(context);
    final colors = termos.colors;
    final textStyles = termos.textStyles;

    Widget header(String title, String subtitle) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: textStyles.sectionTitle(colors.textPrimary)),
          const SizedBox(height: 2),
          Text(subtitle, style: textStyles.body(colors.textMuted)),
        ],
      );
    }

    return TermosGroup(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TermosExpandableSection(
            isExpanded: _firstExpanded,
            onToggle: () =>
                setState(() => _firstExpanded = !_firstExpanded),
            starfieldSeed: 'expandable-first'.hashCode,
            header: header(
              'Hand out',
              'Tap anywhere on the card to toggle.',
            ),
            contentBetween: Text(
              'Always-visible content sits between the header and the '
              'expanded body.',
              style: textStyles.body(colors.textSecondary),
            ),
            expandedChild: Text(
              'Expanded body — animates open with a size transition. '
              'Use this slot for forms, command details, or extended copy.',
              style: textStyles.body(colors.textPrimary),
            ),
          ),
          const SizedBox(height: 12),
          TermosExpandableSection(
            isExpanded: _secondExpanded,
            onToggle: () =>
                setState(() => _secondExpanded = !_secondExpanded),
            accentColor: colors.info,
            starfieldSeed: 'expandable-second'.hashCode,
            header: header(
              'Headers only',
              'Independent state, accent color, and starfield seed.',
            ),
            expandedChild: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                r'$ termos run --expand',
                style: textStyles.codePrimary(colors.textSecondary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// [ScanlinesPainter] strip.
class GalleryScanlinesDemo extends StatelessWidget {
  const GalleryScanlinesDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: CustomPaint(
        painter: ScanlinesPainter(opacity: 0.12),
        child: const SizedBox.expand(),
      ),
    );
  }
}
