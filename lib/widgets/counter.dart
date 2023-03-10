import 'dart:async';
import 'dart:ui';

import 'package:abacus/model/count_wrapper.dart';
import 'package:abacus/util.dart';
import 'package:abacus/widgets/settings.dart';
import 'package:flutter/material.dart';
import 'package:loop_page_view/loop_page_view.dart';

class Counter extends StatefulWidget {
  const Counter({Key? key, required this.counter, this.isFlipped = false})
      : super(key: key);

  final CountWrapper counter;
  final bool isFlipped;

  @override
  State<StatefulWidget> createState() => _CounterState();
}

class _CounterState extends State<Counter> {
  late int _commitCount = widget.counter.getSelected();
  bool _commit = true;
  double? _offset;
  int? _oldCount;
  DateTime _lastUpdate = DateTime.fromMicrosecondsSinceEpoch(0);

  final LoopPageController _pageController = LoopPageController();

  int get _resistance => Settings.get('swipeSens', 35);

  @override
  void initState() {
    super.initState();

    widget.counter.listeners.add(_jump);
  }

  void _jump() {
    _pageController.animateToPage(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutExpo,
    );
  }

  void _increment({bool invert = false}) {
    setState(() {
      _setCount(widget.counter + (invert ? -1 : 1));
    });
  }

  void _dragStart(DragStartDetails args) {
    if (_offset != null) return;
    _offset = args.globalPosition.dy;
    _oldCount ??= widget.counter.getSelected();
  }

  void _dragUpdate(DragUpdateDetails args) {
    var delta = args.globalPosition.dy - _offset!;
    var ls = isLandscape(context);
    var newCount =
        _oldCount! - delta / _resistance * ((widget.isFlipped && !ls) ? -1 : 1);

    setState(() {
      _setCount(newCount.round());
    });
  }

  void _dragEnd(DragEndDetails args) {
    _offset = null;
    _oldCount = null;
  }

