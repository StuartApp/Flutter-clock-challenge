import 'dart:async';

import 'package:ants_clock/math_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_clock_helper/model.dart';

class ThunderLightning extends StatefulWidget {
  final WeatherCondition weatherCondition;

  final bool isDarkMode;

  const ThunderLightning({
    Key key,
    @required this.weatherCondition,
    @required this.isDarkMode,
  }) : super(key: key);

  @override
  _ThunderLightningState createState() => _ThunderLightningState();
}

class _ThunderLightningState extends State<ThunderLightning>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;

  Timer _timer;

  Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _startTimer();
      }
    });

    _animation = Tween(begin: 0.0, end: 0.5)
        .chain(CurveTween(curve: Curves.bounceOut))
        .animate(_animationController);

    if (_isActive()) {
      _startTimer();
    }
  }

  void _startTimer() {
    _timer = Timer(Duration(seconds: randomInt(5, 10)), () {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(ThunderLightning oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.weatherCondition != oldWidget.weatherCondition ||
        widget.isDarkMode != oldWidget.isDarkMode) {
      if (_isActive()) {
        _startTimer();
      } else {
        _animationController.reset();
        _timer?.cancel();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isActive()) {
      return FadeTransition(
        opacity: _animation,
        child: Container(color: Colors.white),
      );
    } else {
      return Container();
    }
  }

  bool _isActive() {
    return widget.weatherCondition == WeatherCondition.thunderstorm &&
        !widget.isDarkMode;
  }
}
