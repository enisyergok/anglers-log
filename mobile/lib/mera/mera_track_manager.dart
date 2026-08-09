import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:adair_flutter_lib/wrappers/path_provider_wrapper.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

class MeraTrackPoint {
  final double lat;
  final double lng;
  final int timestampMs;
  final double? depthM;
  final double? sogKnots;

  const MeraTrackPoint({
    required this.lat,
    required this.lng,
    required this.timestampMs,
    this.depthM,
    this.sogKnots,
  });

  Map<String, dynamic> toJson() => {
        'lat': lat,
        'lng': lng,
        'timestampMs': timestampMs,
        if (depthM != null) 'depthM': depthM,
        if (sogKnots != null) 'sogKnots': sogKnots,
      };

  factory MeraTrackPoint.fromJson(Map<String, dynamic> json) => MeraTrackPoint(
        lat: (json['lat'] as num).toDouble(),
        lng: (json['lng'] as num).toDouble(),
        timestampMs: (json['timestampMs'] as num).toInt(),
        depthM: (json['depthM'] as num?)?.toDouble(),
        sogKnots: (json['sogKnots'] as num?)?.toDouble(),
      );
}

class MeraTrack {
  final String id;
  final String name;
  final List<MeraTrackPoint> points;
  final int startedMs;
  final int? endedMs;

  const MeraTrack({
    required this.id,
    required this.name,
    required this.points,
    required this.startedMs,
    this.endedMs,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'points': points.map((e) => e.toJson()).toList(),
        'startedMs': startedMs,
        if (endedMs != null) 'endedMs': endedMs,
      };

  factory MeraTrack.fromJson(Map<String, dynamic> json) => MeraTrack(
        id: json['id'].toString(),
        name: json['name']?.toString() ?? 'İz',
        points: (json['points'] as List? ?? [])
            .map((e) => MeraTrackPoint.fromJson(e as Map<String, dynamic>))
            .toList(),
        startedMs: (json['startedMs'] as num).toInt(),
        endedMs: (json['endedMs'] as num?)?.toInt(),
      );

  String toGpx() {
    final buf = StringBuffer()
      ..writeln('<?xml version="1.0" encoding="UTF-8"?>')
      ..writeln(
        '<gpx version="1.1" creator="MeraAsistan" xmlns="http://www.topografix.com/GPX/1/1">',
      )
      ..writeln('<trk><name>${_xml(name)}</name><trkseg>');
    for (final p in points) {
      buf.writeln(
        '<trkpt lat="${p.lat}" lon="${p.lng}"><time>${DateTime.fromMillisecondsSinceEpoch(p.timestampMs).toUtc().toIso8601String()}</time></trkpt>',
      );
    }
    buf.writeln('</trkseg></trk></gpx>');
    return buf.toString();
  }

  static String _xml(String s) => s
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;');
}

/// Live track + depth trail recorder (local JSON).
class MeraTrackManager {
  static const _fileName = 'mera_tracks.json';

  static var _instance = MeraTrackManager._();
  static MeraTrackManager get get => _instance;

  @visibleForTesting
  static void set(MeraTrackManager m) => _instance = m;

  @visibleForTesting
  static void reset() => _instance = MeraTrackManager._();

  MeraTrackManager._();

  final _controller = StreamController<void>.broadcast();
  Stream<void> get stream => _controller.stream;

  final List<MeraTrack> _tracks = [];
  MeraTrack? _active;
  var _loaded = false;

  bool get isRecording => _active != null;
  MeraTrack? get active => _active;
  List<MeraTrack> get tracks => List.unmodifiable(_tracks);
  List<MeraTrackPoint> get livePoints =>
      List.unmodifiable(_active?.points ?? const []);

  Future<void> ensureLoaded() async {
    if (_loaded) return;
    try {
      final file = await _file();
      if (await file.exists()) {
        final raw = jsonDecode(await file.readAsString());
        if (raw is List) {
          for (final e in raw) {
            if (e is Map) {
              _tracks.add(
                MeraTrack.fromJson(Map<String, dynamic>.from(e)),
              );
            }
          }
        }
      }
    } catch (_) {}
    _loaded = true;
  }

  Future<void> start({String? name}) async {
    await ensureLoaded();
    if (_active != null) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    _active = MeraTrack(
      id: const Uuid().v4(),
      name: name ??
          'İz ${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}',
      points: const [],
      startedMs: now,
    );
    _controller.add(null);
  }

  Future<void> append({
    required double lat,
    required double lng,
    double? depthM,
    double? sogKnots,
  }) async {
    final a = _active;
    if (a == null) return;
    // Throttle: skip if < 8 m from last point (approx 0.00008 deg).
    if (a.points.isNotEmpty) {
      final last = a.points.last;
      final dLat = (lat - last.lat).abs();
      final dLng = (lng - last.lng).abs();
      if (dLat < 0.00008 && dLng < 0.00008) return;
    }
    final pt = MeraTrackPoint(
      lat: lat,
      lng: lng,
      timestampMs: DateTime.now().millisecondsSinceEpoch,
      depthM: depthM,
      sogKnots: sogKnots,
    );
    _active = MeraTrack(
      id: a.id,
      name: a.name,
      points: [...a.points, pt],
      startedMs: a.startedMs,
    );
    _controller.add(null);
  }

  Future<MeraTrack?> stop() async {
    final a = _active;
    if (a == null) return null;
    final done = MeraTrack(
      id: a.id,
      name: a.name,
      points: a.points,
      startedMs: a.startedMs,
      endedMs: DateTime.now().millisecondsSinceEpoch,
    );
    _active = null;
    if (done.points.length >= 2) {
      _tracks.insert(0, done);
      await _persist();
    }
    _controller.add(null);
    return done;
  }

  Future<void> delete(String id) async {
    await ensureLoaded();
    _tracks.removeWhere((t) => t.id == id);
    await _persist();
    _controller.add(null);
  }

  Future<void> _persist() async {
    final file = await _file();
    await file.writeAsString(
      jsonEncode(_tracks.map((e) => e.toJson()).toList()),
    );
  }

  Future<File> _file() async {
    final docs = await PathProviderWrapper.get.appDocumentsPath;
    return File(p.join(docs, _fileName));
  }
}
