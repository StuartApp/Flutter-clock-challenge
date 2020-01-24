// Copyright 2020 Stuart Delivery Limited. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

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

double randomDouble(double min, double max) {
  return (random.nextDouble() * (max - min)) + min;
}

int randomInt(int min, int max) {
  return random.nextInt(max - min) + min;
}

final random = Random();
