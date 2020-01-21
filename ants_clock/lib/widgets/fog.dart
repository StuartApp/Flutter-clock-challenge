import 'package:flutter/material.dart';
import 'package:flutter_clock_helper/model.dart';

import '../math_utils.dart';

class Fog extends StatefulWidget {
  final WeatherCondition weatherCondition;

  final bool isDarkMode;

  const Fog({
    Key key,
    @required this.weatherCondition,
    @required this.isDarkMode,
  }) : super(key: key);

  @override
  _FogState createState() => _FogState();
}

class _FogState extends State<Fog> with SingleTickerProviderStateMixin {
  static const _slideRange = 0.10;

  static const _slideDuration = 5000;

  AnimationController _animationController;

  Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: _slideDuration),
    );

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animation = _createAnimation();
        _animationController.forward(from: 0.0);
      }
    });

    _animation = _createAnimation();

    if (_isActive()) {
      _animationController.forward();
    }
  }

  Animation<Offset> _createAnimation() {
    return Tween<Offset>(
      begin: _animation?.value ?? Offset.zero,
      end: Offset(
        randomDouble(-_slideRange, _slideRange),
        randomDouble(-_slideRange, _slideRange),
      ),
    ).chain(CurveTween(curve: Curves.easeInOut)).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(Fog oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.weatherCondition != oldWidget.weatherCondition ||
        widget.isDarkMode != oldWidget.isDarkMode) {
      if (_isActive()) {
        _animationController.forward();
      } else {
        _animationController.reset();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isActive()) {
      return AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Center(
            child: SlideTransition(
              position: _animation,
              child: child,
            ),
          );
        },
        child: Image.asset('assets/fog.png'),
      );
    } else {
      return Container();
    }
  }

  bool _isActive() {
    return widget.weatherCondition == WeatherCondition.foggy &&
        !widget.isDarkMode;
  }
}
