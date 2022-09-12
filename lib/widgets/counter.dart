import 'dart:async';
import 'dart:ui';

import 'package:abacus/model/count_wrapper.dart';
import 'package:flutter/material.dart';

class Counter extends StatefulWidget {
  const Counter({Key? key, required this.counter, this.isOpponent = false})
      : super(key: key);

  final CountWrapper counter;
  final bool isOpponent;

  @override
  State<StatefulWidget> createState() {
    return _CounterState();
  }
}

class _CounterState extends State<Counter> {
  // late CountWrapper widget.counter = CountWrapper(20);
  late int _commitCount = 20;
  bool _commit = true;
  double? _offset;
  int? _oldCount;
  DateTime _lastUpdate = DateTime.fromMicrosecondsSinceEpoch(0);

  static const _resistance = 35;

  void _increment(TapUpDetails args) {
    setState(() {
      _setCount(widget.counter + 1);
    });
  }

  void _decrement(TapUpDetails args) {
    setState(() {
      _setCount(widget.counter - 1);
    });
  }

  void _dragStart(DragStartDetails args) {
    if (_offset != null) return;
    _offset = args.globalPosition.dy;
    _oldCount ??= widget.counter.value;
  }

  void _dragUpdate(DragUpdateDetails args) {
    var delta = args.globalPosition.dy - _offset!;
    var newCount =
        _oldCount! - delta / _resistance * (widget.isOpponent ? -1 : 1);

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
      if (_commit) _commitCount = widget.counter.value;
      _commit = false;
      widget.counter.value = count;
      _lastUpdate = DateTime.now();
    });
    const delay = Duration(seconds: 3);
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
    var countStyle = Theme.of(context).textTheme.displayLarge?.merge(
          const TextStyle(
            fontFeatures: [
              FontFeature.tabularFigures(),
            ],
          ),
        );

    var miniStyle = Theme.of(context).textTheme.titleLarge?.merge(
          TextStyle(
            color: countStyle?.color,
            fontFeatures: const [
              FontFeature.tabularFigures(),
            ],
          ),
        );

    String miniText;
    var diff = widget.counter - _commitCount;
    if (diff == 0) {
      miniText = '±0';
    } else if (diff > 0) {
      miniText = '+$diff';
    } else {
      miniText = '\u2212${diff.abs()}';
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(
        10,
        widget.isOpponent ? 10 : 5,
        10,
        widget.isOpponent ? 5 : 10,
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        child: Stack(
          children: [
            Container(
              color: Colors.grey.withAlpha(32),
              child: Center(
                child: RotatedBox(
                  quarterTurns: widget.isOpponent ? 2 : 0,
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
                              duration: const Duration(milliseconds: 200),
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
            Column(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTapUp: widget.isOpponent ? _decrement : _increment,
                    onVerticalDragStart: _dragStart,
                    onVerticalDragUpdate: _dragUpdate,
                    onVerticalDragEnd: _dragEnd,
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTapUp: widget.isOpponent ? _increment : _decrement,
                    onVerticalDragStart: _dragStart,
                    onVerticalDragUpdate: _dragUpdate,
                    onVerticalDragEnd: _dragEnd,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
