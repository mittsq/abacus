class CountWrapper {
  CountWrapper(int start) {
    reset(start);
  }

  late int count;
  late bool glow;
  late bool showExtras;

  late int storm;
  late int poison;
  late List<int> mana;

  int operator +(int other) {
    return count + other;
  }

  int operator -(int other) {
    return count - other;
  }

  void reset(int start) {
    count = start;
    glow = false;
    showExtras = false;
  }
}

enum ManaColor { white, blue, black, red, green, colorless }
