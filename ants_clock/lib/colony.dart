import 'package:ants_clock/colony_controller.dart';
import 'package:ants_clock/math_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

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

        for (var ant in _colonyController.ants) {
          widgets.add(Positioned(
            child: Transform(
              transform: Matrix4.rotationZ(degToRad(ant.position.bearing)),
              origin: Offset(9.0, 9.0),
              child: Icon(
                Icons.accessibility,
                size: 18.0,
              ),
            ),
            top: ant.position.y - 9.0,
            left: ant.position.x - 9.0,
          ));
        }

        return Stack(
          children: widgets,
        );
      },
    );
  }
}
