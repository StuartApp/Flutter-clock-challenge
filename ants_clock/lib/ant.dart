import 'package:ants_clock/position.dart';
import 'package:ants_clock/position_shifter.dart';

class Ant {
  Ant(Position position) : _position = position;

  Position get position => _position;

  int get frame => _frame;

  bool get isAtDestination => _positionShifter?.isFinished ?? true;

  static const size = 18.0;

  static const halfSize = size / 2;

  static const _framesPerSecond = 30.0;

  Position _position;

  int _frame = 0;

  PositionShifter _positionShifter;

  Duration _lastFrameElapsed;

  void move(Duration elapsed) {
    if (_positionShifter != null) {
      _positionShifter.shift(elapsed);
      _position = _positionShifter.position;

      _lastFrameElapsed ??= elapsed;
      var elapsedSinceLastFrame = (elapsed - _lastFrameElapsed).inMilliseconds;
      if (elapsedSinceLastFrame >= 1000 / _framesPerSecond) {
        _frame = _frame == 0 ? 1 : 0;
        _lastFrameElapsed = elapsed;
      }

      if (_positionShifter.isFinished) {
        _positionShifter = null;
      }
    }
  }

  void setDestination(Position position) {
    _positionShifter = PositionShifter(this.position, position);
  }
}
