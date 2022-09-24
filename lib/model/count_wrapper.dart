class CountWrapper {
  CountWrapper(int start) {
    reset(start);
  }

  late int _count;

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
  }
}
