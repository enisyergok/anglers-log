import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:adair_flutter_lib/wrappers/path_provider_wrapper.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

/// Persists fish-activity snapshot keyed by catch id (uuid string).
class MeraCatchActivitySnapshot {
  final String catchId;
  final double score;
  final String level;
  final String speciesKey;
  final String speciesName;
  final double? lat;
  final double? lng;
  final int computedAtMs;
  final Map<String, dynamic>? envSummary;

  const MeraCatchActivitySnapshot({
    required this.catchId,
    required this.score,
    required this.level,
    required this.speciesKey,
    required this.speciesName,
    this.lat,
    this.lng,
    required this.computedAtMs,
    this.envSummary,
  });

  Map<String, dynamic> toJson() => {
        'catchId': catchId,
        'score': score,
        'level': level,
        'speciesKey': speciesKey,
        'speciesName': speciesName,
        if (lat != null) 'lat': lat,
        if (lng != null) 'lng': lng,
        'computedAtMs': computedAtMs,
        if (envSummary != null) 'envSummary': envSummary,
      };

  factory MeraCatchActivitySnapshot.fromJson(Map<String, dynamic> json) =>
      MeraCatchActivitySnapshot(
        catchId: json['catchId'].toString(),
        score: (json['score'] as num).toDouble(),
        level: json['level']?.toString() ?? '',
        speciesKey: json['speciesKey']?.toString() ?? '',
        speciesName: json['speciesName']?.toString() ?? '',
        lat: (json['lat'] as num?)?.toDouble(),
        lng: (json['lng'] as num?)?.toDouble(),
        computedAtMs: (json['computedAtMs'] as num?)?.toInt() ?? 0,
        envSummary: json['envSummary'] is Map
            ? Map<String, dynamic>.from(json['envSummary'] as Map)
            : null,
      );
}

class MeraCatchActivityStore {
  static const _fileName = 'mera_catch_activity.json';

  static var _instance = MeraCatchActivityStore._();
  static MeraCatchActivityStore get get => _instance;

  @visibleForTesting
  static void set(MeraCatchActivityStore s) => _instance = s;

  @visibleForTesting
  static void reset() => _instance = MeraCatchActivityStore._();

  MeraCatchActivityStore._();

  final _controller = StreamController<void>.broadcast();
  Stream<void> get stream => _controller.stream;

  final Map<String, MeraCatchActivitySnapshot> _byCatchId = {};
  var _loaded = false;

  Future<void> ensureLoaded() async {
    if (_loaded) return;
    try {
      final file = await _file();
      if (await file.exists()) {
        final raw = jsonDecode(await file.readAsString());
        if (raw is Map) {
          for (final e in raw.entries) {
            if (e.value is Map) {
              _byCatchId[e.key.toString()] = MeraCatchActivitySnapshot.fromJson(
                Map<String, dynamic>.from(e.value as Map),
              );
            }
          }
        }
      }
    } catch (_) {
      // ignore corrupt cache
    }
    _loaded = true;
  }

  MeraCatchActivitySnapshot? forCatch(String catchId) => _byCatchId[catchId];

  List<MeraCatchActivitySnapshot> get all =>
      _byCatchId.values.toList(growable: false);

  int get count => _byCatchId.length;

  double? get averageScore {
    if (_byCatchId.isEmpty) return null;
    var sum = 0.0;
    for (final s in _byCatchId.values) {
      sum += s.score;
    }
    return sum / _byCatchId.length;
  }

  Future<void> put(MeraCatchActivitySnapshot snap) async {
    await ensureLoaded();
    _byCatchId[snap.catchId] = snap;
    await _persist();
    _controller.add(null);
  }

  Future<void> remove(String catchId) async {
    await ensureLoaded();
    if (_byCatchId.remove(catchId) != null) {
      await _persist();
      _controller.add(null);
    }
  }

  Future<File> _file() async {
    final docs = await PathProviderWrapper.get.appDocumentsPath;
    return File(p.join(docs, _fileName));
  }

  Future<void> _persist() async {
    final file = await _file();
    final map = <String, dynamic>{};
    for (final e in _byCatchId.entries) {
      map[e.key] = e.value.toJson();
    }
    await file.writeAsString(jsonEncode(map));
  }
}
