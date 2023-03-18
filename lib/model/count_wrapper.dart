import 'package:abacus/util.dart';

class CountWrapper {
  CountWrapper(int start) {
    reset(start);
  }

  late bool glow;

  Map<Unicodes, int> counters = {
    Unicodes.white: 0,
    Unicodes.blue: 0,
    Unicodes.black: 0,
    Unicodes.red: 0,
    Unicodes.green: 0,
    Unicodes.colorless: 0,
    Unicodes.damage: 0,
    Unicodes.storm: 0,
    Unicodes.poison: 0,
    Unicodes.life: 0,
  };

  Unicodes selected = Unicodes.life;

  List<Function> listeners = [];
  List<Unicodes> pins = [];

  int operator +(int other) {
    return get() + other;
  }

  int operator -(int other) {
    return get() - other;
  }

  void reset(int start) {
    for (var c in counters.entries) {
      if (c.key != Unicodes.life) {
        counters[c.key] = 0;
      }
    }

    counters[Unicodes.life] = start;
    glow = false;

    for (var element in listeners) {
      element();
    }
  }

  int get({Unicodes? key}) {
    return counters[key ?? selected] ?? 0;
  }

  void set({required int value, Unicodes? key}) {
    counters[key ?? selected] = value;
  }

  void togglePin(Unicodes code) {
    if (pins.contains(code)) {
      pins.remove(code);
    } else {
      pins.add(code);
    }
  }

  bool isPinned(Unicodes code) {
    return pins.contains(code);
  }
}
