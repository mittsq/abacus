import 'dart:math' as math;

import 'package:abacus/model/count_wrapper.dart';
import 'package:abacus/util.dart';
import 'package:abacus/widgets/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakelock/wakelock.dart';

import 'counter.dart';
import 'needle.dart';

class Holder extends StatefulWidget {
  const Holder({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HolderState();
}

class _HolderState extends State<Holder> with TickerProviderStateMixin {
  bool _showMenu = false;
  bool _showNeedle = false;
  var duration = const Duration(milliseconds: 200);
  late AnimationController _menuController;
  late AnimationController _needleController;
  late Animation<double> _needleAnimation;

  late List<CountWrapper> players;

  @override
  void initState() {
    super.initState();
    _menuController = AnimationController(
      vsync: this,
      duration: duration,
    );
    _needleController = AnimationController(
      vsync: this,
    );
    _needleAnimation = _needleController.drive(Tween(begin: 0, end: 1));

    players = List.generate(
      4,
      (i) => CountWrapper(Settings.get<int>(SettingsKey.starting)),
    );

    _showOverlays(false);

    // bug with JS wakelock library
    Future.delayed(
      const Duration(seconds: 1),
      () => Wakelock.enable(),
    );
  }

  @override
  void dispose() {
    _menuController.dispose();
    super.dispose();
    Wakelock.disable();
  }

  void _openMenu({bool? visible}) {
    setState(() {
      _showMenu = visible ?? !_showMenu;
      if (_showMenu) {
        _menuController.forward();
        _showOverlays(true);
      } else {
        _menuController.reverse();
        _showOverlays(false);
      }
    });
  }

  void _reset() async {
    setState(() {
      for (var p in players) {
        p.reset(Settings.get<int>(SettingsKey.starting));
      }
      _showNeedle = false;
    });
    _openMenu(visible: false);

    var auto = Settings.get<bool>(SettingsKey.autoDecide);
    if (!auto) return;
    var ls = isLandscape(context);
    var fourPlayers = Settings.get<int>(SettingsKey.players) == 4;

    var o = ls ? 0.0 : 0.25;
    var rand = math.Random();

    if (fourPlayers) {
      o += rand.nextInt(4) * 0.25;
    } else {
      o += rand.nextInt(2) * 0.5;
    }

    var r = rand.nextDouble(); // TODO biased end pos
    _needleController.duration = Duration(
      seconds: 2,
      milliseconds: (r * 1000 / 3).round(),
    );
    _needleAnimation = _needleController.drive(
      MyTween(
        m: 0.15,
        p: 3,
        result: r + 6,
        offset: o,
      ),
    );

    int winner = -1;
    r += o;
    if (r >= 1) r -= 1;
    if (ls) {
      if (fourPlayers) {
        if (r < 0.25) {
          winner = 3;
        } else if (r < 0.5) {
          winner = 1;
        } else if (r < 0.75) {
          winner = 2;
        } else {
          winner = 4;
        }
      } else {
        if (r < 0.5) {
          winner = 1;
        } else {
          winner = 2;
        }
      }
    } else {
      if (fourPlayers) {
        if (r < 0.25) {
          winner = 4;
        } else if (r < 0.5) {
          winner = 3;
        } else if (r < 0.75) {
          winner = 1;
        } else {
          winner = 2;
        }
      } else {
        if (r < 0.25 || r > 0.75) {
          winner = 2;
        } else {
          winner = 1;
        }
      }
    }
    print('Spinning to ${r.toStringAsPrecision(3)} with winner $winner');

    _needleController.reset();
    await Future.delayed(duration * 2);
    setState(() => _showNeedle = true);
    await Future.delayed(duration * 2);
    _needleController.forward().whenComplete(() async {
      setState(() {
        for (var p = 0; p < 4; ++p) {
          players[p].glow = p == winner - 1;
        }
      });

      Future.delayed(duration * 2, () {
        setState(() {
          _showNeedle = false;
        });
      });

      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          for (var p in players) {
            p.glow = false;
          }
        });
      });
    });
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const Settings(),
      ),
    ).whenComplete(() => setState(() {}));
    _openMenu(visible: false);
  }

  void _showOverlays(bool show) {
    SystemChrome.setEnabledSystemUIMode(
      show ? SystemUiMode.edgeToEdge : SystemUiMode.immersiveSticky,
      // overlays: SystemUiOverlay.values,
    );
  }

  @override
  Widget build(BuildContext context) {
    var ls = isLandscape(context);

    var leftTop = [
      Expanded(
        child: Counter(
          counter: players[1],
          isFlipped: true,
        ),
      ),
    ];

    var rightBottom = [
      Expanded(
        child: Counter(
          counter: players[0],
          isFlipped: false,
        ),
      ),
    ];

    if (Settings.get<int>(SettingsKey.players) == 4) {
      leftTop.add(
        Expanded(
          child: Counter(
            counter: players[3],
            isFlipped: true,
          ),
        ),
      );

      rightBottom.add(
        Expanded(
          child: Counter(
            counter: players[2],
            isFlipped: false,
          ),
        ),
      );
    }

    if (ls) {
      leftTop = leftTop.reversed.toList();
      rightBottom = rightBottom.reversed.toList();
    }

    var needleColor = Theme.of(context).colorScheme.primary;
    if (Theme.of(context).colorScheme.primary is MaterialColor) {
      var mc = Theme.of(context).colorScheme.primary as MaterialColor;
      needleColor = mc[300] ?? needleColor;
    }

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(5),
          child: Flex(
            direction: ls ? Axis.horizontal : Axis.vertical,
            children: [
              Expanded(
                child: Flex(
                  direction: ls ? Axis.vertical : Axis.horizontal,
                  children: leftTop,
                ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutExpo,
                child: SizedBox(
                  height: _showMenu ? 100 : 0,
                  width: _showMenu ? 100 : 0,
                ),
              ),
              Expanded(
                child: Flex(
                  direction: ls ? Axis.vertical : Axis.horizontal,
                  children: rightBottom,
                ),
              ),
            ],
          ),
        ),
        Center(
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            child: Material(
              color: Colors.black,
              child: InkWell(
                onTap: _openMenu,
                onLongPress:
                    Settings.get<bool>(SettingsKey.holdToReset) ? _reset : null,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: AnimatedIcon(
                    icon: AnimatedIcons.menu_close,
                    progress: _menuController,
                    color: Theme.of(context).textTheme.displayLarge?.color,
                  ),
                ),
              ),
            ),
          ),
        ),
        Center(
          child: AnimatedOpacity(
            opacity: _showMenu ? 1 : 0,
            duration: duration,
            curve: Curves.ease,
            child: Flex(
              direction: ls ? Axis.vertical : Axis.horizontal,
              children: [
                Expanded(
                  child: Center(
                    child: ClipOval(
                      child: Material(
                        type: MaterialType.transparency,
                        child: InkWell(
                          onTap: _showMenu ? () => _reset() : null,
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Icon(
                              Icons.replay,
                              color: Theme.of(context)
                                  .textTheme
                                  .displayLarge
                                  ?.color,
                              size: 36,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: ClipOval(
                      child: Material(
                        type: MaterialType.transparency,
                        child: InkWell(
                          onTap: _showMenu ? () => _openSettings() : null,
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Icon(
                              Icons.settings,
                              color: Theme.of(context)
                                  .textTheme
                                  .displayLarge
                                  ?.color,
                              size: 36,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        IgnorePointer(
          child: AnimatedOpacity(
            opacity: _showNeedle ? 1 : 0,
            duration: duration,
            child: RotationTransition(
              turns: _needleAnimation,
              child: Center(
                child: NeedleWidget(
                  color: needleColor,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
