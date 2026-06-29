import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:termos_ui/termos_ui.dart';

import '../gallery/gallery_widget_demos.dart';
import 'docs_controller.dart';
import 'docs_shell.dart' show PickColor;

/// The original all-in-one gallery: a left control panel of every theme knob and
/// a right column showing all widget demos at once. Preserved (reachable from
/// the docs app bar) for an at-a-glance overview. Reads the shared
/// [DocsController] so edits stay in sync with the paged docs.
class ClassicGalleryView extends StatelessWidget {
  const ClassicGalleryView({
    super.key,
    required this.controller,
    required this.onPickColor,
  });

  final DocsController controller;
  final PickColor onPickColor;

  @override
  Widget build(BuildContext context) {
    final termos = TermosTheme.of(context);
    final colors = termos.colors;
    final textStyles = termos.textStyles;
    final c = controller;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: 300,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surface,
              border: Border(right: BorderSide(color: colors.border)),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: _ControlPanel(controller: c),
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ColorPickerStrip(controller: c, onShowPicker: onPickColor),
                const SizedBox(height: 24),
                _twoColumnRow(
                  _demoSection('TermosButton', colors, textStyles, const GalleryButtonDemo()),
                  _demoSection('TermosBackButton', colors, textStyles, const GalleryBackButtonDemo()),
                ),
                _fullWidthSection(
                  'TermosLoadingIndicator',
                  colors,
                  textStyles,
                  GalleryLoaderDemo(
                    transitionKey: c.loaderSeed,
                    interactive: true,
                    onBump: () => c.update(() => c.loaderSeed++),
                  ),
                ),
                _fullWidthSection('TermosGroup', colors, textStyles, const GalleryDraggableSquaresDemo()),
                _fullWidthSection(
                  'TermosSegmentedSelector',
                  colors,
                  textStyles,
                  TermosSegmentedSelector(
                    items: const [
                      TermosSegmentedItem(label: 'A'),
                      TermosSegmentedItem(label: 'B'),
                      TermosSegmentedItem(label: 'C'),
                    ],
                    selectedIndex: c.segmentIndex,
                    onSelectionChanged: (i) => c.update(() => c.segmentIndex = i),
                  ),
                ),
                _fullWidthSection('TermosTabBar', colors, textStyles, const GalleryTabBarDemo()),
                _twoColumnRow(
                  _demoSection(
                    'TermosSwitch',
                    colors,
                    textStyles,
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TermosSwitch(value: c.switchOn, onChanged: (v) => c.update(() => c.switchOn = v)),
                    ),
                  ),
                  _demoSection(
                    'TermosTimePicker',
                    colors,
                    textStyles,
                    TermosTimePicker(
                      time: c.time,
                      onTimeChanged: (t) => c.update(() => c.time = t),
                      minuteStep: 15,
                    ),
                  ),
                ),
                _fullWidthSection(
                  'TermosTextField',
                  colors,
                  textStyles,
                  TermosTextField(
                    label: 'Label',
                    controller: c.proseField,
                    hintText: 'Describe your feedback…',
                    textFieldStyle: TermosTextFieldStyle.prose,
                    minLines: 4,
                  ),
                ),
                _fullWidthSection('TermosExpandableSection', colors, textStyles, const GalleryExpandableSectionDemo()),
                _fullWidthSection(
                  'TermosNavBar',
                  colors,
                  textStyles,
                  TermosNavBar(
                    items: _navItems(colors, termos.metrics.navBarIconSize),
                    selectedIndex: c.navIndex,
                    onItemSelected: (i) => c.update(() => c.navIndex = i),
                  ),
                ),
                _fullWidthSection('TermosCrt', colors, textStyles, const GalleryCrtDemo()),
                _fullWidthSection('TermosSlider', colors, textStyles, const GallerySliderShowcase()),
                _twoColumnRow(
                  _demoSection('GlowTopBorderPainter', colors, textStyles, const GalleryGlowTopBorderDemo()),
                  _demoSection('ReactiveStarfieldPainter', colors, textStyles, const GalleryReactiveStarfieldDemo()),
                ),
                _fullWidthSection('ScanlinesPainter', colors, textStyles, const GalleryScanlinesDemo()),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

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

Widget _twoColumnRow(Widget left, Widget right) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        const SizedBox(width: 16),
        Expanded(child: right),
      ],
    ),
  );
}

