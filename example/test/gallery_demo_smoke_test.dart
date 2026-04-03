import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:termos_ui/termos_ui.dart';
import 'package:termos_ui_example/gallery/gallery_capture_theme.dart';
import 'package:termos_ui_example/gallery/gallery_registry.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('gallery demos pump without error', (tester) async {
    final themeData = galleryCaptureTheme();

    for (final entry in galleryCaptureDemoBuilders.entries) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 400,
                height: 600,
                child: ClipRect(
                  child: SingleChildScrollView(
                    child: TermosTheme(
                      data: themeData,
                      child: RepaintBoundary(
                        child: Builder(builder: entry.value),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      // Repeating animations (time picker pulse, loader comet, etc.) never fully settle.
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));
      expect(tester.takeException(), isNull);
    }
  });
}
