import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:adair_flutter_lib/utils/log.dart';
import 'package:adair_flutter_lib/wrappers/path_provider_wrapper.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

/// Local-first fishing ground (mera) pin — depth + bottom type notes.
class MeraSpot {
  final String id;
  final double lat;
  final double lng;
  final double? depthM;
  final String? bottomType;
  final String? note;
  final int timestampMs;

  const MeraSpot({
    required this.id,
    required this.lat,
    required this.lng,
    this.depthM,
    this.bottomType,
    this.note,
    required this.timestampMs,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'lat': lat,
    'lng': lng,
    if (depthM != null) 'depthM': depthM,
    if (bottomType != null) 'bottomType': bottomType,
    if (note != null) 'note': note,
    'timestampMs': timestampMs,
  };

  factory MeraSpot.fromJson(Map<String, dynamic> json) => MeraSpot(
    id: json['id'] as String,
    lat: (json['lat'] as num).toDouble(),
    lng: (json['lng'] as num).toDouble(),
    depthM: (json['depthM'] as num?)?.toDouble(),
    bottomType: json['bottomType'] as String?,
    note: json['note'] as String?,
    timestampMs: json['timestampMs'] as int,
  );

  MeraSpot copyWith({
    double? depthM,
    String? bottomType,
    String? note,
    bool clearNote = false,
    bool clearBottomType = false,
  }) {
    return MeraSpot(
      id: id,
      lat: lat,
      lng: lng,
      depthM: depthM ?? this.depthM,
      bottomType: clearBottomType ? null : (bottomType ?? this.bottomType),
      note: clearNote ? null : (note ?? this.note),
      timestampMs: timestampMs,
    );
  }
}

/// Persists mera spots as JSON on device; export/import without cloud.
class MeraManager {
  static const _fileName = 'mera_spots.json';

  static var _instance = MeraManager._();
  static MeraManager get get => _instance;

  @visibleForTesting
  static void set(MeraManager m) => _instance = m;

  @visibleForTesting
  static void reset() => _instance = MeraManager._();

  MeraManager._();

  final _log = const Log('MeraManager');
  final _controller = StreamController<void>.broadcast();
  final _spots = <MeraSpot>[];
  File? _file;

  Stream<void> get stream => _controller.stream;
  List<MeraSpot> get spots => List.unmodifiable(_spots);

  Future<void> init() async {
    final docs = await PathProviderWrapper.get.appDocumentsPath;
    _file = File(p.join(docs, _fileName));
    if (await _file!.exists()) {
      try {
        final raw = jsonDecode(await _file!.readAsString()) as List<dynamic>;
        _spots
          ..clear()
          ..addAll(
            raw.map((e) => MeraSpot.fromJson(e as Map<String, dynamic>)),
          );
      } catch (e) {
        _log.e(e, reason: 'Failed to load mera spots');
      }
    }
    _notify();
  }

  Future<MeraSpot> add({
    required double lat,
    required double lng,
    double? depthM,
    String? bottomType,
    String? note,
  }) async {
    final spot = MeraSpot(
      id: const Uuid().v4(),
      lat: lat,
      lng: lng,
      depthM: depthM,
      bottomType: bottomType,
      note: note,
      timestampMs: DateTime.now().millisecondsSinceEpoch,
    );
    _spots.add(spot);
    await _persist();
    return spot;
  }

  Future<void> remove(String id) async {
    _spots.removeWhere((s) => s.id == id);
    await _persist();
  }

  Future<void> update(MeraSpot spot) async {
    final i = _spots.indexWhere((s) => s.id == spot.id);
    if (i < 0) return;
    _spots[i] = spot;
    await _persist();
  }

  MeraSpot? byId(String id) {
    for (final s in _spots) {
      if (s.id == id) return s;
    }
    return null;
  }

  /// JSON export for QR/file share.
  String exportJson() =>
      const JsonEncoder.withIndent('  ').convert(_spots.map((e) => e.toJson()).toList());

  Future<int> importJson(String json) async {
    final raw = jsonDecode(json) as List<dynamic>;
    var added = 0;
    for (final e in raw) {
      final spot = MeraSpot.fromJson(e as Map<String, dynamic>);
      if (_spots.any((s) => s.id == spot.id)) {
        continue;
      }
      _spots.add(spot);
      added++;
    }
    await _persist();
    return added;
  }

  /// Minimal GPX of mera waypoints.
  String exportGpx() {
    final buf = StringBuffer()
      ..writeln('<?xml version="1.0" encoding="UTF-8"?>')
      ..writeln('<gpx version="1.1" creator="BalikciGunlugu">')
      ..writeln('<metadata><name>Mera noktaları</name></metadata>');
    for (final s in _spots) {
      buf.writeln(
        '<wpt lat="${s.lat}" lon="${s.lng}"><name>${s.bottomType ?? 'mera'}</name>'
        '<desc>depth=${s.depthM ?? ''} ${s.note ?? ''}</desc></wpt>',
      );
    }
    buf.writeln('</gpx>');
    return buf.toString();
  }

  Future<void> _persist() async {
    if (_file == null) {
      await init();
    }
    await _file!.writeAsString(exportJson());
    _notify();
  }

  void _notify() {
    if (!_controller.isClosed) {
      _controller.add(null);
    }
  }
}
