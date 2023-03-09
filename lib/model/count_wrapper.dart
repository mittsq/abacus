class CountWrapper {
  CountWrapper(int start) {
    reset(start);
  }

  late int count;
  late bool glow;
  late bool showExtras;

  late int storm;
  late int poison;
  late int cmdDmg;
  late List<int> mana;

  CounterType selected = CounterType.life;
  ManaColor selectedMana = ManaColor.white;

  List<Function> listeners = [];

  int operator +(int other) {
    return count + other;
  }

  int operator -(int other) {
    return count - other;
  }

  void reset(int start) {
    count = start;
    storm = 0;
    poison = 0;
    cmdDmg = 0;
    mana = [0, 0, 0, 0, 0, 0];

    glow = false;
    showExtras = false;

    for (var element in listeners) {
      element();
    }
  }
}

enum ManaColor { white, blue, black, red, green, colorless }

enum CounterType { life, storm, poison, cmdDmg, mana }
