import 'package:ants_clock/position.dart';

import 'ant.dart';

class ColonyController {
  factory ColonyController(double worldWidth, double worldHeight) {
    return ColonyController._internal(
      worldWidth,
      worldHeight,
      Ant(Position.random(worldWidth, worldHeight)),
      // Ant(Position(50.0, 50.0, 0.0)),
    );
  }

  ColonyController._internal(this.width, this.height, this.ant);

  final double width;

  final double height;

  final Ant ant;

  Duration _elapsed;

  void tick(Duration elapsed) {
    _elapsed ??= elapsed;

    if (ant.isCompleted) {
      ant.setTarget(Position.random(width, height));
      // ant.setTarget(Position(100.0, 100.0, 0.0));
    }

    ant.move(elapsed);

    _elapsed = elapsed;
  }
}
