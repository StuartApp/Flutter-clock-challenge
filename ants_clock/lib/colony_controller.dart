import 'package:ants_clock/position.dart';

import 'ant.dart';

class ColonyController {
  ColonyController(this.worldWidth, this.worldHeight) {
    for (var i = 0; i < antsNumber; ++i) {
      ants.add(Ant(Position.random(worldWidth, worldHeight)));
    }
  }

  static const antsNumber = 25;

  final double worldWidth;

  final double worldHeight;

  final List<Ant> ants = [];

  Duration _elapsed;

  void tick(Duration elapsed) {
    _elapsed ??= elapsed;

    for (var ant in ants) {
      if (ant.isCompleted) {
        ant.setTarget(Position.random(worldWidth, worldHeight));
      }

      ant.move(elapsed);
    }

    _elapsed = elapsed;
  }
}
