import 'dart:math';

import 'package:ants_clock/position.dart';

import 'ant.dart';
import 'math_utils.dart';

class PathRouter {
  final List<BoundingShape> _boundingShapes = [];

  PathRouter(List<Ant> ants) {
    /*final boundingShapes =
        ants.map((ant) => BoundingShape.fromAnt(ant)).toList();

    while (boundingShapes.isNotEmpty) {
      var bs = boundingShapes.first;
      final bsToRemove = <int>[];

      if (boundingShapes.length >= 2) {
        for (var i = 1; i < boundingShapes.length; ++i) {
          var bs2 = boundingShapes[i];

          if (bs2.intersects(bs)) {
            bs = bs.union(bs2);
            bs.containingAnts.addAll(bs2.containingAnts);
            bsToRemove.add(i);
          }
        }
      }

      _boundingShapes.add(bs);

      for (var index in bsToRemove.reversed) {
        boundingShapes.removeAt(index);
      }
      boundingShapes.removeAt(0);
    }*/
  }

  List<Position> route(Ant ant, Position destination) {
    final route = <Position>[];

    /*final bsIntersection = _getFirstBoundingShapeIntersection(
        ant, ant.position.toPoint(), destination.toPoint());

    if (bsIntersection != null) {
      route.add(ant.position.positionToPoint(bsIntersection.intersection));
    }*/

    route.add(destination);

    return route;
  }

  BoundingShapeIntersection _getFirstBoundingShapeIntersection(
    Ant ant,
    Point<double> begin,
    Point<double> end,
  ) {
    final segment = Segment(begin, end);

    BoundingShapeIntersection closestBSIntersection;

    for (var bs in _boundingShapes) {
      final bsIntersection = segment.getBoundingShapeIntersection(bs);
      if (bsIntersection != null) {
        if (closestBSIntersection == null ||
            bsIntersection.squaredDistance <
                closestBSIntersection.squaredDistance) {
          closestBSIntersection = bsIntersection;
        }
      }
    }

    return closestBSIntersection;
  }

  void _walkAroundBoundingShape(
    List<Position> route,
    Position begin,
    Position end,
    BoundingShapeIntersection boundingShapeIntersection,
  ) {
    throw UnimplementedError();
  }

  void _simplifyRoute(List<Position> route) {
    throw UnimplementedError();
  }
}

class BoundingShape {
  static const double antPadding = 5.0;

  final List<Segment> segments;

  final Rectangle boundsRectangle;

  // TODO Create a boundsSegments to optimize segment intersections calculation
  // final List<Segment> boundsSegments;

  final List<Ant> containingAnts = [];

  BoundingShape(this.segments) : boundsRectangle = _createRectangle(segments);

  factory BoundingShape.fromAnt(Ant ant) {
    final offset = Ant.halfSize + antPadding;
    final topLeft = _getRotatedAntPoint(ant, -offset, -offset);
    final topRight = _getRotatedAntPoint(ant, offset, -offset);
    final bottomLeft = _getRotatedAntPoint(ant, -offset, offset);
    final bottomRight = _getRotatedAntPoint(ant, offset, offset);

    return BoundingShape([
      Segment(topLeft, topRight),
      Segment(topRight, bottomRight),
      Segment(bottomRight, bottomLeft),
      Segment(bottomLeft, topLeft),
    ])
      ..containingAnts.add(ant);
  }

  factory BoundingShape.fromPoints(List<Point<double>> points) {
    final segments = <Segment>[];

    for (var i = 0; i < points.length; ++i) {
      int j = i < points.length - 1 ? i + 1 : 0;
      segments.add(Segment(points[i], points[j]));
    }

    return BoundingShape(segments);
  }

  bool intersects(BoundingShape other) {
    if (!boundsRectangle.intersects(other.boundsRectangle)) return false;

    for (var segment in segments) {
      for (var otherSegment in other.segments) {
        if (segment.getSegmentIntersection(otherSegment) != null) return true;
      }
    }

    return false;
  }

