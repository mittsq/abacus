import 'package:abacus/util.dart';

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

  Unicodes selected = Unicodes.life;

  List<Function> listeners = [];

  int operator +(int other) {
    return getSelected() + other;
  }

  int operator -(int other) {
    return getSelected() - other;
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

  // is there a better way to do this? yes.
  int getSelected() {
    switch (selected) {
      case Unicodes.life:
        return count;
      case Unicodes.storm:
        return storm;
      case Unicodes.poison:
        return poison;
      case Unicodes.damage:
        return cmdDmg;
      case Unicodes.white:
        return mana[0];
      case Unicodes.blue:
        return mana[1];
      case Unicodes.black:
        return mana[2];
      case Unicodes.red:
        return mana[3];
      case Unicodes.green:
        return mana[4];
      case Unicodes.colorless:
        return mana[5];
      default:
        return 0;
    }
  }

  // also yes.
  void setSelected(int x) {
    switch (selected) {
      case Unicodes.life:
        count = x;
        break;
      case Unicodes.storm:
        storm = x;
        break;
      case Unicodes.poison:
        poison = x;
        break;
      case Unicodes.damage:
        cmdDmg = x;
        break;
      case Unicodes.white:
        mana[0] = x;
        break;
      case Unicodes.blue:
        mana[1] = x;
        break;
      case Unicodes.black:
        mana[2] = x;
        break;
      case Unicodes.red:
        mana[3] = x;
        break;
      case Unicodes.green:
        mana[4] = x;
        break;
      case Unicodes.colorless:
        mana[5] = x;
        break;
      default:
        break;
    }
  }
}

enum ManaColor { white, blue, black, red, green, colorless }