  void _setCount(int count) {
    setState(() {
      widget.counter.glow = false;
      if (_commit) _commitCount = widget.counter.getSelected();
      _commit = false;
      widget.counter.setSelected(count);
      _lastUpdate = DateTime.now();
    });
    var delay = const Duration(seconds: 3);
    Timer(
      delay,
      () {
        if (DateTime.now().difference(_lastUpdate) > delay) {
          setState(() {
            _commit = true;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var tabular = const [FontFeature.tabularFigures()];

    var countStyle = Theme.of(context).textTheme.displayLarge?.merge(
          TextStyle(
            fontFeatures: tabular,
            fontWeight: FontWeight.normal,
          ),
        );

    var miniStyle = Theme.of(context).textTheme.headlineSmall?.merge(
          TextStyle(
            color: countStyle?.color,
            fontFeatures: tabular,
          ),
        );

    var ls = isLandscape(context);

    String miniText;
    var diff = widget.counter - _commitCount;
    if (diff == 0) {
      miniText = ''; // '\u20070';
    } else if (diff > 0) {
      miniText = '+$diff';
    } else {
      miniText = '\u2212${diff.abs()}';
    }

    var duration = const Duration(milliseconds: 200);
    var color = const Color(0xFF141414);
    var max = Settings.get('starting', 20);
    var doColor = Settings.get('color', false);
    var border = color;
    var ratio = Curves.easeOutExpo.transform(
      (diff.abs() / max * 2).clamp(0, 1),
    );
    var radius = _commit ? 0.0 : 50.0 * ratio;
    if (doColor && !_commit) {
      border = Color.lerp(
        color,
        diff < 0 ? color.withRed(200) : color.withGreen(200),
        ratio,
      )!;
    }

    if (widget.counter.glow) {
      radius = 50.0;
      border = const Color.fromARGB(255, 200, 200, 200);
    }

    var rounded = const BorderRadius.all(Radius.circular(10));

    var main = Stack(
      children: [
        ClipRRect(
          borderRadius: rounded,
          child: AnimatedContainer(
            duration: _commit ? duration : duration ~/ 2,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(color: border),
                BoxShadow(
                  color: color,
                  spreadRadius: 0,
                  blurRadius: radius,
                )
              ],
            ),
            child: Center(
              child: Column(
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Text(
                        widget.counter.selected.code,
                        style: miniStyle?.copyWith(
                          fontFamily: 'Mana',
                          color: widget.counter.selected.color,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 175,
                    child: Center(
                      child: Text(
                        '${widget.counter.getSelected()}',
                        style: countStyle,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: AnimatedOpacity(
                        opacity: _commit ? 0 : 1,
                        duration: duration,
                        child: Text(
                          miniText,
                          style: miniStyle,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        GestureDetector(
          onVerticalDragStart: _dragStart,
          onVerticalDragUpdate: _dragUpdate,
          onVerticalDragEnd: _dragEnd,
          child: Column(
            children: [
              Expanded(
                child: Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    onTapDown: (details) =>
                        _increment(invert: widget.isFlipped && !ls),
                  ),
                ),
              ),
              Expanded(
                child: Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    onTapDown: (details) =>
                        _increment(invert: !(widget.isFlipped && !ls)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );

    Widget buildBox(Unicodes onTap) {
      var selected = widget.counter.selected == onTap;
      var icon = Text(
        onTap.code,
        style: TextStyle(
          fontFamily: 'Mana',
          color: onTap.color ?? countStyle?.color,
          fontSize: 35,
        ),
      );

      var ret = Icon(
        Icons.arrow_back_rounded,
        color: onTap.color ?? countStyle?.color,
        size: 35,
      );

      return Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: () {
            setState(() {
              _commit = true;
              widget.counter.selected = selected ? Unicodes.life : onTap;
              _jump();
            });
          },
          child: Container(
            width: 100,
            height: 100,
            color:
                onTap.color?.withAlpha(50) ?? countStyle?.color?.withAlpha(50),
            child: Center(
              child: AnimatedCrossFade(
                firstChild: icon,
                secondChild: ret,
                crossFadeState: selected
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: duration ~/ 2,
              ),
            ),
          ),
        ),
      );
    }

    var mana = Center(
      child: ClipRRect(
        borderRadius: rounded,
        child: Flex(
          direction: ls ? Axis.horizontal : Axis.vertical,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flex(
              direction: ls ? Axis.vertical : Axis.horizontal,
              mainAxisSize: MainAxisSize.min,
              children: [
                buildBox(Unicodes.white),
                buildBox(Unicodes.blue),
              ],
            ),
            Flex(
              direction: ls ? Axis.vertical : Axis.horizontal,
              mainAxisSize: MainAxisSize.min,
              children: [
                buildBox(Unicodes.black),
                buildBox(Unicodes.red),
              ],
            ),
            Flex(
              direction: ls ? Axis.vertical : Axis.horizontal,
              mainAxisSize: MainAxisSize.min,
              children: [
                buildBox(Unicodes.green),
                buildBox(Unicodes.colorless),
              ],
            ),
          ],
        ),
      ),
    );

    var others = Center(
      child: ClipRRect(
        borderRadius: rounded,
        child: Flex(
          direction: ls ? Axis.vertical : Axis.horizontal,
          mainAxisSize: MainAxisSize.min,
          children: [
            buildBox(Unicodes.poison),
            buildBox(Unicodes.storm),
            buildBox(Unicodes.damage),
          ],
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.all(5),
      child: RotatedBox(
        quarterTurns: widget.isFlipped && !ls ? 2 : 0,
        child: LoopPageView.builder(
          controller: _pageController,
          itemCount: 3,
          itemBuilder: (context, index) {
            switch (index) {
              case 1:
                return mana;
              case 2:
                return others;
              default:
                return main;
            }
          },
        ),
      ),
    );
  }
}
