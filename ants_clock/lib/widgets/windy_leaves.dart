import 'package:flutter/material.dart';
import 'package:flutter_clock_helper/model.dart';

import 'leaf.dart';

class WindyLeaves extends StatefulWidget {
  final WeatherCondition weatherCondition;

  final bool isDarkMode;

  const WindyLeaves({
    Key key,
    @required this.weatherCondition,
    @required this.isDarkMode,
  }) : super(key: key);

  @override
  _WindyLeavesState createState() => _WindyLeavesState();
}

class _WindyLeavesState extends State<WindyLeaves> {
  @override
  Widget build(BuildContext context) {
    if (widget.weatherCondition == WeatherCondition.windy &&
        !widget.isDarkMode) {
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
      final leaf = Leaf(
        side: leafPosition.side,
        assetNumber: leafPosition.assetNumber,
        parentWidth: constraints.maxWidth,
        parentHeight: constraints.maxHeight,
      );

      switch (leafPosition.side) {
        case Side.top:
          return Positioned(
            left: constraints.maxWidth * leafPosition.position,
            top: 0.0,
            child: leaf,
          );
        case Side.bottom:
          return Positioned(
            left: constraints.maxWidth * leafPosition.position,
            bottom: 0.0,
            child: leaf,
          );
        case Side.left:
          return Positioned(
            left: 0.0,
            top: constraints.maxHeight * leafPosition.position,
            child: leaf,
          );
        case Side.right:
          return Positioned(
            right: 0.0,
            top: constraints.maxHeight * leafPosition.position,
            child: leaf,
          );
      }
      throw ArgumentError.value(leafPosition.side);
    }).toList();
  }
}

const List<_LeafPosition> _leavesPositions = [
  _LeafPosition(0.12, Side.top, 1),
  _LeafPosition(0.24, Side.top, 2),
  _LeafPosition(0.37, Side.top, 3),
  _LeafPosition(0.59, Side.top, 4),
  _LeafPosition(0.73, Side.top, 5),
  _LeafPosition(0.08, Side.bottom, 1),
  _LeafPosition(0.25, Side.bottom, 2),
  _LeafPosition(0.53, Side.bottom, 3),
  _LeafPosition(0.74, Side.bottom, 4),
  _LeafPosition(0.89, Side.bottom, 5),
  _LeafPosition(0.24, Side.left, 1),
  _LeafPosition(0.55, Side.left, 2),
  _LeafPosition(0.02, Side.right, 1),
  _LeafPosition(0.20, Side.right, 2),
  _LeafPosition(0.37, Side.right, 3),
];

class _LeafPosition {
  final double position;
  final Side side;
  final int assetNumber;

  const _LeafPosition(this.position, this.side, this.assetNumber);
}
