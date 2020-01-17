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

/// Finds the counter clockwise angle between two vectors.
///
/// The first vector goes from [origin] to [v1Point].
/// The second vector goes from [origin] to [v2Point].
double ccwVectorsAngle(
  Point<double> origin,
  Point<double> v1Point,
  Point<double> v2Point,
) {
  final v1 = v1Point - origin;
  final v2 = v2Point - origin;
  final v1Mag = sqrt(pow(v1.x, 2) + pow(v1.y, 2));
  final v2Mag = sqrt(pow(v2.x, 2) + pow(v2.y, 2));
  final dotProduct = v1.x * v2.x + v1.y * v2.y;
  final crossProductZ = v1.x * v2.y - v2.x * v1.y;
  var angle = radToDeg(acos((dotProduct / (v1Mag * v2Mag)).clamp(-1.0, 1.0)));
  return crossProductZ < 0.0 || angle == 0.0 ? angle : 360.0 - angle;
}

final random = Random();
