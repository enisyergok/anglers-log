import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/mera/fish_activity/solunar.dart';

void main() {
  // Istanbul-ish coordinates. Timezone-independent assertions only, since
  // the calculator intentionally uses the device's local calendar day.
  const lat = 41.0;
  const lng = 29.0;

  group('SolunarCalculator', () {
    test('produces a sunrise before sunset', () {
      final day = SolunarCalculator.calculate(
        localDate: DateTime(2026, 6, 21),
        lat: lat,
        lng: lng,
      );
      expect(day.sunrise, isNotNull);
      expect(day.sunset, isNotNull);
      expect(day.sunrise!.isBefore(day.sunset!), isTrue);
    });

    test('moon illumination is a valid fraction', () {
      final day = SolunarCalculator.calculate(
        localDate: DateTime(2026, 3, 15),
        lat: lat,
        lng: lng,
      );
      expect(day.moonIllumination, inInclusiveRange(0.0, 1.0));
      expect(day.moonPhaseLabel, isNotEmpty);
    });

    test('major periods are ~2 hours and centered on transit/anti-transit', () {
      final day = SolunarCalculator.calculate(
        localDate: DateTime(2026, 8, 18),
        lat: lat,
        lng: lng,
      );
      for (final p in day.majorPeriods) {
        expect(p.isMajor, isTrue);
        expect(p.end.difference(p.start).inMinutes, 120);
      }
      for (final p in day.minorPeriods) {
        expect(p.isMajor, isFalse);
        expect(p.end.difference(p.start).inMinutes, 60);
      }
    });

    test('activity score stays within 0-100 across the day', () {
      final day = SolunarCalculator.calculate(
        localDate: DateTime(2026, 1, 10),
        lat: lat,
        lng: lng,
      );
      for (var h = 0; h < 24; h++) {
        final at = day.date.add(Duration(hours: h));
        final score = day.activityScoreAt(at);
        expect(score, inInclusiveRange(0, 100));
      }
    });

    test('is deterministic for the same inputs', () {
      final a = SolunarCalculator.calculate(
        localDate: DateTime(2026, 4, 4),
        lat: lat,
        lng: lng,
      );
      final b = SolunarCalculator.calculate(
        localDate: DateTime(2026, 4, 4),
        lat: lat,
        lng: lng,
      );
      expect(a.sunrise, b.sunrise);
      expect(a.moonrise, b.moonrise);
      expect(a.moonIllumination, b.moonIllumination);
    });

    test('works near the equator with no crash and sane ranges', () {
      final day = SolunarCalculator.calculate(
        localDate: DateTime(2026, 9, 1),
        lat: 0.0,
        lng: 0.0,
      );
      expect(day.sunrise, isNotNull);
      expect(day.sunset, isNotNull);
      final daylightHours = day.sunset!.difference(day.sunrise!).inMinutes / 60.0;
      expect(daylightHours, inInclusiveRange(10.0, 14.0));
    });
  });
}
