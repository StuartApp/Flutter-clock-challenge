import 'package:ants_clock/digit.dart';
import 'package:ants_clock/position.dart';

import 'ant.dart';
import 'math_utils.dart';

class ColonyController {
  ColonyController(this.worldWidth, this.worldHeight, int hour, int minute) {
    _hour = hour;
    _minute = minute;
    _shouldRenderTime = true;

    for (var i = 0; i < antsNumber; ++i) {
      ants.add(Ant(Position.random(worldWidth, worldHeight)));
    }
  }

  static const antsNumber = 60;

  static const boundaryPadding = 10.0;

  static const boundarySize = 20.0;

  final double worldWidth;

  final double worldHeight;

  final List<Ant> ants = [];

  int _hour = 0;

  int _minute = 0;

  bool _shouldRenderTime = false;

  Duration _elapsed;

  final _antDigitPositions = <int, Position>{};

  final _antBoundaryPositions = <int, Position>{};

  void setTime(int hour, int minute) {
    _hour = hour;
    _minute = minute;
    _shouldRenderTime = true;
  }

  void tick(Duration elapsed) {
    _elapsed ??= elapsed;

    if (_shouldRenderTime) {
      _assignAntDigitPositions(_hour, _minute);
      _assignAntBoundaryPositions();
      _shouldRenderTime = false;
    } else if (random.nextInt(100) == 0) {
      final antIndexList = _antBoundaryPositions.keys.toList();
      final antIndex = antIndexList[random.nextInt(antIndexList.length)];
      _assignAntBoundaryPosition(antIndex);
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
          antIndex = random.nextInt(antsNumber);
        } while (_antDigitPositions.containsKey(antIndex));
        _antDigitPositions[antIndex] = digit.positions[i];
        ants[antIndex].setTarget(digit.positions[i]);
      }
    }
  }

  void _assignAntBoundaryPositions() {
    _antBoundaryPositions.clear();

    for (var i = 0; i < ants.length; ++i) {
      if (!_antDigitPositions.containsKey(i)) {
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

    _antBoundaryPositions[antIndex] = position;
    ants[antIndex].setTarget(position);
  }

  Position _createPositionAtBoundary() {
    switch (random.nextInt(4)) {
      case 0:
        return Position(
          (random.nextDouble() * boundarySize) + boundaryPadding,
          (random.nextDouble() * (worldHeight - (boundaryPadding * 2))) +
              boundaryPadding,
          random.nextDouble() * 360.0,
        );
      case 1:
        return Position(
          (random.nextDouble() * (worldWidth - (boundaryPadding * 2))) +
              boundaryPadding,
          (random.nextDouble() * boundarySize) + boundaryPadding,
          random.nextDouble() * 360.0,
        );
      case 2:
        return Position(
          worldWidth - ((random.nextDouble() * boundarySize) + boundaryPadding),
          (random.nextDouble() * (worldHeight - (boundaryPadding * 2))) +
              boundaryPadding,
          random.nextDouble() * 360.0,
        );
      case 3:
        return Position(
          (random.nextDouble() * (worldWidth - (boundaryPadding * 2))) +
              boundaryPadding,
          worldHeight -
              ((random.nextDouble() * boundarySize) + boundaryPadding),
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
