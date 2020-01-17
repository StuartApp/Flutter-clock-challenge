import 'package:ants_clock/colony_controller.dart';
import 'package:ants_clock/math_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'ant.dart';

class Colony extends StatefulWidget {
  final int hour;

  final int minute;

  const Colony({
    Key key,
    @required this.hour,
    @required this.minute,
  }) : super(key: key);

  @override
  _ColonyState createState() => _ColonyState();
}

class _ColonyState extends State<Colony> with SingleTickerProviderStateMixin {
  Ticker _ticker;

  ColonyController _colonyController;

  @override
  void initState() {
    super.initState();

    _ticker = createTicker((elapsed) {
      setState(() {
        _colonyController?.tick(elapsed);
      });
    });

    _ticker.start();
  }

  @override
  void didUpdateWidget(Colony oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.hour != oldWidget.hour || widget.minute != oldWidget.minute) {
      _colonyController?.setTime(widget.hour, widget.minute);
    }
  }

  @override
  void dispose() {
    _ticker?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, boxConstraints) {
        if (_colonyController == null ||
            _colonyController.worldWidth != boxConstraints.maxWidth ||
            _colonyController.worldHeight != boxConstraints.maxHeight) {
          _colonyController = ColonyController(
            boxConstraints.maxWidth,
            boxConstraints.maxHeight,
            widget.hour,
            widget.minute,
          );
        }

        final widgets = <Widget>[];

        widgets.add(CustomPaint(
          painter: _BoundingShapePainter(_colonyController),
        ));

        for (var ant in _colonyController.ants) {
          widgets.add(Positioned(
            child: Transform(
              transform: Matrix4.rotationZ(degToRad(ant.position.bearing)),
              origin: Offset(Ant.halfSize, Ant.halfSize),
              child: Image.asset(
                ant.frame == 0 ? 'assets/ant1.png' : 'assets/ant2.png',
                width: Ant.size,
                height: Ant.size,
              ),
            ),
            top: ant.position.y - Ant.halfSize,
            left: ant.position.x - Ant.halfSize,
          ));
        }

        return Stack(
          children: widgets,
        );
      },
    );
  }
}

class _BoundingShapePainter extends CustomPainter {
  final ColonyController _colonyController;

  _BoundingShapePainter(this._colonyController);

  final _paint = Paint()
    ..strokeWidth = 2.0
    ..color = Colors.red
    ..style = PaintingStyle.stroke;

  @override
  void paint(Canvas canvas, Size size) {
    for (var segment in _colonyController.segments) {
      final begin = Offset(segment.begin.x, segment.begin.y);
      final end = Offset(segment.end.x, segment.end.y);
      canvas.drawLine(begin, end, _paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
