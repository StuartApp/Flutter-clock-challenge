// Copyright 2020 Stuart Delivery Limited. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math';

import 'package:ants_clock/models/position.dart';

import 'models/ant.dart';

class PathRouter {
  static const _gridSize = 5.0;

  final double worldWidth;

  final double worldHeight;

  List<List<bool>> _grid;

  int _gridWidth;

  int _gridHeight;

  List<_WayPoint> _wayPoints = [];

  PathRouter(
    this.worldWidth,
    this.worldHeight,
    List<Point> points,
  ) {
    _gridWidth = (worldWidth / _gridSize).floor();
    _gridHeight = (worldHeight / _gridSize).floor();

    _grid = List.generate(_gridHeight, (index) {
      return List.filled(_gridWidth, false);
    });

    for (var point in points) {
      _markGrid(point, true);
    }

    for (var y = 1; y < _gridHeight - 1; ++y) {
      for (var x = 1; x < _gridWidth - 1; ++x) {
        if (_grid[y][x]) {
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

    _connectAllWayPoints();
  }

  void addPoint(Point<double> point) {
    _markGrid(point, true);
  }

  void removePoint(Point<double> point) {
    _markGrid(point, false);
  }

  List<Position> route(Position begin, Position end) {
    final endWayPoint = _WayPoint(end.toPoint());
    _connectWayPoint(endWayPoint, _wayPoints);

    final beginPoint = _getFirstPointInLineNotBlocked(
      begin.toPoint(),
      end.toPoint(),
    );
    final beginWayPoint = _WayPoint(beginPoint);
    _connectWayPoint(beginWayPoint, _wayPoints + [endWayPoint]);

    final List<Position> route = [];

    final result = _findRoute(route, beginWayPoint, begin, end);

    if (!result) {
      route.add(end);
    }

    _disconnectWayPoint(beginWayPoint);
    _disconnectWayPoint(endWayPoint);
    for (var wp in _wayPoints) {
      wp.visited = false;
    }

    return route;
  }

  bool _findRoute(
    List<Position> route,
    _WayPoint wayPoint,
    Position currentPosition,
    Position destination,
  ) {
    final wayPoints = List.of(wayPoint.wayPoints);
    wayPoints.sort((wp1, wp2) {
      final dwp1 = wp1.point.squaredDistanceTo(destination.toPoint());
      final dwp2 = wp2.point.squaredDistanceTo(destination.toPoint());
      return dwp1.compareTo(dwp2);
    });
    for (var wp in wayPoints) {
      if (wp.visited) {
        continue;
      } else {
        wp.visited = true;
      }

      if (wp.point == destination.toPoint()) {
        route.add(destination);
        return true;
      }

      final position = currentPosition.positionToPoint(wp.point);
      if (_findRoute(route, wp, position, destination)) {
        route.insert(0, position);
        return true;
      }
    }
    return false;
  }

  void _markGrid(Point<num> point, bool value) {
    final offset = Point(Ant.halfSize + 5.0, Ant.halfSize + 5.0);
    final topLeft = _getGridPoint(point - offset);
    final bottomRight = _getGridPoint(point + offset);
    for (var y = topLeft.y; y < bottomRight.y; ++y) {
      for (var x = topLeft.x; x < bottomRight.x; ++x) {
        _grid[y][x] = value;
      }
    }
  }

  void _connectAllWayPoints() async {
    for (var wp in _wayPoints) {
      _connectWayPoint(wp, _wayPoints);

      // A better approach will be to do some computations in another isolate,
      // but since we are out of time that's the best we can do to avoid long
      // pauses in the main thread.
      await Future.delayed(Duration.zero);
    }
  }

  void _connectWayPoint(_WayPoint wp, List<_WayPoint> wayPoints) {
    for (var wp2 in wayPoints) {
      if (wp != wp2 &&
          !wp.wayPoints.contains(wp2) &&
          !_isLineBlocked(wp.point, wp2.point)) {
        wp.wayPoints.add(wp2);
        wp2.wayPoints.add(wp);
      }
    }
  }

  void _disconnectWayPoint(_WayPoint wp) {
    for (var wp2 in wp.wayPoints) {
      wp2.wayPoints.remove(wp);
    }
  }

  bool _isLineBlocked(Point<double> begin, Point<double> end) {
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

  Point<double> _getFirstPointInLineNotBlocked(
    Point<double> begin,
    Point<double> end,
  ) {
    final gridBegin = _getGridPoint(begin);
    final gridEnd = _getGridPoint(end);
    final distance =
        (gridEnd.x - gridBegin.x).abs() + (gridEnd.y - gridBegin.y).abs();

    final vector = end - begin;
    final unitVector = (vector) * (1 / distance);

    for (var i = 0; i < distance; ++i) {
      final point = (unitVector * i) + begin;
      final gridPoint = _getGridPoint(point);
      if (!_grid[gridPoint.y][gridPoint.x]) return point;
    }

    return end;
  }

  Point<int> _getGridPoint(Point<double> worldPoint) {
    return Point(
      (worldPoint.x / _gridSize).floor().clamp(0, _gridWidth),
      (worldPoint.y / _gridSize).floor().clamp(0, _gridHeight),
    );
  }

  Point<double> _getWorldPoint(int gridX, int gridY) {
    return Point(
      gridX * _gridSize,
      gridY * _gridSize,
    );
  }

  void _addWayPointIfNotExist(_WayPoint wayPoint) {
    if (!_wayPoints.contains(wayPoint)) {
      _wayPoints.add(wayPoint);
    }
  }
}

class PRPoint {
  final double x;
  final double y;

  PRPoint(this.x, this.y);
}

class _WayPoint {
  final Point<double> point;

  final List<_WayPoint> wayPoints = [];

  bool visited = false;

  _WayPoint(this.point);

  @override
  String toString() {
    return '_WayPoint{point: $point}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _WayPoint &&
          runtimeType == other.runtimeType &&
          point == other.point;

  @override
  int get hashCode => point.hashCode;
}
