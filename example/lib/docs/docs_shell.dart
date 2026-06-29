import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:termos_ui/termos_ui.dart';

import '../gallery/gallery_widget_demos.dart';
import 'docs_controller.dart';
import 'doc_widgets.dart';

/// Signature for opening the shared color-picker dialog.
typedef PickColor = void Function({
  required String title,
  required Color current,
  required ValueChanged<Color> onColor,
});

/// One entry in the left navigation rail.
class _Category {
  const _Category(this.label, this.icon, this.build);
  final String label;

  /// A HugeIcons constant (the package types these as `List<List<dynamic>>`).
  final List<List<dynamic>> icon;
  final List<Widget> Function(BuildContext, DocsController, PickColor) build;
}

/// Paged documentation: a left nav rail of categories, each opening a focused
/// page with a few related widgets, their parameters, and usage snippets.
class DocsShell extends StatefulWidget {
  const DocsShell({
    super.key,
    required this.controller,
    required this.onPickColor,
  });

  final DocsController controller;
  final PickColor onPickColor;

  @override
  State<DocsShell> createState() => _DocsShellState();
}

class _DocsShellState extends State<DocsShell> {
  int _index = 0;

  static final List<_Category> _categories = [
    _Category('Theme', HugeIcons.strokeRoundedPaintBoard, _themePage),
    _Category('Buttons', HugeIcons.strokeRoundedToggleOn, _buttonsPage),
    _Category('Navigation', HugeIcons.strokeRoundedGridView, _navigationPage),
    _Category('Inputs', HugeIcons.strokeRoundedTextFont, _inputsPage),
    _Category('Sliders', HugeIcons.strokeRoundedSlidersHorizontal, _slidersPage),
    _Category('Feedback & effects', HugeIcons.strokeRoundedSparkles, _effectsPage),
    _Category('Badges', HugeIcons.strokeRoundedTag01, _badgesPage),
  ];

