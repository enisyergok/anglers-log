import 'dart:math' as math;

import 'package:mobile/mera/fish_activity/astronomy.dart';

/// A single solunar activity window (major or minor).
class SolunarPeriod {
  final DateTime start;
  final DateTime end;
  final bool isMajor;

  const SolunarPeriod({
    required this.start,
    required this.end,
    required this.isMajor,
  });

  bool contains(DateTime at) =>
      !at.isBefore(start) && at.isBefore(end);
}

/// Offline solunar summary for a single local calendar day, computed purely
/// from date/time and GPS coordinates (no network access).
///
/// Sun/moon rise, set and transit times are derived from standard low
/// precision solar and lunar position formulas (Meeus/Schlyter). Major and
/// minor periods follow traditional solunar theory heuristics and are
/// estimates, not a guarantee of fishing success.
class SolunarDay {
  final DateTime date;
  final DateTime? sunrise;
  final DateTime? sunset;
  final DateTime? moonrise;
  final DateTime? moonset;
  final double moonIllumination;
  final String moonPhaseLabel;
  final List<SolunarPeriod> majorPeriods;
  final List<SolunarPeriod> minorPeriods;

  const SolunarDay({
    required this.date,
    required this.sunrise,
    required this.sunset,
    required this.moonrise,
    required this.moonset,
    required this.moonIllumination,
    required this.moonPhaseLabel,
    required this.majorPeriods,
    required this.minorPeriods,
  });

  List<SolunarPeriod> get allPeriods =>
      [...majorPeriods, ...minorPeriods]
        ..sort((a, b) => a.start.compareTo(b.start));

  SolunarPeriod? activePeriodAt(DateTime at) {
    for (final p in allPeriods) {
      if (p.contains(at)) return p;
    }
    return null;
  }

  SolunarPeriod? nextPeriodAfter(DateTime at) {
    for (final p in allPeriods) {
      if (p.start.isAfter(at)) return p;
    }
    return null;
  }

  /// Coarse 0-100 "activity" heuristic derived from proximity to the nearest
  /// solunar period plus moon illumination. This is a traditional-theory
  /// estimate for display purposes, not a scientific prediction.
  int activityScoreAt(DateTime at) {
    double best = 15;
    for (final p in majorPeriods) {
      best = math.max(best, _proximityScore(at, p, spanMinutes: 60, peak: 100));
    }
    for (final p in minorPeriods) {
      best = math.max(best, _proximityScore(at, p, spanMinutes: 30, peak: 65));
    }
    final illumBonus = (0.5 - (moonIllumination - 0.5).abs()) * 20;
    return (best + illumBonus).clamp(0, 100).round();
  }

  static double _proximityScore(
    DateTime at,
    SolunarPeriod p, {
    required int spanMinutes,
    required double peak,
  }) {
    final center = p.start.add(p.end.difference(p.start) ~/ 2);
    final deltaMin = at.difference(center).inMinutes.abs();
    final falloffMin = spanMinutes * 2;
    if (deltaMin >= falloffMin) return 0;
    return peak * (1 - deltaMin / falloffMin);
  }
}

/// Computes offline solunar data. No network access; deterministic given
/// date, latitude and longitude.
abstract final class SolunarCalculator {
  static const _majorHalfWidth = Duration(minutes: 60);
  static const _minorHalfWidth = Duration(minutes: 30);
  static const _sunHorizonDeg = -0.833;
  static const _moonHorizonDeg = 0.125;

  static SolunarDay calculate({
    required DateTime localDate,
    required double lat,
    required double lng,
  }) {
    final dayStart = DateTime(localDate.year, localDate.month, localDate.day);
    final dayEnd = dayStart.add(const Duration(days: 1));

    final sun = _riseSetTransit(
      start: dayStart,
      end: dayEnd,
      lat: lat,
      lng: lng,
      horizonDeg: _sunHorizonDeg,
      position: _sunEquatorial,
    );
    final moon = _riseSetTransit(
      start: dayStart,
      end: dayEnd,
      lat: lat,
      lng: lng,
      horizonDeg: _moonHorizonDeg,
      position: _moonEquatorial,
    );

    final major = <SolunarPeriod>[];
    if (moon.transit != null) {
      major.add(_periodAround(moon.transit!, _majorHalfWidth, true));
    }
    if (moon.antiTransit != null) {
      major.add(_periodAround(moon.antiTransit!, _majorHalfWidth, true));
    }
    final minor = <SolunarPeriod>[];
    if (moon.rise != null) {
      minor.add(_periodAround(moon.rise!, _minorHalfWidth, false));
    }
    if (moon.set != null) {
      minor.add(_periodAround(moon.set!, _minorHalfWidth, false));
    }

    final noonUtc = dayStart.add(const Duration(hours: 12)).toUtc();
    final illum = AstronomyProvider.moonIllumination(noonUtc);
    final phaseLabel = AstronomyProvider.moonPhaseLabel(illum, noonUtc);

    return SolunarDay(
      date: dayStart,
      sunrise: sun.rise,
      sunset: sun.set,
      moonrise: moon.rise,
      moonset: moon.set,
      moonIllumination: illum,
      moonPhaseLabel: phaseLabel,
      majorPeriods: major,
      minorPeriods: minor,
    );
  }

