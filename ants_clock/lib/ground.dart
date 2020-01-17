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
  AnimationController _windyController;
  var _leafSize = 50.0;

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
      case WeatherCondition.cloudy:
        // TODO: Handle this case.
        break;
      case WeatherCondition.foggy:
        // TODO: Handle this case.
        break;
      case WeatherCondition.rainy:
        // TODO: Handle this case.
        break;
      case WeatherCondition.snowy:
        // TODO: Handle this case.
        break;
      case WeatherCondition.sunny:
        // TODO: Handle this case.
        break;
      case WeatherCondition.thunderstorm:
        // TODO: Handle this case.
        break;
      case WeatherCondition.windy:
        // animate to right:
        _windyController.animateTo(1.0);
        break;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage('assets/bg_with_leaves.png'),
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

  void _stopLeafAnimation() {}
}
