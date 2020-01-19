import 'dart:math';

import 'models/ant.dart';

class PathRouter2 {
  static const gridSize = 5.0;

  final double worldWidth;

  final double worldHeight;

  List<List<bool>> _grid;

  List<_WayPoint> _wayPoints = [];

  PathRouter2(
    this.worldWidth,
    this.worldHeight,
    List<Ant> ants,
  ) {
    final gridSize = _getGridPoint(Point(worldWidth, worldHeight));

    _grid = List.generate(gridSize.y, (index) {
      return List.filled(gridSize.x, false);
    });

    for (var ant in ants) {
      final offset = Point(Ant.halfSize, Ant.halfSize);
      final topLeft = _getGridPoint(ant.position.toPoint() - offset);
      final bottomRight = _getGridPoint(ant.position.toPoint() + offset);
      for (var y = topLeft.y; y < bottomRight.y; ++y) {
        for (var x = topLeft.x; x < bottomRight.x; ++x) {
          _grid[y][x] = true;
        }
      }
    }

    for (var y = 1; y < gridSize.y - 1; ++y) {
      for (var x = 1; x < gridSize.x - 1; ++x) {
        if (!_grid[y - 1][x] && !_grid[y][x - 1]) {
          _addWayPointIfNotExist((_WayPoint(_getWorldPoint(x - 1, y - 1))));
        }
        if (!_grid[y - 1][x] && !_grid[y][x + 1]) {
          _addWayPointIfNotExist(_WayPoint(_getWorldPoint(x + 1, y - 1)));
        }
        if (!_grid[y + 1][x] && !_grid[y][x - 1]) {
          _addWayPointIfNotExist(_WayPoint(_getWorldPoint(x - 1, y + 1)));
        }
        if (!_grid[y + 1][x] && !_grid[y][x + 1]) {
          _addWayPointIfNotExist(_WayPoint(_getWorldPoint(x + 1, y + 1)));
        }
      }
    }
  }

  Point<int> _getGridPoint(Point<double> worldPoint) {
    return Point(
      (worldPoint.x / gridSize).floor(),
      (worldPoint.y / gridSize).floor(),
    );
  }

  Point<double> _getWorldPoint(int gridX, int gridY) {
    return Point(
      gridX * gridSize,
      gridY * gridSize,
    );
  }

  bool _isLineClear(Point<double> begin, Point<double> end) {
    final gridBegin = _getGridPoint(begin);
    final gridEnd = _getGridPoint(end);
    final distance =
        (gridEnd.x - gridBegin.x).abs() + (gridEnd.y - gridBegin.y).abs();

    final vector = end - begin;
    final unitVector = (vector) * (1 / distance);

    for (var i = 0; i < distance; ++i) {
      final point = (unitVector * i) + begin;
      final gridPoint = _getGridPoint(point);
      if (_grid[gridPoint.y][gridPoint.x]) return true;
    }

    return false;
  }

  void _addWayPointIfNotExist(_WayPoint wayPoint) {
    if (!_wayPoints.contains(wayPoint)) {
      _wayPoints.add(wayPoint);
    }
  }
}

class _WayPoint {
  final Point<double> point;
  final List<_WayPoint> wayPoints = [];

  _WayPoint(this.point);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _WayPoint &&
          runtimeType == other.runtimeType &&
          point == other.point;

  @override
  int get hashCode => point.hashCode;
}
