import 'dart:math' as math;

import 'package:abacus/model/count_wrapper.dart';
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

  late CountWrapper player1, player2;
  int get _starting => Settings.prefs!.getInt('starting') ?? 20;

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

    Wakelock.enable();
    _showOverlays(false);

    player1 = CountWrapper(_starting);
    player2 = CountWrapper(_starting);
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
      player1.reset(_starting);
      player2.reset(_starting);
      _showNeedle = false;
    });
    _openMenu(visible: false);

    var auto = Settings.prefs!.getBool('autoDecide') ?? false;
    if (!auto) return;
    var isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    var o = isLandscape ? 0.0 : 0.25;
    var r = math.Random().nextDouble();
    _needleController.duration = Duration(
      seconds: 2,
      milliseconds: (1000 / 3 * r).round(),
    );
    _needleAnimation = _needleController.drive(MyTween(
      m: 0.5,
      iterations: 6,
      result: r,
      offset: o,
    ));

    int winner;
    r += o;
    if (r > 1) r -= 1;
    if (isLandscape) {
      winner = r < 0.5 ? 1 : 2;
    } else {
      winner = r < 0.25 || r > 0.75 ? 1 : 2;
    }
    // print('spinning to ${r.toStringAsPrecision(3)} with winner $winner');

    _needleController.reset();
    await Future.delayed(duration * 2);
    setState(() => _showNeedle = true);
    await Future.delayed(duration * 2);
    _needleController.forward().whenComplete(() async {
      await Future.delayed(duration * 2);
      setState(() => _showNeedle = false);
    });
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const Settings(),
      ),
    );
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
    var isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    return Stack(
      children: [
        Flex(
          direction: isLandscape ? Axis.horizontal : Axis.vertical,
          children: [
            Expanded(
              child: Counter(
                counter: player2,
                isFlipped: true,
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
              child: Counter(
                counter: player1,
              ),
            ),
          ],
        ),
        Center(
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            child: Material(
              color: Colors.black,
              child: InkWell(
                onTap: _openMenu,
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
              direction: isLandscape ? Axis.vertical : Axis.horizontal,
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
                  color: Theme.of(context).textTheme.displayLarge?.color ??
                      Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
