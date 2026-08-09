import 'package:mobile/mera/turkish_sea_fish_catalog.dart';

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

enum _SpeciesGroup {
  coastalBream,
  predatorBass,
  bluefish,
  pelagic,
  demersal,
  flat,
  cephalopod,
  defaultCoastal,
}

/// Central configuration — curated templates + factory for full catalog.
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
    clarityWeight: 0,
    oxygenWeight: 0,
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
    clarityWeight: 0,
    oxygenWeight: 0,
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
    clarityWeight: 0,
    oxygenWeight: 0,
    dayPhaseBias: {
      'preDawn': 0.7,
      'sunrise': 0.85,
      'day': 0.55,
      'sunset': 0.85,
      'dusk': 0.8,
      'night': 0.65,
    },
  );

  /// All catalog species (primary picker source).
  static List<SpeciesActivityProfile> get primary =>
      TurkishSeaFishCatalog.all.map(fromCatalog).toList(growable: false);

  static SpeciesActivityProfile fromCatalog(TurkishSeaFish fish) {
    final curated = _curatedBySlug[fish.slug];
    if (curated != null) return curated;
    return _fromGroup(fish, _groupFor(fish));
  }

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
    for (final f in TurkishSeaFishCatalog.all) {
      if (f.name.toLowerCase() == n || f.slug == n) return fromCatalog(f);
      for (final a in f.aliases) {
        if (n.contains(a.toLowerCase())) return fromCatalog(f);
      }
    }
    return null;
  }

  static const _curatedBySlug = {
    'cipura': cipura,
    'levrek': levrek,
    'mercan': mercan,
  };

  static _SpeciesGroup _groupFor(TurkishSeaFish fish) {
    final s = '${fish.slug} ${fish.name} ${fish.scientificName ?? ''}'
        .toLowerCase();
    if (s.contains('lufer') ||
        s.contains('lüfer') ||
        s.contains('cinekop') ||
        s.contains('çinekop') ||
        s.contains('sarikanat') ||
        s.contains('bluefish') ||
        s.contains('pomatomus')) {
      return _SpeciesGroup.bluefish;
    }
    if (s.contains('levrek') || s.contains('dicentrarchus')) {
      return _SpeciesGroup.predatorBass;
    }
    if (s.contains('cipura') ||
        s.contains('çipura') ||
        s.contains('mercan') ||
        s.contains('sparus') ||
        s.contains('pagellus') ||
        s.contains('sargoz') ||
        s.contains('sargo') ||
        s.contains('karagoz') ||
        s.contains('karagöz') ||
        s.contains('fangri') ||
        s.contains('sinagrit') ||
        s.contains('tranca')) {
      return _SpeciesGroup.coastalBream;
    }
    if (s.contains('palamut') ||
        s.contains('ton') ||
        s.contains('orkinos') ||
        s.contains('uskumru') ||
        s.contains('kolyoz') ||
        s.contains('scomber') ||
        s.contains('thunnus')) {
      return _SpeciesGroup.pelagic;
    }
    if (s.contains('kalkan') ||
        s.contains('dil') ||
        s.contains('pisi') ||
        s.contains('flat') ||
        s.contains('solea') ||
        s.contains('scophthalmus')) {
      return _SpeciesGroup.flat;
    }
    if (s.contains('ahtapot') ||
        s.contains('siparis') ||
        s.contains('sübye') ||
        s.contains('subye') ||
        s.contains('mürekkep') ||
        s.contains('murekkep') ||
        s.contains('octopus') ||
        s.contains('sepia') ||
        s.contains('loligo')) {
      return _SpeciesGroup.cephalopod;
    }
    if (s.contains('mezgit') ||
        s.contains('tekir') ||
        s.contains('barbun') ||
        s.contains('izmarit') ||
        s.contains('kupes') ||
        s.contains('isfirya') ||
        s.contains('merlan') ||
        s.contains('mullus')) {
      return _SpeciesGroup.demersal;
    }
    return _SpeciesGroup.defaultCoastal;
  }

  static SpeciesActivityProfile _fromGroup(
    TurkishSeaFish fish,
    _SpeciesGroup group,
  ) {
    switch (group) {
      case _SpeciesGroup.coastalBream:
        return _cloneTemplate(cipura, fish, tide: 3.5, current: 5);
      case _SpeciesGroup.predatorBass:
        return _cloneTemplate(levrek, fish);
      case _SpeciesGroup.bluefish:
        return SpeciesActivityProfile(
          key: fish.slug,
          nameTr: fish.name,
          scientificName: fish.scientificName ?? '',
          tempMinC: 12,
          tempMaxC: 26,
          tempIdealMinC: 16,
          tempIdealMaxC: 22,
          temperatureWeight: 4,
          lightWeight: 4,
          timeWeight: 5,
          windWeight: 4,
          waveWeight: 4,
          currentWeight: 5,
          pressureTrendWeight: 1.5,
          moonWeight: 1.5,
          cloudWeight: 2,
          tideWeight: 4,
          clarityWeight: 0,
          oxygenWeight: 0,
          dayPhaseBias: {
            'preDawn': 0.9,
            'sunrise': 1.0,
            'day': 0.5,
            'sunset': 1.0,
            'dusk': 0.95,
            'night': 0.6,
          },
        );
      case _SpeciesGroup.pelagic:
        return SpeciesActivityProfile(
          key: fish.slug,
          nameTr: fish.name,
          scientificName: fish.scientificName ?? '',
          tempMinC: 14,
          tempMaxC: 28,
          tempIdealMinC: 18,
          tempIdealMaxC: 24,
          temperatureWeight: 5,
          lightWeight: 3,
          timeWeight: 3,
          windWeight: 3,
          waveWeight: 4,
          currentWeight: 5,
          pressureTrendWeight: 1,
          moonWeight: 1,
          cloudWeight: 2,
          tideWeight: 2,
          clarityWeight: 0,
          oxygenWeight: 0,
          dayPhaseBias: {
            'preDawn': 0.6,
            'sunrise': 0.75,
            'day': 0.7,
            'sunset': 0.8,
            'dusk': 0.7,
            'night': 0.45,
          },
        );
      case _SpeciesGroup.demersal:
        return _cloneTemplate(mercan, fish, tide: 3, light: 2.5);
      case _SpeciesGroup.flat:
        return SpeciesActivityProfile(
          key: fish.slug,
          nameTr: fish.name,
          scientificName: fish.scientificName ?? '',
          tempMinC: 10,
          tempMaxC: 24,
          tempIdealMinC: 14,
          tempIdealMaxC: 20,
          temperatureWeight: 4,
          lightWeight: 2,
          timeWeight: 3,
          windWeight: 2,
          waveWeight: 2,
          currentWeight: 3,
          pressureTrendWeight: 1,
          moonWeight: 1,
          cloudWeight: 2,
          tideWeight: 4,
          clarityWeight: 0,
          oxygenWeight: 0,
          dayPhaseBias: {
            'preDawn': 0.7,
            'sunrise': 0.8,
            'day': 0.5,
            'sunset': 0.85,
            'dusk': 0.8,
            'night': 0.7,
          },
        );
      case _SpeciesGroup.cephalopod:
        return SpeciesActivityProfile(
          key: fish.slug,
          nameTr: fish.name,
          scientificName: fish.scientificName ?? '',
          tempMinC: 12,
          tempMaxC: 26,
          tempIdealMinC: 15,
          tempIdealMaxC: 22,
          temperatureWeight: 3,
          lightWeight: 4,
          timeWeight: 5,
          windWeight: 2,
          waveWeight: 2,
          currentWeight: 3,
          pressureTrendWeight: 1,
          moonWeight: 2,
          cloudWeight: 2,
          tideWeight: 3,
          clarityWeight: 0,
          oxygenWeight: 0,
          dayPhaseBias: {
            'preDawn': 0.55,
            'sunrise': 0.6,
            'day': 0.35,
            'sunset': 0.85,
            'dusk': 1.0,
            'night': 0.95,
          },
        );
      case _SpeciesGroup.defaultCoastal:
        return _cloneTemplate(cipura, fish, tide: 3, current: 4);
    }
  }

  static SpeciesActivityProfile _cloneTemplate(
    SpeciesActivityProfile t,
    TurkishSeaFish fish, {
    double? tide,
    double? current,
    double? light,
  }) {
    return SpeciesActivityProfile(
      key: fish.slug,
      nameTr: fish.name,
      scientificName: fish.scientificName ?? t.scientificName,
      tempMinC: t.tempMinC,
      tempMaxC: t.tempMaxC,
      tempIdealMinC: t.tempIdealMinC,
      tempIdealMaxC: t.tempIdealMaxC,
      temperatureWeight: t.temperatureWeight,
      lightWeight: light ?? t.lightWeight,
      timeWeight: t.timeWeight,
      windWeight: t.windWeight,
      waveWeight: t.waveWeight,
      currentWeight: current ?? t.currentWeight,
      pressureTrendWeight: t.pressureTrendWeight,
      moonWeight: t.moonWeight,
      cloudWeight: t.cloudWeight,
      tideWeight: tide ?? t.tideWeight,
      clarityWeight: 0,
      oxygenWeight: 0,
      dayPhaseBias: t.dayPhaseBias,
    );
  }
}
