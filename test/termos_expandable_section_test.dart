import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:termos_ui/termos_ui.dart';

void main() {
  testWidgets(
    'non-overlay mode toggles from the visible card body and lets nested controls handle taps',
    (tester) async {
      var expanded = false;
      var toggleCount = 0;
      var nestedTapCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: TermosTheme(
            data: TermosThemeData.dark().copyWith(heavyEffectsEnabled: false),
            child: Scaffold(
              body: Center(
                child: StatefulBuilder(
                  builder: (context, setState) {
                    return SizedBox(
                      width: 320,
                      child: TermosExpandableSection(
                        isExpanded: expanded,
                        useOverlayTapTarget: false,
                        onToggle: () {
                          setState(() {
                            expanded = !expanded;
                            toggleCount += 1;
                          });
                        },
                        header: Row(
                          children: [
                            const Expanded(child: Text('Header')),
                            GestureDetector(
                              key: const Key('nested-control'),
                              behavior: HitTestBehavior.opaque,
                              onTap: () => nestedTapCount += 1,
                              child: const SizedBox.square(
                                dimension: 48,
                                child: Icon(Icons.bookmark_border),
                              ),
                            ),
                          ],
                        ),
                        contentBetween: const Text('Preview sentence'),
                        expandedChild: const Text('Expanded details'),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Preview sentence'));
      await tester.pumpAndSettle();

      expect(toggleCount, 1);
      expect(find.text('Expanded details'), findsOneWidget);

      await tester.tap(find.byKey(const Key('nested-control')));
      await tester.pumpAndSettle();

      expect(nestedTapCount, 1);
      expect(toggleCount, 1);
      expect(find.text('Expanded details'), findsOneWidget);
    },
  );
}
