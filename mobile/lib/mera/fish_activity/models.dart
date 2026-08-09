import 'package:flutter/foundation.dart';

/// Daylight / clock phase for heuristic activity windows.
enum DayPhase { night, preDawn, sunrise, day, sunset, dusk }

enum ActivityLevel {
  veryLow,
  low,
  medium,
  high,
  veryHigh,
}

enum ConfidenceLevel { low, medium, high }

enum TempFit { low, suitable, high, unknown }

/// One factor contribution shown in "Koşulların Aktiviteye Etkisi".
class ActivityFactor {
  final String id;
  final String name;
  final String valueLabel;
  final double contribution; // signed score points after weighting
  final double rawScore; // 0–100 factor quality
  final bool available;
  final String? detail;

  const ActivityFactor({
    required this.id,
    required this.name,
    required this.valueLabel,
    required this.contribution,
    required this.rawScore,
    required this.available,
    this.detail,
  });
}

class BestWindow {
  final DateTime start;
  final DateTime end;
  final double avgScore;
  final String reason;

  const BestWindow({
    required this.start,
    required this.end,
    required this.avgScore,
    required this.reason,
  });

  Duration get duration => end.difference(start);
}

class HourlyActivityPoint {
  final DateTime time;
  final double score;

  const HourlyActivityPoint({required this.time, required this.score});
}

class FishActivityResult {
  final double score;
  final ActivityLevel level;
  final ConfidenceLevel confidence;
  final List<ActivityFactor> factors;
  final BestWindow? bestWindow;
  final List<HourlyActivityPoint> hourly;
  final String explanation;
  final String disclaimer;
  final DateTime computedAt;
  final String speciesKey;
  final String speciesName;
  final DayPhase dayPhase;
  final TempFit waterTempFit;

  const FishActivityResult({
    required this.score,
    required this.level,
    required this.confidence,
    required this.factors,
    required this.bestWindow,
    required this.hourly,
    required this.explanation,
    required this.disclaimer,
    required this.computedAt,
    required this.speciesKey,
    required this.speciesName,
    required this.dayPhase,
    required this.waterTempFit,
  });

  static String levelLabel(ActivityLevel l) {
    switch (l) {
      case ActivityLevel.veryLow:
        return 'Çok Düşük';
      case ActivityLevel.low:
        return 'Düşük';
      case ActivityLevel.medium:
        return 'Orta';
      case ActivityLevel.high:
        return 'Yüksek';
      case ActivityLevel.veryHigh:
        return 'Çok Yüksek';
    }
  }

  static ActivityLevel levelFor(double score) {
    if (score < 20) return ActivityLevel.veryLow;
    if (score < 40) return ActivityLevel.low;
    if (score < 60) return ActivityLevel.medium;
    if (score < 80) return ActivityLevel.high;
    return ActivityLevel.veryHigh;
  }
}

/// Raw environmental snapshot — null means unavailable (never invent).
class FishEnvSnapshot {
  final double lat;
  final double lng;
  final String? placeName;
  final DateTime fetchedAt;

  final double? airTempC;
  final double? humidity;
  final double? windKmh;
  final double? windDirDeg;
  final double? pressureHpa;
  final double? pressureChange6h;
  final int? weatherCode;
  final double? cloudCover;

  final DateTime? sunrise;
  final DateTime? sunset;

  final double? waterTempC;
  final double? waveHeightM;
  final double? wavePeriodS;
  final double? currentSpeedKn;
  final double? currentDirDeg;

  final double? tideHeightM;
  final String? tidePhaseLabel;

  final double? salinityPsu;
  final double? clarityM;
  final double? dissolvedOxygenMgL;

  final double? moonIllumination; // 0–1
  final String? moonPhaseLabel;

  final List<HourlyEnvSample> hourly;

  /// True when served from disk after a failed online fetch.
  final bool stale;
  final Duration? cacheAge;

  const FishEnvSnapshot({
    required this.lat,
    required this.lng,
    required this.placeName,
    required this.fetchedAt,
    this.airTempC,
    this.humidity,
    this.windKmh,
    this.windDirDeg,
    this.pressureHpa,
    this.pressureChange6h,
    this.weatherCode,
    this.cloudCover,
    this.sunrise,
    this.sunset,
    this.waterTempC,
    this.waveHeightM,
    this.wavePeriodS,
    this.currentSpeedKn,
    this.currentDirDeg,
    this.tideHeightM,
    this.tidePhaseLabel,
    this.salinityPsu,
    this.clarityM,
    this.dissolvedOxygenMgL,
    this.moonIllumination,
    this.moonPhaseLabel,
    this.hourly = const [],
    this.stale = false,
    this.cacheAge,
  });

