// Copyright 2020 Stuart Delivery Limited. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

class Cloud extends StatefulWidget {
  final int assetNumber;
  final BoxConstraints constraints;

  const Cloud({Key key, this.assetNumber, this.constraints}) : super(key: key);

  @override
  _CloudState createState() => _CloudState();
}

class _CloudState extends State<Cloud> with SingleTickerProviderStateMixin {
  AnimationController _animationController;

  Animation<double> _animation;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 4000 * widget.assetNumber * 2),
    );

    var movingForward = true;

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (movingForward) {
          _animation = _createAnimation(false);
          _animationController.forward(from: 0.0);
          movingForward = false;
        } else {
          _animation = _createAnimation(true);
          _animationController.forward(from: 0.0);
          movingForward = true;
        }
      }
    });

    _animation = _createAnimation(true);
    _animationController.forward();

    super.initState();
  }

  double _initialY() {
    switch (widget.assetNumber) {
      case 1:
        return 0;
        break;
      case 2:
        return 0 - widget.constraints.maxHeight / 3.0;
        break;
      case 3:
        return widget.constraints.maxHeight / 3.0;
        break;
      case 4:
        return (widget.constraints.maxHeight / 3.0) * 2.0;
        break;
      default:
        return 0;
        break;
    }
  }

  Animation<double> _createAnimation(bool forward) {
    double endX = widget.constraints.maxWidth * (1  + widget.assetNumber/10.0);
    if (forward) {
      return Tween(
        begin: _animation?.value ?? 0 - endX,
        end: endX,
      ).chain(CurveTween(curve: Curves.easeOut)).animate(_animationController);
    } else {
      return Tween(
        begin: _animation?.value ?? 0.0,
        end: 0 - endX,
      ).chain(CurveTween(curve: Curves.easeOut)).animate(_animationController);
    }
  }

  @override
  Widget build(BuildContext context) {

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform(
          transform: Matrix4.translationValues(_animation.value, _initialY(), 0),
          origin: Offset(100.0 * widget.assetNumber, _initialY()),
          child: child,
        );
      },
      child: Image.asset(_getFilename(widget.assetNumber)),
    );
  }

  String _getFilename(int num) {
    return "assets/cloud_$num.png";
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }
}