Widget _demoSection(String title, TermosColors colors, TermosTextStyles textStyles, Widget child) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        SelectableText(title, style: textStyles.codePrimary(colors.textPrimary).copyWith(fontSize: 13)),
        const SizedBox(height: 12),
        child,
      ],
    ),
  );
}

Widget _fullWidthSection(String title, TermosColors colors, TermosTextStyles textStyles, Widget child) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SelectableText(title, style: textStyles.codePrimary(colors.textPrimary).copyWith(fontSize: 13)),
        const SizedBox(height: 12),
        child,
      ],
    ),
  );
}

class _ColorPickerStrip extends StatelessWidget {
  const _ColorPickerStrip({required this.controller, required this.onShowPicker});

  final DocsController controller;
  final PickColor onShowPicker;

  @override
  Widget build(BuildContext context) {
    final t = TermosTheme.of(context);
    final colors = t.colors;
    final textStyles = t.textStyles;
    final c = controller;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectableText('Colors', style: textStyles.sectionTitle(colors.textPrimary)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _ColorChip(label: 'primary', color: c.primary, onTap: () => onShowPicker(title: 'primary', current: c.primary, onColor: (v) => c.update(() => c.primary = v))),
              _ColorChip(label: 'background', color: c.background, onTap: () => onShowPicker(title: 'background', current: c.background, onColor: (v) => c.update(() => c.background = v))),
              _ColorChip(label: 'surface', color: c.surface, onTap: () => onShowPicker(title: 'surface', current: c.surface, onColor: (v) => c.update(() => c.surface = v))),
              _ColorChip(label: 'card', color: c.card, onTap: () => onShowPicker(title: 'card', current: c.card, onColor: (v) => c.update(() => c.card = v))),
            ],
          ),
        ],
      ),
    );
  }
}

class _ColorChip extends StatelessWidget {
  const _ColorChip({required this.label, required this.color, required this.onTap});

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
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: colors.border),
              ),
            ),
            const SizedBox(width: 8),
            SelectableText(label, style: t.textStyles.codePrimary(colors.textPrimary)),
          ],
        ),
      ),
    );
  }
}

class _ControlPanel extends StatelessWidget {
  const _ControlPanel({required this.controller});

  final DocsController controller;

