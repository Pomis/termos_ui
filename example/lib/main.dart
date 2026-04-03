import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:termos_ui/termos_ui.dart';
import 'package:termos_ui_example/gallery/gallery_widget_demos.dart';

void main() => runApp(const TermosUiExampleApp());

/// Interactive gallery for `termos_ui` widgets with sliders and color pickers.
class TermosUiExampleApp extends StatefulWidget {
  const TermosUiExampleApp({super.key});

  @override
  State<TermosUiExampleApp> createState() => _TermosUiExampleAppState();
}

class _TermosUiExampleAppState extends State<TermosUiExampleApp> {
  bool _useLightTheme = false;
  bool _heavyEffects = true;
  bool _showAdditionalThemeMetrics = false;

  late Color _primary;
  late Color _background;
  late Color _surface;
  late Color _card;

  double _dotSize = 2;
  double _gridSpacing = 6;
  double _blobRadius = 112;

  double _borderRadius = 6;
  double _buttonHeight = 44;
  double _navBarCornerRadius = 28;
  double _navBarHeight = 72;
  double _glowStrokeWidth = 2;

  double _starfieldIntensityLight = 1.8;
  double _starfieldIntensityDark = 1.5;

  double _navGlowMix = 0.5;
  double _navStarfieldIntensity = 1.5;

  double _segmentedGlowMix = 0.5;

  double _crtScanlineOpacity = 0.06;
  double _crtVignette = 0.5;

  double _tpScanLight = 0.015;
  double _tpScanDark = 0.03;

  int _navIndex = 1;
  int _segmentIndex = 0;
  bool _switchOn = true;
  TimeOfDay _time = const TimeOfDay(hour: 14, minute: 30);

  int _loaderSeed = 0;

