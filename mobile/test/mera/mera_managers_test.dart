import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/mera/mera_no_catch_manager.dart';
import 'package:mobile/mera/mera_route_manager.dart';
import 'package:mobile/mera/mera_shell.dart';

void main() {
  group('MeraNoCatchReport', () {
    test('parses num timestampMs (double-safe)', () {
      final r = MeraNoCatchReport.fromJson({
        'id': 'a',
        'lat': 41.0,
        'lng': 29.0,
        'note': 'x',
        'timestampMs': 1710000000000.0,
      });
      expect(r.id, 'a');
      expect(r.timestampMs, 1710000000000);
      expect(r.lat, 41.0);
    });

    test('roundtrip json', () {
      const r = MeraNoCatchReport(
        id: 'b',
        lat: 40.5,
        lng: 28.5,
        note: 'n',
        timestampMs: 123,
      );
      final again = MeraNoCatchReport.fromJson(r.toJson());
      expect(again.id, r.id);
      expect(again.note, 'n');
      expect(again.timestampMs, 123);
    });
  });

  group('MeraRoute', () {
    test('cruiseKnots matches UI 7.4', () {
      expect(MeraRoute.cruiseKnots, 7.4);
    });

    test('rejects near-zero distance ETA', () {
      const r = MeraRoute(
        id: 'z',
        name: 'z',
        createdMs: 0,
        points: [
          MeraRoutePoint(lat: 40.0, lng: 29.0),
          MeraRoutePoint(lat: 40.0, lng: 29.0),
        ],
      );
      expect(r.distanceMeters, lessThan(1));
      expect(r.estimatedAt7kn, Duration.zero);
    });
  });

  group('MeraShell', () {
    tearDown(MeraShell.reset);

    test('switchTab invokes callback', () {
      var hit = -1;
      MeraShell.switchTab = (i) => hit = i;
      MeraShell.goRecords();
      expect(hit, MeraShell.tabRecords);
      MeraShell.goHome();
      expect(hit, MeraShell.tabHome);
    });
  });
}
