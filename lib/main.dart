import 'dart:ui';

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
    return MaterialApp(
      title: 'Abacus',
      theme: ThemeData.dark(),
      home: Container(
        color: Colors.black,
        child: const Holder(),
      ),
      scrollBehavior: AppScrollBehavior(),
      debugShowCheckedModeBanner: false,
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
