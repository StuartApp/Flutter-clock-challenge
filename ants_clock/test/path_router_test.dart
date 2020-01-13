import 'dart:math';

import 'package:ants_clock/ant.dart';
import 'package:ants_clock/path_router.dart';
import 'package:ants_clock/position.dart';
import 'package:test/test.dart';

void main() {
  group('Segment', () {
    test('Segment intersection with other segment', () {
      final segment1 = Segment(Point(0.0, 0.0), Point(5.0, 0.0));
      final segment2 = Segment(Point(2.5, 2.0), Point(2.5, -2.0));

      final intersection = segment1.getSegmentIntersection(segment2);

      expect(intersection, isNotNull);
      expect(intersection.x, 2.5);
      expect(intersection.y, 0.0);
    });

    test('Segment intersection with other segment', () {
      final segment1 = Segment(Point(2.5, 2.0), Point(2.5, -2.0));
      final segment2 = Segment(Point(0.0, 0.0), Point(5.0, 0.0));

      final intersection = segment1.getSegmentIntersection(segment2);

      expect(intersection, isNotNull);
      expect(intersection.x, 2.5);
      expect(intersection.y, 0.0);
    });

    test('Segment intersection with other segment', () {
      final segment1 = Segment(Point(0.0, 0.0), Point(4.0, 4.0));
      final segment2 = Segment(Point(0.0, 2.0), Point(4.0, 2.0));

      final intersection = segment1.getSegmentIntersection(segment2);

      expect(intersection, isNotNull);
      expect(intersection.x, 2.0);
      expect(intersection.y, 2.0);
    });

    test('Segment intersection with bounding shape', () {
      final segment = Segment(Point(0.0, 1.0), Point(8.0, 1.0));

      final boundingBox = BoundingShape.fromPoints([
        Point(6.0, 0.0),
        Point(6.0, 2.0),
        Point(4.0, 2.0),
        Point(4.0, 0.0),
      ]);

      final intersection = segment.getBoundingShapeIntersection(boundingBox);

      expect(intersection, isNotNull);
      expect(intersection.point.x, 4.0);
      expect(intersection.point.y, 1.0);
    });
  });

  group('BoundingShape', () {
    test('Bounding shape bounds rectangle creation', () {
      final bs = BoundingShape([
        Segment(Point(1.0, 1.0), Point(2.0, 2.0)),
        Segment(Point(2.0, 2.0), Point(1.0, 3.0)),
        Segment(Point(1.0, 3.0), Point(0.0, 2.0)),
        Segment(Point(0.0, 2.0), Point(1.0, 1.0)),
      ]);

      expect(bs.boundsRectangle.top, 1.0);
      expect(bs.boundsRectangle.bottom, 3.0);
      expect(bs.boundsRectangle.left, 0.0);
      expect(bs.boundsRectangle.right, 2.0);
    });

    test('Get Ant bounding shape with bearing 0', () {
      final offset = Ant.halfSize + BoundingShape.antPadding;
      final ant = Ant(Position(100.0, 100.0, 0.0));
      final boundingShape = BoundingShape.fromAnt(ant);

      expect(boundingShape.segments[0].begin.x, 100.0 - offset);
      expect(boundingShape.segments[0].begin.y, 100.0 - offset);
      expect(boundingShape.segments[0].end.x, 100.0 + offset);
      expect(boundingShape.segments[0].end.y, 100.0 - offset);

      expect(boundingShape.segments[1].begin.x, 100.0 + offset);
      expect(boundingShape.segments[1].begin.y, 100.0 - offset);
      expect(boundingShape.segments[1].end.x, 100.0 + offset);
      expect(boundingShape.segments[1].end.y, 100.0 + offset);

      expect(boundingShape.segments[2].begin.x, 100.0 + offset);
      expect(boundingShape.segments[2].begin.y, 100.0 + offset);
      expect(boundingShape.segments[2].end.x, 100.0 - offset);
      expect(boundingShape.segments[2].end.y, 100.0 + offset);

      expect(boundingShape.segments[3].begin.x, 100.0 - offset);
      expect(boundingShape.segments[3].begin.y, 100.0 + offset);
      expect(boundingShape.segments[3].end.x, 100.0 - offset);
      expect(boundingShape.segments[3].end.y, 100.0 - offset);
    });

    test('Get Ant bounding shape with bearing 90', () {
      final offset = Ant.halfSize + BoundingShape.antPadding;
      final ant = Ant(Position(100.0, 100.0, 90.0));
      final boundingShape = BoundingShape.fromAnt(ant);

      expect(boundingShape.segments[0].begin.x, 100.0 + offset);
      expect(boundingShape.segments[0].begin.y, 100.0 - offset);
      expect(boundingShape.segments[0].end.x, 100.0 + offset);
      expect(boundingShape.segments[0].end.y, 100.0 + offset);

      expect(boundingShape.segments[1].begin.x, 100.0 + offset);
      expect(boundingShape.segments[1].begin.y, 100.0 + offset);
      expect(boundingShape.segments[1].end.x, 100.0 - offset);
      expect(boundingShape.segments[1].end.y, 100.0 + offset);

      expect(boundingShape.segments[2].begin.x, 100.0 - offset);
      expect(boundingShape.segments[2].begin.y, 100.0 + offset);
      expect(boundingShape.segments[2].end.x, 100.0 - offset);
      expect(boundingShape.segments[2].end.y, 100.0 - offset);

      expect(boundingShape.segments[3].begin.x, 100.0 - offset);
      expect(boundingShape.segments[3].begin.y, 100.0 - offset);
      expect(boundingShape.segments[3].end.x, 100.0 + offset);
      expect(boundingShape.segments[3].end.y, 100.0 - offset);
    });

    test(
        'Union of two bounding shapes '
        '(2nd square overlaps right side of 1st square)', () {
      final bs1 = BoundingShape([
        Segment(Point(1.0, 1.0), Point(3.0, 1.0)),
        Segment(Point(3.0, 1.0), Point(3.0, 3.0)),
        Segment(Point(3.0, 3.0), Point(1.0, 3.0)),
        Segment(Point(1.0, 3.0), Point(1.0, 1.0)),
      ]);

      final bs2 = BoundingShape([
        Segment(Point(2.0, 2.0), Point(4.0, 2.0)),
        Segment(Point(4.0, 2.0), Point(4.0, 4.0)),
        Segment(Point(4.0, 4.0), Point(2.0, 4.0)),
        Segment(Point(2.0, 4.0), Point(2.0, 2.0)),
      ]);

      final result = bs1.union(bs2);

      expect(result.segments.length, 8);
      expect(result.segments.first.begin, result.segments.last.end);
    });

    test(
        'Union of two bounding shapes '
        '(2nd square overlaps left side of 1st square)', () {
      final bs1 = BoundingShape.fromPoints([
        Point(1.0, 0.0),
        Point(3.0, 0.0),
        Point(3.0, 3.0),
        Point(1.0, 3.0),
      ]);

      final bs2 = BoundingShape.fromPoints([
        Point(0.0, 1.0),
        Point(2.0, 1.0),
        Point(2.0, 2.0),
        Point(0.0, 2.0),
      ]);

      final result = bs1.union(bs2);

      expect(result.segments.length, 8);
      expect(result.segments.first.begin, result.segments.last.end);
    });

    test(
        'Union of two bounding shapes '
        '(2nd square is on the right side of 1st square)', () {
      final bs1 = BoundingShape.fromPoints([
        Point(0.0, 0.0),
        Point(1.0, 0.0),
        Point(1.0, 1.0),
        Point(0.0, 1.0),
      ]);

      final bs2 = BoundingShape.fromPoints([
        Point(1.0, 0.0),
        Point(2.0, 0.0),
        Point(2.0, 1.0),
        Point(1.0, 1.0),
      ]);

      final result = bs1.union(bs2);

      expect(result.segments.length, 6);
      expect(result.segments.first.begin, result.segments.last.end);
    });

    test(
        'Union of two bounding shapes '
        '(2nd square is below of 1st square)', () {
      final bs1 = BoundingShape.fromPoints([
        Point(0.0, 0.0),
        Point(10.0, 0.0),
        Point(10.0, 10.0),
        Point(0.0, 10.0),
      ]);
      final bs2 = BoundingShape.fromPoints([
        Point(0.0, 5.0),
        Point(10.0, 5.0),
        Point(10.0, 15.0),
        Point(0.0, 15.0),
      ]);

      final result = bs1.union(bs2);

      expect(result.segments.length, 8);
      expect(result.segments.first.begin, result.segments.last.end);
    });

    test('Union of two squares (One is rotated 45 degrees)', () {
      final bs1 = BoundingShape.fromPoints([
        Point(0.0, 0.0),
        Point(10.0, 0.0),
        Point(10.0, 10.0),
        Point(0.0, 10.0),
      ]);
      final bs2 = BoundingShape.fromPoints([
        Point(5.0, 8.0),
        Point(10.0, 13.0),
        Point(5.0, 18.0),
        Point(0.0, 13.0),
      ]);

      final result = bs1.union(bs2);

      expect(result.segments.length, 7);
      expect(result.segments.first.begin, result.segments.last.end);
    });

    /*test('Union of two Ants', () {
      final bs1 = BoundingShape.fromAnt(Ant(Position(
        50.0, // 203.71428571428572,
        50.0, // 133.57142857142858,
        0.0, // 0.48988011388701125,
      )));
      final bs2 = BoundingShape.fromAnt(Ant(Position(
        50.0, // 203.71428571428572,
        57.0, // 109.28571428571429,
        45.0, // 358.6102085078564,
      )));

      final result = bs1.union(bs2);

      expect(result.segments.length, 8);
      expect(result.segments.first.begin, result.segments.last.end);
    });*/
  });

  group('Path router', () {
    test('test 1', () {
      final size = Ant.size + (BoundingShape.antPadding * 2);

      final ants = [
        Ant(Position(0, 50.0, 0.0)),
        Ant(Position(50.0, 50.0, 0.0)),
        Ant(Position(50.0, 50.0 + size - 5.0, 0.0)),
        Ant(Position(100.0, 50.0, 0.0)),
      ];

      final pathRouter = PathRouter(ants);
      final route = pathRouter.route(ants.first, Position(150.0, 50.0, 0.0));

      expect(route.length, 8);
    });
  });
}
