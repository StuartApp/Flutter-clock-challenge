// Copyright 2020 Stuart Delivery Limited. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:ants_clock/models/position.dart';
import 'package:flutter/animation.dart';

import 'math_utils.dart';

abstract class PositionShifter {
  Position get position;

  bool get isFinished;

  factory PositionShifter(Position begin, Position end) {
    final bearing = begin.bearingTo(end);
    final beginRotated = begin.copy(bearing: bearing);
    final endRotated = end.copy(bearing: bearing);

    return _SequencePositionShifter([
      _TurnPositionShifter(begin, beginRotated),
      _WalkPositionShifter(beginRotated, endRotated),
      _TurnPositionShifter(endRotated, end)
    ]);
  }

  void shift(Duration elapsed);
}

class _WalkPositionShifter implements PositionShifter {
  _WalkPositionShifter(Position begin, Position end) {
    final distance = begin.distanceTo(end);
    if (distance > 0.0) {
      _duration = distance ~/ (_pixelsPerSecond / 1000);
    } else {
      _duration = 0;
      _isFinished = true;
    }

    _xAnimatable = _createAnimatable(begin.x, end.x);
    _yAnimatable = _createAnimatable(begin.y, end.y);

    _position = begin;
  }

  static const _pixelsPerSecond = 150;

  Duration _start;

  int _duration;

  Duration _lateralMovementStart;

  Animatable<double> _xAnimatable;

  Animatable<double> _yAnimatable;

  Position _position;

  bool _isFinished = false;

  _LateralStepper _lateralStepper = _LateralStepper();

  @override
  Position get position => _position;

  @override
  bool get isFinished => _isFinished;

  @override
  void shift(Duration elapsed) {
    _start ??= elapsed;
    _lateralMovementStart ??= elapsed;

    final elapsedSinceStart = (elapsed - _start).inMilliseconds;
    final t = (elapsedSinceStart / _duration).clamp(0.0, 1.0);

    _position = _lateralStepper.step(
      elapsed,
      Position(
        _xAnimatable.transform(t),
        _yAnimatable.transform(t),
        _position.bearing,
      ),
    );

    _isFinished = t == 1.0;
  }

  Animatable<double> _createAnimatable(double begin, double end) {
    return Tween(begin: begin, end: end)
        .chain(CurveTween(curve: const Cubic(0.10, 0.0, 0.90, 1.0)));
  }
}

class _LateralStepper {
  _LateralStepper() {
    _reset();
  }

  Duration _start;

  int _duration;

  Animatable<double> _animatable;

  Position step(Duration elapsed, Position position) {
    _start ??= elapsed;

    final elapsedSinceStart = (elapsed - _start).inMilliseconds;
    final t = (elapsedSinceStart / _duration).clamp(0.0, 1.0);

    var movedPosition = position.offset(
      _animatable.transform(t),
      normalizeAngle(position.bearing + 90.0),
    );

    if (elapsedSinceStart > _duration) _reset();

    return movedPosition;
  }

  void _reset() {
    _start = null;
    _duration = 50 + random.nextInt(50);
    _animatable = Tween(
      begin: _animatable?.transform(1.0) ?? 0.0,
      end: random.nextDouble() * 2.5 - 1.25,
    ).chain(CurveTween(curve: Curves.easeInOut));
  }
}

class _TurnPositionShifter implements PositionShifter {
  _TurnPositionShifter(Position begin, Position end) {
    final angle = _calcRotation(begin.bearing, end.bearing);

    if (angle != 0.0) {
      _duration = angle.abs() ~/ (_degreesPerSecond / 1000);
    } else {
      _duration = 0;
      _isFinished = true;
    }

    _bearingAnimatable = _createAnimatable(
      begin.bearing,
      begin.bearing + angle,
    );

    _position = begin;
  }

  static const _degreesPerSecond = 360;

  Duration _start;

  int _duration;

  Animatable<double> _bearingAnimatable;

  Position _position;

  bool _isFinished = false;

  @override
  Position get position => _position;

  @override
  bool get isFinished => _isFinished;

  @override
  void shift(Duration elapsed) {
    _start ??= elapsed;

    final elapsedSinceStart = (elapsed - _start).inMilliseconds;
    final t = (elapsedSinceStart / _duration).clamp(0.0, 1.0);

    _position = Position(
      _position.x,
      _position.y,
      normalizeAngle(_bearingAnimatable.transform(t)),
    );

    _isFinished = t == 1.0;
  }

  Animatable<double> _createAnimatable(double begin, double end) {
    return Tween(begin: begin, end: end)
        .chain(CurveTween(curve: Curves.easeInOut));
  }

  double _calcRotation(double begin, double end) {
    if (end >= begin) {
      final angle1 = end - begin;
      final angle2 = (360.0 - end) + begin;
      return angle1 <= angle2 ? angle1 : -angle2;
    } else {
      final angle1 = begin - end;
      final angle2 = (360.0 - begin) + end;
      return angle1 <= angle2 ? -angle1 : angle2;
    }
  }
}

class _SequencePositionShifter implements PositionShifter {
  _SequencePositionShifter(List<PositionShifter> shifters) {
    assert(shifters.isNotEmpty);
    _shifters.addAll(shifters);
  }

  final _shifters = <PositionShifter>[];

  var _currentShifterIndex = 0;

  PositionShifter get _currentShifter => _shifters[_currentShifterIndex];

  @override
  Position get position => _currentShifter.position;

  @override
  bool get isFinished =>
      _currentShifterIndex == _shifters.length - 1 &&
      _currentShifter.isFinished;

  @override
  void shift(Duration elapsed) {
    if (_currentShifter.isFinished &&
        _currentShifterIndex < _shifters.length - 1) {
      _currentShifterIndex++;
      _currentShifter.shift(elapsed);
    } else {
      _currentShifter.shift(elapsed);
    }
  }
}
