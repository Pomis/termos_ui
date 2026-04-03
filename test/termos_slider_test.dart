import 'package:flutter_test/flutter_test.dart';
import 'package:termos_ui/termos_ui.dart';

void main() {
  group('TermosSlider.discreteValues', () {
    test('spacing 1..10 step 1 yields 10 positions', () {
      final values = TermosSlider.discreteValues(start: 1, end: 10, step: 1);
      expect(values, [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);
      expect(values.length, lessThanOrEqualTo(TermosSlider.kMaxDiscreteSteps));
    });

    test('evenStep(0, 255) yields at most 10 values from 0 to 255', () {
      final step = TermosSlider.evenStep(0, 255);
      final values = TermosSlider.discreteValues(start: 0, end: 255, step: step);
      expect(values.length, TermosSlider.kMaxDiscreteSteps);
      expect(values.first, 0);
      expect(values.last, closeTo(255, 1e-6));
    });

    test('evenStep(40, 160, maxSteps: 6) yields 6 blob positions', () {
      final step = TermosSlider.evenStep(40, 160, maxSteps: 6);
      expect(step, 24);
      final values = TermosSlider.discreteValues(start: 40, end: 160, step: step);
      expect(values, [40, 64, 88, 112, 136, 160]);
    });

    test('evenStep(0, 18, maxSteps: 4) yields 4 border radii', () {
      final step = TermosSlider.evenStep(0, 18, maxSteps: 4);
      expect(step, 6);
      final values = TermosSlider.discreteValues(start: 0, end: 18, step: step);
      expect(values, [0, 6, 12, 18]);
    });
  });

  group('TermosSlider.snap', () {
    test('snaps to nearest discrete value', () {
      expect(TermosSlider.snap(6.2, 1, 10, 1), 6);
      expect(TermosSlider.snap(6.7, 1, 10, 1), 7);
    });
  });
}
