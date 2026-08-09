import 'package:adair_flutter_lib/utils/page.dart';
import 'package:flutter/widgets.dart';
import 'package:mobile/mera/mera_records_page.dart';

/// Lightweight shell bridge so nested Mera pages can switch bottom tabs.
class MeraShell {
  static void Function(int index)? switchTab;

  static const tabHome = 0;
  static const tabRoutes = 1;
  static const tabMarks = 2;
  static const tabBoat = 3;
  static const tabSettings = 4;

  /// Legacy alias — stats live under Marks entry points.
  static const tabStats = tabMarks;

  static void goHome() => switchTab?.call(tabHome);
  static void goRoutes() => switchTab?.call(tabRoutes);
  static void goMarks() => switchTab?.call(tabMarks);
  static void goBoat() => switchTab?.call(tabBoat);

  /// Opens Yakalamalarım (not Marks). Call after popping to a stable context.
  static void goRecords(BuildContext context) {
    present(context, const MeraRecordsPage());
  }

  static void reset() => switchTab = null;
}
