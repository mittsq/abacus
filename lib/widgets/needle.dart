import 'package:flutter/material.dart';
import 'dart:math' as math;

class NeedleWidget extends StatefulWidget {
  const NeedleWidget({super.key, this.color = Colors.white});

  final Color color;

  @override
  State<StatefulWidget> createState() => _NeedleState();
}

class _NeedleState extends State<NeedleWidget> {
  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: CustomPaint(
        painter: _NeedlePainter(widget.color),
      ),
    );
  }
}

class _NeedlePainter extends CustomPainter {
  final Paint _paint;
  _NeedlePainter(Color color) : _paint = Paint()..color = color;

  @override
  void paint(Canvas canvas, Size size) {
    var dx = size.width / 2;
    var dy = size.height / 2;

    var path = Path()
      ..moveTo(dx - 5, dy - 40) // center
      ..lineTo(dx, 1.15 * dy - math.min(dx, dy)) // top
      ..lineTo(dx + 5, dy - 40) // center
      ..arcTo(
        Rect.fromCenter(
          center: Offset(dx, dy - 40),
          width: 10,
          height: 10,
        ),
        0,
        math.pi,
        true,
      );

    // canvas.save();
    // canvas.translate(dx, dy);
    // canvas.rotate(_angle);
    // canvas.translate(-dx, -dy);
    canvas.drawPath(path, _paint);
    // canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class MyTween extends Tween<double> {
  final double result;
  final double m;
  final double offset;

  MyTween({
    required this.m,
    this.result = 0,
    this.offset = 0,
  }) : super(end: result + offset, begin: offset) {
    assert(result >= 0);
    assert(m > 0 && m < 1);
  }

  @override
  double lerp(double t) {
    var v = (3 * t) / (2 * m + 1);
    if (t > m) {
      v = (t * t * t - 3 * t * t + 3 * t + 2 * m * m * m - 3 * m * m) /
          (2 * math.pow(m, 3) - 3 * math.pow(m, 2) + 1);
    }
    return v * result + offset;
  }
}