  final _proseFieldController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _applyPalette(TermosColors.dark);
  }

  @override
  void dispose() {
    _proseFieldController.dispose();
    super.dispose();
  }

  void _applyPalette(TermosColors source) {
    _primary = source.primary;
    _background = source.background;
    _surface = source.surface;
    _card = source.card;
  }

  TermosThemeData _themeData() {
    final base = _useLightTheme ? TermosThemeData.light() : TermosThemeData.dark();
    final customColors = base.colors.copyWith(
      primary: _primary,
      background: _background,
      surface: _surface,
      card: _card,
    );
    return base.copyWith(
      colors: customColors,
      textStyles: TermosTextStyles.fromColors(customColors),
      dotGrid: base.dotGrid.copyWith(
        dotSize: _dotSize,
        spacing: _gridSpacing,
        blobRadius: _blobRadius,
      ),
      metrics: base.metrics.copyWith(
        borderRadius: _borderRadius,
        buttonHeight: _buttonHeight,
        navBarCornerRadius: _navBarCornerRadius,
        navBarHeight: _navBarHeight,
        glowTopBorderStrokeWidth: _glowStrokeWidth,
        crtScanlineOpacity: _crtScanlineOpacity,
        crtVignetteStrength: _crtVignette,
      ),
      starfield: base.starfield.copyWith(
        intensityButtonLight: _starfieldIntensityLight,
        intensityButtonDark: _starfieldIntensityDark,
      ),
      navBar: base.navBar.copyWith(
        glowColorMixWithWhite: _navGlowMix,
        starfieldIntensityLight: _navStarfieldIntensity,
      ),
      segmented: base.segmented.copyWith(
        glowColorMixWithWhite: _segmentedGlowMix,
      ),
      timePicker: base.timePicker.copyWith(
        scanlineOpacityLight: _tpScanLight,
        scanlineOpacityDark: _tpScanDark,
      ),
      heavyEffectsEnabled: _heavyEffects,
    );
  }

  void _set(VoidCallback fn) => setState(fn);

  Future<void> _showColorPicker({
    required String title,
    required Color current,
    required ValueChanged<Color> onColor,
  }) async {
    final themeSnapshot = _themeData();
    await showDialog<void>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: true,
      builder: (dialogContext) {
        return TermosTheme(
          data: themeSnapshot,
          child: _TermosColorPickerDialog(
            title: title,
            initialColor: current,
            onApply: onColor,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final termos = _themeData();
    final colors = termos.colors;
    final textStyles = termos.textStyles;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'termos_ui Theme configurator',
      theme: ThemeData(
        useMaterial3: true,
        brightness: _useLightTheme ? Brightness.light : Brightness.dark,
        scaffoldBackgroundColor: colors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: colors.primary,
          brightness: _useLightTheme ? Brightness.light : Brightness.dark,
        ),
      ),
      home: TermosTheme(
        data: termos,
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              'termos_ui Theme configurator',
              style: textStyles.sectionTitle(colors.primary),
            ),
            backgroundColor: colors.surface,
            foregroundColor: colors.textPrimary,
          ),
          body: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 300,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.surface,
                    border: Border(
                      right: BorderSide(color: colors.border),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(12),
                    child: _ControlPanel(
                  colors: colors,
                  textStyles: textStyles,
                  useLightTheme: _useLightTheme,
                  heavyEffects: _heavyEffects,
                  showAdditionalThemeMetrics: _showAdditionalThemeMetrics,
                  onToggleAdditionalThemeMetrics: () => _set(
                    () => _showAdditionalThemeMetrics = !_showAdditionalThemeMetrics,
                  ),
                  dotSize: _dotSize,
                  gridSpacing: _gridSpacing,
                  blobRadius: _blobRadius,
                  borderRadius: _borderRadius,
                  buttonHeight: _buttonHeight,
                  navBarCornerRadius: _navBarCornerRadius,
                  navBarHeight: _navBarHeight,
                  glowStrokeWidth: _glowStrokeWidth,
                  starfieldIntensityLight: _starfieldIntensityLight,
                  starfieldIntensityDark: _starfieldIntensityDark,
                  navGlowMix: _navGlowMix,
                  navStarfieldIntensity: _navStarfieldIntensity,
                  segmentedGlowMix: _segmentedGlowMix,
                  crtScanlineOpacity: _crtScanlineOpacity,
                  crtVignette: _crtVignette,
                  tpScanLight: _tpScanLight,
                  tpScanDark: _tpScanDark,
                  onToggleLight: (v) => _set(() {
                    _useLightTheme = v;
                    _applyPalette(v ? TermosColors.light : TermosColors.dark);
                  }),
                  onToggleHeavy: (v) => _set(() => _heavyEffects = v),
                  onDotSize: (v) => _set(() => _dotSize = v),
                  onGridSpacing: (v) => _set(() => _gridSpacing = v),
                  onBlobRadius: (v) => _set(() => _blobRadius = v),
                  onBorderRadius: (v) => _set(() => _borderRadius = v),
                  onButtonHeight: (v) => _set(() => _buttonHeight = v),
                  onNavBarCornerRadius: (v) => _set(() => _navBarCornerRadius = v),
                  onNavBarHeight: (v) => _set(() => _navBarHeight = v),
                  onGlowStrokeWidth: (v) => _set(() => _glowStrokeWidth = v),
                  onStarfieldLight: (v) => _set(() => _starfieldIntensityLight = v),
                  onStarfieldDark: (v) => _set(() => _starfieldIntensityDark = v),
                  onNavGlowMix: (v) => _set(() => _navGlowMix = v),
                  onNavStarfieldIntensity: (v) => _set(() => _navStarfieldIntensity = v),
                  onSegmentedGlowMix: (v) => _set(() => _segmentedGlowMix = v),
                  onCrtScanline: (v) => _set(() => _crtScanlineOpacity = v),
                  onCrtVignette: (v) => _set(() => _crtVignette = v),
                  onTpScanLight: (v) => _set(() => _tpScanLight = v),
                  onTpScanDark: (v) => _set(() => _tpScanDark = v),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _ColorPickerStrip(
                        colors: colors,
                        textStyles: textStyles,
                        primary: _primary,
                        background: _background,
                        surface: _surface,
                        card: _card,
                        onPickPrimary: (c) => _set(() => _primary = c),
                        onPickBackground: (c) => _set(() => _background = c),
                        onPickSurface: (c) => _set(() => _surface = c),
                        onPickCard: (c) => _set(() => _card = c),
                        onShowPicker: _showColorPicker,
                      ),
                      const SizedBox(height: 24),
                _twoColumnRow(
                  _demoSection(
                    'TermosButton',
                    colors,
                    textStyles,
                    const GalleryButtonDemo(),
                  ),
                  _demoSection(
                    'TermosBackButton',
                    colors,
                    textStyles,
                    const GalleryBackButtonDemo(),
                  ),
                ),
                _fullWidthSection(
                  'TermosLoadingIndicator',
                  colors,
                  textStyles,
                  GalleryLoaderDemo(
                    transitionKey: _loaderSeed,
                    interactive: true,
                    onBump: () => _set(() => _loaderSeed++),
                  ),
                ),
                _fullWidthSection(
                  'TermosGroup',
                  colors,
                  textStyles,
                  const GalleryDraggableSquaresDemo(),
                ),
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
                    selectedIndex: _segmentIndex,
                    onSelectionChanged: (i) => _set(() => _segmentIndex = i),
                  ),
                ),
                _twoColumnRow(
                  _demoSection(
                    'TermosSwitch',
                    colors,
                    textStyles,
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TermosSwitch(
                        value: _switchOn,
                        onChanged: (v) => _set(() => _switchOn = v),
                      ),
                    ),
                  ),
                  _demoSection(
                    'TermosTimePicker',
                    colors,
                    textStyles,
                    TermosTimePicker(
                      time: _time,
                      onTimeChanged: (t) => _set(() => _time = t),
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
                    controller: _proseFieldController,
                    hintText: 'Describe your feedback…',
                    textFieldStyle: TermosTextFieldStyle.prose,
                    minLines: 4,
                  ),
                ),
                _fullWidthSection(
                  'TermosNavBar',
                  colors,
                  textStyles,
                  TermosNavBar(
                    items: [
                      TermosNavBarItem(
                        icon: HugeIcons.strokeRoundedMenu01,
                        label: 'Item A',
                        color: colors.primary,
                      ),
                      TermosNavBarItem(
                        icon: HugeIcons.strokeRoundedLayers01,
                        label: 'Item B',
                        color: colors.info,
                      ),
                      TermosNavBarItem(
                        icon: HugeIcons.strokeRoundedGridView,
                        label: 'Item C',
                        color: colors.warning,
                      ),
                      TermosNavBarItem(
                        icon: HugeIcons.strokeRoundedMoreHorizontal,
                        label: 'Item D',
                        color: colors.error,
                      ),
                    ],
                    selectedIndex: _navIndex,
                    onItemSelected: (i) => _set(() => _navIndex = i),
                  ),
                ),
                _fullWidthSection(
                  'TermosCrt',
                  colors,
                  textStyles,
                  const GalleryCrtDemo(),
                ),
                _fullWidthSection(
                  'TermosSlider',
                  colors,
                  textStyles,
                  const GallerySliderShowcase(),
                ),
                _twoColumnRow(
                  _demoSection(
                    'GlowTopBorderPainter',
                    colors,
                    textStyles,
                    const GalleryGlowTopBorderDemo(),
                  ),
                  _demoSection(
                    'ReactiveStarfieldPainter',
                    colors,
                    textStyles,
                    const GalleryReactiveStarfieldDemo(),
                  ),
                ),
                _fullWidthSection(
                  'ScanlinesPainter',
                  colors,
                  textStyles,
                  const GalleryScanlinesDemo(),
                ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Pure Flutter RGB editor — works on web (no canvas/gesture issues from third-party pickers).
class _TermosColorPickerDialog extends StatefulWidget {
  const _TermosColorPickerDialog({
    required this.title,
    required this.initialColor,
    required this.onApply,
  });

  final String title;
  final Color initialColor;
  final ValueChanged<Color> onApply;

  @override
  State<_TermosColorPickerDialog> createState() => _TermosColorPickerDialogState();
}

class _TermosColorPickerDialogState extends State<_TermosColorPickerDialog> {
  late Color _color;

  @override
  void initState() {
    super.initState();
    _color = widget.initialColor;
  }

  static int _ch(Color c, double Function(Color) comp) =>
      (comp(c) * 255.0).round().clamp(0, 255);

  void _setRgb(int r, int g, int b) {
    setState(() {
      _color = Color.fromARGB(255, r, g, b);
    });
  }

  @override
  Widget build(BuildContext context) {
    final termos = TermosTheme.of(context);
    final colors = termos.colors;
    final textStyles = termos.textStyles;
    final metrics = termos.metrics;
    final r = _ch(_color, (c) => c.r);
    final g = _ch(_color, (c) => c.g);
    final b = _ch(_color, (c) => c.b);

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SelectableText(widget.title, style: textStyles.sectionTitle(colors.textPrimary)),
              const SizedBox(height: 16),
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: _color,
                        borderRadius: BorderRadius.circular(metrics.borderRadius),
                        border: Border.all(color: colors.dotGridButtonBorder, width: 1),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SelectableText('R', style: textStyles.codePrimary(colors.textMuted)),
                    SizedBox(
                      height: 44,
                      child: TermosSlider(
                        value: r.toDouble(),
                        start: 0,
                        end: 255,
                        step: TermosSlider.evenStep(0, 255),
                        formatValue: (v) => v.round().clamp(0, 255).toString(),
                        onChanged: (v) {
                          final nextR = v.round().clamp(0, 255);
                          final base = _color;
                          _setRgb(nextR, _ch(base, (c) => c.g), _ch(base, (c) => c.b));
                        },
                      ),
                    ),
                    SelectableText('G', style: textStyles.codePrimary(colors.textMuted)),
                    SizedBox(
                      height: 44,
                      child: TermosSlider(
                        value: g.toDouble(),
                        start: 0,
                        end: 255,
                        step: TermosSlider.evenStep(0, 255),
                        formatValue: (v) => v.round().clamp(0, 255).toString(),
                        onChanged: (v) {
                          final nextG = v.round().clamp(0, 255);
                          final base = _color;
                          _setRgb(_ch(base, (c) => c.r), nextG, _ch(base, (c) => c.b));
                        },
                      ),
                    ),
                    SelectableText('B', style: textStyles.codePrimary(colors.textMuted)),
                    SizedBox(
                      height: 44,
                      child: TermosSlider(
                        value: b.toDouble(),
                        start: 0,
                        end: 255,
                        step: TermosSlider.evenStep(0, 255),
                        formatValue: (v) => v.round().clamp(0, 255).toString(),
                        onChanged: (v) {
                          final nextB = v.round().clamp(0, 255);
                          final base = _color;
                          _setRgb(_ch(base, (c) => c.r), _ch(base, (c) => c.g), nextB);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      widget.onApply(_color);
                      Navigator.of(context).pop();
                    },
                    child: const Text('Apply'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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

Widget _demoSection(
  String title,
  TermosColors colors,
  TermosTextStyles textStyles,
  Widget child,
) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        SelectableText(
          title,
          style: textStyles.codePrimary(colors.textPrimary).copyWith(fontSize: 13),
        ),
        const SizedBox(height: 12),
        child,
      ],
    ),
  );
}

Widget _fullWidthSection(
  String title,
  TermosColors colors,
  TermosTextStyles textStyles,
  Widget child,
) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SelectableText(
          title,
          style: textStyles.codePrimary(colors.textPrimary).copyWith(fontSize: 13),
        ),
        const SizedBox(height: 12),
        child,
      ],
    ),
  );
}

