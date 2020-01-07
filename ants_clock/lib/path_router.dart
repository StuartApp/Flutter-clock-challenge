import 'dart:math';

import 'package:ants_clock/position.dart';

import 'ant.dart';
import 'math_utils.dart';

class PathRouter {
  List<Position> route(Ant traveller, List<Ant> ants, Position destination) {
    final route = <Position>[];

    final ignoredAnts = [traveller];
    var currentPosition = traveller.position;
    BoundingBoxIntersection intersection;

    do {
      intersection = _getFirstBoundingBoxIntersection(
          ignoredAnts, ants, currentPosition.toPoint(), destination.toPoint());

      if (intersection != null) {
        _walkAroundBoundingBox(
          route,
          currentPosition,
          destination,
          intersection,
        );
        currentPosition = route.last;
      }
    } while (intersection != null);

    route.add(destination);

    return route;
  }

  BoundingBoxIntersection _getFirstBoundingBoxIntersection(
    List<Ant> ignoredAnts,
    List<Ant> ants,
    Point<double> begin,
    Point<double> end,
  ) {
    final segment = Segment(begin, end);

    BoundingBoxIntersection closestIntersection;
    Ant closestAnt;

    for (var ant in ants) {
      if (ignoredAnts.contains(ant)) continue;

      final intersection = segment.getBoundingBoxIntersection(ant.boundingBox);
      if (intersection != null) {
        if (closestIntersection == null ||
            closestIntersection.squaredDistance >
                intersection.squaredDistance) {
          closestIntersection = intersection;
          closestAnt = ant;
        }
      }
    }

    if (closestAnt != null) {
      ignoredAnts.add(closestAnt);
    }

    return closestIntersection;
  }

  void _walkAroundBoundingBox(
    List<Position> route,
    Position begin,
    Position end,
    BoundingBoxIntersection boundingBoxIntersection,
  ) {
    final boundingBox = boundingBoxIntersection.boundingBox;
    final boundingBoxSegment = boundingBoxIntersection.boundingBoxSegment;
    final vertices = boundingBox.getAllVertices(boundingBoxSegment, true);

    var currentPosition =
        begin.positionToPoint(boundingBoxIntersection.intersection);
    route.add(currentPosition);

    var currentVertex = vertices.first;

    final endPoint = end.toPoint();
    double currentDistance = currentVertex.squaredDistanceTo(endPoint);
    double previousDistance;

    while (previousDistance == null || previousDistance > currentDistance) {
      currentPosition = currentPosition.positionToPoint(currentVertex);
      route.add(currentPosition);

      previousDistance = currentDistance;
      vertices.removeAt(0);
      currentVertex = vertices.first;
      currentDistance = currentVertex.squaredDistanceTo(endPoint);
    }
  }
}

class BoundingBox {
  final Segment top;
  final Segment right;
  final Segment bottom;
  final Segment left;

  BoundingBox(this.top, this.right, this.bottom, this.left);

  factory BoundingBox.fromAnt(Ant ant) {
    final offset = Ant.halfSize + 5.0;
    final topLeft = _getRotatedAntPoint(ant, -offset, -offset);
    final topRight = _getRotatedAntPoint(ant, offset, -offset);
    final bottomLeft = _getRotatedAntPoint(ant, -offset, offset);
    final bottomRight = _getRotatedAntPoint(ant, offset, offset);

    return BoundingBox(
      Segment(topLeft, topRight),
      Segment(topRight, bottomRight),
      Segment(bottomRight, bottomLeft),
      Segment(bottomLeft, topLeft),
    );
  }

  Segment getSegment(BoundingBoxSegment which) {
    switch (which) {
      case BoundingBoxSegment.top:
        return top;
      case BoundingBoxSegment.right:
        return right;
      case BoundingBoxSegment.bottom:
        return bottom;
      case BoundingBoxSegment.left:
        return left;
    }
    throw ArgumentError.value(which);
  }

