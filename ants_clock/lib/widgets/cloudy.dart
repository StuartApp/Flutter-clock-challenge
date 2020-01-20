import 'package:flutter/material.dart';
import 'package:flutter_clock_helper/model.dart';

import 'cloud.dart';

class Cloudy extends StatefulWidget {
  final WeatherCondition weatherCondition;

  const Cloudy({Key key, this.weatherCondition}) : super(key: key);

  @override
  _CloudyState createState() => _CloudyState();
}

class _CloudyState extends State<Cloudy> {
  @override
  Widget build(BuildContext context) {
    if (widget.weatherCondition == WeatherCondition.cloudy) {
      return Stack(children: [
        Cloud(assetNumber: 1),
        Cloud(assetNumber: 2),
        Cloud(assetNumber: 3),
        Cloud(assetNumber: 4),
      ]);
    } else {
      return Container();
    }
  }


}
