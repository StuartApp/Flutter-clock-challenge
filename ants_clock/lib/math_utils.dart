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

final random = Random();
