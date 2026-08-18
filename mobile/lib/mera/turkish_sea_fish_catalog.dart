/// Built-in Turkish sea species — visuals are EXISTING project assets only.
///
/// Rule: [imageAsset] must point at a file already in `assets/fish/`.
/// Never invent paths, never cross-map species artwork.
class TurkishSeaFish {
  const TurkishSeaFish({
    required this.id,
    required this.slug,
    required this.name,
    required this.aliases,
    this.scientificName,
  });

  /// Stable species id (prefer scientific kebab-case when known).
  final String id;
  final String slug;
  final String name;
  final List<String> aliases;
  final String? scientificName;

  /// Existing silhouette path (always present for catalog entries).
  String get svgAsset => 'assets/fish/$slug.svg';

  /// Existing PNG artwork path when present for the species.
  String? get pngAsset {
    if (TurkishSeaFishCatalog.existingPngSlugs.contains(slug)) {
      return 'assets/fish/$slug.png';
    }
    return null;
  }

  /// Existing Siren reference WebP for photo species.
  String? get photoAsset {
    switch (slug) {
      case 'cipura':
      case 'levrek':
      case 'mercan':
        return 'assets/fish/$slug.webp';
      default:
        return null;
    }
  }

  /// Canonical display asset — PNG photo when present, else WebP, else SVG.
  String get imageAsset => pngAsset ?? photoAsset ?? svgAsset;
}

