import 'package:ants_clock/math_utils.dart';
import 'package:ants_clock/models/position.dart';

abstract class Digit {
  factory Digit.number(
      int number, double x, double y, double width, double height) {
    return _NumberDigit(number, x, y, width, height);
  }

  factory Digit.separator(double x, double y, double width, double height) {
    return _SeparatorDigit(x, y, width, height);
  }

  List<Position> get positions;
}

class _NumberDigit implements Digit {
  _NumberDigit(int number, double x, double y, double width, double height) {
    _positionsMap.forEach((position, numbers) {
      if (numbers.contains(number)) {
        _positions.add(_createPosition(position, x, y, width, height));
      }
    });
  }

  List<Position> get positions => _positions;

  static const _horizontal = 90.0;
  static const _vertical = 0.0;

  /// Unscaled digit part [Position]
  ///
  ///  -   top
  /// | |  topLeft and topRight
  ///  -   middle
  /// | |  bottomLeft and bottomRight
  ///  _   bottom
  static const _top1 = Position(0.4, 0.0, _horizontal);
  static const _top2 = Position(0.6, 0.0, _horizontal);
  static const _topLeft1 = Position(0.25, 0.1, _vertical);
  static const _topLeft2 = Position(0.25, 0.35, _vertical);
  static const _topCenter1 = Position(0.5, 0.1, _vertical);
  static const _topCenter2 = Position(0.5, 0.35, _vertical);
  static const _topRight1 = Position(0.75, 0.1, _vertical);
  static const _topRight2 = Position(0.75, 0.35, _vertical);
  static const _middle1 = Position(0.4, 0.5, _horizontal);
  static const _middle2 = Position(0.6, 0.5, _horizontal);
  static const _bottomLeft1 = Position(0.25, 0.65, _vertical);
  static const _bottomLeft2 = Position(0.25, 0.9, _vertical);
  static const _bottomCenter1 = Position(0.5, 0.65, _vertical);
  static const _bottomCenter2 = Position(0.5, 0.9, _vertical);
  static const _bottomRight1 = Position(0.75, 0.65, _vertical);
  static const _bottomRight2 = Position(0.75, 0.9, _vertical);
  static const _bottom1 = Position(0.4, 1.0, _horizontal);
  static const _bottom2 = Position(0.6, 1.0, _horizontal);

  static const _positionsMap = <Position, List<int>>{
    _top1: [0, 2, 3, 5, 6, 7, 8, 9],
    _top2: [0, 2, 3, 5, 6, 7, 8, 9],
    _topLeft1: [0, 4, 5, 6, 8, 9],
    _topLeft2: [0, 4, 5, 6, 8, 9],
    _topCenter1: [1],
    _topCenter2: [1],
    _topRight1: [0, 2, 3, 4, 7, 8, 9],
    _topRight2: [0, 2, 3, 4, 7, 8, 9],
    _middle1: [2, 3, 4, 5, 6, 8, 9],
    _middle2: [2, 3, 4, 5, 6, 8, 9],
    _bottomLeft1: [0, 2, 6, 8],
    _bottomLeft2: [0, 2, 6, 8],
    _bottomCenter1: [1],
    _bottomCenter2: [1],
    _bottomRight1: [0, 3, 4, 5, 6, 7, 8, 9],
    _bottomRight2: [0, 3, 4, 5, 6, 7, 8, 9],
    _bottom1: [0, 2, 3, 5, 6, 8],
    _bottom2: [0, 2, 3, 5, 6, 8],
  };

  final List<Position> _positions = [];
}

class _SeparatorDigit implements Digit {
  _SeparatorDigit(double x, double y, double width, double height) {
    _positions.add(_createPosition(_top, x, y, width, height));
    _positions.add(_createPosition(_bottom, x, y, width, height));
  }

  List<Position> get positions => _positions;

  static const _top = Position(0.5, 0.35, 0.0);

  static const _bottom = Position(0.5, 0.65, 0.0);

  final List<Position> _positions = [];
}

Position _createPosition(
    Position position, double x, double y, double width, double height) {
  final orientation = random.nextInt(2) == 0 ? 0.0 : 180.0;
  final noise = (random.nextDouble() * 20.0) - 10.0;
  return Position(
    x + ((position.x - 0.5) * width),
    y + ((position.y - 0.5) * height),
    normalizeAngle(position.bearing + orientation + noise),
  );
}
