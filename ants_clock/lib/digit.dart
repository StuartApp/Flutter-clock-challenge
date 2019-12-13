import 'package:ants_clock/position.dart';

class Digit {
  /// Unscaled digit part [Position]
  ///
  ///  -   top
  /// | |  topLeft and topRight
  ///  -   middle
  /// | |  bottomLeft and bottomRight
  ///  _   bottom
  static const _top1 = Position(0.4, 0.0, 90.0);
  static const _top2 = Position(0.6, 0.0, 90.0);
  static const _topLeft1 = Position(0.25, 0.2, 0.0);
  static const _topLeft2 = Position(0.25, 0.4, 0.0);
  static const _topRight1 = Position(0.75, 0.2, 180.0);
  static const _topRight2 = Position(0.75, 0.4, 180.0);
  static const _middle1 = Position(0.4, 0.5, 270.0);
  static const _middle2 = Position(0.6, 0.5, 90.0);
  static const _bottomLeft1 = Position(0.25, 0.6, 180.0);
  static const _bottomLeft2 = Position(0.25, 0.8, 0.0);
  static const _bottomRight1 = Position(0.75, 0.6, 0.0);
  static const _bottomRight2 = Position(0.75, 0.8, 180.0);
  static const _bottom1 = Position(0.4, 1.0, 90.0);
  static const _bottom2 = Position(0.6, 1.0, 270.0);

  static const _positionsMap = <Position, List<int>>{
    _top1: [0, 2, 3, 5, 6, 7, 8, 9],
    _top2: [0, 2, 3, 5, 6, 7, 8, 9],
    _topLeft1: [0, 4, 5, 6, 8, 9],
    _topLeft2: [0, 4, 5, 6, 8, 9],
    _topRight1: [0, 1, 2, 3, 4, 7, 8, 9],
    _topRight2: [0, 1, 2, 3, 4, 7, 8, 9],
    _middle1: [2, 3, 4, 5, 6, 8, 9],
    _middle2: [2, 3, 4, 5, 6, 8, 9],
    _bottomLeft1: [0, 2, 6, 8],
    _bottomLeft2: [0, 2, 6, 8],
    _bottomRight1: [0, 1, 3, 4, 5, 6, 7, 8, 9],
    _bottomRight2: [0, 1, 3, 4, 5, 6, 7, 8, 9],
    _bottom1: [0, 2, 3, 5, 6, 8],
    _bottom2: [0, 2, 3, 5, 6, 8],
  };

  final List<Position> _positions = [];

  Digit(int number, x, y, width, height) {
    _positionsMap.forEach((position, numbers) {
      if (numbers.contains(number)) {
        _positions.add(_createPosition(position, x, y, width, height));
      }
    });
  }

  List<Position> get positions => _positions;

  Position _createPosition(Position position, x, y, width, height) {
    return Position(
      x + ((position.x - 0.5) * width),
      y + ((position.y - 0.5) * height),
      position.bearing,
    );
  }
}
