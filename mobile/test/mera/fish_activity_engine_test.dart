import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/mera/fish_activity/engine.dart';
import 'package:mobile/mera/fish_activity/models.dart';
import 'package:mobile/mera/fish_activity/species_profiles.dart';

void main() {
  const engine = FishActivityEngine();

  FishEnvSnapshot baseEnv({
    double? waterTemp,
    double? windKmh,
    DateTime? at,
  }) {
    final now = at ?? DateTime(2026, 8, 9, 18, 30);
    return FishEnvSnapshot(
      lat: 37.03,
      lng: 27.43,
      placeName: 'Bodrum',
      fetchedAt: now,
      airTempC: 28,
      humidity: 55,
      windKmh: windKmh ?? 18,
      windDirDeg: 45,
      pressureHpa: 1014,
      pressureChange6h: -1.2,
      weatherCode: 1,
      cloudCover: 40,
      sunrise: DateTime(2026, 8, 9, 6, 20),
      sunset: DateTime(2026, 8, 9, 19, 55),
      waterTempC: waterTemp ?? 23.5,
      waveHeightM: 0.6,
      wavePeriodS: 4.2,
      moonIllumination: 0.72,
      moonPhaseLabel: 'Şişkin Ay',
      hourly: [
        for (var h = 0; h < 24; h++)
          HourlyEnvSample(
            time: DateTime(2026, 8, 9, h),
            airTempC: 26,
            windKmh: 15,
            waterTempC: waterTemp ?? 23.5,
            waveHeightM: 0.5,
            cloudCover: 30,
            pressureHpa: 1014,
          ),
      ],
    );
  }

  test('score is computed not fixed 82', () {
    final a = engine.calculate(
      species: SpeciesActivityProfiles.cipura,
      env: baseEnv(waterTemp: 22),
      at: DateTime(2026, 8, 9, 18, 30),
    );
    final b = engine.calculate(
      species: SpeciesActivityProfiles.cipura,
      env: baseEnv(waterTemp: 10),
      at: DateTime(2026, 8, 9, 18, 30),
    );
    expect(a.score, isNot(equals(82)));
    expect(a.score, greaterThan(b.score));
    expect(a.disclaimer, contains('tahmin'));
  });

  test('species profiles change score', () {
    final env = baseEnv(waterTemp: 19);
    final cipura = engine.calculate(
      species: SpeciesActivityProfiles.cipura,
      env: env,
      at: DateTime(2026, 8, 9, 6, 30),
    );
    final levrek = engine.calculate(
      species: SpeciesActivityProfiles.levrek,
      env: env,
      at: DateTime(2026, 8, 9, 6, 30),
    );
    // Both valid; levrek prefers cooler — scores should differ
    expect(cipura.speciesKey, 'cipura');
    expect(levrek.speciesKey, 'levrek');
    expect(cipura.score, isNot(equals(levrek.score)));
  });

  test('missing oxygen stays unavailable', () {
    final r = engine.calculate(
      species: SpeciesActivityProfiles.mercan,
      env: baseEnv(),
    );
    final o2 = r.factors.firstWhere((f) => f.id == 'oxygen');
    expect(o2.available, isFalse);
    expect(o2.valueLabel, 'Desteklenmiyor');
  });

  test('best window is derived from hourly curve', () {
    final r = engine.calculate(
      species: SpeciesActivityProfiles.cipura,
      env: baseEnv(),
      at: DateTime(2026, 8, 9, 12),
    );
    expect(r.hourly.length, greaterThan(20));
    expect(r.bestWindow, isNotNull);
    expect(r.bestWindow!.end.isAfter(r.bestWindow!.start), isTrue);
  });
}
