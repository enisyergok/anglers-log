/// Lightweight shell bridge so nested Mera pages can switch bottom tabs.
class MeraShell {
  static void Function(int index)? switchTab;

  static const tabHome = 0;
  static const tabRoutes = 1;
  static const tabStats = 2;
  static const tabRecords = 3;
  static const tabSettings = 4;

  static void goHome() => switchTab?.call(tabHome);
  static void goRecords() => switchTab?.call(tabRecords);
  static void goRoutes() => switchTab?.call(tabRoutes);

  static void reset() => switchTab = null;
}
