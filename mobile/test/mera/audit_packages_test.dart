import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/location_monitor.dart';
import 'package:mobile/mera/fish_activity/engine.dart';
import 'package:mobile/mera/fish_activity/models.dart';
import 'package:mobile/mera/fish_activity/species_profiles.dart';
import 'package:mobile/mera/turkish_sea_fish_catalog.dart';
import 'package:mobile/navigation/nav_geo.dart';

void main() {
  group('audit package honesty', () {
    test('catalog species count matches activity profiles', () {
      expect(
        SpeciesActivityProfiles.primary.length,
        TurkishSeaFishCatalog.all.length,
      );
      expect(SpeciesActivityProfiles.primary.length, greaterThanOrEqualTo(10));
    });

    test('clarity and oxygen never contribute to weighted score', () {
      final env = FishEnvSnapshot(
        lat: 41,
        lng: 29,
        placeName: 'test',
        fetchedAt: DateTime.now(),
        waterTempC: 20,
        windKmh: 10,
        waveHeightM: 0.5,
        pressureHpa: 1013,
        cloudCover: 40,
        sunrise: DateTime.now().subtract(const Duration(hours: 6)),
        sunset: DateTime.now().add(const Duration(hours: 6)),
        moonIllumination: 0.5,
        moonPhaseLabel: 'test',
      );
      final result = const FishActivityEngine().calculate(
        species: SpeciesActivityProfiles.cipura,
        env: env,
      );
      final clarity = result.factors.where((f) => f.id == 'clarity').single;
      final oxygen = result.factors.where((f) => f.id == 'oxygen').single;
      expect(clarity.available, isFalse);
      expect(oxygen.available, isFalse);
      expect(clarity.valueLabel, 'Desteklenmiyor');
      expect(oxygen.valueLabel, 'Desteklenmiyor');
      expect(clarity.contribution, 0);
      expect(oxygen.contribution, 0);
    });

    test('tide scores when phase label present', () {
      final env = FishEnvSnapshot(
        lat: 41,
        lng: 29,
        placeName: 'test',
        fetchedAt: DateTime.now(),
        waterTempC: 20,
        windKmh: 10,
        sunrise: DateTime.now().subtract(const Duration(hours: 6)),
        sunset: DateTime.now().add(const Duration(hours: 6)),
        tideHeightM: 0.4,
        tidePhaseLabel: 'Yükselen',
        moonIllumination: 0.4,
      );
      final result = const FishActivityEngine().calculate(
        species: SpeciesActivityProfiles.cipura,
        env: env,
      );
      final tide = result.factors.where((f) => f.id == 'tide').single;
      expect(tide.available, isTrue);
      expect(tide.rawScore, greaterThan(50));
    });

    test('shallow polygons only for marmara', () {
      expect(ShallowPolygonCatalog.forRegion('marmara'), isNotEmpty);
      expect(ShallowPolygonCatalog.forRegion('ege'), isEmpty);
      expect(ShallowPolygonCatalog.forRegion('akdeniz'), isEmpty);
      expect(ShallowPolygonCatalog.forRegion(null), isEmpty);
    });

    test('LocationPoint exposes GPS speed in knots', () {
      final p = LocationPoint(lat: 41, lng: 29, heading: null, speedMps: 5.144);
      expect(p.speedKnots, closeTo(10, 0.1));
      final none = LocationPoint(lat: 41, lng: 29, heading: null);
      expect(none.speedKnots, isNull);
    });

    test('env disk json roundtrip keeps tide', () {
      final snap = FishEnvSnapshot(
        lat: 40.9,
        lng: 29.1,
        placeName: 'Pendik',
        fetchedAt: DateTime.fromMillisecondsSinceEpoch(1_700_000_000_000),
        tideHeightM: 0.22,
        tidePhaseLabel: 'Alçalan',
        waterTempC: 18.5,
      );
      final back = FishEnvSnapshot.fromDiskJson(snap.toDiskJson());
      expect(back.tideHeightM, 0.22);
      expect(back.tidePhaseLabel, 'Alçalan');
      expect(back.waterTempC, 18.5);
      expect(back.stale, isFalse);
      final stale = back.copyWith(
        stale: true,
        cacheAge: const Duration(minutes: 12),
      );
      expect(stale.stale, isTrue);
      expect(stale.cacheAge?.inMinutes, 12);
    });
  });
}
