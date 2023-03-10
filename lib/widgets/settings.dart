import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:github/github.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  static SharedPreferences? prefs;
  static final Map<String, dynamic> _cache = {};

  @override
  State<StatefulWidget> createState() => _SettingsState();

  static bool set<T>(String key, T value) {
    if (T == int) {
      prefs!.setInt(key, value as int);
    } else if (T == double) {
      prefs!.setDouble(key, value as double);
    } else if (T == bool) {
      prefs!.setBool(key, value as bool);
    } else {
      prefs!.setString(key, '$value');
    }

    _cache[key] = value;
    print('Saved $key: $value');
    return true;
  }

  static T get<T>(String key, T defaultValue) {
    T value = defaultValue;
    if (_cache.containsKey(key)) {
      return _cache[key] as T;
    }

    if (prefs!.containsKey(key)) {
      if (T == int) {
        value = prefs!.getInt(key) as T;
      } else if (T == double) {
        value = prefs!.getDouble(key) as T;
      } else if (T == bool) {
        value = prefs!.getBool(key) as T;
      } else {
        value = prefs!.getString(key) as T;
      }
      _cache[key] = value;
      print('Loaded $key: $value');
    }
    return value;
  }
}

class _SettingsState extends State<Settings> {
  final _settingsKey = GlobalKey<FormState>();
  bool _isStartingValid = true;

  late int _players;
  late int _starting;
  late bool _autoDecide;
  late bool _holdToReset;
  late bool _color;
  late bool _showCounters;

  late Timer _timer;
  String _updateString = '';

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );

    _players = Settings.get('players', 2);
    _starting = Settings.get('starting', 20);
    _autoDecide = Settings.get('autoDecide', false);
    _holdToReset = Settings.get('holdToReset', true);
    _color = Settings.get('color', false);
    _showCounters = Settings.get('showCounters', true);
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

  int get _swipeSens => Settings.get('swipeSens', 35);

  void _changeSens(int? sens) {
    setState(() {
      Settings.set('swipeSens', sens ?? 35);
    });
  }

  String _lastUpdateString() {
    var lastUpdate = Settings.get('lastUpdate', 0);
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
      Settings.set('lastUpdate', DateTime.now().millisecondsSinceEpoch);
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
        Settings.set('starting', _starting = int.parse(value));
      });
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
            title: Text('Number of Players ${_players == 1 ? '⚠️' : ''}'),
            trailing: SizedBox(
              width: 150,
              child: Row(
                children: [
                  Expanded(
                    child: Slider(
                      value: log(_players) / log(2),
                      min: 0,
                      max: 2,
                      divisions: 2,
                      onChanged: (value) {
                        setState(() {
                          Settings.set(
                            'players',
                            _players = pow(2, value).toInt(),
                          );
                        });
                      },
                    ),
                  ),
                  Text(
                    '$_players',
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
                initialValue: '$_starting',
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
                      Settings.set('starting', _starting = x!);
                    }
                  });
                },
              ),
            ),
          ),
          SwitchListTile(
            title: const Text('Decide Starting Player on Reset'),
            value: _autoDecide,
            onChanged: (value) {
              setState(() {
                Settings.set('autoDecide', _autoDecide = value);
              });
            },
          ),
          SwitchListTile(
            title: const Text('Hold the Menu Icon to Reset'),
            value: _holdToReset,
            onChanged: (value) {
              setState(() {
                Settings.set('holdToReset', _holdToReset = value);
              });
            },
          ),
          ListTile(
            title: const Text('Swipe Sensitivity'),
            trailing: SizedBox(
              width: 100,
              child: DropdownButton(
                onChanged: _changeSens,
                value: _swipeSens,
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
            value: _color,
            onChanged: (value) {
              setState(() {
                Settings.set('color', _color = value);
              });
            },
          ),
          SwitchListTile(
            title: const Text('Always Show Non-Zero Counters'),
            value: _showCounters,
            onChanged: (value) {
              setState(() {
                Settings.set('showCounters', _showCounters = value);
              });
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('Check for updates'),
            subtitle: Text(_updateString = _lastUpdateString()),
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
