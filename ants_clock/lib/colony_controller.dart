import 'dart:math';

import 'package:ants_clock/digit.dart';
import 'package:ants_clock/position.dart';

import 'ant.dart';

class ColonyController {
  ColonyController(this.worldWidth, this.worldHeight, int hour, int minute) {
    _hour = hour;
    _minute = minute;
    _isTimeUpdated = true;

    for (var i = 0; i < antsNumber; ++i) {
      ants.add(Ant(Position.random(worldWidth, worldHeight)));
    }
  }

  static const antsNumber = 75;

  static const boundaryPadding = 20.0;

  static const boundarySize = 10.0;

  final double worldWidth;

  final double worldHeight;

  final List<Ant> ants = [];

  int _hour = 0;

  int _minute = 0;

  bool _isTimeUpdated = false;

  Duration _elapsed;

  final _random = Random();

  void setTime(int hour, int minute) {
    _hour = hour;
    _minute = minute;
    _isTimeUpdated = true;
  }

  void tick(Duration elapsed) {
    _elapsed ??= elapsed;

    if (_isTimeUpdated && ants.every((ant) => ant.isMoveFinished)) {
      Map<int, Position> antTargets = _assignAntTargets(_hour, _minute);

      for (var i = 0; i < ants.length; ++i) {
        var ant = ants[i];
        if (antTargets.containsKey(i)) {
          ant.setTarget(antTargets[i]);
        } else {
          ant.setTarget(_createPositionAtBoundary());
        }
      }

      _isTimeUpdated = false;
    }

    for (var ant in ants) {
      ant.move(elapsed);
    }

    _elapsed = elapsed;
  }

  Map<int, Position> _assignAntTargets(int hour, int minute) {
    final width = worldHeight / 3.0;
    final height = worldHeight / 3.0;

    final digits = [
      Digit(
        hour ~/ 10,
        worldWidth / 2.0 - ((width / 2.0) * 3.0),
        worldHeight / 2.0,
        width,
        height,
      ),
      Digit(
        hour % 10,
        worldWidth / 2.0 - ((width / 2.0) * 1.0),
        worldHeight / 2.0,
        width,
        height,
      ),
      Digit(
        minute ~/ 10,
        worldWidth / 2.0 + ((width / 2.0) * 1.0),
        worldHeight / 2.0,
        width,
        height,
      ),
      Digit(
        minute % 10,
        worldWidth / 2.0 + ((width / 2.0) * 3.0),
        worldHeight / 2.0,
        width,
        height,
      )
    ];

    final antTargets = <int, Position>{};

    for (var digit in digits) {
      for (var i = 0; i < digit.positions.length; ++i) {
        int antIndex;

        do {
          antIndex = _random.nextInt(antsNumber);
        } while (antTargets.containsKey(antIndex));

        antTargets[antIndex] = digit.positions[i];
      }
    }

    return antTargets;
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
