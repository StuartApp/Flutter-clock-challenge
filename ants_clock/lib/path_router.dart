import 'dart:math';

import 'ant.dart';
import 'math_utils.dart';

class Segment {
  final Point<double> begin;

  final Point<double> end;

  final Rectangle<double> rectangle;

  Segment(this.begin, this.end) : rectangle = Rectangle.fromPoints(begin, end);

  bool intersects(Segment other) {
    if (!rectangle.intersects(other.rectangle)) return false;

    Point<double> intersectionPoint = _calcIntersectionPoint(other);

    return rectangle.containsPoint(intersectionPoint) &&
        other.rectangle.containsPoint(intersectionPoint);
  }

  Point<double> _calcIntersectionPoint(Segment other) {
    final a1 = (end.y - begin.y) / (end.x - begin.x);
    final b1 = -((begin.x * a1) - begin.y);

    final a2 = (other.end.y - other.begin.y) / (other.end.x - other.begin.x);
    final b2 = -((other.begin.x * a2) - other.begin.y);

    final x = (b2 - b1) / (a1 - a2);
    final y = (a1 * x) + a2;

    return Point(x, y);
  }
}

class BoundingBox {
  final Segment top;
  final Segment left;
  final Segment right;
  final Segment bottom;

  BoundingBox(this.top, this.left, this.right, this.bottom);

  factory BoundingBox.fromAnt(Ant ant) {
    final angle = 90.0 - ant.position.bearing;
    final h = sqrt(Ant.halfSize * Ant.halfSize + Ant.halfSize * Ant.halfSize);
    final x1 = cos(degToRad(45.0 + angle)) * h;
    final y1 = sin(degToRad(45.0 + angle)) * h;
  }
}
