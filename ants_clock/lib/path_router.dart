import 'dart:collection';
import 'dart:math';

import 'package:ants_clock/models/position.dart';

import 'models/ant.dart';
import 'math_utils.dart';

class PathRouter {
  final List<BoundingShape> _boundingShapes = [];

  // DBG
  List<BoundingShape> get boundingShapes => _boundingShapes;

  // DBG
  List<Segment> get segments =>
      _boundingShapes.expand((bs) => bs.segments).toList();

  PathRouter(List<Ant> ants) {
    final boundingShapes =
        ants.map((ant) => BoundingShape.fromAnt(ant)).toList();

    while (boundingShapes.isNotEmpty) {
      var bs = boundingShapes.first;
      final bsToRemove = <int>[];

      if (boundingShapes.length >= 2) {
        for (var i = 1; i < boundingShapes.length; ++i) {
          var bs2 = boundingShapes[i];

          if (bs2.intersects(bs)) {
            bs = bs.union(bs2);
            bsToRemove.add(i);
          }
        }
      }

      _boundingShapes.add(bs);

      for (var index in bsToRemove.reversed) {
        boundingShapes.removeAt(index);
      }
      boundingShapes.removeAt(0);
    }
  }

  List<Position> route(Ant ant, Position destination) {
    final route = <Position>[];

    Position currentPosition = ant.position;

    var bsIntersection = _getFirstBoundingShapeIntersection(
        ant, currentPosition.toPoint(), destination.toPoint());

    while (bsIntersection != null) {
      _walkAroundBoundingShape(
          route, currentPosition, destination, bsIntersection);

      currentPosition = route.last;

      bsIntersection = _getFirstBoundingShapeIntersection(
          ant, currentPosition.toPoint(), destination.toPoint());
    }

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
      if (bs.relatedAnts.contains(ant)) continue;

      final bsIntersection = segment.getBoundingShapeIntersection(bs);
      if (bsIntersection != null) {
        if (closestBSIntersection == null ||
            bsIntersection.squaredDistance <
                closestBSIntersection.squaredDistance) {
          if (bsIntersection.point != begin) {
            closestBSIntersection = bsIntersection;
          }
        }
      }
    }

