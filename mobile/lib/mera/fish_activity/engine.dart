import 'package:intl/intl.dart';
import 'package:mobile/mera/fish_activity/astronomy.dart';
import 'package:mobile/mera/fish_activity/env_provider.dart';
import 'package:mobile/mera/fish_activity/models.dart';
import 'package:mobile/mera/fish_activity/species_profiles.dart';

/// Heuristic fish-activity estimate — probabilistic, not a guarantee.
class FishActivityEngine {
  const FishActivityEngine();

  FishActivityResult calculate({
    required SpeciesActivityProfile species,
    required FishEnvSnapshot env,
    DateTime? at,
  }) {
    final now = at ?? DateTime.now();
    final phase = AstronomyProvider.dayPhase(
      now: now,
      sunrise: env.sunrise,
      sunset: env.sunset,
    );

    final factors = <ActivityFactor>[];
    var weightedSum = 0.0;
    var weightTotal = 0.0;
    var availableCore = 0;
    var missingImportant = 0;

    void addFactor({
      required String id,
      required String name,
      required String valueLabel,
      required double weight,
      required double? raw0to100,
      String? detail,
      bool important = false,
    }) {
      if (raw0to100 == null || weight <= 0) {
        factors.add(
          ActivityFactor(
            id: id,
            name: name,
            valueLabel: valueLabel,
            contribution: 0,
            rawScore: 0,
            available: false,
            detail: detail ?? 'Veri yok',
          ),
        );
        if (important) missingImportant++;
        return;
      }
      availableCore++;
      final contrib = ((raw0to100 - 50) / 50) * weight * 8;
      weightedSum += raw0to100 * weight;
      weightTotal += weight;
      factors.add(
        ActivityFactor(
          id: id,
          name: name,
          valueLabel: valueLabel,
          contribution: contrib,
          rawScore: raw0to100,
          available: true,
          detail: detail,
        ),
      );
    }

    // --- Water temperature ---
    TempFit tempFit = TempFit.unknown;
    double? tempScore;
    String tempLabel = 'Veri yok';
    if (env.waterTempC != null) {
      final t = env.waterTempC!;
      tempLabel = '${t.toStringAsFixed(1)} °C';
      if (t < species.tempMinC) {
        tempFit = TempFit.low;
        tempScore = _ramp(t, species.tempMinC - 6, species.tempMinC) * 40;
      } else if (t > species.tempMaxC) {
        tempFit = TempFit.high;
        tempScore = _ramp(species.tempMaxC + 6, species.tempMaxC, t) * 40;
        tempScore = 40 - tempScore.clamp(0, 40);
      } else if (t >= species.tempIdealMinC && t <= species.tempIdealMaxC) {
        tempFit = TempFit.suitable;
        tempScore = 88 +
            12 *
                (1 -
                    ((t - (species.tempIdealMinC + species.tempIdealMaxC) / 2)
                            .abs() /
                        ((species.tempIdealMaxC - species.tempIdealMinC) / 2 +
                            0.01)));
      } else {
        tempFit = TempFit.suitable;
        final towardIdeal = t < species.tempIdealMinC
            ? _ramp(t, species.tempMinC, species.tempIdealMinC)
            : _ramp(species.tempMaxC, species.tempIdealMaxC, t);
        tempScore = 55 + towardIdeal * 30;
      }
    }
    addFactor(
      id: 'waterTemp',
      name: 'Su Sıcaklığı',
      valueLabel: tempLabel,
      weight: species.temperatureWeight,
      raw0to100: tempScore,
      detail: _tempFitLabel(tempFit),
      important: true,
    );

    // --- Light / day phase ---
    final bias =
        species.dayPhaseBias[AstronomyProvider.dayPhaseKey(phase)] ?? 0.5;
    final lightScore = (bias * 100).clamp(0, 100);
    addFactor(
      id: 'light',
      name: 'Gün Işığı',
      valueLabel: AstronomyProvider.dayPhaseLabel(phase),
      weight: species.lightWeight,
      raw0to100: lightScore.toDouble(),
      detail: _lightDetail(phase, env),
      important: true,
    );

    // --- Time (paired with light; mild extra for dusk/dawn clocks) ---
    final timeScore = lightScore * 0.85 + 15;
    addFactor(
      id: 'time',
      name: 'Saat',
      valueLabel: DateFormat('HH:mm').format(now),
      weight: species.timeWeight,
      raw0to100: timeScore.clamp(0, 100),
      detail: 'Tür + ışık fazı ile birlikte değerlendirildi',
      important: true,
    );

    // --- Wind ---
    double? windScore;
    String windLabel = 'Veri yok';
    if (env.windKmh != null) {
      final kn = env.windKmh! / 1.852;
      windLabel =
          '${FishEnvProvider.windName(env.windDirDeg)} ${kn.toStringAsFixed(0)} kn';
      // Light–moderate wind often favorable for coastal; gale reduces.
      if (kn < 2) {
        windScore = 48;
      } else if (kn <= 12) {
        windScore = 70 + (kn / 12) * 20;
      } else if (kn <= 20) {
        windScore = 85 - (kn - 12) * 3;
      } else {
        windScore = (40 - (kn - 20) * 2).clamp(10, 40);
      }
    }
    addFactor(
      id: 'wind',
      name: 'Rüzgâr',
      valueLabel: windLabel,
      weight: species.windWeight,
      raw0to100: windScore,
      important: true,
    );

    // --- Wave ---
    double? waveScore;
    String waveLabel = 'Veri yok';
    if (env.waveHeightM != null) {
      final w = env.waveHeightM!;
      waveLabel = '${w.toStringAsFixed(1)} m';
      if (w < 0.2) {
        waveScore = 45;
      } else if (w <= 1.0) {
        waveScore = 75 + w * 15;
      } else if (w <= 2.0) {
        waveScore = 80 - (w - 1) * 25;
      } else {
        waveScore = 25;
      }
    }
    addFactor(
      id: 'wave',
      name: 'Dalga',
      valueLabel: waveLabel,
      weight: species.waveWeight,
      raw0to100: waveScore,
    );

    // --- Current (only if real) ---
    double? currentScore;
    String currentLabel = 'Veri yok';
    if (env.currentSpeedKn != null) {
      final c = env.currentSpeedKn!;
      final dir = FishEnvProvider.compass(env.currentDirDeg);
      currentLabel = '${c.toStringAsFixed(1)} kn → $dir';
      if (c < 0.1) {
        currentScore = 40;
      } else if (c <= 1.2) {
        currentScore = 65 + c * 25;
      } else {
        currentScore = (90 - (c - 1.2) * 20).clamp(30, 90);
      }
    }
    addFactor(
      id: 'current',
      name: 'Akıntı',
      valueLabel: currentLabel,
      weight: species.currentWeight,
      raw0to100: currentScore,
      important: true,
    );

    // --- Pressure trend (low weight; no causal claims) ---
    double? pressureScore;
    String pressureLabel = 'Veri yok';
    if (env.pressureHpa != null) {
      final p = env.pressureHpa!;
      final d = env.pressureChange6h;
      if (d != null) {
        final arrow = d > 0.5 ? '↑' : (d < -0.5 ? '↓' : '→');
        pressureLabel =
            '${p.toStringAsFixed(0)} hPa $arrow ${d.abs().toStringAsFixed(1)} / 6s';
        // Mild heuristic: slow change slightly preferred; rapid drop slightly lower.
        if (d.abs() < 2) {
          pressureScore = 62;
        } else if (d < -4) {
          pressureScore = 48;
        } else if (d > 4) {
          pressureScore = 52;
        } else {
          pressureScore = 58;
        }
      } else {
        pressureLabel = '${p.toStringAsFixed(0)} hPa';
        pressureScore = 55;
      }
    }
    addFactor(
      id: 'pressure',
      name: 'Basınç Trendi',
      valueLabel: pressureLabel,
      weight: species.pressureTrendWeight,
      raw0to100: pressureScore,
      detail: 'Dolaylı hava göstergesi — kesin ısırık sinyali değil',
    );

    // --- Moon (low weight) ---
    double? moonScore;
    String moonLabel = 'Veri yok';
    if (env.moonIllumination != null) {
      final pct = (env.moonIllumination! * 100).round();
      moonLabel = '${env.moonPhaseLabel ?? 'Ay'} · %$pct';
      // Mild: avoid claiming activity; slight preference near quarters mid-range
      moonScore = 50 + (0.5 - (env.moonIllumination! - 0.5).abs()) * 20;
    }
    addFactor(
      id: 'moon',
      name: 'Ay Fazı',
      valueLabel: moonLabel,
      weight: species.moonWeight,
      raw0to100: moonScore,
      detail: 'Düşük ağırlık — gelgit/ışık bağlamı',
    );

    // --- Cloud ---
    double? cloudScore;
    String cloudLabel = 'Veri yok';
    if (env.cloudCover != null) {
      cloudLabel = '%${env.cloudCover!.round()}';
      // Light cloud can help coastal sight-feeders less spooked
      final c = env.cloudCover!;
      if (c < 15) {
        cloudScore = 48;
      } else if (c <= 70) {
        cloudScore = 70;
      } else {
        cloudScore = 58;
      }
    }
    addFactor(
      id: 'cloud',
      name: 'Bulutluluk',
      valueLabel: cloudLabel,
      weight: species.cloudWeight,
      raw0to100: cloudScore,
    );

    // --- Clarity / O2 / Tide — only if present ---
    addFactor(
      id: 'clarity',
      name: 'Su Berraklığı',
      valueLabel: env.clarityM != null
          ? '${env.clarityM!.toStringAsFixed(1)} m'
          : 'Veri yok',
      weight: species.clarityWeight,
      raw0to100: null,
    );
    addFactor(
      id: 'oxygen',
      name: 'Çözünmüş Oksijen',
      valueLabel: env.dissolvedOxygenMgL != null
          ? '${env.dissolvedOxygenMgL!.toStringAsFixed(1)} mg/L'
          : 'Veri yok',
      weight: species.oxygenWeight,
      raw0to100: null,
    );
    addFactor(
      id: 'tide',
      name: 'Gelgit',
      valueLabel: env.tidePhaseLabel ?? 'Veri yok',
      weight: species.tideWeight,
      raw0to100: null,
    );

    final score = weightTotal <= 0
        ? 40.0
        : (weightedSum / weightTotal).clamp(0.0, 100.0);

    // Recompute contributions so they sum visually relative to final score
    final scaledFactors = factors.map((f) {
      if (!f.available) return f;
      final share = (f.rawScore - 50) / 50 * (f.contribution.abs() > 0
          ? (speciesWeightOf(species, f.id) * 3.5)
          : 0);
      return ActivityFactor(
        id: f.id,
        name: f.name,
        valueLabel: f.valueLabel,
        contribution: share,
        rawScore: f.rawScore,
        available: f.available,
        detail: f.detail,
      );
    }).toList()
      ..sort((a, b) => b.contribution.abs().compareTo(a.contribution.abs()));

    final confidence = _confidence(
      availableCore: availableCore,
      missingImportant: missingImportant,
      hasMarine: env.waterTempC != null || env.waveHeightM != null,
      hasCurrent: env.currentSpeedKn != null,
      age: Duration.zero,
    );

    final hourly = _hourlyCurve(species, env, now);
    final best = _bestWindow(hourly, phase);

    final level = FishActivityResult.levelFor(score);
    final explanation = _explain(
      species: species,
      level: level,
      tempFit: tempFit,
      phase: phase,
      factors: scaledFactors,
      env: env,
    );

    return FishActivityResult(
      score: score,
      level: level,
      confidence: confidence,
      factors: scaledFactors,
      bestWindow: best,
      hourly: hourly,
      explanation: explanation,
      disclaimer:
          'Bu skor çevresel veriler ve tür özelliklerine göre oluşturulan '
          'bir tahmindir; av başarısı yem, derinlik ve tecrübeye de bağlıdır.',
      computedAt: now,
      speciesKey: species.key,
      speciesName: species.nameTr,
      dayPhase: phase,
      waterTempFit: tempFit,
    );
  }

