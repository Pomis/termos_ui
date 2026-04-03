import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Loads bundled Roboto so glyphs render in goldens (Ahem placeholders otherwise).
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  final robotoLoader = FontLoader('Roboto')
    ..addFont(rootBundle.load('fonts/Roboto-Regular.ttf'))
    ..addFont(rootBundle.load('fonts/Roboto-Medium.ttf'))
    ..addFont(rootBundle.load('fonts/Roboto-Bold.ttf'));
  await robotoLoader.load();
  await testMain();
}
