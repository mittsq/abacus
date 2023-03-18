import 'dart:async';
import 'dart:ui';

import 'package:abacus/model/count_wrapper.dart';
import 'package:abacus/util.dart';
import 'package:abacus/widgets/box.dart';
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
  late int _commitCount = widget.counter.get();
  bool _commit = true;
  double? _offset;
  int? _oldCount;
  DateTime _lastUpdate = DateTime.fromMicrosecondsSinceEpoch(0);

  final LoopPageController _pageController = LoopPageController();

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
    _oldCount ??= widget.counter.get();
  }

  void _dragUpdate(DragUpdateDetails args) {
    var delta = args.globalPosition.dy - _offset!;
    var ls = isLandscape(context);
    var res = Settings.get<int>(SettingsKey.swipeSens);
    var newCount =
        _oldCount! - delta / res * ((widget.isFlipped && !ls) ? -1 : 1);

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
      if (_commit) _commitCount = widget.counter.get();
      _commit = false;
      widget.counter.set(value: count);
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
    var countStyle = getTextStyle(context);
    var miniStyle = Theme.of(context).textTheme.headlineSmall?.merge(
          TextStyle(
            color: countStyle?.color,
            fontFeatures: const [FontFeature.tabularFigures()],
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
    var max = Settings.get<int>(SettingsKey.starting);
    var doColor = Settings.get<bool>(SettingsKey.color);
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

    var otherList = <TextSpan>[];
    if (Settings.get<bool>(SettingsKey.showCounters)) {
      otherList.addAll(
        widget.counter.counters.entries
            .where((c) =>
                c.value != 0 &&
                c.key != Unicodes.life &&
                c.key != widget.counter.selected)
            .map(
              (c) => TextSpan(
                text: c.key.code,
                style: miniStyle?.copyWith(
                  fontFamily: 'Mana',
                  color: c.key.color,
                ),
                children: [
                  TextSpan(
                    text: ' ${c.value}\n',
                    style: miniStyle,
                  ),
                ],
              ),
            ),
      );

      if (widget.counter.selected != Unicodes.life) {
        otherList.add(
          TextSpan(
            text: '\ue95c',
            style: miniStyle?.copyWith(fontFamily: 'Mana'),
            children: [
              TextSpan(
                text: ' ${widget.counter.get(key: Unicodes.life)}\n',
                style: miniStyle,
              ),
            ],
          ),
        );
      }
    }

    void onBoxSelect() {
      setState(() {
        _commit = true;
        _jump();
      });
    }

    // probably better to bubble up the state change somehow
    void reloadState() {
      setState(() {});
    }

    var pins = widget.counter.pins.map((e) {
      return Expanded(
        child: CounterBox(
          parent: widget,
          unicode: e,
          onSelect: onBoxSelect,
          forceUpdate: reloadState,
          size: const Size.fromHeight(40),
        ),
      );
    });

    var main = ClipRRect(
      borderRadius: rounded,
      child: Stack(
        children: [
          AnimatedContainer(
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
                        '${widget.counter.get()}',
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
          AnimatedOpacity(
            opacity: otherList.isEmpty ? 0 : 1,
            duration: duration,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text.rich(TextSpan(children: otherList)),
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
                      onTapDown: (details) => _increment(invert: false),
                    ),
                  ),
                ),
                Expanded(
                  child: Material(
                    type: MaterialType.transparency,
                    child: InkWell(
                      onTapDown: (details) => _increment(invert: true),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Expanded(child: Container()),
              Row(children: pins.toList()),
            ],
          ),
        ],
      ),
    );

    Widget emplace(Widget child) {
      return Padding(
        padding: const EdgeInsets.all(10),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: ClipRRect(
            borderRadius: rounded,
            child: child,
          ),
        ),
      );
    }

    var boxSize = const Size.square(100);
    var mana = emplace(Flex(
      direction: ls ? Axis.horizontal : Axis.vertical,
      mainAxisSize: MainAxisSize.min,
      children: [
        Flex(
          direction: ls ? Axis.vertical : Axis.horizontal,
          mainAxisSize: MainAxisSize.min,
          children: [
            CounterBox(
              parent: widget,
              unicode: Unicodes.white,
              onSelect: onBoxSelect,
              forceUpdate: reloadState,
              size: boxSize,
            ),
            CounterBox(
              parent: widget,
              unicode: Unicodes.blue,
              onSelect: onBoxSelect,
              forceUpdate: reloadState,
              size: boxSize,
            ),
          ],
        ),
        Flex(
          direction: ls ? Axis.vertical : Axis.horizontal,
          mainAxisSize: MainAxisSize.min,
          children: [
            CounterBox(
              parent: widget,
              unicode: Unicodes.black,
              onSelect: onBoxSelect,
              forceUpdate: reloadState,
              size: boxSize,
            ),
            CounterBox(
              parent: widget,
              unicode: Unicodes.red,
              onSelect: onBoxSelect,
              forceUpdate: reloadState,
              size: boxSize,
            ),
          ],
        ),
        Flex(
          direction: ls ? Axis.vertical : Axis.horizontal,
          mainAxisSize: MainAxisSize.min,
          children: [
            CounterBox(
              parent: widget,
              unicode: Unicodes.green,
              onSelect: onBoxSelect,
              forceUpdate: reloadState,
              size: boxSize,
            ),
            CounterBox(
              parent: widget,
              unicode: Unicodes.colorless,
              onSelect: onBoxSelect,
              forceUpdate: reloadState,
              size: boxSize,
            ),
          ],
        ),
      ],
    ));

    var others = emplace(
      Flex(
        direction: ls ? Axis.horizontal : Axis.vertical,
        mainAxisSize: MainAxisSize.min,
        children: [
          CounterBox(
            parent: widget,
            unicode: Unicodes.poison,
            onSelect: onBoxSelect,
            forceUpdate: reloadState,
            size: boxSize,
          ),
          CounterBox(
            parent: widget,
            unicode: Unicodes.storm,
            onSelect: onBoxSelect,
            forceUpdate: reloadState,
            size: boxSize,
          ),
          CounterBox(
            parent: widget,
            unicode: Unicodes.damage,
            onSelect: onBoxSelect,
            forceUpdate: reloadState,
            size: boxSize,
          ),
        ],
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
