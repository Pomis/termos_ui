import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:termos_ui/termos_ui.dart';

void main() {
  testWidgets('TermosTheme provides data to descendants', (tester) async {
    late TermosThemeData captured;
    await tester.pumpWidget(
      TermosTheme(
        data: TermosThemeData.dark(),
        child: Builder(
          builder: (context) {
            captured = TermosTheme.of(context);
            return const SizedBox();
          },
        ),
      ),
    );
    expect(captured.colors.primary, const Color(0xFF4ADE80));
    expect(captured.dotGrid.dotSize, 2.0);
    expect(captured.heavyEffectsEnabled, isTrue);
  });
}
