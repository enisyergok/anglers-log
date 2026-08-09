import 'package:flutter/material.dart';

/// Offline / local stub — no Firebase Crashlytics calls.
class CrashlyticsWrapper {
  static var _instance = CrashlyticsWrapper._();

  static CrashlyticsWrapper get get => _instance;

  @visibleForTesting
  static void set(CrashlyticsWrapper manager) => _instance = manager;

  @visibleForTesting
  static void reset() => _instance = CrashlyticsWrapper._();

  CrashlyticsWrapper._();

  Future<void> setCrashlyticsCollectionEnabled(bool enabled) => Future.value();

  Future<void> recordFlutterFatalError(FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
    return Future.value();
  }

  Future<void> log(String message) => Future.value();

  Future<void> setUserId(String identifier) => Future.value();

  Future<void> setCustomKey(String key, Object value) => Future.value();

  Future<void> recordError(
    dynamic message,
    StackTrace? stack, {
    dynamic reason,
    Iterable<Object> information = const [],
    bool? printDetails,
    bool fatal = false,
  }) {
    if (printDetails ?? true) {
      // ignore: avoid_print
      print("CrashlyticsStub: $message\n$stack");
    }
    return Future.value();
  }
}
