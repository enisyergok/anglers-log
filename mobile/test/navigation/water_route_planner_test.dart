import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile/navigation/land_polygon_catalog.dart';
import 'package:mobile/navigation/nav_geo.dart';
import 'package:mobile/navigation/water_route_planner.dart';

void main() {
  group('WaterRoutePlanner', () {
    test('open water stays as direct segment', () {
      const a = LatLng(40.9, 28.2);
      const b = LatLng(40.95, 28.4);
      final plan = WaterRoutePlanner.planSegment(
        a,
        b,
        land: LandPolygonCatalog.all,
      );
      expect(plan.points, [a, b]);
      expect(plan.avoidedLand, isFalse);
      expect(plan.failed, isFalse);
    });

    test('Kapıdağ crossing inserts water waypoints', () {
      // South of Kapıdağ → north of Kapıdağ (straight line through land).
      const a = LatLng(40.40, 27.92);
      const b = LatLng(40.65, 27.92);
      expect(
        NavGeo.routeHitsLand(a, b, [LandPolygonCatalog.kapidag]),
        isTrue,
      );

      final plan = WaterRoutePlanner.planSegment(
        a,
        b,
        land: [LandPolygonCatalog.kapidag],
      );
      expect(plan.failed, isFalse);
      expect(plan.avoidedLand, isTrue);
      expect(plan.points.length, greaterThan(2));
      expect(plan.points.first, a);
      expect(plan.points.last, b);
      expect(
        NavGeo.pathHitsLand(plan.points, [LandPolygonCatalog.kapidag]),
        isFalse,
      );
    });

    test('full route planner expands each land-crossing leg', () {
      const a = LatLng(40.40, 27.92);
      const mid = LatLng(40.70, 28.20);
      const b = LatLng(40.80, 28.30);
      final plan = WaterRoutePlanner.planRoute(
        [a, mid, b],
        land: LandPolygonCatalog.all,
      );
      expect(plan.points.first, a);
      expect(plan.points.last, b);
      expect(plan.points.length, greaterThanOrEqualTo(3));
    });
  });

  group('LandPolygonCatalog', () {
    test('has multiple peninsula/island rings', () {
      expect(LandPolygonCatalog.all.length, greaterThanOrEqualTo(5));
      for (final ring in LandPolygonCatalog.all) {
        expect(ring.length, greaterThanOrEqualTo(3));
      }
    });
  });
}
