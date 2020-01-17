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

  group('Counter clockwise vectors angle', () {
    test('180', () {
      final angle =
          ccwVectorsAngle(Point(1.0, 1.0), Point(1.0, 0.0), Point(1.0, 2.0));
      expect(angle, 180.0);
    });

    test('90', () {
      final angle =
          ccwVectorsAngle(Point(1.0, 1.0), Point(1.0, 0.0), Point(0.0, 1.0));
      expect(angle, 90.0);
    });

    test('270', () {
      final angle =
          ccwVectorsAngle(Point(1.0, 1.0), Point(1.0, 0.0), Point(2.0, 1.0));
      expect(angle, 270.0);
    });

    test('270', () {
      final angle =
          ccwVectorsAngle(Point(1.0, 3.0), Point(0.0, 3.0), Point(1.0, 2.0));
      expect(angle, 270.0);
    });

    test('0', () {
      final angle =
          ccwVectorsAngle(Point(1.0, 2.0), Point(1.0, 3.0), Point(1.0, 4.0));
      expect(angle, 0.0);
    });

    test('180', () {
      final angle = ccwVectorsAngle(
          Point(209.0, 141.2), Point(219.8, 130.4), Point(200.0, 150.2));
      expect(angle, 180.0);
    });
  });
}
