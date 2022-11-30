import 'dart:async';
import 'dart:ui';

import 'package:abacus/model/count_wrapper.dart';
import 'package:abacus/widgets/settings.dart';
import 'package:flutter/material.dart';

class Counter extends StatefulWidget {
  const Counter({Key? key, required this.counter, this.isFlipped = false})
      : super(key: key);

  final CountWrapper counter;
  final bool isFlipped;

  @override
  State<StatefulWidget> createState() => _CounterState();
}

class _CounterState extends State<Counter> {
  late int _commitCount = widget.counter.value;
  bool _commit = true;
  double? _offset;
  int? _oldCount;
  DateTime _lastUpdate = DateTime.fromMicrosecondsSinceEpoch(0);

  int get _resistance => Settings.get('swipeSens', 35);

  void _increment({bool invert = false}) {
    setState(() {
      _setCount(widget.counter + (invert ? -1 : 1));
    });
  }

  void _dragStart(DragStartDetails args) {
    if (_offset != null) return;
    _offset = args.globalPosition.dy;
    _oldCount ??= widget.counter.value;
  }

  void _dragUpdate(DragUpdateDetails args) {
    var delta = args.globalPosition.dy - _offset!;
    var isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    var newCount = _oldCount! -
        delta / _resistance * ((widget.isFlipped && !isLandscape) ? -1 : 1);

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
      if (_commit) _commitCount = widget.counter.value;
      _commit = false;
      widget.counter.value = count;
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

    var isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    EdgeInsetsGeometry padding;
    if (isLandscape) {
      padding = EdgeInsets.fromLTRB(
        widget.isFlipped ? 10 : 5,
        10,
        widget.isFlipped ? 5 : 10,
        10,
      );
    } else {
      padding = EdgeInsets.fromLTRB(
        10,
        widget.isFlipped ? 10 : 5,
        10,
        widget.isFlipped ? 5 : 10,
      );
    }

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

    return Padding(
      padding: padding,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
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
                child: RotatedBox(
                  quarterTurns: (widget.isFlipped && !isLandscape) ? 2 : 0,
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(),
                      ),
                      SizedBox(
                        width: 175,
                        child: Center(
                          child: Text(
                            '${widget.counter.value}',
                            style: countStyle,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10),
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
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Column(
            children: [
              Expanded(
                child: Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    onTapDown: (details) =>
                        _increment(invert: widget.isFlipped && !isLandscape),
                  ),
                ),
              ),
              Expanded(
                child: Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    onTapDown: (details) =>
                        _increment(invert: !(widget.isFlipped && !isLandscape)),
                  ),
                ),
              ),
            ],
          ),
          GestureDetector(
            onVerticalDragStart: _dragStart,
            onVerticalDragUpdate: _dragUpdate,
            onVerticalDragEnd: _dragEnd,
          ),
        ],
      ),
    );
  }
}
