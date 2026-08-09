import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:adair_flutter_lib/wrappers/path_provider_wrapper.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

class MeraRoutePoint {
  final double lat;
  final double lng;
  final String? label;

  const MeraRoutePoint({required this.lat, required this.lng, this.label});

  Map<String, dynamic> toJson() => {
    'lat': lat,
    'lng': lng,
    if (label != null) 'label': label,
  };

  factory MeraRoutePoint.fromJson(Map<String, dynamic> json) => MeraRoutePoint(
    lat: (json['lat'] as num).toDouble(),
    lng: (json['lng'] as num).toDouble(),
    label: json['label'] as String?,
  );
}

class MeraRoute {
  final String id;
  final String name;
  final List<MeraRoutePoint> points;
  final int createdMs;

  /// Fallback cruise speed when no boat profile is available.
  static const cruiseKnots = 7.4;

  const MeraRoute({
    required this.id,
    required this.name,
    required this.points,
    required this.createdMs,
  });

  double get distanceMeters {
    var total = 0.0;
    for (var i = 0; i < points.length - 1; i++) {
      total += _haversine(points[i], points[i + 1]);
    }
    return total;
  }

  double get distanceNm => distanceMeters / 1852.0;

  /// Estimated time at [knots] (defaults to [cruiseKnots]).
  Duration estimatedAt({double knots = cruiseKnots}) {
    if (distanceNm <= 0 || knots <= 0) {
      return Duration.zero;
    }
    final hours = distanceNm / knots;
    return Duration(minutes: (hours * 60).round());
  }

  /// Estimated time at the built-in default cruise speed.
  Duration get estimatedAt7kn => estimatedAt();

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'points': points.map((e) => e.toJson()).toList(),
    'createdMs': createdMs,
  };

  factory MeraRoute.fromJson(Map<String, dynamic> json) => MeraRoute(
    id: json['id'].toString(),
    name: json['name'].toString(),
    points: (json['points'] as List<dynamic>)
        .map((e) => MeraRoutePoint.fromJson(e as Map<String, dynamic>))
        .toList(),
    createdMs: (json['createdMs'] as num).toInt(),
  );

  static double _haversine(MeraRoutePoint a, MeraRoutePoint b) {
    const r = 6371000.0;
    final dLat = _rad(b.lat - a.lat);
    final dLng = _rad(b.lng - a.lng);
    final lat1 = _rad(a.lat);
    final lat2 = _rad(b.lat);
    final h =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) *
            math.cos(lat2) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    return 2 * r * math.asin(math.sqrt(h));
  }

  static double _rad(double d) => d * math.pi / 180.0;
}

class MeraRouteManager {
  static const _fileName = 'mera_routes.json';

  static var _instance = MeraRouteManager._();
  static MeraRouteManager get get => _instance;

  @visibleForTesting
  static void set(MeraRouteManager m) => _instance = m;

  @visibleForTesting
  static void reset() => _instance = MeraRouteManager._();

  /// When true, empty first load shows in-memory demo routes (not persisted).
  @visibleForTesting
  static var debugSeedDemoRoutes = false;

  MeraRouteManager._();

  final _controller = StreamController<void>.broadcast();
  Stream<void> get stream => _controller.stream;

  List<MeraRoute> _routes = [];
  var _loaded = false;
  Future<void>? _loading;

  List<MeraRoute> get routes => List.unmodifiable(_routes);

  Future<void> ensureLoaded() async {
    if (_loaded) return;
    _loading ??= _load();
    await _loading;
  }

  Future<void> _load() async {
    try {
      final file = await _file();
      if (await file.exists()) {
        final raw = jsonDecode(await file.readAsString()) as List<dynamic>;
        final parsed = <MeraRoute>[];
        for (final e in raw) {
          try {
            parsed.add(MeraRoute.fromJson(e as Map<String, dynamic>));
          } catch (_) {}
        }
        _routes = parsed;
      } else {
        // Honest empty start — never seed Bodrum/Moda demos as user data.
        // Opt-in only via debug flag (in-memory; not persisted).
        _routes = debugSeedDemoRoutes ? _seedDemoRoutes() : [];
      }
    } catch (_) {
      _routes = debugSeedDemoRoutes ? _seedDemoRoutes() : [];
    }
    _loaded = true;
  }

  Future<MeraRoute> add({
    required String name,
    required List<MeraRoutePoint> points,
  }) async {
    await ensureLoaded();
    final route = MeraRoute(
      id: const Uuid().v4(),
      name: name,
      points: points,
      createdMs: DateTime.now().millisecondsSinceEpoch,
    );
    _routes = [route, ..._routes];
    await _persist();
    _controller.add(null);
    return route;
  }

  Future<void> delete(String id) async {
    await ensureLoaded();
    _routes = _routes.where((r) => r.id != id).toList();
    await _persist();
    _controller.add(null);
  }

  Future<void> rename(String id, String name) async {
    await ensureLoaded();
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    _routes = [
      for (final r in _routes)
        if (r.id == id)
          MeraRoute(
            id: r.id,
            name: trimmed,
            points: r.points,
            createdMs: r.createdMs,
          )
        else
          r,
    ];
    await _persist();
    _controller.add(null);
  }

  Future<void> updatePoints(String id, List<MeraRoutePoint> points) async {
    await ensureLoaded();
    if (points.length < 2) return;
    _routes = [
      for (final r in _routes)
        if (r.id == id)
          MeraRoute(
            id: r.id,
            name: r.name,
            points: points,
            createdMs: r.createdMs,
          )
        else
          r,
    ];
    await _persist();
    _controller.add(null);
  }

  MeraRoute? byId(String id) {
    for (final r in _routes) {
      if (r.id == id) return r;
    }
    return null;
  }

  Future<File> _file() async {
    final docs = await PathProviderWrapper.get.appDocumentsPath;
    return File(p.join(docs, _fileName));
  }

  Future<void> _persist() async {
    final file = await _file();
    await file.writeAsString(
      jsonEncode(_routes.map((e) => e.toJson()).toList()),
    );
  }

  List<MeraRoute> _seedDemoRoutes() {
    final now = DateTime.now().millisecondsSinceEpoch;
    return [
      MeraRoute(
        id: 'demo-bodrum',
        name: 'Bodrum - Yalıkavak',
        createdMs: now - Duration(days: 3).inMilliseconds,
        points: const [
          MeraRoutePoint(lat: 37.034, lng: 27.430, label: '1'),
          MeraRoutePoint(lat: 37.055, lng: 27.360, label: '2'),
          MeraRoutePoint(lat: 37.105, lng: 27.290, label: '3'),
        ],
      ),
      MeraRoute(
        id: 'demo-marmara',
        name: 'Moda - Adalar',
        createdMs: now - Duration(days: 10).inMilliseconds,
        points: const [
          MeraRoutePoint(lat: 40.980, lng: 29.025, label: '1'),
          MeraRoutePoint(lat: 40.900, lng: 29.080, label: '2'),
          MeraRoutePoint(lat: 40.870, lng: 29.120, label: '3'),
        ],
      ),
    ];
  }
}