  BoundingBoxSegment getNextBoundingBoxSegment(
      BoundingBoxSegment which, bool clockwise) {
    if (clockwise) {
      switch (which) {
        case BoundingBoxSegment.top:
          return BoundingBoxSegment.right;
        case BoundingBoxSegment.right:
          return BoundingBoxSegment.bottom;
        case BoundingBoxSegment.bottom:
          return BoundingBoxSegment.left;
        case BoundingBoxSegment.left:
          return BoundingBoxSegment.top;
      }
    } else {
      switch (which) {
        case BoundingBoxSegment.top:
          return BoundingBoxSegment.left;
        case BoundingBoxSegment.right:
          return BoundingBoxSegment.top;
        case BoundingBoxSegment.bottom:
          return BoundingBoxSegment.right;
        case BoundingBoxSegment.left:
          return BoundingBoxSegment.bottom;
      }
    }
    throw ArgumentError.value(which);
  }

  List<Point<double>> getAllVertices(
    BoundingBoxSegment segmentFrom,
    bool clockwise,
  ) {
    final points = <Point<double>>[];
    var currentSegment = segmentFrom;
    for (var i = 0; i < 4; ++i) {
      final segment = getSegment(currentSegment);
      points.add(clockwise ? segment.end : segment.begin);
      currentSegment = getNextBoundingBoxSegment(currentSegment, clockwise);
    }
    return points;
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

enum BoundingBoxSegment { top, right, bottom, left }

class BoundingBoxIntersection {
  final BoundingBox boundingBox;
  final BoundingBoxSegment boundingBoxSegment;
  final Point<double> intersection;
  final double squaredDistance;

  BoundingBoxIntersection(
    this.boundingBox,
    this.boundingBoxSegment,
    this.intersection,
    this.squaredDistance,
  );
}

class Segment {
  final Point<double> begin;

  final Point<double> end;

  final Rectangle<double> rectangle;

  Segment(this.begin, this.end) : rectangle = Rectangle.fromPoints(begin, end);

  Point<double> getSegmentIntersection(Segment other) {
    if (!rectangle.intersects(other.rectangle)) return null;

    Point<double> intersectionPoint = _calcIntersectionPoint(other);

    return intersectionPoint != null &&
            rectangle.containsPoint(intersectionPoint) &&
            other.rectangle.containsPoint(intersectionPoint)
        ? intersectionPoint
        : null;
  }

  BoundingBoxIntersection getBoundingBoxIntersection(BoundingBox boundingBox) {
    final intersections = <BoundingBoxIntersection>[
      _createBoundingBoxIntersection(boundingBox, BoundingBoxSegment.top),
      _createBoundingBoxIntersection(boundingBox, BoundingBoxSegment.right),
      _createBoundingBoxIntersection(boundingBox, BoundingBoxSegment.bottom),
      _createBoundingBoxIntersection(boundingBox, BoundingBoxSegment.left),
    ];

    intersections.removeWhere((i) => i == null);
    intersections.sort((a, b) {
      return a.squaredDistance.compareTo(b.squaredDistance);
    });

    return intersections.isNotEmpty ? intersections.first : null;
  }

  BoundingBoxIntersection _createBoundingBoxIntersection(
    BoundingBox boundingBox,
    BoundingBoxSegment boundingBoxSegment,
  ) {
    final segment = boundingBox.getSegment(boundingBoxSegment);
    final intersection = getSegmentIntersection(segment);
    return intersection != null
        ? BoundingBoxIntersection(
            boundingBox,
            boundingBoxSegment,
            intersection,
            begin.squaredDistanceTo(intersection),
          )
        : null;
  }

  Point<double> _calcIntersectionPoint(Segment other) {
    final a1 = end.x != begin.x ? (end.y - begin.y) / (end.x - begin.x) : 1;
    final b1 = -((begin.x * a1) - begin.y);

    final a2 = other.end.x != other.begin.x
        ? (other.end.y - other.begin.y) / (other.end.x - other.begin.x)
        : 1;
    final b2 = -((other.begin.x * a2) - other.begin.y);

    double x;
    double y;

    if (a1 == a2) {
      return null;
    } else if (a1 == 1) {
      x = begin.x;
      y = (a2 * x) + b2;
    } else if (a2 == 1) {
      x = other.begin.x;
      y = (a1 * x) + b1;
    } else {
      x = (b2 - b1) / (a1 - a2);
      y = (a1 * x) + b1;
    }

    return Point(x, y);
  }
}