  double speciesWeightOf(SpeciesActivityProfile s, String id) {
    switch (id) {
      case 'waterTemp':
        return s.temperatureWeight;
      case 'light':
        return s.lightWeight;
      case 'time':
        return s.timeWeight;
      case 'wind':
        return s.windWeight;
      case 'wave':
        return s.waveWeight;
      case 'current':
        return s.currentWeight;
      case 'pressure':
        return s.pressureTrendWeight;
      case 'moon':
        return s.moonWeight;
      case 'cloud':
        return s.cloudWeight;
      default:
        return 1;
    }
  }

  List<HourlyActivityPoint> _hourlyCurve(
    SpeciesActivityProfile species,
    FishEnvSnapshot env,
    DateTime now,
  ) {
    final day = DateTime(now.year, now.month, now.day);
    final points = <HourlyActivityPoint>[];
    for (var h = 0; h <= 24; h++) {
      final t = day.add(Duration(hours: h));
      final sample = _nearestHourly(env.hourly, t);
      final mini = FishEnvSnapshot(
        lat: env.lat,
        lng: env.lng,
        placeName: env.placeName,
        fetchedAt: env.fetchedAt,
        airTempC: sample?.airTempC ?? env.airTempC,
        humidity: env.humidity,
        windKmh: sample?.windKmh ?? env.windKmh,
        windDirDeg: env.windDirDeg,
        pressureHpa: sample?.pressureHpa ?? env.pressureHpa,
        pressureChange6h: env.pressureChange6h,
        weatherCode: sample?.weatherCode ?? env.weatherCode,
        cloudCover: sample?.cloudCover ?? env.cloudCover,
        sunrise: env.sunrise,
        sunset: env.sunset,
        waterTempC: sample?.waterTempC ?? env.waterTempC,
        waveHeightM: sample?.waveHeightM ?? env.waveHeightM,
        wavePeriodS: env.wavePeriodS,
        currentSpeedKn: env.currentSpeedKn,
        currentDirDeg: env.currentDirDeg,
        moonIllumination: env.moonIllumination,
        moonPhaseLabel: env.moonPhaseLabel,
        hourly: const [],
      );
      // Lightweight score for hour: reuse phase+temp+wind only for speed
      final phase = AstronomyProvider.dayPhase(
        now: t,
        sunrise: env.sunrise,
        sunset: env.sunset,
      );
      final bias =
          species.dayPhaseBias[AstronomyProvider.dayPhaseKey(phase)] ?? 0.5;
      var s = bias * 55;
      if (mini.waterTempC != null) {
        final tt = mini.waterTempC!;
        if (tt >= species.tempIdealMinC && tt <= species.tempIdealMaxC) {
          s += 25;
        } else if (tt >= species.tempMinC && tt <= species.tempMaxC) {
          s += 12;
        }
      } else {
        s += 8;
      }
      if (mini.windKmh != null) {
        final kn = mini.windKmh! / 1.852;
        if (kn >= 3 && kn <= 14) s += 12;
        if (kn > 22) s -= 15;
      }
      if (mini.waveHeightM != null) {
        final w = mini.waveHeightM!;
        if (w >= 0.3 && w <= 1.2) s += 8;
        if (w > 2.5) s -= 12;
      }
      points.add(HourlyActivityPoint(time: t, score: s.clamp(0, 100)));
    }
    return points;
  }

