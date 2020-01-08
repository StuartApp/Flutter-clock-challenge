import 'package:ants_clock/digit.dart';
import 'package:ants_clock/path_router.dart';
import 'package:ants_clock/position.dart';

import 'ant.dart';
import 'math_utils.dart';

class ColonyController {
  ColonyController(this.worldWidth, this.worldHeight, int hour, int minute) {
    _hour = hour;
    _minute = minute;
    _shouldRenderTime = true;

    // DBG BEGIN

    ants.add(Ant(Position(30.0, worldHeight / 2.0, 0.0)));

    /*for (var i = 0; i < 10; ++i) {
      ants.add(Ant(Position(
        250.0 + ((random.nextDouble() * 200.0) - 100.0),
        worldHeight / 2.0 + ((random.nextDouble() * 200.0) - 100.0),
        0.0,
      )));
    }*/

    ants.add(Ant(Position(200.0 + 0, worldHeight / 2.0 - 12, 0.0)));
    ants.add(Ant(Position(200.0 + 0, worldHeight / 2.0 + 12, 0.0)));
    ants.add(Ant(Position(200.0 + 100, worldHeight / 2.0 + 0, 0.0)));

    // DBG END

    /*for (var i = 0; i < _antsNumber; ++i) {
      ants.add(Ant(Position.random(worldWidth, worldHeight)));
    }*/
  }

  final double worldWidth;

  final double worldHeight;

  final List<Ant> ants = [];

  static const _antsNumber = 60;

  static const _boundaryPadding = 10.0;

  static const _boundarySize = 20.0;

  int _hour = 0;

  int _minute = 0;

  bool _shouldRenderTime = false;

  Duration _elapsed;

  final _antDigitPositions = <int, Position>{};

  final _antBoundaryPositions = <int, Position>{};

  final _pathRouter = PathRouter();

  void setTime(int hour, int minute) {
    _hour = hour;
    _minute = minute;
    _shouldRenderTime = true;
  }

  void tick(Duration elapsed) {
    _elapsed ??= elapsed;

    // DBG
    if (ants.first.isAtDestination &&
        ants.first.position.x < worldWidth - 30.0) {
      final route = _pathRouter.route(
          ants.first,
          ants,
          Position(
            worldWidth - 30.0,
            worldHeight / 2.0,
            0.0,
          ));

      ants.first.setRoute(route);
    }

    /*if (_shouldRenderTime) {
      _assignAntDigitPositions(_hour, _minute);
      _assignAntBoundaryPositions();
      _shouldRenderTime = false;
    } else if (random.nextInt(100) == 0) {
      final antIndexList = _antBoundaryPositions.keys.toList();
      final antIndex = antIndexList[random.nextInt(antIndexList.length)];
      _assignAntBoundaryPosition(antIndex, skipAnts: true);
    }*/

    for (var ant in ants) {
      ant.move(elapsed);
    }

    _elapsed = elapsed;
  }

  void _assignAntDigitPositions(int hour, int minute) {
    _antDigitPositions.clear();

    List<Digit> digits = _createDigits(hour, minute);

    for (var digit in digits) {
      for (var i = 0; i < digit.positions.length; ++i) {
        int antIndex;
        do {
          antIndex = random.nextInt(_antsNumber);
        } while (_antDigitPositions.containsKey(antIndex));
        _antDigitPositions[antIndex] = digit.positions[i];
        _antBoundaryPositions.remove(antIndex);
        ants[antIndex].setRoute([digit.positions[i]]);
      }
    }
  }

  void _assignAntBoundaryPositions() {
    for (var i = 0; i < ants.length; ++i) {
      if (!_antDigitPositions.containsKey(i) && ants[i].isAtDestination) {
        _assignAntBoundaryPosition(i);
      }
    }
  }

  void _assignAntBoundaryPosition(int antIndex, {bool skipAnts = false}) {
    _antBoundaryPositions.remove(antIndex);

    Position position;
    final bool Function(Position) isCloseToPosition = (p) {
      return p.distanceTo(position) <= Ant.size;
    };

    do {
      position = _createPositionAtBoundary();
    } while (_antBoundaryPositions.values.any(isCloseToPosition));

    List<Position> route;

    if (skipAnts) {
      route = _pathRouter.route(ants[antIndex], ants, position);
    } else {
      route = [position];
    }

    _antBoundaryPositions[antIndex] = position;
    ants[antIndex].setRoute(route);
  }

  Position _createPositionAtBoundary() {
    switch (random.nextInt(4)) {
      case 0:
        return Position(
          (random.nextDouble() * _boundarySize) + _boundaryPadding,
          (random.nextDouble() * (worldHeight - (_boundaryPadding * 2))) +
              _boundaryPadding,
          random.nextDouble() * 360.0,
        );
      case 1:
        return Position(
          (random.nextDouble() * (worldWidth - (_boundaryPadding * 2))) +
              _boundaryPadding,
          (random.nextDouble() * _boundarySize) + _boundaryPadding,
          random.nextDouble() * 360.0,
        );
      case 2:
        return Position(
          worldWidth -
              ((random.nextDouble() * _boundarySize) + _boundaryPadding),
          (random.nextDouble() * (worldHeight - (_boundaryPadding * 2))) +
              _boundaryPadding,
          random.nextDouble() * 360.0,
        );
      case 3:
        return Position(
          (random.nextDouble() * (worldWidth - (_boundaryPadding * 2))) +
              _boundaryPadding,
          worldHeight -
              ((random.nextDouble() * _boundarySize) + _boundaryPadding),
          random.nextDouble() * 360.0,
        );
      default:
        return Position.zero();
    }
  }

  List<Digit> _createDigits(int hour, int minute) {
    final width = worldHeight / 3.0;
    final height = worldHeight / 3.0;

    final digits = [
      Digit.number(
        hour ~/ 10,
        worldWidth / 2.0 - ((width / 2.0) * 3.0),
        worldHeight / 2.0,
        width,
        height,
      ),
      Digit.number(
        hour % 10,
        worldWidth / 2.0 - ((width / 2.0) * 1.2),
        worldHeight / 2.0,
        width,
        height,
      ),
      Digit.separator(
        worldWidth / 2.0,
        worldHeight / 2.0,
        width,
        height,
      ),
      Digit.number(
        minute ~/ 10,
        worldWidth / 2.0 + ((width / 2.0) * 1.2),
        worldHeight / 2.0,
        width,
        height,
      ),
      Digit.number(
        minute % 10,
        worldWidth / 2.0 + ((width / 2.0) * 3.0),
        worldHeight / 2.0,
        width,
        height,
      )
    ];
    return digits;
  }
}
