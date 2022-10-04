extension NumExtensions on double {
  double roundTo(double value) => (this / value).roundToDouble() * value;
}
