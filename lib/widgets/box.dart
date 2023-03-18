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
    required this.size,
  });

  final Counter parent;
  final Unicodes unicode;
  final Size size;
  final Function()? onSelect;
  final Function() forceUpdate;

  @override
  State<CounterBox> createState() => _CounterBoxState();
}

class _CounterBoxState extends State<CounterBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  RelativeRect _pointer = RelativeRect.fill;

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

  void _clear() {
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
  }

  void _openMenu() {
    var isPinned = widget.parent.counter.isPinned(widget.unicode);

    showMenu(
      context: context,
      position: _pointer,
      items: [
        PopupMenuItem(
          onTap: _clear,
          child: const ListTile(
            leading: Icon(Icons.delete_forever_rounded),
            title: Text('Reset'),
          ),
        ),
        PopupMenuItem(
          onTap: () {
            widget.parent.counter.togglePin(widget.unicode);
            widget.forceUpdate();
          },
          child: ListTile(
            leading: Icon(
              isPinned ? Icons.close_rounded : Icons.push_pin_rounded,
            ),
            title: Text(isPinned ? 'Unpin' : 'Pin'),
          ),
        ),
      ],
    );
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
        onTapDown: (details) {
          var x = details.globalPosition.dx;
          var y = details.globalPosition.dy;
          _pointer = RelativeRect.fromLTRB(x, y, x, y);
        },
        onLongPress: _openMenu,
        child: Container(
          width: widget.size.width,
          height: widget.size.height,
          color: boxColor?.withAlpha(50),
          child: Center(
            child: RotationTransition(
              turns: _animation,
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
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
        ),
      ),
    );
  }
}
