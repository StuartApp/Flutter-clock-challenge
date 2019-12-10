import 'package:ants_clock/colony_controller.dart';
import 'package:ants_clock/math_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class Colony extends StatefulWidget {
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
  void dispose() {
    _ticker?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, boxConstraints) {
        if (_colonyController == null ||
            _colonyController.width != boxConstraints.maxWidth ||
            _colonyController.height != boxConstraints.maxHeight) {
          _colonyController = ColonyController(
            boxConstraints.maxWidth,
            boxConstraints.maxHeight,
          );
        }

        return Stack(
          children: <Widget>[
            Positioned(
              child: Transform(
                transform: Matrix4.rotationZ(
                    degToRad(_colonyController.ant.position.bearing)),
                origin: Offset(12.0, 12.0),
                child: Icon(Icons.accessibility),
              ),
              top: _colonyController.ant.position.y,
              left: _colonyController.ant.position.x,
            )
          ],
        );
      },
    );
  }
}
