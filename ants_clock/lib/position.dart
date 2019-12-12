import 'dart:math';

import 'package:ants_clock/math_utils.dart';

class Position {
  static final _random = Random();

  final double x;

  final double y;

  final double bearing;

  Position(this.x, this.y, this.bearing);

  Position.zero() : this(0.0, 0.0, 0.0);

  Position.random(double width, double height)
      : this(
          _random.nextDouble() * width,
          _random.nextDouble() * height,
          _random.nextDouble() * 360.0,
        );

  double distanceTo(Position position) {
    var dx = x - position.x;
    var dy = y - position.y;
    return sqrt(dx * dx + dy * dy);
  }

  double bearingTo(Position position) {
    final c = distanceTo(position);
    final a = (position.x - x).abs();
    if (c == 0.0) {
      return bearing;
    } else {
      final angle = radToDeg(acos(a / c));
      if (position.x >= x) {
        if (position.y <= y) {
          return 90.0 - angle;
        } else {
          return 90.0 + angle;
        }
      } else {
        if (position.y <= y) {
          return 270.0 + angle;
        } else {
          return 270.0 - angle;
        }
      }
    }
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
}