class _ColorPickerStrip extends StatelessWidget {
  const _ColorPickerStrip({
    required this.colors,
    required this.textStyles,
    required this.primary,
    required this.background,
    required this.surface,
    required this.card,
    required this.onPickPrimary,
    required this.onPickBackground,
    required this.onPickSurface,
    required this.onPickCard,
    required this.onShowPicker,
  });

  final TermosColors colors;
  final TermosTextStyles textStyles;
  final Color primary;
  final Color background;
  final Color surface;
  final Color card;
  final ValueChanged<Color> onPickPrimary;
  final ValueChanged<Color> onPickBackground;
  final ValueChanged<Color> onPickSurface;
  final ValueChanged<Color> onPickCard;
  final Future<void> Function({
    required String title,
    required Color current,
    required ValueChanged<Color> onColor,
  }) onShowPicker;

  @override
  Widget build(BuildContext context) {
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
                _ColorChip(
                  label: 'primary',
                  color: primary,
                  textStyles: textStyles,
                  colors: colors,
                  onTap: () => onShowPicker(
                    title: 'primary',
                    current: primary,
                    onColor: onPickPrimary,
                  ),
                ),
                _ColorChip(
                  label: 'background',
                  color: background,
                  textStyles: textStyles,
                  colors: colors,
                  onTap: () => onShowPicker(
                    title: 'background',
                    current: background,
                    onColor: onPickBackground,
                  ),
                ),
                _ColorChip(
                  label: 'surface',
                  color: surface,
                  textStyles: textStyles,
                  colors: colors,
                  onTap: () => onShowPicker(
                    title: 'surface',
                    current: surface,
                    onColor: onPickSurface,
                  ),
                ),
                _ColorChip(
                  label: 'card',
                  color: card,
                  textStyles: textStyles,
                  colors: colors,
                  onTap: () => onShowPicker(
                    title: 'card',
                    current: card,
                    onColor: onPickCard,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _ColorChip extends StatelessWidget {
  const _ColorChip({
    required this.label,
    required this.color,
    required this.textStyles,
    required this.colors,
    required this.onTap,
  });

  final String label;
  final Color color;
  final TermosTextStyles textStyles;
  final TermosColors colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
            SelectableText(label, style: textStyles.codePrimary(colors.textPrimary)),
          ],
        ),
      ),
    );
  }
}

