import 'package:flutter/widgets.dart';

extension NumExtensions on double {
  double roundTo(double value) => (this / value).roundToDouble() * value;
}

bool isLandscape(BuildContext context) =>
    MediaQuery.of(context).orientation == Orientation.landscape;

enum Unicodes {
  white('\ue600', Color(0xfffefddf)),
  blue('\ue601', Color(0xffbae7fb)),
  black('\ue602', Color(0xffd7d0cd)),
  red('\ue603', Color(0xfffaba9f)),
  green('\ue604', Color(0xffabddbd)),
  colorless('\ue904', Color(0xffd7d0cd)),
  damage('\ue628', null),
  storm('\ue907', null),
  poison('\ue618', null);

  const Unicodes(this.code, this.color);
  final String code;
  final Color? color;

  @override
  String toString() => code;
}