    return closestBSIntersection;
  }

  void _walkAroundBoundingShape(
    List<Position> route,
    Position begin,
    Position end,
    BoundingShapeIntersection bsIntersection,
  ) {
    route.add(begin.positionToPoint(bsIntersection.point));

    final segments = bsIntersection.boundingShape.segments;
    final Point<double> endPoint = end.toPoint();

    Point<double> closestPoint;
    double closestDistance;
    for (var segment in segments) {
      final distance = segment.end.squaredDistanceTo(endPoint);
      if (closestDistance == null ||
          segment.end.squaredDistanceTo(endPoint) < closestDistance) {
        closestPoint = segment.end;
        closestDistance = distance;
      }
    }

    var index = bsIntersection.segmentIndex;
    while (segments[index].end != closestPoint) {
      route.add(route.last.positionToPoint(segments[index].end));
      index++;
      if (index >= segments.length) index = 0;
    }

    route.add(route.last.positionToPoint(segments[index].end));
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

  final Set<Ant> relatedAnts = Set();

  BoundingShape(this.segments) : boundsRectangle = _createRectangle(segments);

  factory BoundingShape.fromAnt(Ant ant) {
    final offset = Ant.halfSize + antPadding;
    final topLeft = _getRotatedAntPoint(ant, -offset, -offset);
    final topRight = _getRotatedAntPoint(ant, offset, -offset);
    final bottomLeft = _getRotatedAntPoint(ant, -offset, offset);
    final bottomRight = _getRotatedAntPoint(ant, offset, offset);

    return BoundingShape(
      [
        Segment(topLeft, topRight),
        Segment(topRight, bottomRight),
        Segment(bottomRight, bottomLeft),
        Segment(bottomLeft, topLeft),
      ],
    )..relatedAnts.add(ant);
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

    _unifyVertices(thisShapeVertices, otherShapeVertices);

    _linkVertices(thisShapeVertices);
    _linkVertices(otherShapeVertices);
    _linkCommonVertices(thisShapeVertices, otherShapeVertices);

    final points = <Point<double>>[];

    _Vertex currentVertex =
        _findInitialBottomVertex([thisShapeVertices, otherShapeVertices]);
    _Vertex previousVertex = _Vertex(currentVertex.point - Point(1.0, 0.0));

    while (!currentVertex.isVisited) {
      points.add(currentVertex.point);
      _Vertex nextVertex =
          _findLeftmostLinkedVertex(currentVertex, previousVertex);
      previousVertex = currentVertex;
      currentVertex.markAsVisited();
      currentVertex = nextVertex;
    }

    return BoundingShape.fromPoints(points)
      ..relatedAnts.addAll(relatedAnts)
      ..relatedAnts.addAll(other.relatedAnts);
  }

  List<_Vertex> _getShapeVertices(BoundingShape other) {
    final points = LinkedHashSet<Point<double>>();
    for (var segment in segments) {
      final intersections = _findIntersections(segment, other, true);
      points.addAll(intersections);
      points.add(segment.end);
    }
    return points.map((p) => _Vertex(p)).toList();
  }

  List<Point<double>> _findIntersections(
    Segment segment,
    BoundingShape other,
    bool sorted,
  ) {
    final points = <Point<double>>[];
    for (var otherSegment in other.segments) {
      final point = segment.getSegmentIntersection(otherSegment);
      if (point != null) points.add(point);
    }

    if (sorted) {
      points.sort((a, b) => segment.begin
          .squaredDistanceTo(a)
          .compareTo(segment.begin.squaredDistanceTo(b)));
    }

    return points;
  }

  void _unifyVertices(List<_Vertex> verticesA, List<_Vertex> verticesB) {
    for (var vertices in [verticesA, verticesB]) {
      for (var i = 0; i < vertices.length; ++i) {
        var v1 = vertices[i];
        for (var j = i + 1; j < vertices.length; ++j) {
          var v2 = vertices[j];
          if (v1.isClose(v2)) {
            vertices[j] = v1.copy();
          }
        }
      }
    }
    for (var v1 in verticesA) {
      for (var i = 0; i < verticesB.length; ++i) {
        var v2 = verticesB[i];
        if (v1.isClose(v2)) {
          verticesB[i] = v1.copy();
        }
      }
    }
    _removeListDuplicates(verticesA);
    _removeListDuplicates(verticesB);
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

  _Vertex _findInitialBottomVertex(List<List<_Vertex>> verticesLists) {
    _Vertex vertex;
    for (var vertices in verticesLists) {
      for (var v in vertices) {
        if (vertex == null || v.point.y > vertex.point.y) {
          vertex = v;
        } else if (v.point.y == vertex.point.y && v.point.x < vertex.point.x) {
          vertex = v;
        }
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
      if (v == previousVertex) continue;
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
    var leftTop = Point(_roundDouble(left), _roundDouble(top));
    var rightBottom = Point(_roundDouble(right), _roundDouble(bottom));
    return Rectangle.fromPoints(leftTop, rightBottom);
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
  final Point<double> point;
  final double squaredDistance;

  BoundingShapeIntersection(
    this.boundingShape,
    this.segmentIndex,
    this.point,
    this.squaredDistance,
  );
}

class Segment {
  final Point<double> begin;

  final Point<double> end;

  final Rectangle<double> rectangle;

  Segment(Point<double> begin, Point<double> end)
      : begin = _roundPoint(begin),
        end = _roundPoint(end),
        rectangle = Rectangle.fromPoints(
          _roundPoint(begin),
          _roundPoint(end),
        );

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

  @override
  String toString() {
    return 'Segment{begin: $begin, end: $end}';
  }

  Point<double> _calcIntersectionPoint(Segment other) {
    final m1 = begin.x != end.x
        ? (end.y - begin.y) / (end.x - begin.x)
        : double.infinity;
    final c1 = -((begin.x * m1) - begin.y);

    final m2 = other.begin.x != other.end.x
        ? (other.end.y - other.begin.y) / (other.end.x - other.begin.x)
        : double.infinity;
    final c2 = -((other.begin.x * m2) - other.begin.y);

    double x;
    double y;

    if (m1 == m2) {
      return null;
    } else if (m1 == double.infinity) {
      x = begin.x;
      y = (m2 * x) + c2;
    } else if (m2 == double.infinity) {
      x = other.begin.x;
      y = (m1 * x) + c1;
    } else {
      x = (c2 - c1) / (m1 - m2);
      y = (m1 * x) + c1;
    }

    return Point(_roundDouble(x), _roundDouble(y));
  }
}

class _Vertex {
  final Point<double> point;

  final Set<_Vertex> linkedVertices = Set();

  bool _visited = false;

  _Vertex(this.point);

  bool get isVisited => _visited;

  void markAsVisited() {
    _visited = true;
  }

  bool isClose(_Vertex other) {
    return _pointsAreClose(point, other.point);
  }

  _Vertex copy() {
    return _Vertex(point);
  }

  @override
  String toString() {
    final linked = linkedVertices.map((v) => v.point.toString()).join(', ');
    return '_Vertex{'
        'point: $point, '
        'visited: $_visited, '
        'linkedVertices: [$linked]'
        '}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _Vertex &&
          runtimeType == other.runtimeType &&
          point == other.point;

  @override
  int get hashCode => point.hashCode;
}

Point<double> _roundPoint(Point<double> point) {
  return Point(_roundDouble(point.x), _roundDouble(point.y));
}

double _roundDouble(double num) {
  return (num * 10.0).round() / 10.0;
}

bool _pointsAreClose(Point<double> a, Point<double> b) {
  return (b.x - a.x).abs() <= 1.0 && (b.y - a.y).abs() <= 1.0;
}

void _removeListDuplicates<T>(List<T> list) {
  final itemsToRemove = <int>[];
  for (var i = 1; i < list.length; ++i) {
    if (list[i] == list[i - 1]) {
      itemsToRemove.add(i);
    }
  }
  /*if (list[list.length - 1] == list[0]) {
    itemsToRemove.add(list.length - 1);
  }*/
  for (var i = itemsToRemove.length - 1; i >= 0; --i) {
    list.removeAt(itemsToRemove[i]);
  }
}