  @override
  Widget build(BuildContext context) {
    final t = TermosTheme.of(context);
    final colors = t.colors;
    final sections = _categories[_index].build(
      context,
      widget.controller,
      widget.onPickColor,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: 232,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surface,
              border: Border(right: BorderSide(color: colors.border)),
            ),
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              children: [
                for (var i = 0; i < _categories.length; i++)
                  _NavEntry(
                    category: _categories[i],
                    selected: i == _index,
                    onTap: () => setState(() => _index = i),
                  ),
              ],
            ),
          ),
        ),
        Expanded(
          child: ColoredBox(
            color: colors.background,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 28),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: sections,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _NavEntry extends StatelessWidget {
  const _NavEntry({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final _Category category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = TermosTheme.of(context);
    final colors = t.colors;
    final tint = selected ? colors.primary : colors.textMuted;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: selected ? colors.primary.withAlpha(28) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            child: Row(
              children: [
                HugeIcon(icon: category.icon, color: tint, size: 18),
                const SizedBox(width: 12),
                Text(
                  category.label,
                  style: t.textStyles.body(
                    selected ? colors.textPrimary : colors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Demo helpers ────────────────────────────────────────────────────────────

List<TermosNavBarItem> _navItems(TermosColors colors, double iconSize) => [
  TermosNavBarItem(
    icon: HugeIcon(icon: HugeIcons.strokeRoundedMenu01, color: Colors.white, size: iconSize),
    label: 'Item A',
    color: colors.primary,
  ),
  TermosNavBarItem(
    icon: HugeIcon(icon: HugeIcons.strokeRoundedLayers01, color: Colors.white, size: iconSize),
    label: 'Item B',
    color: colors.info,
  ),
  TermosNavBarItem(
    icon: HugeIcon(icon: HugeIcons.strokeRoundedGridView, color: Colors.white, size: iconSize),
    label: 'Item C',
    color: colors.warning,
  ),
  TermosNavBarItem(
    icon: HugeIcon(icon: HugeIcons.strokeRoundedMoreHorizontal, color: Colors.white, size: iconSize),
    label: 'Item D',
    color: colors.error,
  ),
];

// ── Pages ───────────────────────────────────────────────────────────────────

List<Widget> _themePage(BuildContext context, DocsController c, PickColor pick) {
  return [
    DocSection(
      title: 'Palette',
      description:
          'The four colors every termos widget derives its surfaces, text, and '
          'glow from. Tap a swatch to change it.',
      demoBackground: false,
      demo: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          _Swatch('primary', c.primary, () => pick(title: 'primary', current: c.primary, onColor: (v) => c.update(() => c.primary = v))),
          _Swatch('background', c.background, () => pick(title: 'background', current: c.background, onColor: (v) => c.update(() => c.background = v))),
          _Swatch('surface', c.surface, () => pick(title: 'surface', current: c.surface, onColor: (v) => c.update(() => c.surface = v))),
          _Swatch('card', c.card, () => pick(title: 'card', current: c.card, onColor: (v) => c.update(() => c.card = v))),
        ],
      ),
      controls: [
        SwitchRow(label: 'Light palette', value: c.useLightTheme, onChanged: c.setLightTheme),
        SwitchRow(
          label: 'heavyEffectsEnabled (dot grid / starfield)',
          value: c.heavyEffects,
          onChanged: (v) => c.update(() => c.heavyEffects = v),
        ),
      ],
      code: 'MaterialApp(\n'
          '  theme: ThemeData(extensions: [\n'
          '    ${c.useLightTheme ? 'TermosThemeData.light()' : 'TermosThemeData.dark()'},\n'
          '  ]),\n'
          ');',
    ),
    DocSection(
      title: 'DotGridConfig',
      description:
          'The dot-grid mesh shared by buttons, the nav bar, and tap targets. '
          'Size, spacing, and the blob radius that ripples on press.',
      demo: const GalleryButtonDemo(),
      controls: [
        SliderRow(label: 'dotSize', value: c.dotSize, start: 1, end: 4, step: 1, onChanged: (v) => c.update(() => c.dotSize = v)),
        SliderRow(label: 'spacing', value: c.gridSpacing, start: 0, end: 8, step: 1, onChanged: (v) => c.update(() => c.gridSpacing = v)),
        SliderRow(label: 'blobRadius', value: c.blobRadius, start: 40, end: 160, step: TermosSlider.evenStep(40, 160, maxSteps: 6), onChanged: (v) => c.update(() => c.blobRadius = v)),
        DetailedSliderRow(label: 'borderRadius', value: c.borderRadius, min: 0, max: 64, divisions: 8, subdivisions: 2, onChanged: (v) => c.update(() => c.borderRadius = v)),
      ],
      code: 'TermosThemeData.dark().copyWith(\n'
          '  dotGrid: const DotGridConfig(\n'
          '    dotSize: ${_n(c.dotSize)},\n'
          '    spacing: ${_n(c.gridSpacing)},\n'
          '    blobRadius: ${_n(c.blobRadius)},\n'
          '  ),\n'
          ');',
    ),
  ];
}

List<Widget> _buttonsPage(BuildContext context, DocsController c, PickColor pick) {
  return [
    DocSection(
      title: 'TermosButton',
      description:
          'Primary action button with a dot-grid fill and a starfield glow that '
          'reacts to press and hover.',
      demo: const GalleryButtonDemo(),
      controls: [
        DetailedSliderRow(label: 'buttonHeight', value: c.buttonHeight, min: 40, max: 80, divisions: 5, subdivisions: 4, onChanged: (v) => c.update(() => c.buttonHeight = v)),
        ContinuousSliderRow(label: 'starfield intensityButtonDark', value: c.starfieldIntensityDark, min: 0, max: 3, divisions: 6, onChanged: (v) => c.update(() => c.starfieldIntensityDark = v)),
      ],
      code: 'TermosButton(\n'
          "  label: 'Continue',\n"
          '  onPressed: () {},\n'
          ');',
    ),
    DocSection(
      title: 'TermosBackButton',
      description: 'Compact back affordance with the same starfield treatment.',
      demo: const GalleryBackButtonDemo(),
      controls: [
        DetailedSliderRow(label: 'backButtonIconSize', value: c.backButtonIconSize, min: 12, max: 32, divisions: 5, subdivisions: 4, onChanged: (v) => c.update(() => c.backButtonIconSize = v)),
      ],
      code: 'TermosBackButton(onPressed: () => Navigator.pop(context));',
    ),
  ];
}

List<Widget> _navigationPage(BuildContext context, DocsController c, PickColor pick) {
  final t = TermosTheme.of(context);
  final colors = t.colors;
  return [
    DocSection(
      title: 'TermosNavBar',
      description:
          'Bottom navigation with dot grid, tap ripples, reactive starfield, and '
          'a sliding top-edge glow. Switch the shell between solid and glass.',
      demoBackground: false,
      demo: TermosNavBar(
        items: _navItems(colors, t.metrics.navBarIconSize),
        selectedIndex: c.navIndex,
        onItemSelected: (i) => c.update(() => c.navIndex = i),
      ),
      controls: [
        SwitchRow(label: 'glass style (navBarStyle)', value: c.navBarGlass, onChanged: (v) => c.update(() => c.navBarGlass = v)),
        if (c.navBarGlass) ...[
          ContinuousSliderRow(label: 'glass blurSigma', value: c.glassBlurSigma, min: 0, max: 20, divisions: 10, onChanged: (v) => c.update(() => c.glassBlurSigma = v)),
          SliderRow(label: 'glass reflectBoost', value: c.glassReflectBoost, start: 0, end: 1, step: TermosSlider.evenStep(0, 1), onChanged: (v) => c.update(() => c.glassReflectBoost = v)),
        ],
        DetailedSliderRow(label: 'navBarCornerRadius', value: c.navBarCornerRadius, min: 0, max: 64, divisions: 8, subdivisions: 2, onChanged: (v) => c.update(() => c.navBarCornerRadius = v)),
        DetailedSliderRow(label: 'navBarHeight', value: c.navBarHeight, min: 48, max: 128, divisions: 5, subdivisions: 4, onChanged: (v) => c.update(() => c.navBarHeight = v)),
        SliderRow(label: 'starfieldIntensityLight', value: c.navStarfieldIntensity, start: 0.5, end: 3, step: TermosSlider.evenStep(0.5, 3), onChanged: (v) => c.update(() => c.navStarfieldIntensity = v)),
      ],
      code: c.navBarGlass
          ? '// On the theme:\n'
              'TermosThemeData.dark().copyWith(\n'
              '  navBarStyle: TermosNavBarStyle.glass(\n'
              '    blurSigma: ${_n(c.glassBlurSigma)},\n'
              '    reflectBoost: ${_n(c.glassReflectBoost)},\n'
              '  ),\n'
              ');\n\n'
              'TermosNavBar(items: items, selectedIndex: i, onItemSelected: onTap);'
          : 'TermosNavBar(\n'
              '  items: items,\n'
              '  selectedIndex: selectedIndex,\n'
              '  onItemSelected: (i) => setState(() => selectedIndex = i),\n'
              ');',
    ),
    const DocSection(
      title: 'TermosTabBar',
      description: 'Scrollable top tabs with a glow indicator tracking the selection.',
      demoBackground: false,
      demo: GalleryTabBarDemo(),
      code: 'TermosTabBar(tabs: tabs, selectedIndex: i, onTabSelected: onTap);',
    ),
    DocSection(
      title: 'TermosSegmentedSelector',
      description: 'A small set of mutually-exclusive options with a glowing selection.',
      demo: TermosSegmentedSelector(
        items: const [
          TermosSegmentedItem(label: 'A'),
          TermosSegmentedItem(label: 'B'),
          TermosSegmentedItem(label: 'C'),
        ],
        selectedIndex: c.segmentIndex,
        onSelectionChanged: (i) => c.update(() => c.segmentIndex = i),
      ),
      controls: [
        SliderRow(label: 'glowColorMixWithWhite', value: c.segmentedGlowMix, start: 0, end: 1, step: TermosSlider.evenStep(0, 1), onChanged: (v) => c.update(() => c.segmentedGlowMix = v)),
        SliderRow(label: 'unselectedLabelMixWithWhiteLight', value: c.segmentedUnselectedLabelMix, start: 0, end: 1, step: TermosSlider.evenStep(0, 1), onChanged: (v) => c.update(() => c.segmentedUnselectedLabelMix = v)),
      ],
      code: 'TermosSegmentedSelector(\n'
          "  items: const [TermosSegmentedItem(label: 'A'), /* … */],\n"
          '  selectedIndex: i,\n'
          '  onSelectionChanged: onSelect,\n'
          ');',
    ),
  ];
}

List<Widget> _inputsPage(BuildContext context, DocsController c, PickColor pick) {
  return [
    DocSection(
      title: 'TermosTextField',
      description: 'Text input with prose styling, labels, and a focus glow.',
      demo: TermosTextField(
        label: 'Label',
        controller: c.proseField,
        hintText: 'Describe your feedback…',
        textFieldStyle: TermosTextFieldStyle.prose,
        minLines: 4,
      ),
      code: 'TermosTextField(\n'
          "  label: 'Label',\n"
          '  controller: controller,\n'
          '  textFieldStyle: TermosTextFieldStyle.prose,\n'
          '  minLines: 4,\n'
          ');',
    ),
    DocSection(
      title: 'TermosSwitch',
      description: 'A toggle with the dot-grid mesh on the active track.',
      demo: Align(
        alignment: Alignment.centerLeft,
        child: TermosSwitch(value: c.switchOn, onChanged: (v) => c.update(() => c.switchOn = v)),
      ),
      code: 'TermosSwitch(value: on, onChanged: (v) => setState(() => on = v));',
    ),
    DocSection(
      title: 'TermosTimePicker',
      description: 'A drum time picker with scanlines and a glowing selection band.',
      demo: TermosTimePicker(
        time: c.time,
        onTimeChanged: (t) => c.update(() => c.time = t),
        minuteStep: 15,
      ),
      controls: [
        SliderRow(label: 'scanlineOpacityDark', value: c.tpScanDark, start: 0, end: 0.1, step: TermosSlider.evenStep(0, 0.1), onChanged: (v) => c.update(() => c.tpScanDark = v)),
      ],
      code: 'TermosTimePicker(\n'
          '  time: time,\n'
          '  onTimeChanged: onChange,\n'
          '  minuteStep: 15,\n'
          ');',
    ),
  ];
}

List<Widget> _slidersPage(BuildContext context, DocsController c, PickColor pick) {
  return [
    const DocSection(
      title: 'Slider family',
      description:
          'TermosSlider (snapping), TermosContinuousSlider, TermosDetailedSlider '
          '(major + minor ticks), and the floating-label variant. These power the '
          'parameter controls throughout this docs app.',
      demo: GallerySliderShowcase(),
      code: 'TermosSlider(\n'
          '  value: value,\n'
          '  start: 0,\n'
          '  end: 100,\n'
          '  step: 10,\n'
          '  onChanged: onChanged,\n'
          ');',
    ),
  ];
}

List<Widget> _effectsPage(BuildContext context, DocsController c, PickColor pick) {
  return [
    DocSection(
      title: 'TermosLoadingIndicator',
      description: 'A randomized, animated loader assembled from dot-grid glyphs.',
      demo: GalleryLoaderDemo(
        transitionKey: c.loaderSeed,
        interactive: true,
        onBump: () => c.update(() => c.loaderSeed++),
      ),
      code: 'const TermosLoadingIndicator();',
    ),
    DocSection(
      title: 'TermosCrt',
      description: 'Wraps content in a CRT bezel with scanlines and a vignette.',
      demo: const GalleryCrtDemo(),
      controls: [
        SliderRow(label: 'crtScanlineOpacity', value: c.crtScanlineOpacity, start: 0, end: 0.2, step: TermosSlider.evenStep(0, 0.2), onChanged: (v) => c.update(() => c.crtScanlineOpacity = v)),
        SliderRow(label: 'crtVignetteStrength', value: c.crtVignette, start: 0, end: 1, step: TermosSlider.evenStep(0, 1), onChanged: (v) => c.update(() => c.crtVignette = v)),
      ],
      code: 'TermosCrt(child: child);',
    ),
    const DocSection(
      title: 'TermosExpandableSection',
      description: 'A disclosure section that expands from its tapped header.',
      demo: GalleryExpandableSectionDemo(),
      code: 'TermosExpandableSection(header: header, child: body);',
    ),
    const DocSection(
      title: 'TermosGroup',
      description: 'A draggable, reorderable group of dot-grid tiles.',
      demo: GalleryDraggableSquaresDemo(),
      code: 'TermosGroup(children: tiles);',
    ),
    const DocSection(
      title: 'Painters',
      description:
          'The low-level painters the widgets compose: GlowTopBorderPainter, '
          'ReactiveStarfieldPainter, and ScanlinesPainter.',
      demo: Column(
        children: [
          GalleryGlowTopBorderDemo(),
          SizedBox(height: 16),
          GalleryReactiveStarfieldDemo(),
          SizedBox(height: 16),
          GalleryScanlinesDemo(),
        ],
      ),
      code: 'CustomPaint(painter: ReactiveStarfieldPainter(/* … */));',
    ),
  ];
}

List<Widget> _badgesPage(BuildContext context, DocsController c, PickColor pick) {
  final colors = TermosTheme.of(context).colors;
  return [
    DocSection(
      title: 'TermosBadge',
      description:
          'A tinted pill — translucent fill, matching hairline border, optional '
          'leading icon. Defaults to the theme primary; pass any accent.',
      demo: Wrap(
        spacing: 12,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          TermosBadge(
            label: 'PRO',
            letterSpacing: 1.4,
            icon: HugeIcon(icon: HugeIcons.strokeRoundedLock, size: 12, color: colors.primary),
          ),
          const TermosBadge(label: '3/5', letterSpacing: 0.6),
          TermosBadge(label: 'NEW', color: colors.info, borderRadius: 6, fillAlpha: 22, letterSpacing: 1.8),
          TermosBadge(label: 'SALE', color: colors.warning),
          TermosBadge(label: 'ERROR', color: colors.error),
        ],
      ),
      code: 'TermosBadge(\n'
          "  label: 'PRO',\n"
          '  icon: Icon(Icons.lock, size: 12, color: colors.primary),\n'
          ');\n\n'
          "TermosBadge(label: 'NEW', color: colors.info, borderRadius: 6);",
    ),
    DocSection(
      title: 'TermosBadgeDot',
      description: 'A small glowing dot for "unseen / new" affordances next to a label.',
      demo: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Inbox', style: TermosTheme.of(context).textStyles.body(colors.textPrimary)),
          const SizedBox(width: 6),
          const TermosBadgeDot(),
        ],
      ),
      code: 'const TermosBadgeDot();',
    ),
  ];
}

/// Formats a double for code snippets: drops a trailing `.0`.
String _n(double v) {
  if (v == v.roundToDouble()) return v.toInt().toString();
  return v.toStringAsFixed(2);
}

class _Swatch extends StatelessWidget {
  const _Swatch(this.label, this.color, this.onTap);

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = TermosTheme.of(context);
    final colors = t.colors;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colors.border),
              ),
            ),
            const SizedBox(width: 8),
            Text(label, style: t.textStyles.codePrimary(colors.textPrimary)),
          ],
        ),
      ),
    );
  }
}
