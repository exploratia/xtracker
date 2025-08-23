import 'package:flutter_test/flutter_test.dart';
import 'package:xtracker/src/util/math_utils.dart';

void main() {
  group('Math Utils', () {
    test('test lerp', () {
      expect(MathUtils.lerp(0, 100, 0), 0);
      expect(MathUtils.lerp(0, 100, 1), 100);
      expect(MathUtils.lerp(0, 100, 0.05), 5);

      expect(MathUtils.lerp(10, 20, 0), 10);
      expect(MathUtils.lerp(10, 20, 1), 20);
      expect(MathUtils.lerp(10, 20, 0.05), 10.5);
    });

    test('test invLerp', () {
      expect(MathUtils.invLerp(0, 100, 0), 0);
      expect(MathUtils.invLerp(0, 100, 100), 1);
      expect(MathUtils.invLerp(0, 100, 5), 0.05);

      expect(MathUtils.invLerp(10, 20, 10), 0);
      expect(MathUtils.invLerp(10, 20, 20), 1);
      expect(MathUtils.invLerp(10, 20, 10.5), 0.05);
    });
  });
}
