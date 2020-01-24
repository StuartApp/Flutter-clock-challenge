// Copyright 2020 Stuart Delivery Limited. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_clock_helper/model.dart';

class Ground extends StatefulWidget {
  final Widget child;

  final WeatherCondition weatherCondition;

  final bool isDarkMode;

  const Ground({
    Key key,
    @required this.child,
    @required this.weatherCondition,
    @required this.isDarkMode,
  }) : super(key: key);

  @override
  _GroundState createState() => _GroundState();
}

class _GroundState extends State<Ground> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage(_getBackgroundImage()),
            ),
          ),
          child: widget.child,
        );
      },
    );
  }

  String _getBackgroundImage() {
    if (widget.isDarkMode) {
      return 'assets/bg_dark.png';
    }

    switch (widget.weatherCondition) {
      case WeatherCondition.cloudy:
        return 'assets/bg_sunny.png';
      case WeatherCondition.foggy:
        return 'assets/bg_foggy.png';
      case WeatherCondition.rainy:
        return 'assets/bg_rainy.png';
      case WeatherCondition.snowy:
        return 'assets/bg_snowy.png';
      case WeatherCondition.sunny:
        return 'assets/bg_sunny.png';
      case WeatherCondition.thunderstorm:
        return 'assets/bg_thunderstorm.png';
      case WeatherCondition.windy:
        return 'assets/bg_windy.png';
    }
    throw ArgumentError.value(widget.weatherCondition);
  }
}
