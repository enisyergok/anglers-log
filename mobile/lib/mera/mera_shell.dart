/// Lightweight shell bridge so nested Mera pages can switch bottom tabs.
class MeraShell {
  static void Function(int index)? switchTab;

  static const tabHome = 0;
  static const tabRoutes = 1;
  static const tabMarks = 2;
  static const tabBoat = 3;
  static const tabSettings = 4;

  /// Legacy aliases used by catch success / older call sites.
  static const tabStats = tabMarks;
  static const tabRecords = tabMarks;

  static void goHome() => switchTab?.call(tabHome);
  static void goRecords() => switchTab?.call(tabMarks);
  static void goRoutes() => switchTab?.call(tabRoutes);
  static void goMarks() => switchTab?.call(tabMarks);
  static void goBoat() => switchTab?.call(tabBoat);

  static void reset() => switchTab = null;
}