  BoundingShape union(BoundingShape other) {
    final thisShapeVertices = _getShapeVertices(other);
    final otherShapeVertices = other._getShapeVertices(this);

    _linkVertices(thisShapeVertices);
    _linkVertices(otherShapeVertices);
    _linkCommonVertices(thisShapeVertices, otherShapeVertices);

    final initialVertex = _findInitialBottomVertex(thisShapeVertices);
    _Vertex currentVertex = initialVertex;
    _Vertex previousVertex = _Vertex(initialVertex.point - Point(1.0, 0.0));

    final points = <Point<double>>[];

    while (currentVertex != initialVertex || !currentVertex.isVisited) {
      points.add(currentVertex.point);
      _Vertex nextVertex =
          _findLeftmostLinkedVertex(currentVertex, previousVertex);
      previousVertex = currentVertex;
      currentVertex.markAsVisited();
      currentVertex = nextVertex;
    }

    return BoundingShape.fromPoints(points);
  }

  List<_Vertex> _getShapeVertices(BoundingShape other) {
    final vertices = <_Vertex>[];
    for (var segment in segments) {
      final points = _findIntersections(segment, other);
      vertices.addAll(points.map((p) => _Vertex(p)));
      vertices.add(_Vertex(segment.end));
    }
    return vertices;
  }

  List<Point<double>> _findIntersections(Segment segment, BoundingShape other) {
    final points = <Point<double>>[];
    for (var otherSegment in other.segments) {
      final point = segment.getSegmentIntersection(otherSegment);
      if (point != null) points.add(point);
    }

    points.sort((a, b) => segment.begin
        .squaredDistanceTo(a)
        .compareTo(segment.begin.squaredDistanceTo(b)));

    return points;
  }

  void _linkVertices(List<_Vertex> thisShapeVertices) {
    for (var i = 0; i < thisShapeVertices.length; ++i) {
      final vertex = thisShapeVertices[i];
      final prevIndex = i - 1 >= 0 ? i - 1 : thisShapeVertices.length - 1;
      final nextIndex = i + 1 < thisShapeVertices.length ? i + 1 : 0;
      vertex.linkedVertices.add(thisShapeVertices[prevIndex]);
      vertex.linkedVertices.add(thisShapeVertices[nextIndex]);
    }
  }

  void _linkCommonVertices(
    List<_Vertex> verticesA,
    List<_Vertex> verticesB,
  ) {
    for (var va in verticesA) {
      for (var vb in verticesB) {
        if (va.point == vb.point) {
          va.linkedVertices.addAll(vb.linkedVertices);
          vb.linkedVertices.addAll(va.linkedVertices);
        }
      }
    }
  }

  _Vertex _findInitialBottomVertex(List<_Vertex> thisShapeVertices) {
    _Vertex vertex;
    for (var v in thisShapeVertices) {
      if (vertex == null || v.point.y > vertex.point.y) {
        vertex = v;
      } else if (v.point.y == vertex.point.y && v.point.x < vertex.point.x) {
        vertex = v;
      }
    }
    return vertex;
  }

  _Vertex _findLeftmostLinkedVertex(
    _Vertex currentVertex,
    _Vertex previousVertex,
  ) {
    _Vertex vertex;
    double maxAngle;
    for (var v in currentVertex.linkedVertices) {
      final angle =
          ccwVectorsAngle(currentVertex.point, previousVertex.point, v.point);
      if (maxAngle == null || angle > maxAngle) {
        vertex = v;
        maxAngle = angle;
      }
    }
    return vertex;
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

class BoundingShapeIntersection {
  final BoundingShape boundingShape;
  final int segmentIndex;
  final Point<double> intersection;
  final double squaredDistance;

  BoundingShapeIntersection(
    this.boundingShape,
    this.segmentIndex,
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

  BoundingShapeIntersection getBoundingShapeIntersection(
    BoundingShape boundingShape,
  ) {
    BoundingShapeIntersection closestIntersection;

    for (var i = 0; i < boundingShape.segments.length; ++i) {
      final segment = boundingShape.segments[i];
      final point = getSegmentIntersection(segment);

      if (point != null) {
        final distance = begin.squaredDistanceTo(point);

        if (closestIntersection == null ||
            closestIntersection.squaredDistance > distance) {
          closestIntersection =
              BoundingShapeIntersection(boundingShape, i, point, distance);
        }
      }
    }

    return closestIntersection;
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

class _Vertex {
  final Point<double> point;

  final List<_Vertex> linkedVertices = [];

  bool _visited = false;

  _Vertex(this.point);

  bool get isVisited => _visited;

  void markAsVisited() {
    _visited = true;
  }
}