abstract final class TurkishSeaFishCatalog {
  /// Species that have a dedicated existing SVG (or WebP) in the project.
  /// Do not add entries here without a matching `assets/fish/<slug>.svg`.
  static const List<TurkishSeaFish> all = [
    TurkishSeaFish(
      id: 'sparus-aurata',
      slug: 'cipura',
      name: 'Çipura',
      scientificName: 'Sparus aurata',
      aliases: ['cipura', 'çupra', 'cupra'],
    ),
    TurkishSeaFish(
      id: 'dicentrarchus-labrax',
      slug: 'levrek',
      name: 'Levrek',
      scientificName: 'Dicentrarchus labrax',
      aliases: ['levrek', 'bass', 'seabass'],
    ),
    TurkishSeaFish(
      id: 'pagellus-erythrinus',
      slug: 'mercan',
      name: 'Mercan',
      scientificName: 'Pagellus erythrinus',
      aliases: ['mercan'],
    ),
    TurkishSeaFish(
      id: 'pomatomus-saltatrix',
      slug: 'lufer',
      name: 'Lüfer',
      scientificName: 'Pomatomus saltatrix',
      aliases: ['lüfer', 'lufer', 'bluefish'],
    ),
    TurkishSeaFish(
      id: 'pomatomus-saltatrix-juvenile',
      slug: 'cinekop',
      name: 'Çinekop',
      scientificName: 'Pomatomus saltatrix',
      aliases: ['çinekop', 'cinekop'],
    ),
    TurkishSeaFish(
      id: 'sarikanat',
      slug: 'sarikanat',
      name: 'Sarıkanat',
      aliases: ['sarıkanat', 'sarikanat'],
    ),
    TurkishSeaFish(
      id: 'sarda-sarda',
      slug: 'palamut',
      name: 'Palamut',
      scientificName: 'Sarda sarda',
      aliases: ['palamut', 'bonito'],
    ),
    TurkishSeaFish(
      id: 'euthynnus-alletteratus',
      slug: 'torik',
      name: 'Torik',
      scientificName: 'Euthynnus alletteratus',
      aliases: ['torik'],
    ),
    TurkishSeaFish(
      id: 'thunnus-thynnus',
      slug: 'orkinos',
      name: 'Orkinos',
      scientificName: 'Thunnus thynnus',
      aliases: ['orkinos', 'tuna'],
    ),
    TurkishSeaFish(
      id: 'scomber-scombrus',
      slug: 'uskumru',
      name: 'Uskumru',
      scientificName: 'Scomber scombrus',
      aliases: ['uskumru', 'mackerel'],
    ),
    TurkishSeaFish(
      id: 'scomber-japonicus',
      slug: 'kolyoz',
      name: 'Kolyoz',
      scientificName: 'Scomber japonicus',
      aliases: ['kolyoz'],
    ),
    TurkishSeaFish(
      id: 'engraulis-encrasicolus',
      slug: 'hamsi',
      name: 'Hamsi',
      scientificName: 'Engraulis encrasicolus',
      aliases: ['hamsi', 'anchovy'],
    ),
    TurkishSeaFish(
      id: 'sardina-pilchardus',
      slug: 'sardalya',
      name: 'Sardalya',
      scientificName: 'Sardina pilchardus',
      aliases: ['sardalya', 'sardine'],
    ),
    TurkishSeaFish(
      id: 'sprattus-sprattus',
      slug: 'caca',
      name: 'Çaça',
      scientificName: 'Sprattus sprattus',
      aliases: ['çaça', 'caca', 'sprat'],
    ),
    TurkishSeaFish(
      id: 'trachurus-mediterraneus',
      slug: 'istavrit',
      name: 'İstavrit',
      scientificName: 'Trachurus mediterraneus',
      aliases: ['istavrit', 'ıstavrit'],
    ),
    TurkishSeaFish(
      id: 'mullus-barbatus',
      slug: 'barbun',
      name: 'Barbun',
      scientificName: 'Mullus barbatus',
      aliases: ['barbun', 'barbunya'],
    ),
    TurkishSeaFish(
      id: 'mullus-surmuletus',
      slug: 'tekir',
      name: 'Tekir',
      scientificName: 'Mullus surmuletus',
      aliases: ['tekir'],
    ),
    TurkishSeaFish(
      id: 'merlangius-merlangus',
      slug: 'mezgit',
      name: 'Mezgit',
      scientificName: 'Merlangius merlangus',
      aliases: ['mezgit', 'whiting'],
    ),
    TurkishSeaFish(
      id: 'psetta-maxima',
      slug: 'kalkan',
      name: 'Kalkan',
      scientificName: 'Psetta maxima',
      aliases: ['kalkan', 'turbot'],
    ),
    TurkishSeaFish(
      id: 'solea-solea',
      slug: 'dil',
      name: 'Dil',
      scientificName: 'Solea solea',
      aliases: ['dil balığı', 'dil', 'sole'],
    ),
    TurkishSeaFish(
      id: 'diplodus-vulgaris',
      slug: 'karagoz',
      name: 'Karagöz',
      scientificName: 'Diplodus vulgaris',
      aliases: ['karagöz', 'karagoz'],
    ),
    TurkishSeaFish(
      id: 'diplodus-sargus',
      slug: 'sargoz',
      name: 'Sargoz',
      scientificName: 'Diplodus sargus',
      aliases: ['sargoz', 'sargos', 'sargöz'],
    ),
    TurkishSeaFish(
      id: 'lithognathus-mormyrus',
      slug: 'mirmir',
      name: 'Mırmır',
      scientificName: 'Lithognathus mormyrus',
      aliases: ['mırmır', 'mirmir'],
    ),
    TurkishSeaFish(
      id: 'boops-boops',
      slug: 'kupes',
      name: 'Kupes',
      scientificName: 'Boops boops',
      aliases: ['kupes', 'küpez'],
    ),
    TurkishSeaFish(
      id: 'spicara-smaris',
      slug: 'izmarit',
      name: 'İzmarit',
      scientificName: 'Spicara smaris',
      aliases: ['izmarit', 'ızmarit'],
    ),
    TurkishSeaFish(
      id: 'epinephelus-marginatus',
      slug: 'orfoz',
      name: 'Orfoz',
      scientificName: 'Epinephelus marginatus',
      aliases: ['orfoz', 'grouper'],
    ),
    TurkishSeaFish(
      id: 'epinephelus-aeneus',
      slug: 'lahos',
      name: 'Lahos',
      scientificName: 'Epinephelus aeneus',
      aliases: ['lahos', 'lagos'],
    ),
    TurkishSeaFish(
      id: 'dentex-dentex',
      slug: 'sinagrit',
      name: 'Sinagrit',
      scientificName: 'Dentex dentex',
      aliases: ['sinagrit', 'sinarit'],
    ),
    TurkishSeaFish(
      id: 'fangri',
      slug: 'fangri',
      name: 'Fangri',
      aliases: ['fangri'],
    ),
    TurkishSeaFish(
      id: 'seriola-dumerili',
      slug: 'akya',
      name: 'Akya',
      scientificName: 'Seriola dumerili',
      aliases: ['akya'],
    ),
    TurkishSeaFish(
      id: 'mugil-cephalus',
      slug: 'kefal',
      name: 'Kefal',
      scientificName: 'Mugil cephalus',
      aliases: ['kefal', 'mullet'],
    ),
    TurkishSeaFish(
      id: 'belone-belone',
      slug: 'zargana',
      name: 'Zargana',
      scientificName: 'Belone belone',
      aliases: ['zargana', 'needlefish'],
    ),
    TurkishSeaFish(
      id: 'scorpaena-scrofa',
      slug: 'iskorpit',
      name: 'İskorpit',
      scientificName: 'Scorpaena scrofa',
      aliases: ['iskorpit', 'scorpionfish'],
    ),
    TurkishSeaFish(
      id: 'chelidonichthys-lucerna',
      slug: 'kirlangic',
      name: 'Kırlangıç',
      scientificName: 'Chelidonichthys lucerna',
      aliases: ['kırlangıç', 'kirlangic'],
    ),
    TurkishSeaFish(
      id: 'umbrina-cirrosa',
      slug: 'minakop',
      name: 'Minakop',
      scientificName: 'Umbrina cirrosa',
      aliases: ['minakop'],
    ),
    TurkishSeaFish(
      id: 'argyrosomus-regius',
      slug: 'eskina',
      name: 'Eşkina',
      scientificName: 'Argyrosomus regius',
      aliases: ['eşkina', 'eskina'],
    ),
    TurkishSeaFish(
      id: 'epinephelus-costae',
      slug: 'granyoz',
      name: 'Granyöz',
      scientificName: 'Epinephelus costae',
      aliases: ['granyöz', 'granyoz', 'grida'],
    ),
    TurkishSeaFish(
      id: 'dasyatis',
      slug: 'vatoz',
      name: 'Vatoz',
      scientificName: 'Dasyatis spp.',
      aliases: ['vatoz', 'ray'],
    ),
    TurkishSeaFish(
      id: 'kalamar',
      slug: 'kalamar',
      name: 'Kalamar',
      aliases: ['kalamar', 'squid'],
    ),
    TurkishSeaFish(
      id: 'ahtapot',
      slug: 'ahtapot',
      name: 'Ahtapot',
      aliases: ['ahtapot', 'octopus'],
    ),
    TurkishSeaFish(
      id: 'karides',
      slug: 'karides',
      name: 'Karides',
      aliases: ['karides', 'shrimp'],
    ),
    TurkishSeaFish(
      id: 'istakoz',
      slug: 'istakoz',
      name: 'Istakoz',
      aliases: ['istakoz', 'lobster'],
    ),
    TurkishSeaFish(
      id: 'lipsoz',
      slug: 'lipsoz',
      name: 'Lipsoz',
      aliases: ['lipsoz'],
    ),
    TurkishSeaFish(
      id: 'gelincik',
      slug: 'gelincik',
      name: 'Gelincik',
      aliases: ['gelincik'],
    ),
    TurkishSeaFish(
      id: 'horozbina',
      slug: 'horozbina',
      name: 'Horozbina',
      aliases: ['horozbina'],
    ),
    TurkishSeaFish(
      id: 'kayabaligi',
      slug: 'kayabaligi',
      name: 'Kayabalığı',
      aliases: ['kayabalığı', 'kayabaligi'],
    ),
    TurkishSeaFish(
      id: 'ispendek',
      slug: 'ispendek',
      name: 'İspendek',
      aliases: ['ispendek', 'işpendek'],
    ),
    TurkishSeaFish(
      id: 'oblada-melanura',
      slug: 'melanur',
      name: 'Melanur',
      scientificName: 'Oblada melanura',
      aliases: ['melanur', 'melanurya'],
    ),
    TurkishSeaFish(
      id: 'lafina',
      slug: 'lafina',
      name: 'Lafina',
      aliases: ['lafina', 'lafena'],
    ),
    TurkishSeaFish(
      id: 'pacoz',
      slug: 'pacoz',
      name: 'Paçoz',
      aliases: ['paçoz', 'pacoz'],
    ),
    TurkishSeaFish(
      id: 'atherina-boyeri',
      slug: 'gumus',
      name: 'Gümüş',
      scientificName: 'Atherina boyeri',
      aliases: ['gümüş', 'gumus'],
    ),
    TurkishSeaFish(
      id: 'trachinus-draco',
      slug: 'trakonya',
      name: 'Trakonya',
      scientificName: 'Trachinus draco',
      aliases: ['trakonya', 'trahonya', 'pisi'],
    ),
  ];

