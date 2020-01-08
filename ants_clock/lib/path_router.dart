import 'dart:math';

import 'package:ants_clock/pair.dart';
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

    _simplifyRoute(route);

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

  List<Point<double>> _getAdjacentSegmentsVertices(
    List<Ant> ants,
    BoundingBox boundingBox,
    BoundingBoxSegment boundingBoxSegment,
  ) {
    final segment = boundingBox.getSegment(boundingBoxSegment);
    segment.getBoundingBoxIntersection(boundingBox);
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

  void _simplifyRoute(List<Position> route) {
    // route.removeAt(0);
    // for (var i = route.length - 1; i >= 0; --i) {}
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

class BoundingShape {
  static const padding = 5.0;

  final List<Segment> segments;

  final Rectangle bounds;

  BoundingShape(this.segments) : bounds = _createRectangle(segments);

  factory BoundingShape.fromAnt(Ant ant) {
    final offset = Ant.halfSize + padding;
    final topLeft = _getRotatedAntPoint(ant, -offset, -offset);
    final topRight = _getRotatedAntPoint(ant, offset, -offset);
    final bottomLeft = _getRotatedAntPoint(ant, -offset, offset);
    final bottomRight = _getRotatedAntPoint(ant, offset, offset);

    return BoundingShape([
      Segment(topLeft, topRight),
      Segment(topRight, bottomRight),
      Segment(bottomRight, bottomLeft),
      Segment(bottomLeft, topLeft),
    ]);
  }

  bool intersects(BoundingShape other) {
    if (!bounds.intersects(other.bounds)) return false;

    for (var segment in segments) {
      for (var otherSegment in other.segments) {
        if (segment.getSegmentIntersection(otherSegment) != null) return true;
      }
    }

    return false;
  }

  BoundingShape union(BoundingShape other) {
    final newSegments = <Segment>[];

    final thisIterator = _SegmentsIterator(segments);
    final otherIterator = _SegmentsIterator(other.segments);

    var usingThisIterator = true;
    var currentIterator = thisIterator;
    var followingIterator = otherIterator;

    final firstPoint = segments.first.begin;

    while (currentIterator.currentSegment.end != firstPoint) {
      final pair = _findIntersectingSegment(
        currentIterator.currentSegment,
        followingIterator.segments,
      );

      if (pair == null) {
        newSegments.add(currentIterator.currentSegment);
        currentIterator.next();
      } else {
        followingIterator.setCurrentIndex(pair.first);

        newSegments.add(Segment(
          currentIterator.currentSegment.begin,
          pair.last,
        ));

        newSegments.add(Segment(
          pair.last,
          followingIterator.currentSegment.end,
        ));

        followingIterator.next();

        if (usingThisIterator) {
          usingThisIterator = false;
          currentIterator = otherIterator;
          followingIterator = thisIterator;
        } else {
          usingThisIterator = true;
          currentIterator = thisIterator;
          followingIterator = otherIterator;
        }
      }
    }

    newSegments.add(currentIterator.currentSegment);

    return BoundingShape(newSegments);
  }

  Pair<int, Point<double>> _findIntersectingSegment(
      Segment segment, List<Segment> segments) {
    for (var i = 0; i < segments.length; ++i) {
      var s = segments[i];
      final intersection = segment.getSegmentIntersection(s);
      if (intersection != null) {
        return Pair(i, intersection);
      }
    }
    return null;
  }

  static Rectangle _createRectangle(List<Segment> segments) {
    double top;
    double right;
    double bottom;
    double left;
    for (var s in segments) {
      top = min(top ?? s.begin.y, min(s.begin.y, s.end.y));
      right = max(right ?? s.begin.x, max(s.begin.x, s.end.x));
      bottom = max(bottom ?? s.begin.y, max(s.begin.y, s.end.y));
      left = min(left ?? s.begin.x, min(s.begin.x, s.end.x));
    }
    return Rectangle.fromPoints(Point(left, top), Point(right, bottom));
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

class _SegmentsIterator {
  final List<Segment> segments;
  var _currentIndex = 0;

  _SegmentsIterator(this.segments);

  Segment get currentSegment => segments[_currentIndex];

  void next() {
    _currentIndex++;
    if (_currentIndex == segments.length) {
      _currentIndex = 0;
    }
  }

  void setCurrentIndex(int index) {
    _currentIndex = index.clamp(0, segments.length - 1);
  }
}
