import 'package:flutter/cupertino.dart';

extension NumExtensions on double {
  double roundTo(double value) => (this / value).roundToDouble() * value;
}

bool isLandscape(BuildContext context) =>
    MediaQuery.of(context).orientation == Orientation.landscape;