  HourlyEnvSample? _nearestHourly(List<HourlyEnvSample> list, DateTime t) {
    if (list.isEmpty) return null;
    HourlyEnvSample? best;
    var bestDiff = 1 << 30;
    for (final s in list) {
      final d = (s.time.difference(t).inMinutes).abs();
      if (d < bestDiff) {
        bestDiff = d;
        best = s;
      }
    }
    return best;
  }

  BestWindow? _bestWindow(List<HourlyActivityPoint> hourly, DayPhase nowPhase) {
    if (hourly.length < 2) return null;
    // Find max contiguous stretch where score >= peak*0.85 and length >= 1h
    var peak = 0.0;
    for (final p in hourly) {
      if (p.score > peak) peak = p.score;
    }
    final thr = (peak * 0.82).clamp(45, 95);
    var bestStart = 0;
    var bestEnd = 0;
    var bestAvg = -1.0;
    var i = 0;
    while (i < hourly.length) {
      if (hourly[i].score < thr) {
        i++;
        continue;
      }
      var j = i;
      var sum = 0.0;
      while (j < hourly.length && hourly[j].score >= thr) {
        sum += hourly[j].score;
        j++;
      }
      final len = j - i;
      if (len >= 1) {
        final avg = sum / len;
        if (avg > bestAvg ||
            (avg == bestAvg && len > (bestEnd - bestStart))) {
          bestAvg = avg;
          bestStart = i;
          bestEnd = j - 1;
        }
      }
      i = j;
    }
    if (bestAvg < 0) {
      // fallback: single peak hour ±30m
      var maxI = 0;
      for (var k = 0; k < hourly.length; k++) {
        if (hourly[k].score > hourly[maxI].score) maxI = k;
      }
      bestStart = maxI;
      bestEnd = maxI;
      bestAvg = hourly[maxI].score;
    }
    final start = hourly[bestStart].time;
    final end = hourly[bestEnd].time.add(const Duration(minutes: 50));
    return BestWindow(
      start: start,
      end: end,
      avgScore: bestAvg,
      reason: AstronomyProvider.dayPhaseLabel(nowPhase),
    );
  }

