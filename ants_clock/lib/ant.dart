import 'package:flutter/cupertino.dart';

class Ant {
  // TODO Use Point instead?
  double x;

  double y;

  double angle;

  double targetX;

  double targetY;

  Ant({
    @required this.x,
    @required this.y,
    @required this.targetX,
    @required this.targetY,
  });
}
