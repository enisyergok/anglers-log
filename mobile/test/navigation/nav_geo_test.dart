import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile/navigation/nav_geo.dart';
import 'package:mobile/navigation/nmea_udp_listener.dart';
import 'package:mobile/navigation/mera_manager.dart';

void main() {
  group('NavGeo.haversineMeters', () {
    test('zero for same point', () {
      const p = LatLng(41.0, 29.0);
      expect(NavGeo.haversineMeters(p, p), closeTo(0, 0.01));
    });

    test('Istanbul to roughly 1 degree east ~85km', () {
      const a = LatLng(41.0, 29.0);
      const b = LatLng(41.0, 30.0);
      final d = NavGeo.haversineMeters(a, b);
      expect(d, greaterThan(80000));
      expect(d, lessThan(95000));
    });
  });

  group('NavGeo.bearingDegrees', () {
    test('due east ~90', () {
      const a = LatLng(0, 0);
      const b = LatLng(0, 1);
      expect(NavGeo.bearingDegrees(a, b), closeTo(90, 1));
    });
  });

  group('NavGeo.routeHitsShallows', () {
    test('segment through demo polygon is detected', () {
      const a = LatLng(40.90, 28.80);
      const b = LatLng(40.90, 29.10);
      expect(
        NavGeo.routeHitsShallows(a, b, ShallowPolygonCatalog.marmaraDemo),
        isTrue,
      );
    });

    test('segment far away is clear', () {
      const a = LatLng(42.5, 29.0);
      const b = LatLng(42.6, 29.1);
      expect(
        NavGeo.routeHitsShallows(a, b, ShallowPolygonCatalog.marmaraDemo),
        isFalse,
      );
    });
  });

  group('NmeaParser', () {
    test('parses DBT meters', () {
      final snap = NmeaParser.apply(
        '\$SDDBT,16.4,f,5.0,M,2.7,F*0D',
        null,
      );
      expect(snap?.depthM, closeTo(5.0, 0.01));
    });

    test('parses DPT', () {
      final snap = NmeaParser.apply('\$SDDPT,12.3,0.0*00', null);
      expect(snap?.depthM, closeTo(12.3, 0.01));
    });

    test('parses VTG sog/cog', () {
      final snap = NmeaParser.apply(
        '\$GPVTG,54.7,T,34.4,M,5.5,N,10.2,K*39',
        null,
      );
      expect(snap?.cogDegrees, closeTo(54.7, 0.1));
      expect(snap?.sogKnots, closeTo(5.5, 0.1));
    });
  });

  group('MeraSpot json roundtrip', () {
    test('encode/decode', () {
      const spot = MeraSpot(
        id: 'abc',
        lat: 40.7,
        lng: 29.1,
        depthM: 8.5,
        bottomType: 'taşlık',
        note: 'test',
        timestampMs: 1,
      );
      final again = MeraSpot.fromJson(spot.toJson());
      expect(again.id, spot.id);
      expect(again.depthM, spot.depthM);
      expect(again.bottomType, spot.bottomType);
    });
  });

  group('ShallowPolygonCatalog', () {
    test('geojson is valid-ish', () {
      final json = ShallowPolygonCatalog.toGeoJson(
        ShallowPolygonCatalog.marmaraDemo,
      );
      expect(json.contains('FeatureCollection'), isTrue);
      expect(json.contains('Polygon'), isTrue);
    });

    test('forRegion returns empty until real shallow packages ship', () {
      expect(ShallowPolygonCatalog.forRegion('marmara'), isEmpty);
      expect(ShallowPolygonCatalog.forRegion('ege'), isEmpty);
      expect(ShallowPolygonCatalog.forRegion(null), isEmpty);
      expect(ShallowPolygonCatalog.marmaraDemoLegacy, isNotEmpty);
    });
  });
}
