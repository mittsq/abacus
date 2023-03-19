import 'dart:ui';

import 'package:flutter/material.dart';

extension NumExtensions on double {
  double roundTo(double value) => (this / value).roundToDouble() * value;
}

bool isLandscape(BuildContext context) =>
    MediaQuery.of(context).orientation == Orientation.landscape;

TextStyle? getTextStyle(BuildContext context) =>
    Theme.of(context).textTheme.displayLarge?.merge(
          const TextStyle(
            fontFeatures: [FontFeature.tabularFigures()],
            fontWeight: FontWeight.normal,
            fontSize: 120,
          ),
        );

enum Unicodes {
  white('\ue600', Color(0xfffefddf)),
  blue('\ue601', Color(0xffbae7fb)),
  black('\ue602', Color(0xffd7d0cd)),
  red('\ue603', Color(0xfffaba9f)),
  green('\ue604', Color(0xffabddbd)),
  colorless('\ue904', Color(0xffd7d0cd)),
  damage('\ue628', null),
  storm('\ue907', null),
  poison('\ue618', null),
  life(' ', null);

  const Unicodes(this.code, this.color);
  final String code;
  final Color? color;

  @override
  String toString() => code;
}

const Map<int, String> accentColors = {
  0: 'Red',
  1: 'Pink',
  2: 'Purple',
  3: 'Deep Purple',
  4: 'Indigo',
  5: 'Blue',
  6: 'Light Blue',
  7: 'Cyan',
  8: 'Teal',
  9: 'Green',
  10: 'Light Green',
  11: 'Lime',
  12: 'Yellow',
  13: 'Amber',
  14: 'Orange',
  15: 'Deep Orange',
  16: 'Brown',
  17: 'Blue Grey',
};

class ThemeNotifier with ChangeNotifier {
  ThemeNotifier._();

  static final ThemeNotifier instance = ThemeNotifier._();

  void notify() {
    notifyListeners();
  }
}
