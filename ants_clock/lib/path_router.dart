import 'dart:math';

import 'package:ants_clock/position.dart';

import 'ant.dart';
import 'math_utils.dart';

class PathRouter {
  final List<Ant> _ants;

  PathRouter(this._ants);

  List<Position> route(Ant traveller, Position destination) {
    final route = <Position>[];

    final segment = Segment(
      traveller.position.toPoint(),
      destination.toPoint(),
    );

    for (var ant in _ants) {
      if (ant != traveller) {
        final intersection =
            segment.getBoundingBoxIntersection(ant.boundingBox);
        if (intersection != null) {
          final point = intersection.segment.begin;
          route.add(traveller.position.positionToPoint(point));
        }
      }
    }

    route.add(destination);

    return route;
  }
}

class BoundingBox {
  final Segment top;
  final Segment right;
  final Segment bottom;
  final Segment left;

  BoundingBox(this.top, this.right, this.bottom, this.left);

  factory BoundingBox.fromAnt(Ant ant) {
    final topLeft = _getRotatedAntPoint(ant, -Ant.halfSize, -Ant.halfSize);
    final topRight = _getRotatedAntPoint(ant, Ant.halfSize, -Ant.halfSize);
    final bottomLeft = _getRotatedAntPoint(ant, -Ant.halfSize, Ant.halfSize);
    final bottomRight = _getRotatedAntPoint(ant, Ant.halfSize, Ant.halfSize);

    return BoundingBox(
      Segment(topLeft, topRight),
      Segment(topRight, bottomRight),
      Segment(bottomRight, bottomLeft),
      Segment(bottomLeft, topLeft),
    );
  }

  static Point<double> _getRotatedAntPoint(
      Ant ant, double xOffset, double yOffset) {
    return rotatePoint(
      Point(
        ant.position.x + xOffset,
        ant.position.y + yOffset,
      ),
      ant.position.toPoint(),
      ant.position.bearing,
    );
  }
}

class Segment {
  final Point<double> begin;

  final Point<double> end;

  final Rectangle<double> rectangle;

  Segment(this.begin, this.end) : rectangle = Rectangle.fromPoints(begin, end);

  Point<double> getSegmentIntersection(Segment other) {
    if (!rectangle.intersects(other.rectangle)) return null;

    Point<double> intersectionPoint = _calcIntersectionPoint(other);

    return rectangle.containsPoint(intersectionPoint) &&
            other.rectangle.containsPoint(intersectionPoint)
        ? intersectionPoint
        : null;
  }

  BoundingBoxIntersection getBoundingBoxIntersection(BoundingBox boundingBox) {
    BoundingBoxIntersection createBoundingBoxIntersection(Segment segment) {
      final intersection = getSegmentIntersection(segment);
      return intersection != null
          ? BoundingBoxIntersection(segment, intersection)
          : null;
    }

    return createBoundingBoxIntersection(boundingBox.top) ??
        createBoundingBoxIntersection(boundingBox.right) ??
        createBoundingBoxIntersection(boundingBox.bottom) ??
        createBoundingBoxIntersection(boundingBox.left);
  }

  Point<double> _calcIntersectionPoint(Segment other) {
    final a1 = (end.y - begin.y) / (end.x - begin.x);
    final b1 = -((begin.x * a1) - begin.y);

    final a2 = (other.end.y - other.begin.y) / (other.end.x - other.begin.x);
    final b2 = -((other.begin.x * a2) - other.begin.y);

    final x = (b2 - b1) / (a1 - a2);
    final y = (a1 * x) + b2;

    return Point(x, y);
  }
}

class BoundingBoxIntersection {
  final Segment segment;
  final Point<double> intersection;

  BoundingBoxIntersection(this.segment, this.intersection);
}
