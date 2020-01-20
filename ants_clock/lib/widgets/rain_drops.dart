import 'dart:async';

import 'package:ants_clock/math_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_clock_helper/model.dart';

class RainDrops extends StatefulWidget {
  final WeatherCondition weatherCondition;

  const RainDrops({Key key, this.weatherCondition}) : super(key: key);

  @override
  _RainDropsState createState() => _RainDropsState();
}

class _RainDropsState extends State<RainDrops> {
  static const rainyRainDropInterval = 100;
  static const thunderstormRainDropInterval = 25;

  final List<_RainDropPosition> _rainDropPositions = [];

  int _rainDropInterval;

  Timer _timer;

  double _width;

  double _height;

  @override
  void initState() {
    super.initState();
    _rainDropInterval = _getRainDropInterval();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(RainDrops oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.weatherCondition != oldWidget.weatherCondition) {
      _rainDropInterval = _getRainDropInterval();

      _timer?.cancel();

      _width = null;
      _height = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final weather = widget.weatherCondition;
    if (weather != WeatherCondition.rainy &&
        weather != WeatherCondition.thunderstorm) {
      return Container();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        _initTimer(constraints);

        return Stack(
          children: _buildRainDrops(),
        );
      },
    );
  }

  void _initTimer(BoxConstraints constraints) {
    if (_width == constraints.maxWidth && _height == constraints.maxHeight)
      return;

    _width = constraints.maxWidth;
    _height = constraints.maxHeight;

    _rainDropPositions.clear();
    _timer?.cancel();
    _timer = Timer.periodic(Duration(milliseconds: _rainDropInterval), (timer) {
      setState(() {
        final rainDropKey = GlobalKey<_RainDropState>();

        final _RainDropPosition rainDropPosition = _RainDropPosition(
          randomDouble(0.0, _width - _RainDropState.rainDropSize),
          randomDouble(0.0, _height - _RainDropState.rainDropSize),
          _RainDrop(key: rainDropKey),
          rainDropKey,
        );

        _rainDropPositions.removeWhere((position) {
          return position.rainDropKey.currentState?.isCompleted ?? true;
        });

        _rainDropPositions.add(rainDropPosition);
      });
    });
  }

  List<Widget> _buildRainDrops() {
    return _rainDropPositions.map((rainDropPosition) {
      return Positioned(
        child: rainDropPosition.rainDrop,
        left: rainDropPosition.left,
        top: rainDropPosition.top,
      );
    }).toList();
  }

  int _getRainDropInterval() {
    return widget.weatherCondition == WeatherCondition.rainy
        ? rainyRainDropInterval
        : thunderstormRainDropInterval;
  }
}

class _RainDropPosition {
  final double left;
  final double top;
  final _RainDrop rainDrop;
  final GlobalKey<_RainDropState> rainDropKey;

  _RainDropPosition(this.left, this.top, this.rainDrop, this.rainDropKey);
}

class _RainDrop extends StatefulWidget {
  const _RainDrop({Key key}) : super(key: key);

  @override
  _RainDropState createState() => _RainDropState();
}

class _RainDropState extends State<_RainDrop>
    with SingleTickerProviderStateMixin {
  static const rainDropSize = 35.0;

  AnimationController _controller;

  bool get isCompleted => _controller.status == AnimationStatus.completed;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _CustomPainter(_controller.value),
          size: Size(rainDropSize, rainDropSize),
        );
      },
    );
  }
}

class _CustomPainter extends CustomPainter {
  static const Color _color = Color.fromRGBO(34, 144, 156, 1.0);

  static const double _beginOpacity = 0.5;

  final double t;

  final Paint _paintStroke = Paint()
    ..color = _color.withOpacity(1.0)
    ..strokeWidth = 1.0
    ..style = PaintingStyle.stroke;

  final Paint _paintFill = Paint()
    ..color = _color.withOpacity(0.10)
    ..style = PaintingStyle.fill;

  _CustomPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);

    _drawDropFalling(canvas, center);

    _drawDropRipple(canvas, center, size.shortestSide / 2.0, 0.25, 1.0);

    _drawDropRipple(canvas, center, size.shortestSide / 3.0, 0.5, 1.0);
  }

  void _drawDropFalling(Canvas canvas, Offset center) {
    final interval = CurveTween(curve: Interval(0.0, 0.25));
    final radius = Tween(begin: 5.0, end: 0.0).chain(interval);
    canvas.drawCircle(center, radius.transform(t), _paintFill);
  }

  void _drawDropRipple(
    Canvas canvas,
    Offset center,
    double size,
    double intervalBegin,
    double intervalEnd,
  ) {
    final interval = CurveTween(curve: Interval(intervalBegin, intervalEnd));
    final opacity = Tween(begin: _beginOpacity, end: 0.0).chain(interval);
    final radius = Tween(begin: 0.0, end: size).chain(interval);

    _paintStroke.color = _color.withOpacity(opacity.transform(t));
    canvas.drawCircle(center, radius.transform(t), _paintStroke);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return (oldDelegate as _CustomPainter).t != t;
  }
}
