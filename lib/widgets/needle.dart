import 'package:flutter/material.dart';
import 'dart:math' as math;

class NeedleWidget extends StatelessWidget {
  const NeedleWidget({super.key, this.color = Colors.white});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: CustomPaint(
        painter: _NeedlePainter(color),
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

    canvas.drawPath(path, _paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class MyTween extends Tween<double> {
  final double result;
  final double m;
  final double p;
  final double offset;

  MyTween({
    required this.m,
    required this.p,
    this.result = 0,
    this.offset = 0,
  }) : super(end: result + offset, begin: offset) {
    assert(result >= 0);
    assert(m > 0 && m < 1);
    assert(p > 0 && (5 * p) % 1 == 0);
  }

  @override // https://desmos.com/calculator/rygujepgvi
  double lerp(double t) {
    double v;

    if (t < m) {
      v = p * t / (1 - m + p * m);
    } else {
      var a = math.pow(m - 1, 1 - p) / (1 - m + p * m);
      v = a * math.pow(t - 1, p) + 1;
    }

    return v * result + offset;
  }
}
