class CountWrapper {
  CountWrapper(this._count);

  int _count;

  int operator +(int other) {
    return _count + other;
  }

  int operator -(int other) {
    return _count - other;
  }

  int get value => _count;
  set value(v) => _count = v;
}