  static const digerAsset = 'assets/fish/diger.svg';

  /// Species with high-resolution full-color PNG artwork extracted from poster sprite.
  static const Set<String> existingPngSlugs = {
    'akya',
    'barbun',
    'caca',
    'cinekop',
    'cipura',
    'dil',
    'eskina',
    'fangri',
    'gelincik',
    'granyoz',
    'gumus',
    'hamsi',
    'horozbina',
    'iskorpit',
    'istavrit',
    'izmarit',
    'kalkan',
    'karagoz',
    'kayabaligi',
    'kefal',
    'kirlangic',
    'kolyoz',
    'kupes',
    'lafina',
    'lahos',
    'levrek',
    'lipsoz',
    'lufer',
    'melanur',
    'mercan',
    'mezgit',
    'minakop',
    'mirmir',
    'orfoz',
    'orkinos',
    'palamut',
    'sardalya',
    'sargoz',
    'sarikanat',
    'sinagrit',
    'tekir',
    'torik',
    'trakonya',
    'uskumru',
    'vatoz',
    'zargana',
  };

  /// Existing raster photos already in the app.
  static const Set<String> existingPhotoSlugs = {
    'cipura',
    'levrek',
    'mercan',
  };

  static TurkishSeaFish? byId(String id) {
    for (final fish in all) {
      if (fish.id == id) return fish;
    }
    return null;
  }

