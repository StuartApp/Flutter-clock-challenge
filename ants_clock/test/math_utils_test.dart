import 'dart:math';

import 'package:ants_clock/math_utils.dart';
import 'package:test/test.dart';

void main() {
  test('Rotate a Point clockwise 90', () {
    final point = Point(2.0, 2.0);
    final origin = Point(2.0, 1.0);
    final result = rotatePoint(point, origin, 90.0);

    expect(result.x, closeTo(1.0, 0.1));
    expect(result.y, closeTo(1.0, 0.1));
  });

  test('Rotate a Point counter clockwise 90', () {
    final point = Point(2.0, 2.0);
    final origin = Point(2.0, 1.0);
    final result = rotatePoint(point, origin, -90.0);

    expect(result.x, closeTo(3.0, 0.1));
    expect(result.y, closeTo(1.0, 0.1));
  });

  test('Rotate a Point clockwise 180', () {
    final point = Point(2.0, 2.0);
    final origin = Point(2.0, 1.0);
    final result = rotatePoint(point, origin, 180.0);

    expect(result.x, closeTo(2.0, 0.1));
    expect(result.y, closeTo(0.0, 0.1));
  });
}
