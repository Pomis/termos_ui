import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:termos_ui/termos_ui.dart';

import 'docs/classic_gallery_view.dart';
import 'docs/docs_controller.dart';
import 'docs/docs_shell.dart';

void main() => runApp(const TermosUiExampleApp());

/// Example app for `termos_ui`: paged documentation by default, with the
/// classic all-in-one gallery one tap away.
class TermosUiExampleApp extends StatefulWidget {
  const TermosUiExampleApp({super.key});

  @override
  State<TermosUiExampleApp> createState() => _TermosUiExampleAppState();
}

class _TermosUiExampleAppState extends State<TermosUiExampleApp> {
  final DocsController _controller = DocsController();
  final _navigatorKey = GlobalKey<NavigatorState>();
  bool _classic = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Opens the shared color picker. [MaterialApp] is built under this state, so
  /// dialogs use a context from inside the app (the navigator).
  void _showColorPicker({
    required String title,
    required Color current,
    required ValueChanged<Color> onColor,
  }) {
    final navigatorContext = _navigatorKey.currentContext;
    if (navigatorContext == null || !mounted) return;

    final themeSnapshot = _controller.themeData();
    var dialogColor = current;

    showDialog<void>(
      context: navigatorContext,
      useRootNavigator: true,
      barrierDismissible: true,
      builder: (dialogContext) {
        final colors = themeSnapshot.colors;
        final textStyles = themeSnapshot.textStyles;
        return TermosTheme(
          data: themeSnapshot,
          child: StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                backgroundColor: colors.surface,
                title: SelectableText(title, style: textStyles.sectionTitle(colors.textPrimary)),
                content: SingleChildScrollView(
                  child: ColorPicker(
                    pickerColor: dialogColor,
                    onColorChanged: (color) => setDialogState(() => dialogColor = color),
                    enableAlpha: false,
                    displayThumbColor: true,
                    pickerAreaHeightPercent: 0.75,
                    labelTypes: const [ColorLabelType.rgb],
                    hexInputBar: true,
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: Text('Cancel', style: textStyles.codePrimary(colors.primary)),
                  ),
                  TextButton(
                    onPressed: () {
                      onColor(dialogColor);
                      Navigator.of(dialogContext).pop();
                    },
                    child: Text('Apply', style: textStyles.codePrimary(colors.primary)),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final termos = _controller.themeData();
        final colors = termos.colors;
        final textStyles = termos.textStyles;

        return MaterialApp(
          navigatorKey: _navigatorKey,
          debugShowCheckedModeBanner: false,
          title: 'termos_ui',
          theme: ThemeData(
            useMaterial3: true,
            brightness: _controller.useLightTheme ? Brightness.light : Brightness.dark,
            scaffoldBackgroundColor: colors.background,
            colorScheme: ColorScheme.fromSeed(
              seedColor: colors.primary,
              brightness: _controller.useLightTheme ? Brightness.light : Brightness.dark,
            ),
          ),
          home: TermosTheme(
            data: termos,
            child: Scaffold(
              appBar: AppBar(
                title: Text(
                  _classic ? 'termos_ui · gallery' : 'termos_ui · docs',
                  style: textStyles.sectionTitle(colors.primary),
                ),
                backgroundColor: colors.surface,
                foregroundColor: colors.textPrimary,
                actions: [
                  TextButton.icon(
                    onPressed: () => setState(() => _classic = !_classic),
                    icon: HugeIcon(
                      icon: _classic
                          ? HugeIcons.strokeRoundedBook02
                          : HugeIcons.strokeRoundedGridView,
                      color: colors.primary,
                      size: 18,
                    ),
                    label: Text(
                      _classic ? 'Docs' : 'Classic gallery',
                      style: textStyles.body(colors.primary),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
              body: _classic
                  ? ClassicGalleryView(
                      controller: _controller,
                      onPickColor: _showColorPicker,
                    )
                  : DocsShell(
                      controller: _controller,
                      onPickColor: _showColorPicker,
                    ),
            ),
          ),
        );
      },
    );
  }
}
