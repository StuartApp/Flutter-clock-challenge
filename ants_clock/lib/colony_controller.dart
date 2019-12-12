import 'dart:math';

import 'package:ants_clock/position.dart';

import 'ant.dart';

class ColonyController {
  ColonyController(this.worldWidth, this.worldHeight) {
    for (var i = 0; i < antsNumber; ++i) {
      ants.add(Ant(Position.random(worldWidth, worldHeight)));
    }
  }

  static const antsNumber = 100;

  static const boundaryPadding = 20.0;

  static const boundarySize = 10.0;

  final double worldWidth;

  final double worldHeight;

  final List<Ant> ants = [];

  Duration _elapsed;

  final _random = Random();

  void tick(Duration elapsed) {
    _elapsed ??= elapsed;

    if (ants.every((ant) => ant.isMoveFinished)) {
      var selectedIndex = _random.nextInt(antsNumber);
      for (var i = 0; i < ants.length; ++i) {
        var ant = ants[i];
        if (i == selectedIndex) {
          ant.setTarget(_createPositionAtCenter());
        } else {
          ant.setTarget(_createPositionAtBoundary());
        }
      }
    }

    for (var ant in ants) {
      ant.move(elapsed);
    }

    _elapsed = elapsed;
  }

  Position _createPositionAtCenter() {
    return Position(
      worldWidth / 2.0,
      worldHeight / 2.0,
      0.0,
    );
  }

  Position _createPositionAtBoundary() {
    switch (_random.nextInt(4)) {
      case 0:
        return Position(
          (_random.nextDouble() * boundarySize) + boundaryPadding,
          (_random.nextDouble() * (worldHeight - (boundaryPadding * 2))) +
              boundaryPadding,
          _random.nextDouble() * 360.0,
        );
      case 1:
        return Position(
          (_random.nextDouble() * (worldWidth - (boundaryPadding * 2))) +
              boundaryPadding,
          (_random.nextDouble() * boundarySize) + boundaryPadding,
          _random.nextDouble() * 360.0,
        );
      case 2:
        return Position(
          worldWidth -
              ((_random.nextDouble() * boundarySize) + boundaryPadding),
          (_random.nextDouble() * (worldHeight - (boundaryPadding * 2))) +
              boundaryPadding,
          _random.nextDouble() * 360.0,
        );
      case 3:
        return Position(
          (_random.nextDouble() * (worldWidth - (boundaryPadding * 2))) +
              boundaryPadding,
          worldHeight -
              ((_random.nextDouble() * boundarySize) + boundaryPadding),
          _random.nextDouble() * 360.0,
        );
      default:
        return Position.zero();
    }
  }
}
