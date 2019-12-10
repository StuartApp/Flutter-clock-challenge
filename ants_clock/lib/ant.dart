import 'package:ants_clock/position.dart';
import 'package:ants_clock/position_shifter.dart';

class Ant {
  Position position;

  PositionShifter _positionShifter;

  Ant(Position initialPosition) : position = initialPosition;

  bool get isCompleted =>
      _positionShifter == null || _positionShifter.isCompleted;

  void move(Duration elapsed) {
    if (_positionShifter != null) {
      _positionShifter.shift(elapsed);

      position = _positionShifter.position;

      if (_positionShifter.isCompleted) {
        _positionShifter = null;
      }
    }
  }

  void setTarget(Position position) {
    _positionShifter = PositionShifter(this.position, position);
  }
}
