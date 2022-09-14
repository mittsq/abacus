class CountWrapper {
  CountWrapper(this._start) {
    reset();
  }

  final int _start;
  late int _count;

  int operator +(int other) {
    return _count + other;
  }

  int operator -(int other) {
    return _count - other;
  }

  int get value => _count;
  set value(v) => _count = v;

  void reset() {
    _count = _start;
  }
}
