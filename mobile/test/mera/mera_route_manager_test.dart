import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/mera/mera_route_manager.dart';

void main() {
  test('MeraRoute distance and ETA for Bodrum-Yalıkavak seed', () {
    const route = MeraRoute(
      id: 't',
      name: 'test',
      createdMs: 0,
      points: [
        MeraRoutePoint(lat: 37.034, lng: 27.430),
        MeraRoutePoint(lat: 37.055, lng: 27.360),
        MeraRoutePoint(lat: 37.105, lng: 27.290),
      ],
    );
    expect(route.distanceNm, greaterThan(5));
    expect(route.distanceNm, lessThan(30));
    expect(route.estimatedAt7kn.inMinutes, greaterThan(30));
  });

  test('MeraRoute empty points is zero distance', () {
    const route = MeraRoute(
      id: 'e',
      name: 'empty',
      createdMs: 0,
      points: [],
    );
    expect(route.distanceMeters, 0);
    expect(route.estimatedAt7kn, Duration.zero);
  });
}
