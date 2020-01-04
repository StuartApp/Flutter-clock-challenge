import 'package:ants_clock/ant.dart';
import 'package:ants_clock/path_router.dart';
import 'package:ants_clock/position.dart';
import 'package:test/test.dart';

void main() {
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
}
