import 'package:flutter/material.dart';
import 'package:flutter_clock_helper/model.dart';

import 'leaf.dart';

class WindyLeaves extends StatefulWidget {
  final WeatherCondition weatherCondition;

  const WindyLeaves({
    Key key,
    @required this.weatherCondition,
  }) : super(key: key);

  @override
  _WindyLeavesState createState() => _WindyLeavesState();
}

class _WindyLeavesState extends State<WindyLeaves> {
  @override
  Widget build(BuildContext context) {
    if (widget.weatherCondition == WeatherCondition.windy) {
      return LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: _buildLeaves(constraints),
          );
        },
      );
    } else {
      return Container();
    }
  }

  List<Widget> _buildLeaves(BoxConstraints constraints) {
    return _leavesPositions.map((leafPosition) {
      return Positioned(
        left: constraints.maxWidth * leafPosition.x,
        top: constraints.maxHeight * leafPosition.y,
        child: Leaf(
          side: leafPosition.side,
          assetNumber: leafPosition.assetNumber,
          parentWidth: constraints.maxWidth,
          parentHeight: constraints.maxHeight,
        ),
      );
    }).toList();
  }
}

const List<_LeafPosition> _leavesPositions = [
  _LeafPosition(0.12, 0.0, Side.top, 1),
  _LeafPosition(0.24, 0.0, Side.top, 2),
  _LeafPosition(0.37, 0.0, Side.top, 3),
  _LeafPosition(0.59, 0.0, Side.top, 4),
  _LeafPosition(0.73, 0.0, Side.top, 5),
];

class _LeafPosition {
  final double x;
  final double y;
  final Side side;
  final int assetNumber;

  const _LeafPosition(this.x, this.y, this.side, this.assetNumber);
}
