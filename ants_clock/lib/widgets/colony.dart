import 'package:ants_clock/colony_controller.dart';
import 'package:ants_clock/math_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

import '../models/ant.dart';

class Colony extends StatefulWidget {
  final int hour;

  final int minute;

  final bool isDarkMode;

  const Colony({
    Key key,
    @required this.hour,
    @required this.minute,
    @required this.isDarkMode,
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
        // TODO Set state only if tick returns true
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
          String imageFilename;
          if (widget.isDarkMode) {
            imageFilename = ant.frame == 0
                ? 'assets/ant_dark_frame_1.png'
                : 'assets/ant_dark_frame_2.png';
          } else {
            imageFilename = ant.frame == 0
                ? 'assets/ant_frame_1.png'
                : 'assets/ant_frame_2.png';
          }

          widgets.add(Positioned(
            child: Transform(
              transform: Matrix4.rotationZ(degToRad(ant.position.bearing)),
              origin: Offset(Ant.halfSize, Ant.halfSize),
              child: Image.asset(
                imageFilename,
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
