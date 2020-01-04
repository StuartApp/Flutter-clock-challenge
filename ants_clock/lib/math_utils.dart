import 'dart:math';

double radToDeg(double rad) {
  return rad * (180.0 / pi);
}

double degToRad(double deg) {
  return deg * (pi / 180.0);
}

double normalizeAngle(double angle) {
  if (angle > 360.0) {
    return angle - 360.0;
  } else if (angle < 0.0) {
    return 360.0 + angle;
  } else {
    return angle;
  }
}

Point<double> rotatePoint(
    Point<double> point, Point<double> origin, double angle) {
  final rad = degToRad(angle);
  final cosRad = cos(rad);
  final sinRad = sin(rad);

  final translated = point - origin;
  final rotated = Point(
    translated.x * cosRad - translated.y * sinRad,
    translated.x * sinRad + translated.y * cosRad,
  );

  return rotated + origin;
}

final random = Random();
