import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:termos_ui/termos_ui.dart';
import 'package:termos_ui_example/gallery/gallery_capture_theme.dart';
import 'package:termos_ui_example/gallery/gallery_registry.dart';

const _captureKey = Key('gallery_frame_capture');

/// Logical width for README captures (matches example gallery column).
const double _kCaptureWidth = 400;

/// Device pixel ratio for goldens.
const double _kCaptureDpr = 2.0;

const double _kVerticalPadding = 20.0;

/// Per-frame advance for comet loader (~36 fps effective).
const Duration _kLoaderFrameStep = Duration(milliseconds: 28);

const int _kLoaderFrameCount = 45;

Future<void> _pumpCaptureShell(
  WidgetTester tester, {
  required Widget demo,
}) async {
  final themeData = galleryCaptureTheme();
  final baseDark = ThemeData.dark(useMaterial3: true);
  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: baseDark.copyWith(
        scaffoldBackgroundColor: themeData.colors.background,
        textTheme: baseDark.textTheme.apply(
          fontFamily: 'Roboto',
          displayColor: themeData.colors.textPrimary,
          bodyColor: themeData.colors.textPrimary,
        ),
      ),
      home: ColoredBox(
        color: themeData.colors.background,
        child: Scaffold(
          backgroundColor: themeData.colors.background,
          body: Align(
            alignment: Alignment.topCenter,
            child: RepaintBoundary(
              key: _captureKey,
              child: ColoredBox(
                color: themeData.colors.background,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: _kVerticalPadding),
                  child: SizedBox(
                    width: _kCaptureWidth,
                    child: TermosTheme(
                      data: themeData,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [demo],
                      ),
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
  await tester.pump();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final update = Platform.environment['UPDATE_GALLERY'] == '1';

  testWidgets(
    'export gallery PNG sequences (use UPDATE_GALLERY=1 flutter test ... --update-goldens)',
    (tester) async {
      expect(
        update,
        isTrue,
        reason: 'Set UPDATE_GALLERY=1 and pass --update-goldens when refreshing frames.',
      );

      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      tester.view.devicePixelRatio = _kCaptureDpr;
      tester.view.physicalSize = Size(
        _kCaptureWidth * _kCaptureDpr + 64,
        2400,
      );

      for (final entry in galleryGifDemoEntries) {
        final id = entry.key;

        if (id == GalleryCaptureIds.loadingIndicator) {
          await _pumpCaptureShell(
            tester,
            demo: Builder(builder: entry.value),
          );
          for (var frame = 0; frame < _kLoaderFrameCount; frame++) {
            await tester.pump(_kLoaderFrameStep);
            await expectLater(
              find.byKey(_captureKey),
              matchesGoldenFile('goldens/export/$id/frame_${frame.toString().padLeft(3, '0')}.png'),
            );
          }
          continue;
        }

        await _pumpCaptureShell(
          tester,
          demo: Builder(builder: entry.value),
        );
        await tester.pump();
        await tester.pump(const Duration(seconds: 2));
        await expectLater(
          find.byKey(_captureKey),
          matchesGoldenFile('goldens/export/$id/frame_000.png'),
        );
      }
    },
    skip: !update,
  );
}