  ConfidenceLevel _confidence({
    required int availableCore,
    required int missingImportant,
    required bool hasMarine,
    required bool hasCurrent,
    required Duration age,
  }) {
    var points = 0;
    points += availableCore.clamp(0, 8);
    if (hasMarine) points += 2;
    if (hasCurrent) points += 2;
    points -= missingImportant;
    if (points >= 10) return ConfidenceLevel.high;
    if (points >= 6) return ConfidenceLevel.medium;
    return ConfidenceLevel.low;
  }

  String _explain({
    required SpeciesActivityProfile species,
    required ActivityLevel level,
    required TempFit tempFit,
    required DayPhase phase,
    required List<ActivityFactor> factors,
    required FishEnvSnapshot env,
  }) {
    final buf = StringBuffer();
    if (tempFit == TempFit.suitable) {
      buf.writeln(
        'Su sıcaklığı ${species.nameTr} için uygun aralıkta görünüyor.',
      );
    } else if (tempFit == TempFit.low) {
      buf.writeln('Su sıcaklığı tür için düşük tarafta olabilir.');
    } else if (tempFit == TempFit.high) {
      buf.writeln('Su sıcaklığı tür için yüksek tarafta olabilir.');
    } else {
      buf.writeln('Su sıcaklığı verisi eksik; tahmin belirsizliği arttı.');
    }

    if (phase == DayPhase.sunset ||
        phase == DayPhase.dusk ||
        phase == DayPhase.sunrise ||
        phase == DayPhase.preDawn) {
      buf.writeln(
        'Mevcut ışık fazı (${AstronomyProvider.dayPhaseLabel(phase)}) '
        'beslenme penceresini destekliyor olabilir.',
      );
    } else if (phase == DayPhase.day) {
      buf.writeln(
        'Gündüz saatlerinde koşullar türe göre daha seçici olabilir.',
      );
    }

    final top = factors.where((f) => f.available && f.contribution > 2).take(2);
    for (final f in top) {
      if (f.id == 'wind' || f.id == 'wave') {
        buf.writeln('Rüzgâr/deniz koşulları tahmini olumlu yönde etkiliyor.');
        break;
      }
    }

    switch (level) {
      case ActivityLevel.veryHigh:
      case ActivityLevel.high:
        buf.writeln(
          'Genel olarak koşullar ${species.nameTr} aktivitesi açısından '
          'olumlu görünüyor.',
        );
      case ActivityLevel.medium:
        buf.writeln('Koşullar orta seviyede görünüyor.');
      case ActivityLevel.low:
      case ActivityLevel.veryLow:
        buf.writeln(
          'Koşullar şu an daha zorlayıcı görünüyor; veri veya saat '
          'değiştikçe tahmin güncellenir.',
        );
    }
    return buf.toString().trim();
  }

  static double _ramp(double x, double a, double b) {
    if (b <= a) return 0;
    return ((x - a) / (b - a)).clamp(0.0, 1.0);
  }

  static String _tempFitLabel(TempFit f) {
    switch (f) {
      case TempFit.low:
        return 'Düşük';
      case TempFit.suitable:
        return 'Uygun';
      case TempFit.high:
        return 'Yüksek';
      case TempFit.unknown:
        return 'Veri yok';
    }
  }

  static String _lightDetail(DayPhase phase, FishEnvSnapshot env) {
    if (env.sunset != null &&
        (phase == DayPhase.sunset || phase == DayPhase.dusk)) {
      return 'Gün batımına yaklaşıyor';
    }
    if (env.sunrise != null &&
        (phase == DayPhase.sunrise || phase == DayPhase.preDawn)) {
      return 'Gün doğumuna yaklaşıyor';
    }
    return AstronomyProvider.dayPhaseLabel(phase);
  }
}
