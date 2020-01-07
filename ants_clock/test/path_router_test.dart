import 'dart:math';

import 'package:ants_clock/ant.dart';
import 'package:ants_clock/path_router.dart';
import 'package:ants_clock/position.dart';
import 'package:test/test.dart';

void main() {
  group('BoundingBox', () {
    test('Get Ant bounding box with bearing 0', () {
      final ant = Ant(Position(100.0, 100.0, 0.0));
      final boundingBox = BoundingBox.fromAnt(ant);

      expect(boundingBox.top.begin.x, 100.0 - Ant.halfSize);
      expect(boundingBox.top.begin.y, 100.0 - Ant.halfSize);
      expect(boundingBox.top.end.x, 100.0 + Ant.halfSize);
      expect(boundingBox.top.end.y, 100.0 - Ant.halfSize);

      expect(boundingBox.right.begin.x, 100.0 + Ant.halfSize);
      expect(boundingBox.right.begin.y, 100.0 - Ant.halfSize);
      expect(boundingBox.right.end.x, 100.0 + Ant.halfSize);
      expect(boundingBox.right.end.y, 100.0 + Ant.halfSize);

      expect(boundingBox.bottom.begin.x, 100.0 + Ant.halfSize);
      expect(boundingBox.bottom.begin.y, 100.0 + Ant.halfSize);
      expect(boundingBox.bottom.end.x, 100.0 - Ant.halfSize);
      expect(boundingBox.bottom.end.y, 100.0 + Ant.halfSize);

      expect(boundingBox.left.begin.x, 100.0 - Ant.halfSize);
      expect(boundingBox.left.begin.y, 100.0 + Ant.halfSize);
      expect(boundingBox.left.end.x, 100.0 - Ant.halfSize);
      expect(boundingBox.left.end.y, 100.0 - Ant.halfSize);
    });

    test('Get Ant bounding box with bearing 90', () {
      final ant = Ant(Position(100.0, 100.0, 90.0));
      final boundingBox = BoundingBox.fromAnt(ant);

      expect(boundingBox.top.begin.x, 100.0 + Ant.halfSize);
      expect(boundingBox.top.begin.y, 100.0 - Ant.halfSize);
      expect(boundingBox.top.end.x, 100.0 + Ant.halfSize);
      expect(boundingBox.top.end.y, 100.0 + Ant.halfSize);

      expect(boundingBox.right.begin.x, 100.0 + Ant.halfSize);
      expect(boundingBox.right.begin.y, 100.0 + Ant.halfSize);
      expect(boundingBox.right.end.x, 100.0 - Ant.halfSize);
      expect(boundingBox.right.end.y, 100.0 + Ant.halfSize);

      expect(boundingBox.bottom.begin.x, 100.0 - Ant.halfSize);
      expect(boundingBox.bottom.begin.y, 100.0 + Ant.halfSize);
      expect(boundingBox.bottom.end.x, 100.0 - Ant.halfSize);
      expect(boundingBox.bottom.end.y, 100.0 - Ant.halfSize);

      expect(boundingBox.left.begin.x, 100.0 - Ant.halfSize);
      expect(boundingBox.left.begin.y, 100.0 - Ant.halfSize);
      expect(boundingBox.left.end.x, 100.0 + Ant.halfSize);
      expect(boundingBox.left.end.y, 100.0 - Ant.halfSize);
    });
  });

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
}
