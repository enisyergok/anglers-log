import 'dart:convert';
import 'dart:math';

import 'package:latlong2/latlong.dart';

/// Pure geometry helpers for A–B routing and shallow-water checks.
class NavGeo {
  NavGeo._();

  static const _earthRadiusM = 6371000.0;

  /// Great-circle distance in meters.
  static double haversineMeters(LatLng a, LatLng b) {
    final dLat = _rad(b.latitude - a.latitude);
    final dLon = _rad(b.longitude - a.longitude);
    final lat1 = _rad(a.latitude);
    final lat2 = _rad(b.latitude);
    final h =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    return 2 * _earthRadiusM * asin(min(1.0, sqrt(h)));
  }

  /// Initial bearing degrees [0, 360).
  static double bearingDegrees(LatLng from, LatLng to) {
    final lat1 = _rad(from.latitude);
    final lat2 = _rad(to.latitude);
    final dLon = _rad(to.longitude - from.longitude);
    final y = sin(dLon) * cos(lat2);
    final x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
    return (_deg(atan2(y, x)) + 360) % 360;
  }

  /// True if segment [a]→[b] intersects any edge of [polygon] (ring, closed).
  static bool segmentIntersectsPolygon(LatLng a, LatLng b, List<LatLng> polygon) {
    if (polygon.length < 3) {
      return false;
    }
    if (_pointInPolygon(a, polygon) || _pointInPolygon(b, polygon)) {
      return true;
    }
    for (var i = 0; i < polygon.length; i++) {
      final p1 = polygon[i];
      final p2 = polygon[(i + 1) % polygon.length];
      if (_segmentsIntersect(a, b, p1, p2)) {
        return true;
      }
    }
    return false;
  }

  static bool routeHitsShallows(LatLng a, LatLng b, List<List<LatLng>> polygons) {
    return routeHitsLand(a, b, polygons);
  }

  /// True if segment [a]→[b] intersects any land / obstacle polygon.
  static bool routeHitsLand(LatLng a, LatLng b, List<List<LatLng>> polygons) {
    for (final poly in polygons) {
      if (segmentIntersectsPolygon(a, b, poly)) {
        return true;
      }
    }
    return false;
  }

  /// True if any consecutive pair in [points] hits land.
  static bool pathHitsLand(List<LatLng> points, List<List<LatLng>> polygons) {
    for (var i = 0; i < points.length - 1; i++) {
      if (routeHitsLand(points[i], points[i + 1], polygons)) {
        return true;
      }
    }
    return false;
  }

  /// Cross-track error (meters). Positive = right of course A→B.
  static double crossTrackErrorMeters(LatLng a, LatLng b, LatLng p) {
    final d13 = haversineMeters(a, p) / _earthRadiusM;
    final brng13 = _rad(bearingDegrees(a, p));
    final brng12 = _rad(bearingDegrees(a, b));
    return asin(sin(d13) * sin(brng13 - brng12)) * _earthRadiusM;
  }

  static double _rad(double d) => d * pi / 180;
  static double _deg(double r) => r * 180 / pi;

  static bool _pointInPolygon(LatLng p, List<LatLng> ring) {
    // Ray casting
    var inside = false;
    for (var i = 0, j = ring.length - 1; i < ring.length; j = i++) {
      final xi = ring[i].longitude;
      final yi = ring[i].latitude;
      final xj = ring[j].longitude;
      final yj = ring[j].latitude;
      final intersect =
          ((yi > p.latitude) != (yj > p.latitude)) &&
          (p.longitude <
              (xj - xi) * (p.latitude - yi) / ((yj - yi) + 1e-15) + xi);
      if (intersect) {
        inside = !inside;
      }
    }
    return inside;
  }

  static bool _segmentsIntersect(LatLng a, LatLng b, LatLng c, LatLng d) {
    final o1 = _orient(a, b, c);
    final o2 = _orient(a, b, d);
    final o3 = _orient(c, d, a);
    final o4 = _orient(c, d, b);
    if (o1 != o2 && o3 != o4) {
      return true;
    }
    return false;
  }

  static int _orient(LatLng a, LatLng b, LatLng c) {
    final v =
        (b.longitude - a.longitude) * (c.latitude - a.latitude) -
        (b.latitude - a.latitude) * (c.longitude - a.longitude);
    if (v > 1e-12) {
      return 1;
    }
    if (v < -1e-12) {
      return -1;
    }
    return 0;
  }
}

/// Sample shallow polygons near Marmara (demo / open-data stand-in).
/// Real packages should replace this with EMODnet-derived GeoJSON.
class ShallowPolygonCatalog {
  /// Approximate shallow embayment polygons (lat/lng rings).
  static List<List<LatLng>> marmaraDemo = [
    [
      const LatLng(40.95, 28.85),
      const LatLng(40.95, 29.05),
      const LatLng(40.85, 29.05),
      const LatLng(40.85, 28.85),
    ],
    [
      const LatLng(40.40, 27.20),
      const LatLng(40.40, 27.45),
      const LatLng(40.28, 27.45),
      const LatLng(40.28, 27.20),
    ],
  ];

  /// Shallow warnings disabled until real EMODnet-derived polygons ship.
  /// Demo Marmara boxes caused false alarms — honesty over fake safety.
  static List<List<LatLng>> forRegion(String? regionId) {
    return const [];
  }

  /// Legacy demo polygons (tests / future GeoJSON packaging only).
  static List<List<LatLng>> get marmaraDemoLegacy => marmaraDemo;

  static String toGeoJson(List<List<LatLng>> polygons) {
    final features = polygons
        .map(
          (ring) => {
            'type': 'Feature',
            'properties': {'kind': 'shallow'},
            'geometry': {
              'type': 'Polygon',
              'coordinates': [
                [
                  ...ring.map((p) => [p.longitude, p.latitude]),
                  [ring.first.longitude, ring.first.latitude],
                ],
              ],
            },
          },
        )
        .toList();
    return jsonEncode({'type': 'FeatureCollection', 'features': features});
  }
}
