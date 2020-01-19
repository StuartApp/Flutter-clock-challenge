import 'package:ants_clock/math_utils.dart';
import 'package:flutter/material.dart';

class Leaf extends StatefulWidget {
  final Side side;

  final int assetNumber;

  final double parentWidth;

  final double parentHeight;

  const Leaf({
    Key key,
    @required this.side,
    @required this.assetNumber,
    @required this.parentWidth,
    @required this.parentHeight,
  }) : super(key: key);

  @override
  _LeafState createState() => _LeafState();
}

class _LeafState extends State<Leaf> with SingleTickerProviderStateMixin {
  AnimationController _animationController;

  Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2000),
    );

    var movingForward = true;

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (movingForward) {
          _animation = _createAnimation(false);
          _animationController.duration = Duration(milliseconds: 3000);
          _animationController.forward(from: 0.0);
          movingForward = false;
        } else {
          _animation = _createAnimation(true);
          _animationController.duration = Duration(milliseconds: 2000);
          _animationController.forward(from: 0.0);
          movingForward = true;
        }
      }
    });

    _animation = _createAnimation(true);
    _animationController.forward();
  }

  Animation<double> _createAnimation(bool forward) {
    if (forward) {
      double endAngle;
      switch (widget.side) {
        case Side.top:
          endAngle = 30.0 + random.nextDouble() * 15.0;
          break;
        case Side.bottom:
          endAngle = -30.0 + random.nextDouble() * 15.0;
          break;
        case Side.left:
          endAngle = -20.0 + random.nextDouble() * 10.0;
          break;
        case Side.right:
          endAngle = 5.0 + random.nextDouble() * 5.0;
          break;
      }
      return Tween(
        begin: _animation?.value ?? 0.0,
        end: endAngle,
      )
          .chain(CurveTween(curve: Curves.bounceInOut))
          .animate(_animationController);
    } else {
      return Tween(
        begin: _animation?.value ?? 0.0,
        end: 0.0,
      ).chain(CurveTween(curve: Curves.easeOut)).animate(_animationController);
    }
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asset = _getAsset();

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform(
          transform: Matrix4.rotationZ(degToRad(_animation.value)),
          origin: asset.getRotationOffset(
            widget.parentWidth,
            widget.parentHeight,
          ),
          child: child,
        );
      },
      child: Image.asset(
        asset.getFilename(),
        width: asset.getWidth(widget.parentWidth),
        height: asset.getHeight(widget.parentHeight),
        fit: BoxFit.contain,
      ),
    );
  }

  _Asset _getAsset() {
    return _assets.firstWhere((asset) {
      return asset.side == widget.side &&
          asset.assetNumber == widget.assetNumber;
    });
  }
}

enum Side { top, bottom, left, right }

final _sideFilenames = {
  Side.top: 'top',
  Side.bottom: 'bottom',
  Side.left: 'left',
  Side.right: 'right',
};

const _assets = [
  _Asset(
    side: Side.top,
    assetNumber: 1,
    width: 55.0,
    height: 114.0,
    rotationOrigin: Offset(24.0, 0.0),
  ),
  _Asset(
    side: Side.top,
    assetNumber: 2,
    width: 59.0,
    height: 96.0,
    rotationOrigin: Offset(43.0, 0.0),
  ),
  _Asset(
    side: Side.top,
    assetNumber: 3,
    width: 111.0,
    height: 94.0,
    rotationOrigin: Offset(41.0, 0.0),
  ),
  _Asset(
    side: Side.top,
    assetNumber: 4,
    width: 60.0,
    height: 106.0,
    rotationOrigin: Offset(41.0, 0.0),
  ),
  _Asset(
    side: Side.top,
    assetNumber: 5,
    width: 78.0,
    height: 106.0,
    rotationOrigin: Offset(68.0, 0.0),
  ),
  _Asset(
    side: Side.bottom,
    assetNumber: 1,
    width: 49.0,
    height: 102.0,
    rotationOrigin: Offset(39.0, 102.0),
  ),
  _Asset(
    side: Side.bottom,
    assetNumber: 2,
    width: 112.0,
    height: 87.0,
    rotationOrigin: Offset(64.0, 87.0),
  ),
  _Asset(
    side: Side.bottom,
    assetNumber: 3,
    width: 107.0,
    height: 135.0,
    rotationOrigin: Offset(8.0, 135.0),
  ),
  _Asset(
    side: Side.bottom,
    assetNumber: 4,
    width: 59.0,
    height: 105.0,
    rotationOrigin: Offset(20.0, 105.0),
  ),
  _Asset(
    side: Side.bottom,
    assetNumber: 5,
    width: 78.0,
    height: 106.0,
    rotationOrigin: Offset(40.0, 106.0),
  ),
  _Asset(
    side: Side.left,
    assetNumber: 1,
    width: 73.0,
    height: 94.0,
    rotationOrigin: Offset(0.0, 51.0),
  ),
  _Asset(
    side: Side.left,
    assetNumber: 2,
    width: 113.0,
    height: 97.0,
    rotationOrigin: Offset(0.0, 96.0),
  ),
  _Asset(
    side: Side.right,
    assetNumber: 1,
    width: 68.0,
    height: 69.0,
    rotationOrigin: Offset(68.0, 9.0),
  ),
  _Asset(
    side: Side.right,
    assetNumber: 2,
    width: 87.0,
    height: 36.0,
    rotationOrigin: Offset(87.0, 2.0),
  ),
  _Asset(
    side: Side.right,
    assetNumber: 3,
    width: 112.0,
    height: 64.0,
    rotationOrigin: Offset(112.0, 32.0),
  ),
];

class _Asset {
  final Side side;
  final int assetNumber;
  final double _width;
  final double _height;
  final Offset _rotationOrigin;

  const _Asset({
    @required this.side,
    @required this.assetNumber,
    @required double width,
    @required double height,
    @required Offset rotationOrigin,
  })  : _width = width,
        _height = height,
        _rotationOrigin = rotationOrigin;

  double getWidth(double parentWidth) => (_width / 800) * parentWidth;

  double getHeight(double parentHeight) => (_height / 480) * parentHeight;

  Offset getRotationOffset(double parentWidth, double parentHeight) {
    return Offset(
      (_rotationOrigin.dx / 800) * parentWidth,
      (_rotationOrigin.dy / 480) * parentHeight,
    );
  }

  String getFilename() {
    return 'assets/leaf'
        '_${_sideFilenames[side]}'
        '_$assetNumber.png';
  }
}
