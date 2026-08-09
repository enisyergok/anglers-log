import 'dart:async';

import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../utils/log.dart';
import '../utils/void_stream_controller.dart';
import 'manager.dart';

final _log = const Log("SubscriptionManager");

enum SubscriptionState { pro, free }

enum RestoreSubscriptionResult { noSubscriptionsFound, error, success }

/// Manages a user's subscription state.
///
/// Offline / local build: RevenueCat is skipped and every user is treated as
/// Pro so paid features remain available without a store or API keys.
class SubscriptionManager implements Manager {
  static var _instance = SubscriptionManager._();

  static SubscriptionManager get get => _instance;

  @visibleForTesting
  static void set(SubscriptionManager manager) => _instance = manager;

  @visibleForTesting
  static void reset() => _instance = SubscriptionManager._();

  SubscriptionManager._();

  final _controller = VoidStreamController();

  var _state = SubscriptionState.pro;

  bool get isFree => !isPro;

  bool get isPro => true;

  /// A [Stream] that fires events when [state] updates. Listeners should
  /// access the [state] property directly, as it will always have a valid
  /// value, unlike the [AsyncSnapshot] passed to the listener function.
  Stream<void> get stream => _controller.stream;

  Future<String> get userId async => "local-pro-user";

  @override
  Future<void> init() async {
    // Skip RevenueCat entirely for offline/local builds.
    _state = SubscriptionState.pro;
    _log.d("SubscriptionManager: forced Pro (RevenueCat disabled)");
  }

  Future<void> purchaseSubscription(Subscription sub) async {
    _state = SubscriptionState.pro;
    _controller.notify();
  }

  Future<RestoreSubscriptionResult> restoreSubscription() async {
    _state = SubscriptionState.pro;
    _controller.notify();
    return RestoreSubscriptionResult.success;
  }

  Future<Subscriptions?> subscriptions() async {
    // No store offerings in offline builds.
    return null;
  }
}

class Subscription {
  final Package package;

  Subscription(this.package);

  String get price => package.storeProduct.priceString;

  int? get trialLengthDays {
    var introPrice = package.storeProduct.introductoryPrice;
    if (introPrice == null) {
      return null;
    }
    var result = 0;

    switch (introPrice.periodUnit) {
      case PeriodUnit.day:
        result = 1;
      case PeriodUnit.week:
        result = 7;
      case PeriodUnit.month:
        result = 30;
      case PeriodUnit.year:
        result = 365;
      case PeriodUnit.unknown:
        _log.e(
          Exception("Invalid period unit found: ${introPrice.periodUnit}"),
        );
        result = 0;
    }

    return result * introPrice.periodNumberOfUnits;
  }
}

/// A convenience class that stores subscription options. A single class like
/// this is easier to manage than a collection of subscriptions, especially
/// when the options shouldn't change.
class Subscriptions {
  final Subscription monthly;
  final Subscription yearly;

  Subscriptions(this.monthly, this.yearly);
}
