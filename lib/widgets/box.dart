import 'package:abacus/widgets/settings.dart';
import 'package:flutter/material.dart';

import '../util.dart';
import 'counter.dart';

class CounterBox extends StatefulWidget {
  const CounterBox({
    super.key,
    required this.parent,
    required this.unicode,
    this.onSelect,
    required this.forceUpdate,
  });

  final Counter parent;
  final Unicodes unicode;
  final Function()? onSelect;
  final Function() forceUpdate;

  @override
  State<CounterBox> createState() => _CounterBoxState();
}

class _CounterBoxState extends State<CounterBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _animation = _controller.drive(Tween(
      begin: 0.0,
      end: -3.0,
    ).chain(
      CurveTween(
        curve: Curves.easeInOutExpo,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    var selected = widget.parent.counter.selected == widget.unicode;
    var boxColor = widget.unicode.color ?? getTextStyle(context)?.color;

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: () {
          setState(() {
            widget.onSelect!();

            widget.parent.counter.selected =
                selected ? Unicodes.life : widget.unicode;
          });
        },
        onLongPress: () {
          _controller.reset();
          _controller.forward();

          setState(() {
            widget.parent.counter.set(
              value: widget.unicode == Unicodes.life
                  ? Settings.get<int>(SettingsKey.starting)
                  : 0,
              key: widget.unicode,
            );
          });

          widget.forceUpdate();
        },
        child: Container(
          width: 100,
          height: 100,
          color: boxColor?.withAlpha(50),
          child: Center(
            child: RotationTransition(
              turns: _animation,
              child: Text(
                selected ? '\ue61b' : widget.unicode.code,
                style: TextStyle(
                  fontFamily: 'Mana',
                  color: boxColor,
                  fontSize: 35,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
