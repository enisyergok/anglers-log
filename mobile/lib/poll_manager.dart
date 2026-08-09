import 'dart:async';

import 'package:adair_flutter_lib/utils/log.dart';
import 'package:adair_flutter_lib/utils/void_stream_controller.dart';
import 'package:flutter/material.dart';

import 'model/gen/user_polls.pb.dart';

/// Offline / local stub — no Firebase Realtime Database calls.
class PollManager {
  static var _instance = PollManager._();

  static PollManager get get => _instance;

  @visibleForTesting
  static void set(PollManager manager) => _instance = manager;

  @visibleForTesting
  static void reset() => _instance = PollManager._();

  PollManager._();

  static const _log = Log("PollManager");

  final _controller = VoidStreamController();

  Polls? polls;

  Stream<void> get stream => _controller.stream;

  bool get canVote => canVoteFree || canVotePro;

  bool get canVoteFree => false;

  bool get canVotePro => false;

  bool get hasFreePoll => false;

  bool get hasProPoll => false;

  bool get hasPoll => false;

  Future<void> initialize() async {
    await fetchPolls();
  }

  Future<void> fetchPolls() async {
    _log.d("Polls disabled (offline/local build)");
    polls = null;
  }

  Future<bool> vote(Poll poll, Option option) async {
    _log.d("Vote ignored (offline/local build)");
    _controller.notify();
    return false;
  }
}
