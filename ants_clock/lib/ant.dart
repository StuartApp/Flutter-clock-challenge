import 'package:ants_clock/position.dart';
import 'package:ants_clock/position_shifter.dart';

class Ant {
  static const size = 18.0;

  static const halfSize = size / 2;

  Position position;

  PositionShifter _positionShifter;

  Ant(this.position);

  bool get isMoveFinished =>
      _positionShifter == null || _positionShifter.isFinished;

  void move(Duration elapsed) {
    if (_positionShifter != null) {
      _positionShifter.shift(elapsed);

      position = _positionShifter.position;

      if (_positionShifter.isFinished) {
        _positionShifter = null;
      }
    }
  }

  void setTarget(Position position) {
    _positionShifter = PositionShifter(this.position, position);
  }
}
