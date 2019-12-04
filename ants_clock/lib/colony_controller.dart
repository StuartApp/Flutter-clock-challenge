import 'dart:math';

import 'ant.dart';

class ColonyController {
  factory ColonyController(double worldWidth, double worldHeight) {
    var random = Random();
    return ColonyController._internal(
      worldWidth,
      worldHeight,
      Ant(
        x: 0,
        y: 0,
        targetX: random.nextDouble() * worldWidth,
        targetY: random.nextDouble() * worldHeight,
      ),
    );
  }

  ColonyController._internal(this.width, this.height, this.ant);

  static const pixelsPerSecond = 200;

  final double width;

  final double height;

  final Ant ant;

  Duration _elapsed;

  final _random = Random();

  void tick(Duration elapsed) {
    _elapsed ??= elapsed;

    var angle = _calcAngle(ant.x, ant.y, ant.targetX, ant.targetY);

    if (ant.x != ant.targetX || ant.y != ant.targetY) {
      ant.x += _calcOffset(ant.x, ant.targetX, elapsed);
      ant.y += _calcOffset(ant.y, ant.targetY, elapsed);
    } else {
      ant.targetX = _random.nextDouble() * width;
      ant.targetY = _random.nextDouble() * height;
    }

    _elapsed = elapsed;
  }

  double _calcOffset(double origin, double target, Duration elapsed) {
    var elapsedMillis = (elapsed - _elapsed).inMilliseconds;
    var offset = elapsedMillis * (pixelsPerSecond / 1000.0);
    offset = min(offset, (target - origin).abs());
    return origin < target ? offset : -offset;
  }

  double _calcAngle(
    double originX,
    double originY,
    double targetX,
    double targetY,
  ) {
    return 0.0;
  }
}
