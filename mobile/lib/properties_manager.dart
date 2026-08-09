import 'package:flutter/foundation.dart';

/// Configuration accessors. Paid API keys are no longer required for offline
/// builds (Open-Meteo, TideTurtle, OSM/OpenSeaMap).
class PropertiesManager {
  static var _instance = PropertiesManager._();

  static PropertiesManager get get => _instance;

  @visibleForTesting
  static void set(PropertiesManager manager) => _instance = manager;

  @visibleForTesting
  static void reset() => _instance = PropertiesManager._();

  PropertiesManager._();

  /// Kept for test mocks / legacy call sites; unused by maps after Mapbox removal.
  String get mapboxApiKey => "";
}
