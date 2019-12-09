import 'package:ants_clock/position.dart';

class Ant {
  Position position;

  PositionShift _positionShift;

  Ant(Position initialPosition) : position = initialPosition;

  bool get isCompleted => _positionShift == null || _positionShift.isCompleted;

  void move(Duration elapsed) {
    if (_positionShift != null) {
      _positionShift.update(elapsed);

      position = _positionShift.position;

      if (_positionShift.isCompleted) {
        _positionShift = null;
      }
    }
  }

  void setTarget(Position position) {
    _positionShift = PositionShift(this.position, position);
  }
}
