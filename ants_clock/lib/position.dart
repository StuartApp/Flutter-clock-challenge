import 'dart:math';
import 'dart:ui';

import 'package:flutter/animation.dart';

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
          0.0,
        );

  double distanceTo(Position position) {
    var dx = x - position.x;
    var dy = y - position.y;
    return sqrt(dx * dx + dy * dy);
  }
}

abstract class PositionShift {
  Position get position;

  bool get isCompleted => true;

  factory PositionShift(Position begin, Position end) {
    return _WalkPositionShift(begin, end);
  }

  void update(Duration elapsed);
}

class _WalkPositionShift implements PositionShift {
  _WalkPositionShift(Position begin, Position end) {
    final distance = begin.distanceTo(end);
    _duration = distance ~/ (_pixelsPerSecond / 1000);

    _xAnimatable = _createAnimatable(begin.x, end.x);
    _yAnimatable = _createAnimatable(begin.y, end.y);

    _position = begin;
  }

  static const _pixelsPerSecond = 150;

  Duration _start;

  int _duration;

  Animatable<double> _xAnimatable;

  Animatable<double> _yAnimatable;

  Position _position;

  bool _isCompleted = false;

  @override
  Position get position => _position;

  @override
  bool get isCompleted => _isCompleted;

  @override
  void update(Duration elapsed) {
    _start ??= elapsed;

    final elapsedSinceStart = (elapsed - _start).inMilliseconds;
    final t = (elapsedSinceStart / _duration).clamp(0.0, 1.0);
    _position = Position(
      _xAnimatable.transform(t),
      _yAnimatable.transform(t),
      0.0,
    );
    _isCompleted = t == 1.0;
  }
}

class _SequencePositionShift {}

Animatable<double> _createAnimatable(double begin, double end) {
  return TweenSequence([
    TweenSequenceItem(
      tween: Tween(begin: begin, end: lerpDouble(begin, end, 0.2))
          .chain(CurveTween(curve: Curves.easeIn)),
      weight: 20.0,
    ),
    TweenSequenceItem(
      tween: Tween(
          begin: lerpDouble(begin, end, 0.2), end: lerpDouble(begin, end, 0.8)),
      weight: 80.0,
    ),
    TweenSequenceItem(
      tween: Tween(begin: lerpDouble(begin, end, 0.8), end: end)
          .chain(CurveTween(curve: Curves.easeOut)),
      weight: 20.0,
    ),
  ]);
}