class _ControlPanel extends StatelessWidget {
  const _ControlPanel({
    required this.colors,
    required this.textStyles,
    required this.useLightTheme,
    required this.heavyEffects,
    required this.showAdditionalThemeMetrics,
    required this.onToggleAdditionalThemeMetrics,
    required this.dotSize,
    required this.gridSpacing,
    required this.blobRadius,
    required this.borderRadius,
    required this.buttonHeight,
    required this.navBarCornerRadius,
    required this.navBarHeight,
    required this.glowStrokeWidth,
    required this.starfieldIntensityLight,
    required this.starfieldIntensityDark,
    required this.navGlowMix,
    required this.navStarfieldIntensity,
    required this.segmentedGlowMix,
    required this.crtScanlineOpacity,
    required this.crtVignette,
    required this.tpScanLight,
    required this.tpScanDark,
    required this.onToggleLight,
    required this.onToggleHeavy,
    required this.onDotSize,
    required this.onGridSpacing,
    required this.onBlobRadius,
    required this.onBorderRadius,
    required this.onButtonHeight,
    required this.onNavBarCornerRadius,
    required this.onNavBarHeight,
    required this.onGlowStrokeWidth,
    required this.onStarfieldLight,
    required this.onStarfieldDark,
    required this.onNavGlowMix,
    required this.onNavStarfieldIntensity,
    required this.onSegmentedGlowMix,
    required this.onCrtScanline,
    required this.onCrtVignette,
    required this.onTpScanLight,
    required this.onTpScanDark,
  });

