import 'package:adair_flutter_lib/managers/subscription_manager.dart';
import 'package:flutter/foundation.dart';

/// Whether Pro-gated features should be available to the current user.
///
/// In debug and profile builds this always returns `true`, so Pro features
/// can be exercised locally without a live RevenueCat connection. Release
/// builds (including the ones produced by CI) are unaffected and always
/// defer to the real entitlement state from [SubscriptionManager].
bool get hasProAccess => !kReleaseMode || SubscriptionManager.get.isPro;
