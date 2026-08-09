import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:adair_flutter_lib/wrappers/path_provider_wrapper.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

/// Local captain / boat profile (Gemim + Ayarlar → Profil).
class MeraBoatProfile {
  static const defaultCruiseKnots = 7.4;

  final String captainName;
  final String boatName;
  final double fuelPercent;
  /// Cruise speed used for route ETA when NMEA SOG is unavailable.
  final double cruiseKnots;

  const MeraBoatProfile({
    this.captainName = 'Kaptan',
    this.boatName = 'Teknem',
    this.fuelPercent = 68,
    this.cruiseKnots = defaultCruiseKnots,
  });

  MeraBoatProfile copyWith({
    String? captainName,
    String? boatName,
    double? fuelPercent,
    double? cruiseKnots,
  }) {
    return MeraBoatProfile(
      captainName: captainName ?? this.captainName,
      boatName: boatName ?? this.boatName,
      fuelPercent: fuelPercent ?? this.fuelPercent,
      cruiseKnots: cruiseKnots ?? this.cruiseKnots,
    );
  }

  Map<String, dynamic> toJson() => {
    'captainName': captainName,
    'boatName': boatName,
    'fuelPercent': fuelPercent,
    'cruiseKnots': cruiseKnots,
  };

  factory MeraBoatProfile.fromJson(Map<String, dynamic> json) =>
      MeraBoatProfile(
        captainName: (json['captainName'] as String?)?.trim().isNotEmpty == true
            ? json['captainName'] as String
            : 'Kaptan',
        boatName: (json['boatName'] as String?)?.trim().isNotEmpty == true
            ? json['boatName'] as String
            : 'Teknem',
        fuelPercent: ((json['fuelPercent'] as num?)?.toDouble() ?? 68)
            .clamp(0, 100),
        cruiseKnots: ((json['cruiseKnots'] as num?)?.toDouble() ??
                defaultCruiseKnots)
            .clamp(0.5, 60),
      );
}

class MeraBoatProfileManager {
  static const _fileName = 'mera_boat_profile.json';

  static var _instance = MeraBoatProfileManager._();
  static MeraBoatProfileManager get get => _instance;

  @visibleForTesting
  static void set(MeraBoatProfileManager m) => _instance = m;

  @visibleForTesting
  static void reset() => _instance = MeraBoatProfileManager._();

  MeraBoatProfileManager._();

  final _controller = StreamController<void>.broadcast();
  Stream<void> get stream => _controller.stream;

  MeraBoatProfile _profile = const MeraBoatProfile();
  var _loaded = false;
  Future<void>? _loading;

  MeraBoatProfile get profile => _profile;

  Future<void> ensureLoaded() async {
    if (_loaded) return;
    _loading ??= _load();
    await _loading;
  }

  Future<void> _load() async {
    try {
      final file = await _file();
      if (await file.exists()) {
        final raw = jsonDecode(await file.readAsString());
        if (raw is Map<String, dynamic>) {
          _profile = MeraBoatProfile.fromJson(raw);
        }
      }
    } catch (_) {}
    _loaded = true;
    _controller.add(null);
  }

  Future<void> save(MeraBoatProfile next) async {
    await ensureLoaded();
    _profile = next;
    final file = await _file();
    await file.writeAsString(jsonEncode(_profile.toJson()));
    _controller.add(null);
  }

  Future<File> _file() async {
    final docs = await PathProviderWrapper.get.appDocumentsPath;
    return File(p.join(docs, _fileName));
  }
}
