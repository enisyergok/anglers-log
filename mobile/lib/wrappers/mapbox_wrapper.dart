import 'package:flutter/material.dart';

class MapboxWrapper {
  static var _instance = MapboxWrapper._();

  static MapboxWrapper get get => _instance;

  @visibleForTesting
  static void set(MapboxWrapper manager) => _instance = manager;

  @visibleForTesting
  static void reset() => _instance = MapboxWrapper._();

  MapboxWrapper._();

  /// No-op: Mapbox access tokens are no longer required.
  void setAccessToken(String token) {}
}
