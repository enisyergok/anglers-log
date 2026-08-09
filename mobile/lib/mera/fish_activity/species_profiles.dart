/// Tunable heuristic weights per species.
///
/// These are **not** validated scientific constants — they encode angler
/// heuristics for Mediterranean coastal species and can be revised when
/// better evidence or catch-log calibration is available.
class SpeciesActivityProfile {
  final String key;
  final String nameTr;
  final String scientificName;
  final double tempMinC;
  final double tempMaxC;
  final double tempIdealMinC;
  final double tempIdealMaxC;

  /// Relative weights (arbitrary units; normalized at runtime).
  final double temperatureWeight;
  final double lightWeight;
  final double timeWeight;
  final double windWeight;
  final double waveWeight;
  final double currentWeight;
  final double pressureTrendWeight;
  final double moonWeight;
  final double cloudWeight;
  final double tideWeight;
  final double clarityWeight;
  final double oxygenWeight;

  /// Preferred day phases (higher = more favorable for this species).
  final Map<String, double> dayPhaseBias;

  const SpeciesActivityProfile({
    required this.key,
    required this.nameTr,
    required this.scientificName,
    required this.tempMinC,
    required this.tempMaxC,
    required this.tempIdealMinC,
    required this.tempIdealMaxC,
    required this.temperatureWeight,
    required this.lightWeight,
    required this.timeWeight,
    required this.windWeight,
    required this.waveWeight,
    required this.currentWeight,
    required this.pressureTrendWeight,
    required this.moonWeight,
    required this.cloudWeight,
    required this.tideWeight,
    required this.clarityWeight,
    required this.oxygenWeight,
    required this.dayPhaseBias,
  });
}

/// Central configuration — edit here when science/data improves.
abstract final class SpeciesActivityProfiles {
  static const cipura = SpeciesActivityProfile(
    key: 'cipura',
    nameTr: 'Çipura',
    scientificName: 'Sparus aurata',
    tempMinC: 12,
    tempMaxC: 28,
    tempIdealMinC: 18,
    tempIdealMaxC: 25,
    temperatureWeight: 5,
    lightWeight: 5,
    timeWeight: 4,
    windWeight: 3,
    waveWeight: 3,
    currentWeight: 5,
    pressureTrendWeight: 1,
    moonWeight: 1,
    cloudWeight: 2,
    tideWeight: 3,
    clarityWeight: 3,
    oxygenWeight: 2,
    dayPhaseBias: {
      'preDawn': 0.85,
      'sunrise': 1.0,
      'day': 0.45,
      'sunset': 1.0,
      'dusk': 0.9,
      'night': 0.55,
    },
  );

  static const levrek = SpeciesActivityProfile(
    key: 'levrek',
    nameTr: 'Levrek',
    scientificName: 'Dicentrarchus labrax',
    tempMinC: 8,
    tempMaxC: 24,
    tempIdealMinC: 12,
    tempIdealMaxC: 20,
    temperatureWeight: 4,
    lightWeight: 5,
    timeWeight: 5,
    windWeight: 4,
    waveWeight: 3,
    currentWeight: 4,
    pressureTrendWeight: 1.5,
    moonWeight: 1,
    cloudWeight: 3,
    tideWeight: 3,
    clarityWeight: 2,
    oxygenWeight: 2,
    dayPhaseBias: {
      'preDawn': 1.0,
      'sunrise': 0.95,
      'day': 0.35,
      'sunset': 0.95,
      'dusk': 1.0,
      'night': 0.7,
    },
  );

  static const mercan = SpeciesActivityProfile(
    key: 'mercan',
    nameTr: 'Mercan',
    scientificName: 'Pagellus erythrinus',
    tempMinC: 14,
    tempMaxC: 26,
    tempIdealMinC: 16,
    tempIdealMaxC: 23,
    temperatureWeight: 4,
    lightWeight: 3,
    timeWeight: 3,
    windWeight: 2,
    waveWeight: 3,
    currentWeight: 5,
    pressureTrendWeight: 1,
    moonWeight: 1,
    cloudWeight: 2,
    tideWeight: 4,
    clarityWeight: 5,
    oxygenWeight: 2,
    dayPhaseBias: {
      'preDawn': 0.7,
      'sunrise': 0.85,
      'day': 0.55,
      'sunset': 0.85,
      'dusk': 0.8,
      'night': 0.65,
    },
  );

  static const List<SpeciesActivityProfile> primary = [cipura, levrek, mercan];

  static SpeciesActivityProfile byKey(String key) {
    for (final p in primary) {
      if (p.key == key) return p;
    }
    return cipura;
  }

  static SpeciesActivityProfile? matchName(String? name) {
    if (name == null) return null;
    final n = name.toLowerCase();
    for (final p in primary) {
      if (p.nameTr.toLowerCase() == n || p.key == n) return p;
    }
    if (n.contains('çipura') || n.contains('cipura')) return cipura;
    if (n.contains('levrek')) return levrek;
    if (n.contains('mercan')) return mercan;
    return null;
  }
}
