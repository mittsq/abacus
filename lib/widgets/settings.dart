import 'dart:async';

import 'package:abacus/main.dart';
import 'package:abacus/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

enum SettingsKey {
  players(2),
  starting(20),
  autoDecide(false),
  holdToReset(true),
  color(true),
  showCounters(true),
  swipeSens(35),
  accent(-1),
  ;

  final dynamic defaultValue;

  const SettingsKey(this.defaultValue);
}

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  static SharedPreferences? prefs;

  // we actually don't need to cache ourselves
  // the shared_preferences library does that for us
  static final Map<SettingsKey, dynamic> _cache = {};

  @override
  State<StatefulWidget> createState() => _SettingsState();

  static bool set<T>(SettingsKey key, T value) {
    var keyString = key.name;
    value = value ?? key.defaultValue as T;

    if (T == int) {
      prefs!.setInt(keyString, value as int);
    } else if (T == double) {
      prefs!.setDouble(keyString, value as double);
    } else if (T == bool) {
      prefs!.setBool(keyString, value as bool);
    } else {
      prefs!.setString(keyString, '$value');
    }

    _cache[key] = value;
    debugPrint('Saved $keyString: $value');
    return true;
  }

  static T get<T>(SettingsKey key) {
    var value = key.defaultValue as T;
    if (_cache.containsKey(key)) {
      return _cache[key] as T;
    }

    var keyString = key.name;

    if (prefs!.containsKey(keyString)) {
      if (T == int) {
        value = prefs!.getInt(keyString) as T;
      } else if (T == double) {
        value = prefs!.getDouble(keyString) as T;
      } else if (T == bool) {
        value = prefs!.getBool(keyString) as T;
      } else {
        value = prefs!.getString(keyString) as T;
      }
      debugPrint('Loaded $keyString: $value');
    }

    _cache[key] = value;
    return value;
  }
}

