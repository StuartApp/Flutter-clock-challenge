import 'package:flutter/material.dart';
import 'package:flutter_clock_helper/model.dart';

class Ground extends StatefulWidget {
  final Widget child;
  final WeatherCondition weatherCondition;

  const Ground({
    Key key,
    @required this.child,
    @required this.weatherCondition,
  }) : super(key: key);

  @override
  _GroundState createState() => _GroundState();
}

class _GroundState extends State<Ground> with SingleTickerProviderStateMixin {
  static const _leafSize = 50.0;

  AnimationController _windyController;

  @override
  void initState() {
    super.initState();
    _windyController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _stopLeafAnimation();
  }

  @override
  Widget build(BuildContext context) {
    _stopLeafAnimation();

    switch (widget.weatherCondition) {
      case WeatherCondition.windy:
        // animate to right:
        _windyController.animateTo(1.0);
        break;
      default:
        break;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage(_getBackgroundImage()),
            ),
          ),
          child: Stack(
              children: []
                ..addAll(_flyingLeaves(constraints))
                ..add(widget.child)),
        );
      },
    );
  }

  List<Widget> _flyingLeaves(BoxConstraints constraints) {
    return []..add(AnimatedBuilder(
        builder: (context, widget) {
          // right leave should travel to left
          return Positioned(
              top: constraints.maxHeight * _windyController.value - _leafSize,
              left: constraints.maxWidth * _windyController.value - _leafSize,
              child: _leaf('assets/leaf_right_1.png'));
        },
        animation: _windyController,
      ));
  }

  Widget _leaf(String assetName) {
    return Container(
      height: _leafSize,
      width: _leafSize,
      child: Image(
        image: AssetImage(
          assetName,
        ),
      ),
    );
  }

  String _getBackgroundImage() {
    switch (widget.weatherCondition) {
      case WeatherCondition.cloudy:
        return 'assets/bg_sunny.png';
      case WeatherCondition.foggy:
        return 'assets/bg_sunny.png';
      case WeatherCondition.rainy:
        return 'assets/bg_sunny.png';
      case WeatherCondition.snowy:
        return 'assets/bg_sunny.png';
      case WeatherCondition.sunny:
        return 'assets/bg_sunny.png';
      case WeatherCondition.thunderstorm:
        return 'assets/bg_sunny.png';
      case WeatherCondition.windy:
        return 'assets/bg_windy.png';
      default:
        return 'assets/bg_sunny.png';
    }
  }

  void _stopLeafAnimation() {}
}
