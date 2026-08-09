import 'dart:math' as math;

import 'package:latlong2/latlong.dart';
import 'package:mobile/navigation/nav_geo.dart';

/// Result of water-aware segment planning.
class WaterRoutePlan {
  final List<LatLng> points;
  final bool avoidedLand;
  final bool failed;

  const WaterRoutePlan({
    required this.points,
    this.avoidedLand = false,
    this.failed = false,
  });
}

/// Inserts waypoints so A→B stays off embedded land polygons when possible.
///
/// Algorithm: visibility-graph Dijkstra over water-offset polygon vertices.
class WaterRoutePlanner {
  WaterRoutePlanner._();

  /// Degrees ≈ 350–450 m mid-latitudes — push vertices into water.
  static const _vertexOffsetDeg = 0.0045;

  /// Max corridor padding when selecting nearby obstacles (degrees).
  static const _corridorPadDeg = 0.35;

  static WaterRoutePlan planSegment(
    LatLng a,
    LatLng b, {
    List<List<LatLng>>? land,
  }) {
    final polys = land ?? const <List<LatLng>>[];
    if (polys.isEmpty || !NavGeo.routeHitsLand(a, b, polys)) {
      return WaterRoutePlan(points: [a, b]);
    }

    final nearby = _nearbyPolys(a, b, polys);
    if (nearby.isEmpty) {
      return WaterRoutePlan(points: [a, b], failed: true);
    }

    final nodes = <LatLng>[a, b];
    for (final ring in nearby) {
      nodes.addAll(_waterSideVertices(ring));
    }

    final path = _dijkstra(nodes, a, b, polys);
    if (path == null || path.length < 2) {
      return WaterRoutePlan(points: [a, b], failed: true);
    }
    return WaterRoutePlan(points: path, avoidedLand: path.length > 2);
  }

  /// Expands a full waypoint list segment-by-segment.
  static WaterRoutePlan planRoute(
    List<LatLng> waypoints, {
    List<List<LatLng>>? land,
  }) {
    if (waypoints.length < 2) {
      return WaterRoutePlan(points: List<LatLng>.from(waypoints));
    }
    final polys = land ?? const <List<LatLng>>[];
    final out = <LatLng>[waypoints.first];
    var avoided = false;
    var failed = false;
    for (var i = 0; i < waypoints.length - 1; i++) {
      final seg = planSegment(waypoints[i], waypoints[i + 1], land: polys);
      out.addAll(seg.points.skip(1));
      avoided = avoided || seg.avoidedLand;
      failed = failed || seg.failed;
    }
    return WaterRoutePlan(points: out, avoidedLand: avoided, failed: failed);
  }

  static List<List<LatLng>> _nearbyPolys(
    LatLng a,
    LatLng b,
    List<List<LatLng>> all,
  ) {
    final minLat =
        math.min(a.latitude, b.latitude) - _corridorPadDeg;
    final maxLat =
        math.max(a.latitude, b.latitude) + _corridorPadDeg;
    final minLng =
        math.min(a.longitude, b.longitude) - _corridorPadDeg;
    final maxLng =
        math.max(a.longitude, b.longitude) + _corridorPadDeg;

    final out = <List<LatLng>>[];
    for (final ring in all) {
      if (ring.length < 3) continue;
      var hitsBox = false;
      for (final p in ring) {
        if (p.latitude >= minLat &&
            p.latitude <= maxLat &&
            p.longitude >= minLng &&
            p.longitude <= maxLng) {
          hitsBox = true;
          break;
        }
      }
      if (hitsBox || NavGeo.segmentIntersectsPolygon(a, b, ring)) {
        out.add(ring);
      }
    }
    return out;
  }

  static List<LatLng> _waterSideVertices(List<LatLng> ring) {
    var cLat = 0.0;
    var cLng = 0.0;
    for (final p in ring) {
      cLat += p.latitude;
      cLng += p.longitude;
    }
    cLat /= ring.length;
    cLng /= ring.length;

    final out = <LatLng>[];
    for (final p in ring) {
      final dLat = p.latitude - cLat;
      final dLng = p.longitude - cLng;
      final len = math.sqrt(dLat * dLat + dLng * dLng);
      if (len < 1e-9) continue;
      out.add(
        LatLng(
          p.latitude + dLat / len * _vertexOffsetDeg,
          p.longitude + dLng / len * _vertexOffsetDeg,
        ),
      );
    }
    return out;
  }

  static List<LatLng>? _dijkstra(
    List<LatLng> nodes,
    LatLng start,
    LatLng goal,
    List<List<LatLng>> land,
  ) {
    final n = nodes.length;
    if (n < 2) return null;

    int indexOf(LatLng p) {
      for (var i = 0; i < n; i++) {
        if (_same(nodes[i], p)) return i;
      }
      return -1;
    }

    final s = indexOf(start);
    final g = indexOf(goal);
    if (s < 0 || g < 0) return null;

    final dist = List<double>.filled(n, double.infinity);
    final prev = List<int>.filled(n, -1);
    final used = List<bool>.filled(n, false);
    dist[s] = 0;

    for (var iter = 0; iter < n; iter++) {
      var u = -1;
      var best = double.infinity;
      for (var i = 0; i < n; i++) {
        if (!used[i] && dist[i] < best) {
          best = dist[i];
          u = i;
        }
      }
      if (u < 0 || best == double.infinity) break;
      if (u == g) break;
      used[u] = true;

      for (var v = 0; v < n; v++) {
        if (used[v] || u == v) continue;
        if (NavGeo.routeHitsLand(nodes[u], nodes[v], land)) continue;
        final w = NavGeo.haversineMeters(nodes[u], nodes[v]);
        final nd = dist[u] + w;
        if (nd < dist[v]) {
          dist[v] = nd;
          prev[v] = u;
        }
      }
    }

    if (dist[g] == double.infinity) return null;

    final path = <LatLng>[];
    for (var cur = g; cur != -1; cur = prev[cur]) {
      path.add(nodes[cur]);
    }
    return path.reversed.toList();
  }

  static bool _same(LatLng a, LatLng b) =>
      (a.latitude - b.latitude).abs() < 1e-9 &&
      (a.longitude - b.longitude).abs() < 1e-9;
}