  static SolunarPeriod _periodAround(
    DateTime center,
    Duration halfWidth,
    bool isMajor,
  ) =>
      SolunarPeriod(
        start: center.subtract(halfWidth),
        end: center.add(halfWidth),
        isMajor: isMajor,
      );

  // --- Rise/set/transit scanning -------------------------------------------

  static _RiseSetTransit _riseSetTransit({
    required DateTime start,
    required DateTime end,
    required double lat,
    required double lng,
    required double horizonDeg,
    required _EquatorialPosition Function(double jd) position,
  }) {
    const stepMinutes = 5;
    final steps = end.difference(start).inMinutes ~/ stepMinutes;
    final times = <DateTime>[];
    final alts = <double>[];

    for (var i = 0; i <= steps; i++) {
      final t = start.add(Duration(minutes: i * stepMinutes));
      final jd = AstronomyProvider.julianDay(t.toUtc());
      final pos = position(jd);
      final alt = _altitudeDeg(pos, jd, lat, lng);
      times.add(t);
      alts.add(alt);
    }

    DateTime? rise;
    DateTime? set;
    var maxAlt = -double.infinity;
    var minAlt = double.infinity;
    var maxIdx = 0;
    var minIdx = 0;

    for (var i = 0; i < alts.length; i++) {
      if (alts[i] > maxAlt) {
        maxAlt = alts[i];
        maxIdx = i;
      }
      if (alts[i] < minAlt) {
        minAlt = alts[i];
        minIdx = i;
      }
      if (i == 0) continue;
      final prev = alts[i - 1] - horizonDeg;
      final curr = alts[i] - horizonDeg;
      if (prev < 0 && curr >= 0 && rise == null) {
        rise = _interpolateCrossing(times[i - 1], times[i], prev, curr);
      } else if (prev >= 0 && curr < 0 && set == null) {
        set = _interpolateCrossing(times[i - 1], times[i], prev, curr);
      }
    }

    final transit = (maxAlt > horizonDeg) ? times[maxIdx] : null;
    final antiTransit = (minAlt < horizonDeg) ? times[minIdx] : null;

    return _RiseSetTransit(
      rise: rise,
      set: set,
      transit: transit,
      antiTransit: antiTransit,
    );
  }

  static DateTime _interpolateCrossing(
    DateTime tA,
    DateTime tB,
    double valA,
    double valB,
  ) {
    final frac = valA / (valA - valB);
    final deltaMs = tB.difference(tA).inMilliseconds * frac;
    return tA.add(Duration(milliseconds: deltaMs.round()));
  }

  static double _altitudeDeg(
    _EquatorialPosition pos,
    double jd,
    double lat,
    double lng,
  ) {
    final t = (jd - 2451545.0) / 36525.0;
    final gmstDeg = _norm360(
      280.46061837 +
          360.98564736629 * (jd - 2451545.0) +
          0.000387933 * t * t -
          (t * t * t) / 38710000.0,
    );
    final lst = _norm360(gmstDeg + lng);
    var h = (lst - pos.raDeg) % 360;
    if (h > 180) h -= 360;
    if (h < -180) h += 360;

    final latRad = _deg2rad(lat);
    final decRad = _deg2rad(pos.decDeg);
    final hRad = _deg2rad(h);
    final sinAlt = math.sin(decRad) * math.sin(latRad) +
        math.cos(decRad) * math.cos(latRad) * math.cos(hRad);
    return _rad2deg(math.asin(sinAlt.clamp(-1.0, 1.0)));
  }

  // --- Sun position (Meeus low precision) -----------------------------------

  static _EquatorialPosition _sunEquatorial(double jd) {
    final t = (jd - 2451545.0) / 36525.0;
    final l0 = _norm360(280.46646 + 36000.76983 * t + 0.0003032 * t * t);
    final m = _norm360(357.52911 + 35999.05029 * t - 0.0001537 * t * t);
    final mRad = _deg2rad(m);
    final c = (1.914602 - 0.004817 * t - 0.000014 * t * t) * math.sin(mRad) +
        (0.019993 - 0.000101 * t) * math.sin(2 * mRad) +
        0.000289 * math.sin(3 * mRad);
    final trueLong = l0 + c;
    final omega = 125.04 - 1934.136 * t;
    final appLong = trueLong - 0.00569 - 0.00478 * math.sin(_deg2rad(omega));
    final eps0 = 23.4392911 -
        (46.8150 * t + 0.00059 * t * t - 0.001813 * t * t * t) / 3600.0;
    final eps = eps0 + 0.00256 * math.cos(_deg2rad(omega));

    final lRad = _deg2rad(appLong);
    final epsRad = _deg2rad(eps);
    final raRad = math.atan2(
      math.cos(epsRad) * math.sin(lRad),
      math.cos(lRad),
    );
    final decRad = math.asin(math.sin(epsRad) * math.sin(lRad));
    return _EquatorialPosition(
      raDeg: _norm360(_rad2deg(raRad)),
      decDeg: _rad2deg(decRad),
    );
  }

