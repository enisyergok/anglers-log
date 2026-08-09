import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:adair_flutter_lib/utils/log.dart';
import 'package:flutter/foundation.dart';

/// Parsed depth / AIS-ish fields from NMEA 0183 sentences.
class NmeaSnapshot {
  final double? depthM;
  final double? sogKnots;
  final double? cogDegrees;
  final DateTime updatedAt;

  const NmeaSnapshot({
    this.depthM,
    this.sogKnots,
    this.cogDegrees,
    required this.updatedAt,
  });

  NmeaSnapshot copyWith({
    double? depthM,
    double? sogKnots,
    double? cogDegrees,
  }) {
    return NmeaSnapshot(
      depthM: depthM ?? this.depthM,
      sogKnots: sogKnots ?? this.sogKnots,
      cogDegrees: cogDegrees ?? this.cogDegrees,
      updatedAt: DateTime.now(),
    );
  }
}

/// Parses common NMEA 0183 depth/speed sentences (DBT, DPT, VTG, RMC).
class NmeaParser {
  static NmeaSnapshot? apply(String sentence, NmeaSnapshot? previous) {
    final line = sentence.trim();
    if (!line.startsWith('\$') && !line.startsWith('!')) {
      return previous;
    }
    final body = line.split('*').first;
    final parts = body.split(',');
    if (parts.isEmpty) {
      return previous;
    }
    final type = parts[0].length >= 3
        ? parts[0].substring(parts[0].length - 3)
        : parts[0];

    var snap =
        previous ?? NmeaSnapshot(updatedAt: DateTime.now());

    switch (type) {
      case 'DBT':
        // $--DBT,x.x,f,y.y,M,z.z,F
        final meters = _d(parts, 3);
        if (meters != null) {
          snap = snap.copyWith(depthM: meters);
        } else {
          final feet = _d(parts, 1);
          if (feet != null) {
            snap = snap.copyWith(depthM: feet * 0.3048);
          }
        }
        break;
      case 'DPT':
        // $--DPT,depth,offset,...
        final depth = _d(parts, 1);
        if (depth != null) {
          snap = snap.copyWith(depthM: depth);
        }
        break;
      case 'VTG':
        // course true at 1, speed knots at 5
        final cog = _d(parts, 1);
        final sog = _d(parts, 5);
        snap = snap.copyWith(cogDegrees: cog, sogKnots: sog);
        break;
      case 'RMC':
        // speed knots at 7, course at 8
        final sog = _d(parts, 7);
        final cog = _d(parts, 8);
        snap = snap.copyWith(sogKnots: sog, cogDegrees: cog);
        break;
    }
    return snap;
  }

  static double? _d(List<String> parts, int i) {
    if (i >= parts.length) {
      return null;
    }
    return double.tryParse(parts[i]);
  }
}

/// Listens for NMEA 0183 over UDP (typical Wi-Fi multiplexers).
class NmeaUdpListener {
  static var _instance = NmeaUdpListener._();
  static NmeaUdpListener get get => _instance;

  @visibleForTesting
  static void set(NmeaUdpListener l) => _instance = l;

  NmeaUdpListener._();

  final _log = const Log('NmeaUdpListener');
  final _controller = StreamController<NmeaSnapshot>.broadcast();

  RawDatagramSocket? _socket;
  NmeaSnapshot? _latest;
  var _running = false;

  Stream<NmeaSnapshot> get stream => _controller.stream;
  NmeaSnapshot? get latest => _latest;
  bool get isRunning => _running;

  Future<void> start({int port = 10110}) async {
    if (_running) {
      return;
    }
    try {
      _socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, port);
      _socket!.broadcastEnabled = true;
      _running = true;
      _socket!.listen((event) {
        if (event != RawSocketEvent.read) {
          return;
        }
        final dg = _socket!.receive();
        if (dg == null) {
          return;
        }
        final text = utf8.decode(dg.data, allowMalformed: true);
        for (final line in text.split(RegExp(r'[\r\n]+'))) {
          if (line.isEmpty) {
            continue;
          }
          final next = NmeaParser.apply(line, _latest);
          if (next != null) {
            _latest = next;
            _controller.add(next);
          }
        }
      });
      _log.d('Listening UDP $port');
    } catch (e, st) {
      _log.e(e, reason: 'NMEA bind failed', stackTrace: st);
      _running = false;
      rethrow;
    }
  }

  Future<void> stop() async {
    _socket?.close();
    _socket = null;
    _running = false;
  }
}
