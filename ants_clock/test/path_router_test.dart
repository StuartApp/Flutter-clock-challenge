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

    test('Segment intersection with bounding box', () {
      final segment = Segment(Point(0.0, 1.0), Point(8.0, 1.0));

      final boundingBox = BoundingBox(
        Segment(Point(4.0, 2.0), Point(6.0, 2.0)),
        Segment(Point(6.0, 2.0), Point(6.0, 0.0)),
        Segment(Point(6.0, 0.0), Point(4.0, 0.0)),
        Segment(Point(4.0, 0.0), Point(4.0, 2.0)),
      );

      final intersection = segment.getBoundingBoxIntersection(boundingBox);

      expect(intersection, isNotNull);
      expect(intersection.intersection.x, 4.0);
      expect(intersection.intersection.y, 1.0);
    });
  });

  group('BoundingShape', () {
    test('Bounding shape bounds creation', () {
      final bs = BoundingShape([
        Segment(Point(1.0, 1.0), Point(2.0, 2.0)),
        Segment(Point(2.0, 2.0), Point(1.0, 3.0)),
        Segment(Point(1.0, 3.0), Point(0.0, 2.0)),
        Segment(Point(0.0, 2.0), Point(1.0, 1.0)),
      ]);

      expect(bs.bounds.top, 1.0);
      expect(bs.bounds.bottom, 3.0);
      expect(bs.bounds.left, 0.0);
      expect(bs.bounds.right, 2.0);
    });

    test('Get Ant bounding shape with bearing 0', () {
      final offset = Ant.halfSize + BoundingShape.padding;
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
      final offset = Ant.halfSize + BoundingShape.padding;
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
  });
}
