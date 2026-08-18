import 'dart:math' as math;

import 'package:mobile/mera/fish_activity/models.dart';

/// Pure astronomy helpers (no fishing claims).
abstract final class AstronomyProvider {
  /// Approximate moon illumination 0–1 (synodic cycle).
  static double moonIllumination(DateTime utc) {
    final jd = _julianDay(utc.toUtc());
    // Ref epoch: new moon ~2000-01-06
    const synodic = 29.53058867;
    final daysSince = jd - 2451549.5;
    final phase = (daysSince % synodic + synodic) % synodic;
    final angle = phase / synodic * 2 * math.pi;
    return (1 - math.cos(angle)) / 2;
  }

  static String moonPhaseLabel(double illumination, DateTime utc) {
    final jd = _julianDay(utc.toUtc());
    const synodic = 29.53058867;
    final daysSince = jd - 2451549.5;
    final age = (daysSince % synodic + synodic) % synodic;
    if (age < 1.85) return 'Yeni Ay';
    if (age < 5.5) return 'Hilal';
    if (age < 9.2) return 'İlkdördün';
    if (age < 12.9) return 'Şişkin Ay';
    if (age < 16.6) return 'Dolunay';
    if (age < 20.3) return 'Azalan Şişkin';
    if (age < 24.0) return 'Sondördün';
    if (age < 27.7) return 'Azalan Hilal';
    return 'Yeni Ay';
  }

  static DayPhase dayPhase({
    required DateTime now,
    required DateTime? sunrise,
    required DateTime? sunset,
  }) {
    if (sunrise == null || sunset == null) {
      final h = now.hour;
      if (h < 5) return DayPhase.night;
      if (h < 7) return DayPhase.sunrise;
      if (h < 17) return DayPhase.day;
      if (h < 19) return DayPhase.sunset;
      if (h < 21) return DayPhase.dusk;
      return DayPhase.night;
    }
    final pre = sunrise.subtract(const Duration(minutes: 60));
    final sunEnd = sunrise.add(const Duration(minutes: 60));
    final setStart = sunset.subtract(const Duration(minutes: 60));
    final duskEnd = sunset.add(const Duration(minutes: 60));
    if (now.isBefore(pre) || !now.isBefore(duskEnd.add(const Duration(minutes: 30)))) {
      return DayPhase.night;
    }
    if (!now.isBefore(pre) && now.isBefore(sunrise)) return DayPhase.preDawn;
    if (!now.isBefore(sunrise) && now.isBefore(sunEnd)) return DayPhase.sunrise;
    if (!now.isBefore(setStart) && now.isBefore(sunset)) return DayPhase.sunset;
    if (!now.isBefore(sunset) && now.isBefore(duskEnd)) return DayPhase.dusk;
    if (now.isAfter(sunEnd) && now.isBefore(setStart)) return DayPhase.day;
    return DayPhase.night;
  }

  static String dayPhaseLabel(DayPhase p) {
    switch (p) {
      case DayPhase.night:
        return 'Gece';
      case DayPhase.preDawn:
        return 'Şafak öncesi';
      case DayPhase.sunrise:
        return 'Gün doğumu';
      case DayPhase.day:
        return 'Gündüz';
      case DayPhase.sunset:
        return 'Gün batımı';
      case DayPhase.dusk:
        return 'Alacakaranlık';
    }
  }

  static String dayPhaseKey(DayPhase p) {
    switch (p) {
      case DayPhase.night:
        return 'night';
      case DayPhase.preDawn:
        return 'preDawn';
      case DayPhase.sunrise:
        return 'sunrise';
      case DayPhase.day:
        return 'day';
      case DayPhase.sunset:
        return 'sunset';
      case DayPhase.dusk:
        return 'dusk';
    }
  }

  /// Julian day number for [utc] (must already be UTC).
  static double julianDay(DateTime utc) => _julianDay(utc);

  static double _julianDay(DateTime utc) {
    final y = utc.year;
    final m = utc.month;
    final d = utc.day +
        (utc.hour + (utc.minute + utc.second / 60.0) / 60.0) / 24.0;
    var yy = y;
    var mm = m;
    if (mm <= 2) {
      yy -= 1;
      mm += 12;
    }
    final a = (yy / 100).floor();
    final b = 2 - a + (a / 4).floor();
    return (365.25 * (yy + 4716)).floor() +
        (30.6001 * (mm + 1)).floor() +
        d +
        b -
        1524.5;
  }
}