  FishEnvSnapshot copyWith({
    bool? stale,
    Duration? cacheAge,
    double? tideHeightM,
    String? tidePhaseLabel,
  }) {
    return FishEnvSnapshot(
      lat: lat,
      lng: lng,
      placeName: placeName,
      fetchedAt: fetchedAt,
      airTempC: airTempC,
      humidity: humidity,
      windKmh: windKmh,
      windDirDeg: windDirDeg,
      pressureHpa: pressureHpa,
      pressureChange6h: pressureChange6h,
      weatherCode: weatherCode,
      cloudCover: cloudCover,
      sunrise: sunrise,
      sunset: sunset,
      waterTempC: waterTempC,
      waveHeightM: waveHeightM,
      wavePeriodS: wavePeriodS,
      currentSpeedKn: currentSpeedKn,
      currentDirDeg: currentDirDeg,
      tideHeightM: tideHeightM ?? this.tideHeightM,
      tidePhaseLabel: tidePhaseLabel ?? this.tidePhaseLabel,
      salinityPsu: salinityPsu,
      clarityM: clarityM,
      dissolvedOxygenMgL: dissolvedOxygenMgL,
      moonIllumination: moonIllumination,
      moonPhaseLabel: moonPhaseLabel,
      hourly: hourly,
      stale: stale ?? this.stale,
      cacheAge: cacheAge ?? this.cacheAge,
    );
  }

  Map<String, dynamic> toDiskJson() => {
        'lat': lat,
        'lng': lng,
        'placeName': placeName,
        'fetchedAtMs': fetchedAt.millisecondsSinceEpoch,
        'airTempC': airTempC,
        'humidity': humidity,
        'windKmh': windKmh,
        'windDirDeg': windDirDeg,
        'pressureHpa': pressureHpa,
        'pressureChange6h': pressureChange6h,
        'weatherCode': weatherCode,
        'cloudCover': cloudCover,
        'sunriseMs': sunrise?.millisecondsSinceEpoch,
        'sunsetMs': sunset?.millisecondsSinceEpoch,
        'waterTempC': waterTempC,
        'waveHeightM': waveHeightM,
        'wavePeriodS': wavePeriodS,
        'currentSpeedKn': currentSpeedKn,
        'currentDirDeg': currentDirDeg,
        'tideHeightM': tideHeightM,
        'tidePhaseLabel': tidePhaseLabel,
        'moonIllumination': moonIllumination,
        'moonPhaseLabel': moonPhaseLabel,
      };

  factory FishEnvSnapshot.fromDiskJson(Map<String, dynamic> json) {
    DateTime? ms(dynamic v) =>
        v == null ? null : DateTime.fromMillisecondsSinceEpoch((v as num).toInt());
    return FishEnvSnapshot(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      placeName: json['placeName'] as String?,
      fetchedAt: ms(json['fetchedAtMs']) ?? DateTime.now(),
      airTempC: (json['airTempC'] as num?)?.toDouble(),
      humidity: (json['humidity'] as num?)?.toDouble(),
      windKmh: (json['windKmh'] as num?)?.toDouble(),
      windDirDeg: (json['windDirDeg'] as num?)?.toDouble(),
      pressureHpa: (json['pressureHpa'] as num?)?.toDouble(),
      pressureChange6h: (json['pressureChange6h'] as num?)?.toDouble(),
      weatherCode: (json['weatherCode'] as num?)?.toInt(),
      cloudCover: (json['cloudCover'] as num?)?.toDouble(),
      sunrise: ms(json['sunriseMs']),
      sunset: ms(json['sunsetMs']),
      waterTempC: (json['waterTempC'] as num?)?.toDouble(),
      waveHeightM: (json['waveHeightM'] as num?)?.toDouble(),
      wavePeriodS: (json['wavePeriodS'] as num?)?.toDouble(),
      currentSpeedKn: (json['currentSpeedKn'] as num?)?.toDouble(),
      currentDirDeg: (json['currentDirDeg'] as num?)?.toDouble(),
      tideHeightM: (json['tideHeightM'] as num?)?.toDouble(),
      tidePhaseLabel: json['tidePhaseLabel'] as String?,
      moonIllumination: (json['moonIllumination'] as num?)?.toDouble(),
      moonPhaseLabel: json['moonPhaseLabel'] as String?,
      hourly: const [],
    );
  }
}

@immutable
class HourlyEnvSample {
  final DateTime time;
  final double? airTempC;
  final double? windKmh;
  final double? pressureHpa;
  final int? weatherCode;
  final double? cloudCover;
  final double? waterTempC;
  final double? waveHeightM;

  const HourlyEnvSample({
    required this.time,
    this.airTempC,
    this.windKmh,
    this.pressureHpa,
    this.weatherCode,
    this.cloudCover,
    this.waterTempC,
    this.waveHeightM,
  });
}
