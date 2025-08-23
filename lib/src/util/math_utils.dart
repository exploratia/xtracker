class MathUtils {
  /// linear interpolation
  ///
  /// [t] value between 0..1
  static num lerp(num min, num max, num t) {
    return min + (max - min) * t;
  }

  /// inverted linear interpolation
  static double invLerp(num min, num max, num v) {
    if (v <= min) return 0;
    if (v >= max) return 1;
    return (v - min) / (max - min);
  }
}
