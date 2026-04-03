import 'package:flutter_test/flutter_test.dart';
import 'package:termos_ui/termos_ui.dart';

void main() {
  group('TermosFloatingSlider.snapToDivisions', () {
    test('0..3 with 5 divisions yields 6 stops including endpoints', () {
      expect(TermosFloatingSlider.snapToDivisions(2, 0, 3, 5), closeTo(1.8, 1e-9));
      expect(TermosFloatingSlider.snapToDivisions(2.2, 0, 3, 5), closeTo(2.4, 1e-9));
      expect(TermosFloatingSlider.snapToDivisions(0, 0, 3, 5), 0);
      expect(TermosFloatingSlider.snapToDivisions(3, 0, 3, 5), 3);
    });
  });
}
