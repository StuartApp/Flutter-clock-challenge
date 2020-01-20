import 'package:flutter/material.dart';

class Cloud extends StatefulWidget {
  final int assetNumber;

  const Cloud({Key key, this.assetNumber}) : super(key: key);

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
      duration: Duration(milliseconds: 10000 * widget.assetNumber),
    );

    var movingForward = true;

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (movingForward) {
          _animation = _createAnimation(false);
          _animationController.duration = Duration(milliseconds: 10000 * widget.assetNumber);
          _animationController.forward(from: 0.0);
          movingForward = false;
        } else {
          _animation = _createAnimation(true);
          _animationController.duration = Duration(milliseconds: 10000 * widget.assetNumber);
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
        return -50;
        break;
      case 3:
        return 100;
        break;
      case 4:
        return 150;
        break;
      default:
        return 0;
        break;
    }
  }

  Animation<double> _createAnimation(bool forward) {
    double endX = (800.0 * widget.assetNumber) / 4;
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
          origin: Offset(100, (widget.assetNumber * 50).toDouble()),
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
