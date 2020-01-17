import 'dart:math';
import 'dart:ui';

import 'package:ants_clock/math_utils.dart';

class Position {
  final double x;

  final double y;

  final double bearing;

  const Position(this.x, this.y, this.bearing);

  const Position.zero() : this(0.0, 0.0, 0.0);

  Position.random(double width, double height)
      : this(
          random.nextDouble() * width,
          random.nextDouble() * height,
          random.nextDouble() * 360.0,
        );

  Position.fromPoint(Point<double> point, double bearing)
      : this(point.x, point.y, bearing);

  double distanceTo(Position position) {
    var dx = x - position.x;
    var dy = y - position.y;
    return sqrt(dx * dx + dy * dy);
  }

  double bearingTo(Position position) {
    return bearingToPoint(position.toPoint());
  }

  double bearingToPoint(Point<double> point) {
    final c = toPoint().distanceTo(point);
    final a = (point.x - x).abs();
    if (c == 0.0) {
      return bearing;
    } else {
      final angle = radToDeg(acos(a / c));
      if (point.x >= x) {
        if (point.y <= y) {
          return 90.0 - angle;
        } else {
          return 90.0 + angle;
        }
      } else {
        if (point.y <= y) {
          return 270.0 + angle;
        } else {
          return 270.0 - angle;
        }
      }
    }
  }

  Position positionToPoint(Point<double> point) {
    return Position.fromPoint(point, bearingToPoint(point));
  }

  Position offset(double distance, [double bearing]) {
    bearing ??= this.bearing;

    final a = 90.0 - bearing;
    final xOffset = cos(degToRad(a)) * distance;
    final yOffset = sin(degToRad(a)) * distance;

    return copy(
      x: x + xOffset,
      y: y - yOffset,
    );
  }

  Point<double> toPoint() {
    return Point(x, y);
  }

  Position copy({
    double x,
    double y,
    double bearing,
  }) {
    return Position(
      x ?? this.x,
      y ?? this.y,
      bearing ?? this.bearing,
    );
  }

  @override
  String toString() {
    return 'Position{x: $x, y: $y, bearing: $bearing}';
  }
}

Position lerpPosition(Position begin, Position end, double t) {
  return Position(
    lerpDouble(begin.x, end.x, t),
    lerpDouble(begin.y, end.y, t),
    begin.bearingTo(end),
  );
}
