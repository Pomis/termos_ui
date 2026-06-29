import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:termos_ui/termos_ui.dart';

void main() {
  Future<void> pumpUnboundedRowButton(
    WidgetTester tester, {
    required bool heavyEffectsEnabled,
    bool multilineLabel = false,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        home: TermosTheme(
          data: TermosThemeData.dark().copyWith(
            heavyEffectsEnabled: heavyEffectsEnabled,
          ),
          child: Scaffold(
            body: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TermosButton(
                    label: const Text('Continue'),
                    onTap: () {},
                    multilineLabel: multilineLabel,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  for (final heavyEffectsEnabled in [true, false]) {
    testWidgets(
      'TermosButton shrink-wraps in unbounded rows with heavyEffectsEnabled=$heavyEffectsEnabled',
      (tester) async {
        await pumpUnboundedRowButton(
          tester,
          heavyEffectsEnabled: heavyEffectsEnabled,
        );

        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'multiline TermosButton shrink-wraps in unbounded rows with heavyEffectsEnabled=$heavyEffectsEnabled',
      (tester) async {
        await pumpUnboundedRowButton(
          tester,
          heavyEffectsEnabled: heavyEffectsEnabled,
          multilineLabel: true,
        );

        expect(tester.takeException(), isNull);
      },
    );
  }
}
