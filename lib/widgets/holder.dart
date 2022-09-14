import 'package:abacus/model/count_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakelock/wakelock.dart';

import 'counter.dart';

class Holder extends StatefulWidget {
  const Holder({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HolderState();
}

class _HolderState extends State<Holder> with SingleTickerProviderStateMixin {
  bool _showMenu = false;
  var duration = const Duration(milliseconds: 200);
  late AnimationController _menuController;

  CountWrapper player1 = CountWrapper(20), player2 = CountWrapper(20);

  @override
  void initState() {
    super.initState();
    _menuController = AnimationController(
      vsync: this,
      duration: duration,
    );
    Wakelock.enable();
    showOverlays(false);
  }

  @override
  void dispose() {
    super.dispose();
    Wakelock.disable();
  }

  void _openMenu({bool? visible}) {
    setState(() {
      _showMenu = visible ?? !_showMenu;
      if (_showMenu) {
        _menuController.forward();
        showOverlays(true);
      } else {
        _menuController.reverse();
        showOverlays(false);
      }
    });
  }

  void _reset() {
    setState(() {
      player1.reset();
      player2.reset();
    });
    _openMenu(visible: false);
  }

  void showOverlays(bool show) {
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
                isOpponent: !isLandscape,
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
                          onTap:
                              null, // _showSettings ? () => _reset(context) : null,
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
      ],
    );
  }
}