  @override
  Widget build(BuildContext context) {
    final t = TermosTheme.of(context);
    final colors = t.colors;
    final textStyles = t.textStyles;
    final c = controller;
    TextStyle heading() => textStyles.sectionTitle(colors.textPrimary);

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectableText('Theme & metrics', style: heading()),
          _ToggleRow(label: 'Light palette', value: c.useLightTheme, onChanged: c.setLightTheme),
          _ToggleRow(
            label: 'Heavy effects (dot grid / starfield)',
            value: c.heavyEffects,
            onChanged: (v) => c.update(() => c.heavyEffects = v),
          ),
          _ToggleRow(
            label: 'Glass nav bar',
            value: c.navBarGlass,
            onChanged: (v) => c.update(() => c.navBarGlass = v),
          ),
          const SizedBox(height: 8),
          _SliderRow(label: 'dotSize', value: c.dotSize, start: 1, end: 4, step: 1, onChanged: (v) => c.update(() => c.dotSize = v)),
          _SliderRow(label: 'spacing', value: c.gridSpacing, start: 0, end: 8, step: 1, onChanged: (v) => c.update(() => c.gridSpacing = v)),
          _SliderRow(label: 'blobRadius', value: c.blobRadius, start: 40, end: 160, step: TermosSlider.evenStep(40, 160, maxSteps: 6), onChanged: (v) => c.update(() => c.blobRadius = v)),
          _DetailedSliderRow(label: 'borderRadius', value: c.borderRadius, min: 0, max: 64, divisions: 8, subdivisions: 2, onChanged: (v) => c.update(() => c.borderRadius = v)),
          _DetailedSliderRow(label: 'buttonHeight', value: c.buttonHeight, min: 40, max: 80, divisions: 5, subdivisions: 4, onChanged: (v) => c.update(() => c.buttonHeight = v)),
          _DetailedSliderRow(label: 'navBarCornerRadius', value: c.navBarCornerRadius, min: 0, max: 64, divisions: 8, subdivisions: 2, onChanged: (v) => c.update(() => c.navBarCornerRadius = v)),
          _DetailedSliderRow(label: 'navBarHeight', value: c.navBarHeight, min: 48, max: 128, divisions: 5, subdivisions: 4, onChanged: (v) => c.update(() => c.navBarHeight = v)),
          _DetailedSliderRow(label: 'glowTopBorderStrokeWidth', value: c.glowStrokeWidth, min: 0, max: 8, divisions: 4, subdivisions: 4, onChanged: (v) => c.update(() => c.glowStrokeWidth = v)),
          _ContinuousSliderRow(label: 'intensityButtonDark', value: c.starfieldIntensityDark, min: 0, max: 3, divisions: 6, onChanged: (v) => c.update(() => c.starfieldIntensityDark = v)),
          _ContinuousSliderRow(label: 'intensityButtonLight', value: c.starfieldIntensityLight, min: 0, max: 3, divisions: 6, onChanged: (v) => c.update(() => c.starfieldIntensityLight = v)),
          _SliderRow(label: 'nav glowColorMixWithWhite', value: c.navGlowMix, start: 0, end: 1, step: TermosSlider.evenStep(0, 1), onChanged: (v) => c.update(() => c.navGlowMix = v)),
          _SliderRow(label: 'nav starfieldIntensityLight', value: c.navStarfieldIntensity, start: 0.5, end: 3, step: TermosSlider.evenStep(0.5, 3), onChanged: (v) => c.update(() => c.navStarfieldIntensity = v)),
          _SliderRow(label: 'segmented glowColorMixWithWhite', value: c.segmentedGlowMix, start: 0, end: 1, step: TermosSlider.evenStep(0, 1), onChanged: (v) => c.update(() => c.segmentedGlowMix = v)),
          _SliderRow(label: 'segmented unselectedLabelMixWithWhiteLight', value: c.segmentedUnselectedLabelMix, start: 0, end: 1, step: TermosSlider.evenStep(0, 1), onChanged: (v) => c.update(() => c.segmentedUnselectedLabelMix = v)),
          _DetailedSliderRow(label: 'backButtonIconSize', value: c.backButtonIconSize, min: 12, max: 32, divisions: 5, subdivisions: 4, onChanged: (v) => c.update(() => c.backButtonIconSize = v)),
          _SliderRow(label: 'crtScanlineOpacity', value: c.crtScanlineOpacity, start: 0, end: 0.2, step: TermosSlider.evenStep(0, 0.2), onChanged: (v) => c.update(() => c.crtScanlineOpacity = v)),
          _SliderRow(label: 'crtVignetteStrength', value: c.crtVignette, start: 0, end: 1, step: TermosSlider.evenStep(0, 1), onChanged: (v) => c.update(() => c.crtVignette = v)),
          _SliderRow(label: 'tp scanlineOpacityLight', value: c.tpScanLight, start: 0, end: 0.08, step: TermosSlider.evenStep(0, 0.08), onChanged: (v) => c.update(() => c.tpScanLight = v)),
          _SliderRow(label: 'tp scanlineOpacityDark', value: c.tpScanDark, start: 0, end: 0.1, step: TermosSlider.evenStep(0, 0.1), onChanged: (v) => c.update(() => c.tpScanDark = v)),
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({required this.label, required this.value, required this.onChanged});

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = TermosTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: SelectableText(label, style: t.textStyles.body(t.colors.textPrimary))),
          TermosSwitch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _ContinuousSliderRow extends StatelessWidget {
  const _ContinuousSliderRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = TermosTheme.of(context);
    return _row(
      t,
      label,
      TermosContinuousSlider(value: value, min: min, max: max, divisions: divisions, compact: true, onChanged: onChanged),
    );
  }
}

class _DetailedSliderRow extends StatelessWidget {
  const _DetailedSliderRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.subdivisions,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final int subdivisions;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = TermosTheme.of(context);
    return _row(
      t,
      label,
      TermosDetailedSlider(value: value, min: min, max: max, divisions: divisions, subdivisions: subdivisions, compact: true, onChanged: onChanged),
    );
  }
}

class _SliderRow extends StatelessWidget {
  const _SliderRow({
    required this.label,
    required this.value,
    required this.start,
    required this.end,
    required this.step,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double start;
  final double end;
  final double step;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = TermosTheme.of(context);
    return _row(
      t,
      label,
      TermosSlider(value: value, start: start, end: end, step: step, compact: true, onChanged: onChanged),
    );
  }
}

Widget _row(TermosThemeData t, String label, Widget child) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SelectableText(
          label,
          style: t.textStyles.codePrimary(t.colors.textMuted).copyWith(fontSize: 12),
          maxLines: 1,
        ),
        const SizedBox(height: 2),
        child,
      ],
    ),
  );
}
