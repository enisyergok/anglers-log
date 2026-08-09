import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:mobile/mera/mera_route_gpx.dart';
import 'package:mobile/mera/mera_route_manager.dart';
import 'package:mobile/navigation/depth_sampler.dart';
import 'package:mobile/navigation/nav_geo.dart';

void main() {
  group('DepthSampler.parseFeatureInfo', () {
    test('parses GRAY_INDEX', () {
      expect(
        DepthSampler.parseFeatureInfo('GRAY_INDEX = -42.5'),
        closeTo(42.5, 0.01),
      );
    });

    test('returns null for junk', () {
      expect(DepthSampler.parseFeatureInfo('no data'), isNull);
    });
  });

  group('MeraRouteGpx', () {
    test('round-trip export/parse', () {
      final route = MeraRoute(
        id: '1',
        name: 'Test',
        points: const [
          MeraRoutePoint(lat: 40.9, lng: 29.0, label: '1'),
          MeraRoutePoint(lat: 40.95, lng: 29.1, label: '2'),
        ],
        createdMs: 0,
      );
      final gpx = MeraRouteGpx.export(route);
      final pts = MeraRouteGpx.parsePoints(gpx);
      expect(pts.length, 2);
      expect(pts.first.latitude, closeTo(40.9, 1e-6));
      expect(pts.last.longitude, closeTo(29.1, 1e-6));
    });

    test('parses trkpt', () {
      const gpx = '''
<gpx><trk><trkseg>
<trkpt lat="37.0" lon="27.4"></trkpt>
<trkpt lat="37.1" lon="27.5"></trkpt>
</trkseg></trk></gpx>
''';
      expect(MeraRouteGpx.parsePoints(gpx).length, 2);
    });
  });

  group('NavGeo.crossTrackErrorMeters', () {
    test('zero on the leg', () {
      final a = const LatLng(40.0, 29.0);
      final b = const LatLng(40.1, 29.0);
      final mid = const LatLng(40.05, 29.0);
      expect(NavGeo.crossTrackErrorMeters(a, b, mid).abs(), lessThan(5));
    });
  });
}