  static TurkishSeaFish? bySlug(String slug) {
    for (final fish in all) {
      if (fish.slug == slug) return fish;
    }
    return null;
  }

  static TurkishSeaFish? match(String? speciesName) {
    final n = _normalize(speciesName);
    if (n.isEmpty) return null;
    for (final fish in all) {
      if (_normalize(fish.name) == n) return fish;
    }
    for (final fish in all) {
      for (final alias in fish.aliases) {
        if (_normalize(alias) == n) return fish;
      }
    }
    for (final fish in all) {
      if (_normalize(fish.scientificName) == n) return fish;
    }
    for (final fish in all) {
      final slug = _normalize(fish.slug);
      final name = _normalize(fish.name);
      if (n.contains(name) || n.contains(slug)) return fish;
      for (final alias in fish.aliases) {
        final a = _normalize(alias);
        if (a.length >= 4 && n.contains(a)) return fish;
      }
    }
    return null;
  }

  /// Resolves to an existing project asset for the species — never invents.
  static String assetFor(String? speciesName) {
    final fish = match(speciesName);
    if (fish == null) return digerAsset;
    return fish.imageAsset;
  }

  /// Validation helpers for tests / QA.
  static List<String> validateUniqueIds() {
    final seen = <String>{};
    final dupes = <String>[];
    for (final f in all) {
      if (!seen.add(f.id)) dupes.add(f.id);
    }
    return dupes;
  }

  static List<String> validateUniqueSlugs() {
    final seen = <String>{};
    final dupes = <String>[];
    for (final f in all) {
      if (!seen.add(f.slug)) dupes.add(f.slug);
    }
    return dupes;
  }

  static String _normalize(String? value) {
    if (value == null) return '';
    var s = value.trim();
    const map = {
      'Ç': 'c',
      'ç': 'c',
      'Ğ': 'g',
      'ğ': 'g',
      'İ': 'i',
      'I': 'i',
      'ı': 'i',
      'Ö': 'o',
      'ö': 'o',
      'Ş': 's',
      'ş': 's',
      'Ü': 'u',
      'ü': 'u',
    };
    for (final e in map.entries) {
      s = s.replaceAll(e.key, e.value);
    }
    return s.toLowerCase();
  }
}
