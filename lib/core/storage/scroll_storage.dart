class ScrollStorage {
  static final Map<String, double> scrollOffsets = {};

  static double getOffset(String key) {
    return scrollOffsets[key] ?? 0.0;
  }

  static void setOffset(String key, double offset) {
    scrollOffsets[key] = offset;
  }
}
