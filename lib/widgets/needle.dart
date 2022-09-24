import 'package:flutter/material.dart';
import 'dart:math' as math;

class NeedleWidget extends StatefulWidget {
  const NeedleWidget({super.key});

  @override
  State<StatefulWidget> createState() => _NeedleState();

  void start() {}
}

class _NeedleState extends State<NeedleWidget>
    with SingleTickerProviderStateMixin {
  late Animation<double> _animation;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this);
    var tween = Tween<double>(begin: -math.pi, end: math.pi);
    _animation = tween.animate(_controller)
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: CustomPaint(
        painter: _NeedlePainter(),
      ),
    );
  }
}

class _NeedlePainter extends CustomPainter {
  double _angle = 0.0, _velocity = 0.0, _acceleration = 0.0;
  bool get isSpinning => _velocity > 0;

  void start() {
    _velocity = 1;
  }

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

    canvas.save();
    canvas.translate(dx, dy);
    canvas.rotate(_angle);
    canvas.translate(-dx, -dy);
    canvas.drawPath(path, Paint()..color = Colors.white);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
