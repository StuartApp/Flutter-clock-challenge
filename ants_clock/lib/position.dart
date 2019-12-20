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

  Position move(double distance, [double bearing]) {
    bearing ??= this.bearing;
    if (bearing <= 90.0) {
      final a = 90.0 - bearing;
      final xOffset = cos(degToRad(a)) * distance;
      final yOffset = sin(degToRad(a)) * distance;
      return copy(
        x: x + xOffset,
        y: y - yOffset,
      );
    } else if (bearing <= 180.0) {
      final a = bearing - 90.0;
      final xOffset = cos(degToRad(a)) * distance;
      final yOffset = sin(degToRad(a)) * distance;
      return copy(
        x: x + xOffset,
        y: y + yOffset,
      );
    } else if (bearing <= 270.0) {
      final a = 270.0 - bearing;
      final xOffset = cos(degToRad(a)) * distance;
      final yOffset = sin(degToRad(a)) * distance;
      return copy(
        x: x - xOffset,
        y: y + yOffset,
      );
    } else {
      final a = bearing - 270.0;
      final xOffset = cos(degToRad(a)) * distance;
      final yOffset = sin(degToRad(a)) * distance;
      return copy(
        x: x - xOffset,
        y: y - yOffset,
      );
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

Position lerpPosition(Position begin, Position end, double t) {
  return Position(
    lerpDouble(begin.x, end.x, t),
    lerpDouble(begin.y, end.y, t),
    begin.bearingTo(end),
  );
}
