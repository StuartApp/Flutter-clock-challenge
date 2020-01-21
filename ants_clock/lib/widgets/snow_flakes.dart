import 'dart:async';

import 'package:ants_clock/math_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_clock_helper/model.dart';

class SnowFlakes extends StatefulWidget {
  final WeatherCondition weatherCondition;

  final bool isDarkMode;

  const SnowFlakes({
    Key key,
    @required this.weatherCondition,
    @required this.isDarkMode,
  }) : super(key: key);

  @override
  _SnowFlakesState createState() => _SnowFlakesState();
}

class _SnowFlakesState extends State<SnowFlakes> {
  static const _snowFlakesInterval = 400;

  static const _snowFlakesPerInterval = 2;

  final List<_SnowFlakePosition> _snowFlakePositions = [];

  Timer _timer;

  double _width;

  double _height;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(SnowFlakes oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.weatherCondition != oldWidget.weatherCondition ||
        widget.isDarkMode != oldWidget.isDarkMode) {
      _timer?.cancel();
      _width = null;
      _height = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.weatherCondition == WeatherCondition.snowy &&
        !widget.isDarkMode) {
      return LayoutBuilder(
        builder: (context, constraints) {
          _initTimer(constraints);
          return Stack(
            children: _buildSnowFlakes(),
          );
        },
      );
    } else {
      return Container();
    }
  }

  void _initTimer(BoxConstraints constraints) {
    if (_width == constraints.maxWidth && _height == constraints.maxHeight) {
      return;
    }

    _width = constraints.maxWidth;
    _height = constraints.maxHeight;

    _snowFlakePositions.clear();
    _timer?.cancel();
    _timer =
        Timer.periodic(Duration(milliseconds: _snowFlakesInterval), (timer) {
      setState(() {
        _snowFlakePositions.removeWhere((position) {
          return position.snowFlakeKey.currentState?.isCompleted ?? true;
        });

        for (var i = 0; i < _snowFlakesPerInterval; ++i) {
          final snowFlakeKey = GlobalKey<_SnowFlakeState>();

          final _SnowFlakePosition snowFlakePosition = _SnowFlakePosition(
            randomDouble(0.0, _width - _SnowFlakeState.snowFlakeSize),
            randomDouble(0.0, _height - _SnowFlakeState.snowFlakeSize),
            _SnowFlake(key: snowFlakeKey),
            snowFlakeKey,
          );

          _snowFlakePositions.add(snowFlakePosition);
        }
      });
    });
  }

  List<Widget> _buildSnowFlakes() {
    return _snowFlakePositions.map<Widget>((snowFlakePosition) {
      return Positioned(
        child: snowFlakePosition.snowFlake,
        left: snowFlakePosition.left,
        top: snowFlakePosition.top,
      );
    }).toList();
  }
}

class _SnowFlakePosition {
  final double left;
  final double top;
  final _SnowFlake snowFlake;
  final GlobalKey<_SnowFlakeState> snowFlakeKey;

  _SnowFlakePosition(this.left, this.top, this.snowFlake, this.snowFlakeKey);
}

class _SnowFlake extends StatefulWidget {
  const _SnowFlake({Key key}) : super(key: key);

  @override
  _SnowFlakeState createState() => _SnowFlakeState();
}

class _SnowFlakeState extends State<_SnowFlake>
    with SingleTickerProviderStateMixin {
  static const snowFlakeSize = 35.0;

  AnimationController _controller;

  bool get isCompleted => _controller.status == AnimationStatus.completed;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 5000),
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
          size: Size(snowFlakeSize, snowFlakeSize),
        );
      },
    );
  }
}

class _CustomPainter extends CustomPainter {
  static const Color _color = Colors.white;

  final double t;

  final Paint _paintFill = Paint()
    ..color = _color.withOpacity(0.5)
    ..style = PaintingStyle.fill;

  _CustomPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);

    _drawSnowFlakeFalling(
      canvas,
      0.0,
      0.25,
      5.0,
      2.5,
      center,
      Offset(size.width / 2.0, -2.5),
      Offset(-size.width / 2.0, 0.0),
    );

    _drawSnowFlakeFalling(
      canvas,
      0.25,
      0.6,
      2.5,
      1.0,
      center,
      Offset(-size.width / 2.0, 0.0),
      Offset(size.width / 4.0, 1.5),
    );

    _drawSnowFlakeFalling(
      canvas,
      0.6,
      1.0,
      1.5,
      0.0,
      center,
      Offset(size.width / 4.0, 1.5),
      Offset(0.0, 2.5),
    );
  }

  void _drawSnowFlakeFalling(
    Canvas canvas,
    double intervalBegin,
    double intervalEnd,
    double beginRadius,
    double endRadius,
    Offset center,
    Offset beginOffset,
    Offset endOffset,
  ) {
    if (t >= intervalBegin && t <= intervalEnd) {
      final interval = CurveTween(curve: Interval(intervalBegin, intervalEnd));
      final radius = Tween(begin: beginRadius, end: endRadius).chain(interval);
      final offset = Tween(begin: center + beginOffset, end: center + endOffset)
          .chain(CurveTween(curve: Curves.easeInOut))
          .chain(interval);
      canvas.drawCircle(offset.transform(t), radius.transform(t), _paintFill);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return (oldDelegate as _CustomPainter).t != t;
  }
}
