import 'dart:ui';

import 'package:abacus/util.dart';
import 'package:abacus/widgets/settings.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'widgets/holder.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Settings.prefs = await SharedPreferences.getInstance();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: themeNotifier,
      child: const Holder(),
      builder: (context, child) {
        var theme = ThemeData.dark(useMaterial3: true).copyWith(
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.primaries[Settings.get<int>(
              SettingsKey.accent,
            )],
            brightness: Brightness.dark,
          ),
        );

        return MaterialApp(
          title: 'Abacus',
          theme: theme,
          home: Container(
            color: Colors.black,
            child: child,
          ),
          scrollBehavior: AppScrollBehavior(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };
}

class ThemeNotifier extends ChangeNotifier {
  int get accent => Settings.get<int>(SettingsKey.accent);

  set accent(int value) {
    Settings.set(SettingsKey.accent, value);
    notifyListeners();
  }
}