class _SettingsState extends State<Settings> {
  bool _isStartingValid = true;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
  }

  @override
  void dispose() {
    super.dispose();
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
    );
  }

  Future<String> _getVersion() async {
    var info = await PackageInfo.fromPlatform();
    return info.version;
  }

  void _openIssues() {
    launchUrl(Uri.parse('https://github.com/mittsq/abacus'));
  }

  void _chooseAccent() {
    Widget generate(int i, Color color, String name) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 4,
          horizontal: 24,
        ),
        child: ListTile(
          leading: _SwatchCircle(color: color),
          title: Text(name),
          onTap: () {
            Navigator.pop(context);
            setState(() {
              Settings.set(SettingsKey.accent, i);
              ThemeNotifier.instance.notify();
            });
          },
        ),
      );
    }

    var list = <Widget>[];

    if (MyApp.dynamicColor != null) {
      list.add(generate(-1, MyApp.dynamicColor!.primary, 'System'));
    }

    for (var i = 0; i < accentColors.length; ++i) {
      list.add(generate(i, Colors.primaries[i], accentColors[i] ?? ''));
    }

    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Accent Color'),
        insetPadding: const EdgeInsets.symmetric(
          horizontal: 60,
          vertical: 120,
        ),
        children: list,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    void saveAndClose(String value) {
      setState(() {
        Settings.set(SettingsKey.starting, int.parse(value));
      });
    }

    var accent = Settings.get<int>(SettingsKey.accent);
    var colorName = accentColors[accent];
    if (accent == -1) {
      colorName = 'System';
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Abacus'),
        automaticallyImplyLeading: true,
        backgroundColor: Colors.black,
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Accent Color'),
            trailing: SizedBox(
              width: 200,
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Text(
                        colorName ?? 'arts',
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ),
                  const _SwatchCircle(),
                ],
              ),
            ),
            onTap: _chooseAccent,
          ),
          ListTile(
            title: const Text('Number of Players'),
            trailing: SegmentedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                  (states) {
                    if (states.contains(MaterialState.selected)) {
                      return Theme.of(context).colorScheme.primaryContainer;
                    }
                    return null;
                  },
                ),
              ),
              onSelectionChanged: (v) {
                setState(() {
                  Settings.set(SettingsKey.players, v.single as int);
                });
              },
              segments: const [
                ButtonSegment(
                  value: 2,
                  icon: Icon(Icons.group_rounded),
                  label: Text('2'),
                ),
                ButtonSegment(
                  value: 4,
                  icon: Icon(Icons.groups_rounded),
                  label: Text('4'),
                ),
              ],
              selected: {Settings.get<int>(SettingsKey.players)},
            ),
          ),
          ListTile(
            title:
                Text('Starting Life Total ${_isStartingValid ? '' : '\u26a0'}'),
            trailing: SizedBox(
              width: 100,
              child: TextFormField(
                initialValue: '${Settings.get<int>(SettingsKey.starting)}',
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                onSaved: (value) => saveAndClose(value!),
                onFieldSubmitted: (value) => saveAndClose(value),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) {
                  setState(() {
                    var x = int.tryParse(value);
                    if (_isStartingValid = (x != null)) {
                      Settings.set(SettingsKey.starting, x!);
                    }
                  });
                },
              ),
            ),
          ),
          SwitchListTile(
            title: const Text('Spin the Needle on Reset'),
            value: Settings.get<bool>(SettingsKey.autoDecide),
            onChanged: (value) {
              setState(() {
                Settings.set(SettingsKey.autoDecide, value);
              });
            },
          ),
          SwitchListTile(
            title: const Text('Hold the Menu Icon to Reset'),
            value: Settings.get<bool>(SettingsKey.holdToReset),
            onChanged: (value) {
              setState(() {
                Settings.set(SettingsKey.holdToReset, value);
              });
            },
          ),
          ListTile(
            title: const Text('Swipe Sensitivity'),
            trailing: SizedBox(
              width: 100,
              child: DropdownButton(
                onChanged: ((value) {
                  // workaround for nullables for some reason
                  var x = int.parse(value.toString());
                  setState(() {
                    Settings.set(SettingsKey.swipeSens, x);
                  });
                }),
                value: Settings.get<int>(SettingsKey.swipeSens),
                alignment: Alignment.center,
                items: const [
                  DropdownMenuItem(
                    value: 50,
                    child: Text('Low'),
                  ),
                  DropdownMenuItem(
                    value: 35,
                    child: Text('Medium'),
                  ),
                  DropdownMenuItem(
                    value: 25,
                    child: Text('High'),
                  ),
                ],
              ),
            ),
          ),
          SwitchListTile(
            title: const Text('Color Effects on Life Change'),
            value: Settings.get<bool>(SettingsKey.color),
            onChanged: (value) {
              setState(() {
                Settings.set(SettingsKey.color, value);
              });
            },
          ),
          SwitchListTile(
            title: const Text('Always Show Non-Zero Counters'),
            value: Settings.get<bool>(SettingsKey.showCounters),
            onChanged: (value) {
              setState(() {
                Settings.set(SettingsKey.showCounters, value);
              });
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('Report a bug or request a feature'),
            onTap: () => _openIssues(),
          ),
          ListTile(
            title: FutureBuilder(
              builder: (context, snapshot) {
                var version = snapshot.hasData ? 'v${snapshot.data}' : '';
                return Text('Abacus $version');
              },
              future: _getVersion(),
            ),
            subtitle: const Text('Made with \u2764 by mittsq using Flutter'),
            onTap: () => showLicensePage(context: context),
          ),
        ],
      ),
    );
  }
}

class _SwatchCircle extends StatelessWidget {
  const _SwatchCircle({this.color});

  final Color? color;

  @override
  Widget build(BuildContext context) {
    var c = color ?? Theme.of(context).colorScheme.primary;

    return ClipOval(
      child: SizedBox.square(
        dimension: 25,
        child: ColoredBox(color: c),
      ),
    );
  }
}
