import 'package:ants_clock/models/digit.dart';
import 'package:ants_clock/models/position.dart';
import 'package:ants_clock/path_router.dart';

import 'math_utils.dart';
import 'models/ant.dart';

class ColonyController {
  ColonyController(this.worldWidth, this.worldHeight, int hour, int minute) {
    _hour = hour;
    _minute = minute;
    _shouldRenderTime = true;

    for (var i = 0; i < _antsNumber; ++i) {
      ants.add(Ant(Position.random(worldWidth, worldHeight)));
    }
  }

  final double worldWidth;

  final double worldHeight;

  final List<Ant> ants = [];

  static const _antsNumber = 65;

  static const _boundaryPadding = 10.0;

  static const _boundarySize = 20.0;

  int _hour = 0;

  int _minute = 0;

  bool _shouldRenderTime = false;

  Duration _elapsed;

  final _antDigitPositions = <int, Position>{};

  final _antBoundaryPositions = <int, Position>{};

  PathRouter _pathRouter;

  void setTime(int hour, int minute) {
    _hour = hour;
    _minute = minute;
    _shouldRenderTime = true;
  }

  void tick(Duration elapsed) {
    _elapsed ??= elapsed;

    if (_shouldRenderTime) {
      _pathRouter = null;
      _assignAntDigitPositions(_hour, _minute);
      _assignAntBoundaryPositions();
      _shouldRenderTime = false;
    } else if (random.nextInt(1000) <= 10 && _pathRouter != null) {
      final antIndexList = _antBoundaryPositions.keys.toList();
      final antIndex = antIndexList[random.nextInt(antIndexList.length)];
      _assignAntBoundaryPosition(antIndex);
    }

    if (_pathRouter == null && ants.every((a) => a.isAtDestination)) {
      var points = ants.map((a) => a.position.toPoint()).toList();
      _pathRouter = PathRouter(worldWidth, worldHeight, points);
    }

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

  void _assignAntBoundaryPosition(int antIndex) {
    _antBoundaryPositions.remove(antIndex);

    Position position;
    final bool Function(Position) isCloseToPosition = (p) {
      return p.distanceTo(position) <= Ant.size;
    };

    do {
      position = _createPositionAtBoundary();
    } while (_antBoundaryPositions.values.any(isCloseToPosition));

    List<Position> route;

    if (_pathRouter != null) {
      route = _pathRouter.route(ants[antIndex].position, position);
      _pathRouter.removePoint(ants[antIndex].position.toPoint());
      _pathRouter.addPoint(route.last.toPoint());
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
    final width = worldHeight / 5.0;
    final height = worldHeight / 3.5;

    final digits = [
      Digit.number(
        hour ~/ 10,
        worldWidth / 2.0 - width * 2.0,
        worldHeight / 2.0,
        width,
        height,
      ),
      Digit.number(
        hour % 10,
        worldWidth / 2.0 - width * 1.0,
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
        worldWidth / 2.0 + width * 1.0,
        worldHeight / 2.0,
        width,
        height,
      ),
      Digit.number(
        minute % 10,
        worldWidth / 2.0 + width * 2.0,
        worldHeight / 2.0,
        width,
        height,
      )
    ];
    return digits;
  }
}
