import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

typedef NonFatalMatcher = bool Function(Object error, StackTrace? stack);

/// Sets up error handlers. Firebase Analytics / Crashlytics are disabled for
/// offline / local builds — this is intentionally a no-op beyond basic logging.
///
/// Must still be called before [runApp] so call sites remain unchanged.
Future<void> setupFirebase({
  bool isRelease = kReleaseMode,
  FirebaseOptions? options,
  NonFatalMatcher? nonFatalMatcher,
}) async {
  // Offline/local: do not initialize Firebase.
  FlutterError.onError = (details) {
    FlutterError.dumpErrorToConsole(details);
  };
}

@visibleForTesting
Future<void> handleIsolateError(dynamic pair) async {
  // No-op: Crashlytics disabled.
}