  final TermosColors colors;
  final TermosTextStyles textStyles;
  final bool useLightTheme;
  final bool heavyEffects;
  final bool showAdditionalThemeMetrics;
  final VoidCallback onToggleAdditionalThemeMetrics;
  final double dotSize;
  final double gridSpacing;
  final double blobRadius;
  final double borderRadius;
  final double buttonHeight;
  final double navBarCornerRadius;
  final double navBarHeight;
  final double glowStrokeWidth;
  final double starfieldIntensityLight;
  final double starfieldIntensityDark;
  final double navGlowMix;
  final double navStarfieldIntensity;
  final double segmentedGlowMix;
  final double crtScanlineOpacity;
  final double crtVignette;
  final double tpScanLight;
  final double tpScanDark;
  final ValueChanged<bool> onToggleLight;
  final ValueChanged<bool> onToggleHeavy;
  final ValueChanged<double> onDotSize;
  final ValueChanged<double> onGridSpacing;
  final ValueChanged<double> onBlobRadius;
  final ValueChanged<double> onBorderRadius;
  final ValueChanged<double> onButtonHeight;
  final ValueChanged<double> onNavBarCornerRadius;
  final ValueChanged<double> onNavBarHeight;
  final ValueChanged<double> onGlowStrokeWidth;
  final ValueChanged<double> onStarfieldLight;
  final ValueChanged<double> onStarfieldDark;
  final ValueChanged<double> onNavGlowMix;
  final ValueChanged<double> onNavStarfieldIntensity;
  final ValueChanged<double> onSegmentedGlowMix;
  final ValueChanged<double> onCrtScanline;
  final ValueChanged<double> onCrtVignette;
  final ValueChanged<double> onTpScanLight;
  final ValueChanged<double> onTpScanDark;

