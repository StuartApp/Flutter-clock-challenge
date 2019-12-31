import 'package:ants_clock/path_router.dart';
import 'package:ants_clock/position.dart';
import 'package:ants_clock/position_shifter.dart';

class Ant {
  Ant(Position position, this._pathRouter) : _position = position;

  static const size = 18.0;

  static const halfSize = size / 2;

  Position get position => _position;

  int get frame => _frame;

  bool get isAtDestination => _positionShifter?.isFinished ?? true;

  BoundingCircle get boundingCircle => BoundingCircle.fromAnt(this);

  static const _framesPerSecond = 30.0;

  final PathRouter _pathRouter;

  Position _position;

  int _frame = 0;

  List<Position> _route = [];

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
        if (_route.isNotEmpty) {
          _positionShifter = PositionShifter(this.position, _route.first);
          _route.removeAt(0);
        } else {
          _positionShifter = null;
        }
      }
    }
  }

  void setDestination(Position position) {
    _route = _pathRouter.route(this, position);
    _positionShifter = PositionShifter(this.position, _route.first);
    _route.removeAt(0);
  }
}
