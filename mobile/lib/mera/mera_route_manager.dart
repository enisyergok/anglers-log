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

  /// Estimated time at 7 kn cruise.
  Duration get estimatedAt7kn {
    if (distanceNm <= 0) {
      return Duration.zero;
    }
    final hours = distanceNm / 7.0;
    return Duration(minutes: (hours * 60).round());
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'points': points.map((e) => e.toJson()).toList(),
    'createdMs': createdMs,
  };

  factory MeraRoute.fromJson(Map<String, dynamic> json) => MeraRoute(
    id: json['id'] as String,
    name: json['name'] as String,
    points: (json['points'] as List<dynamic>)
        .map((e) => MeraRoutePoint.fromJson(e as Map<String, dynamic>))
        .toList(),
    createdMs: json['createdMs'] as int,
  );

  static double _haversine(MeraRoutePoint a, MeraRoutePoint b) {
    const r = 6371000.0;
    final dLat = _rad(b.lat - a.lat);
    final dLng = _rad(b.lng - a.lng);
    final lat1 = _rad(a.lat);
    final lat2 = _rad(b.lat);
    final h =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) * math.cos(lat2) * math.sin(dLng / 2) * math.sin(dLng / 2);
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

  MeraRouteManager._();

  final _controller = StreamController<void>.broadcast();
  Stream<void> get stream => _controller.stream;

  List<MeraRoute> _routes = [];
  var _loaded = false;

  List<MeraRoute> get routes => List.unmodifiable(_routes);

  Future<void> ensureLoaded() async {
    if (_loaded) {
      return;
    }
    try {
      final file = await _file();
      if (await file.exists()) {
        final raw = jsonDecode(await file.readAsString()) as List<dynamic>;
        _routes = raw
            .map((e) => MeraRoute.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {
      _routes = [];
    }
    if (_routes.isEmpty) {
      _routes = _seedDemoRoutes();
      await _persist();
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

  MeraRoute? byId(String id) {
    for (final r in _routes) {
      if (r.id == id) {
        return r;
      }
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
