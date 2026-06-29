import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:termos_ui/termos_ui.dart';
import 'package:termos_ui_example/gallery/gallery_capture_theme.dart';
import 'package:termos_ui_example/gallery/gallery_widget_demos.dart';

const _captureKey = Key('hero_capture');

/// Logical size of the composed hero panel.
const double _kWidth = 900;
const double _kDpr = 3.0;

/// Renders a composed, multi-widget hero panel and exports it to
/// `doc/hero.png` (the README hero image). Run with:
///   UPDATE_GALLERY=1 flutter test test/hero_capture_test.dart --update-goldens
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final update = Platform.environment['UPDATE_GALLERY'] == '1';

  testWidgets('export README hero panel', (tester) async {
    expect(update, isTrue, reason: 'Set UPDATE_GALLERY=1 with --update-goldens.');

    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    tester.view.devicePixelRatio = _kDpr;
    tester.view.physicalSize = Size(_kWidth * _kDpr + 64, 2600);

    final themeData = galleryCaptureTheme();
    final colors = themeData.colors;
    final text = themeData.textStyles;
    final baseDark = ThemeData.dark(useMaterial3: true);

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: baseDark.copyWith(
          scaffoldBackgroundColor: colors.background,
          textTheme: baseDark.textTheme.apply(
            fontFamily: 'Roboto',
            displayColor: colors.textPrimary,
            bodyColor: colors.textPrimary,
          ),
        ),
        home: Scaffold(
          backgroundColor: colors.background,
          body: Align(
          alignment: Alignment.topCenter,
          child: RepaintBoundary(
            key: _captureKey,
            child: ColoredBox(
              color: colors.background,
              child: SizedBox(
                width: _kWidth,
                child: TermosTheme(
                  data: themeData,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(40, 36, 40, 40),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Wordmark + tagline.
                        Text(
                          'termos_ui',
                          style: text.sectionTitle(colors.primary).copyWith(
                                fontSize: 34,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'dot-grid mesh · starfield particles · CRT scanlines',
                          style: text.codePrimary(colors.textMuted)
                              .copyWith(fontSize: 14),
                        ),
                        const SizedBox(height: 28),
                        // Two-column widget showcase.
                        const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _LeftColumn()),
                            SizedBox(width: 28),
                            Expanded(child: _RightColumn()),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const GalleryNavBarDemo(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        ),
      ),
    );

    // Settle entrance animations to a stable resting frame.
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

    await expectLater(
      find.byKey(_captureKey),
      matchesGoldenFile('../doc/hero.png'),
    );
  }, skip: !update);
}

class _LeftColumn extends StatelessWidget {
  const _LeftColumn();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GalleryButtonDemo(),
        SizedBox(height: 18),
        GallerySegmentedDemo(),
        SizedBox(height: 18),
        GallerySwitchDemo(),
        SizedBox(height: 18),
        GallerySliderShowcase(),
      ],
    );
  }
}

class _RightColumn extends StatelessWidget {
  const _RightColumn();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GalleryTextFieldDemo(),
        SizedBox(height: 18),
        GalleryTimePickerDemo(),
      ],
    );
  }
}