  // --- Moon position (Schlyter low precision, ~1 arcmin) --------------------

  static _EquatorialPosition _moonEquatorial(double jd) {
    final d = jd - 2451543.5;

    final n = _norm360(125.1228 - 0.0529538083 * d);
    const i = 5.1454;
    final w = _norm360(318.0634 + 0.1643573223 * d);
    const a = 60.2666;
    const e = 0.054900;
    final m = _norm360(115.3654 + 13.0649929509 * d);

    var eAnom = m + (180 / math.pi) * e * math.sin(_deg2rad(m)) *
        (1 + e * math.cos(_deg2rad(m)));
    for (var iter = 0; iter < 4; iter++) {
      final f = eAnom -
          (180 / math.pi) * e * math.sin(_deg2rad(eAnom)) -
          m;
      final fPrime = 1 - e * math.cos(_deg2rad(eAnom));
      eAnom -= f / fPrime;
    }

    final xv = a * (math.cos(_deg2rad(eAnom)) - e);
    final yv = a * (math.sqrt(1 - e * e) * math.sin(_deg2rad(eAnom)));
    final v = _rad2deg(math.atan2(yv, xv));
    final r = math.sqrt(xv * xv + yv * yv);

    final vw = _deg2rad(v + w);
    final nRad = _deg2rad(n);
    final iRad = _deg2rad(i);
    final xh = r * (math.cos(nRad) * math.cos(vw) -
        math.sin(nRad) * math.sin(vw) * math.cos(iRad));
    final yh = r * (math.sin(nRad) * math.cos(vw) +
        math.cos(nRad) * math.sin(vw) * math.cos(iRad));
    final zh = r * (math.sin(vw) * math.sin(iRad));

    var lonEcl = _rad2deg(math.atan2(yh, xh));
    var latEcl = _rad2deg(math.atan2(zh, math.sqrt(xh * xh + yh * yh)));

    // Perturbation corrections (Sun, elongation, argument of latitude).
    final ws = _norm360(282.9404 + 4.70935e-5 * d);
    final ms = _norm360(356.0470 + 0.9856002585 * d);
    final ls = _norm360(ws + ms);
    final lm = _norm360(n + w + m);
    final dElong = _norm360(lm - ls);
    final f = _norm360(lm - n);

    double s(double deg) => math.sin(_deg2rad(deg));

    lonEcl += -1.274 * s(m - 2 * dElong) +
        0.658 * s(2 * dElong) -
        0.186 * s(ms) -
        0.059 * s(2 * m - 2 * dElong) -
        0.057 * s(m - 2 * dElong + ms) +
        0.053 * s(m + 2 * dElong) +
        0.046 * s(2 * dElong - ms) +
        0.041 * s(m - ms) -
        0.035 * s(dElong) -
        0.031 * s(m + ms) -
        0.015 * s(2 * f - 2 * dElong) +
        0.011 * s(m - 4 * dElong);

    latEcl += -0.173 * s(f - 2 * dElong) -
        0.055 * s(m - f - 2 * dElong) -
        0.046 * s(m + f - 2 * dElong) +
        0.033 * s(f + 2 * dElong) +
        0.017 * s(2 * m + f);

    final ecl = 23.4393 - 3.563e-7 * d;
    final eclRad = _deg2rad(ecl);
    final lonRad = _deg2rad(lonEcl);
    final latRad = _deg2rad(latEcl);

    final xeq = math.cos(lonRad) * math.cos(latRad);
    final yeq = math.sin(lonRad) * math.cos(latRad) * math.cos(eclRad) -
        math.sin(latRad) * math.sin(eclRad);
    final zeq = math.sin(lonRad) * math.cos(latRad) * math.sin(eclRad) +
        math.sin(latRad) * math.cos(eclRad);

    final raDeg = _norm360(_rad2deg(math.atan2(yeq, xeq)));
    final decDeg = _rad2deg(math.asin(zeq.clamp(-1.0, 1.0)));

    return _EquatorialPosition(raDeg: raDeg, decDeg: decDeg);
  }

  static double _deg2rad(double d) => d * math.pi / 180.0;
  static double _rad2deg(double r) => r * 180.0 / math.pi;
  static double _norm360(double d) => ((d % 360) + 360) % 360;
}

class _EquatorialPosition {
  final double raDeg;
  final double decDeg;
  const _EquatorialPosition({required this.raDeg, required this.decDeg});
}

class _RiseSetTransit {
  final DateTime? rise;
  final DateTime? set;
  final DateTime? transit;
  final DateTime? antiTransit;
  const _RiseSetTransit({
    required this.rise,
    required this.set,
    required this.transit,
    required this.antiTransit,
  });
}
