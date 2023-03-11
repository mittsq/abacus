import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:github/github.dart';
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
  lastUpdate(0);

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
    print('Saved $keyString: $value');
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
      print('Loaded $key: $value');
    }

    _cache[key] = value;
    return value;
  }
}

class _SettingsState extends State<Settings> {
  bool _isStartingValid = true;

  late Timer _timer;
  String _updateString = '';

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );

    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (t) => {setState(() => _updateString = _lastUpdateString())},
    );
  }

  @override
  void activate() {
    super.activate();
    _startTimer();
  }

  @override
  void deactivate() {
    super.deactivate();
    _timer.cancel();
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
    );
  }

  void _changeSens(int? sens) {
    setState(() {
      Settings.set(SettingsKey.swipeSens, sens);
    });
  }

  String _lastUpdateString() {
    var lastUpdate = Settings.get<int>(SettingsKey.lastUpdate);
    if (lastUpdate == 0) return 'Last checked never';

    var since = DateTime.now().difference(
      DateTime.fromMillisecondsSinceEpoch(lastUpdate),
    );
    var s = 'Last checked ';
    if (since.inDays > 0) {
      s += '${since.inDays} day${since.inDays == 1 ? '' : 's'}';
    } else if (since.inHours > 0) {
      s += '${since.inHours} hour${since.inHours == 1 ? '' : 's'}';
    } else if (since.inMinutes > 0) {
      s += '${since.inMinutes} minute${since.inMinutes == 1 ? '' : 's'}';
    } else {
      s += '${since.inSeconds} second${since.inSeconds == 1 ? '' : 's'}';
    }
    return '$s ago';
  }

  Future<void> _checkForUpdates() async {
    launchUrl(Uri.parse('https://github.com/mittsq/abacus/releases'));

    setState(() {
      Settings.set(
        SettingsKey.lastUpdate,
        DateTime.now().millisecondsSinceEpoch,
      );
    });

    // var gh = GitHub();
    // var releases = await gh.repositories
    //     .listReleases(RepositorySlug('mittsq', 'abacus'))
    //     .first;
  }

  @override
  Widget build(BuildContext context) {
    void saveAndClose(String value) {
      setState(() {
        Settings.set(SettingsKey.starting, int.parse(value));
      });
    }

    var players = Settings.get<int>(SettingsKey.players);

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
            title: Text('Number of Players ${players == 1 ? '⚠️' : ''}'),
            trailing: SizedBox(
              width: 150,
              child: Row(
                children: [
                  Expanded(
                    child: Slider(
                      value: log(players) / log(2),
                      min: 0,
                      max: 2,
                      divisions: 2,
                      onChanged: (value) {
                        setState(() {
                          Settings.set(
                            SettingsKey.players,
                            players = pow(2, value).toInt(),
                          );
                        });
                      },
                    ),
                  ),
                  Text(
                    '$players',
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            title: Text('Starting Life Total ${_isStartingValid ? '' : '⚠️'}'),
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
                  setState(() {
                    Settings.set(SettingsKey.swipeSens, value as int?);
                  });
                }),
                value: Settings.get<int>(SettingsKey.swipeSens),
                alignment: AlignmentDirectional.centerStart,
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
            title: const Text('Check for updates'),
            subtitle: Text(_updateString),
            onTap: () => _checkForUpdates(),
          ),
          ListTile(
            title: const Text('Abacus v1.0.0'),
            subtitle: const Text('Made with love by mittsq using Flutter'),
            onTap: () => showLicensePage(context: context),
          ),
        ],
      ),
    );
  }
}
