class CountWrapper {
  CountWrapper(int start) {
    reset(start);
  }

  late int _count;
  late bool _glow;

  int operator +(int other) {
    return _count + other;
  }

  int operator -(int other) {
    return _count - other;
  }

  int get value => _count;
  set value(v) => _count = v;

  void reset(int start) {
    _count = start;
    _glow = false;
  }

  bool get glow => _glow;
  set glow(v) => _glow = v;
}