  @override
  Widget build(BuildContext context) {
    TextStyle heading() => textStyles.sectionTitle(colors.textPrimary);

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            SelectableText('Theme & metrics', style: heading()),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: SelectableText(
                      'Light palette',
                      style: textStyles.body(colors.textPrimary),
                    ),
                  ),
                  TermosSwitch(
                    value: useLightTheme,
                    onChanged: onToggleLight,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: SelectableText(
                      'Heavy effects (dot grid / starfield)',
                      style: textStyles.body(colors.textPrimary),
                    ),
                  ),
                  TermosSwitch(
                    value: heavyEffects,
                    onChanged: onToggleHeavy,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 4),
              child: SelectableText(
                'Main',
                style: textStyles.codePrimary(colors.textMuted).copyWith(fontSize: 11),
              ),
            ),
            _SliderRow(
              label: 'dotSize',
              value: dotSize,
              start: 1,
              end: 4,
              step: 1,
              onChanged: onDotSize,
              colors: colors,
              textStyles: textStyles,
            ),
            _SliderRow(
              label: 'spacing',
              value: gridSpacing,
              start: 0,
              end: 8,
              step: 1,
              onChanged: onGridSpacing,
              colors: colors,
              textStyles: textStyles,
            ),
            _DetailedSliderRow(
              label: 'borderRadius',
              value: borderRadius,
              min: 0,
              max: 64,
              divisions: 8,
              subdivisions: 2,
              onChanged: onBorderRadius,
              colors: colors,
              textStyles: textStyles,
            ),
            _DetailedSliderRow(
              label: 'glowTopBorderStrokeWidth',
              value: glowStrokeWidth,
              min: 0,
              max: 8,
              divisions: 4,
              subdivisions: 4,
              onChanged: onGlowStrokeWidth,
              colors: colors,
              textStyles: textStyles,
            ),
            _ContinuousSliderRow(
              label: 'intensityButtonDark',
              value: starfieldIntensityDark,
              min: 0,
              max: 3,
              divisions: 6,
              onChanged: onStarfieldDark,
              colors: colors,
              textStyles: textStyles,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: InkWell(
                onTap: onToggleAdditionalThemeMetrics,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  child: Row(
                    children: [
                      HugeIcon(
                        icon: showAdditionalThemeMetrics
                            ? HugeIcons.strokeRoundedArrowUp01
                            : HugeIcons.strokeRoundedArrowDown01,
                        color: colors.textMuted,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      SelectableText(
                        showAdditionalThemeMetrics ? 'Show less' : 'Show all',
                        style: textStyles.body(colors.primary),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (showAdditionalThemeMetrics) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: SelectableText(
                  'Additional',
                  style: textStyles.codePrimary(colors.textMuted).copyWith(fontSize: 11),
                ),
              ),
              _SliderRow(
                label: 'blobRadius',
                value: blobRadius,
                start: 40,
                end: 160,
                step: TermosSlider.evenStep(40, 160, maxSteps: 6),
                onChanged: onBlobRadius,
                colors: colors,
                textStyles: textStyles,
              ),
              _DetailedSliderRow(
                label: 'buttonHeight',
                value: buttonHeight,
                min: 40,
                max: 80,
                divisions: 5,
                subdivisions: 4,
                onChanged: onButtonHeight,
                colors: colors,
                textStyles: textStyles,
              ),
              _DetailedSliderRow(
                label: 'navBarCornerRadius',
                value: navBarCornerRadius,
                min: 0,
                max: 64,
                divisions: 8,
                subdivisions: 2,
                onChanged: onNavBarCornerRadius,
                colors: colors,
                textStyles: textStyles,
              ),
              _DetailedSliderRow(
                label: 'navBarHeight',
                value: navBarHeight,
                min: 48,
                max: 128,
                divisions: 5,
                subdivisions: 4,
                onChanged: onNavBarHeight,
                colors: colors,
                textStyles: textStyles,
              ),
              _ContinuousSliderRow(
                label: 'intensityButtonLight',
                value: starfieldIntensityLight,
                min: 0,
                max: 3,
                divisions: 6,
                onChanged: onStarfieldLight,
                colors: colors,
                textStyles: textStyles,
              ),
              _SliderRow(
                label: 'glowColorMixWithWhite',
                value: navGlowMix,
                start: 0,
                end: 1,
                step: TermosSlider.evenStep(0, 1),
                onChanged: onNavGlowMix,
                colors: colors,
                textStyles: textStyles,
              ),
              _SliderRow(
                label: 'starfieldIntensityLight',
                value: navStarfieldIntensity,
                start: 0.5,
                end: 3,
                step: TermosSlider.evenStep(0.5, 3),
                onChanged: onNavStarfieldIntensity,
                colors: colors,
                textStyles: textStyles,
              ),
              _SliderRow(
                label: 'glowColorMixWithWhite',
                value: segmentedGlowMix,
                start: 0,
                end: 1,
                step: TermosSlider.evenStep(0, 1),
                onChanged: onSegmentedGlowMix,
                colors: colors,
                textStyles: textStyles,
              ),
              _SliderRow(
                label: 'crtScanlineOpacity',
                value: crtScanlineOpacity,
                start: 0,
                end: 0.2,
                step: TermosSlider.evenStep(0, 0.2),
                onChanged: onCrtScanline,
                colors: colors,
                textStyles: textStyles,
              ),
              _SliderRow(
                label: 'crtVignetteStrength',
                value: crtVignette,
                start: 0,
                end: 1,
                step: TermosSlider.evenStep(0, 1),
                onChanged: onCrtVignette,
                colors: colors,
                textStyles: textStyles,
              ),
              _SliderRow(
                label: 'scanlineOpacityLight',
                value: tpScanLight,
                start: 0,
                end: 0.08,
                step: TermosSlider.evenStep(0, 0.08),
                onChanged: onTpScanLight,
                colors: colors,
                textStyles: textStyles,
              ),
              _SliderRow(
                label: 'scanlineOpacityDark',
                value: tpScanDark,
                start: 0,
                end: 0.1,
                step: TermosSlider.evenStep(0, 0.1),
                onChanged: onTpScanDark,
                colors: colors,
                textStyles: textStyles,
              ),
            ],
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
    required this.colors,
    required this.textStyles,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;
  final TermosColors colors;
  final TermosTextStyles textStyles;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectableText(
            label,
            style: textStyles.codePrimary(colors.textMuted).copyWith(fontSize: 12),
            maxLines: 1,
          ),
          const SizedBox(height: 2),
          TermosContinuousSlider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            compact: true,
            onChanged: onChanged,
          ),
        ],
      ),
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
    required this.colors,
    required this.textStyles,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final int subdivisions;
  final ValueChanged<double> onChanged;
  final TermosColors colors;
  final TermosTextStyles textStyles;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectableText(
            label,
            style: textStyles.codePrimary(colors.textMuted).copyWith(fontSize: 12),
            maxLines: 1,
          ),
          const SizedBox(height: 2),
          TermosDetailedSlider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            subdivisions: subdivisions,
            compact: true,
            onChanged: onChanged,
          ),
        ],
      ),
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
    required this.colors,
    required this.textStyles,
  });

  final String label;
  final double value;
  final double start;
  final double end;
  final double step;
  final ValueChanged<double> onChanged;
  final TermosColors colors;
  final TermosTextStyles textStyles;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectableText(
            label,
            style: textStyles.codePrimary(colors.textMuted).copyWith(fontSize: 12),
            maxLines: 1,
          ),
          const SizedBox(height: 2),
          TermosSlider(
            value: value,
            start: start,
            end: end,
            step: step,
            compact: true,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
