/// Built-in Turkish sea species (Akdeniz, Ege, Marmara, Karadeniz).
/// Each entry has its own artwork — never cross-mapped.
class TurkishSeaFish {
  const TurkishSeaFish({
    required this.slug,
    required this.name,
    required this.aliases,
    this.scientificName,
  });

  final String slug;
  final String name;
  final List<String> aliases;
  final String? scientificName;

  String get asset => 'assets/fish/$slug.svg';
  String get photoAsset => 'assets/fish/$slug.webp';
}

abstract final class TurkishSeaFishCatalog {
  static const List<TurkishSeaFish> all = [
    TurkishSeaFish(
      slug: 'cipura',
      name: 'Çipura',
      scientificName: 'Sparus aurata',
      aliases: ['cipura', 'çupra', 'cupra'],
    ),
    TurkishSeaFish(
      slug: 'levrek',
      name: 'Levrek',
      scientificName: 'Dicentrarchus labrax',
      aliases: ['levrek', 'bass', 'seabass'],
    ),
    TurkishSeaFish(
      slug: 'mercan',
      name: 'Mercan',
      scientificName: 'Pagellus erythrinus',
      aliases: ['mercan'],
    ),
    TurkishSeaFish(
      slug: 'sinagrit',
      name: 'Sinagrit',
      scientificName: 'Dentex dentex',
      aliases: ['sinagrit', 'sinarit'],
    ),
    TurkishSeaFish(
      slug: 'tranca',
      name: 'Trança',
      scientificName: 'Pagellus acarne',
      aliases: ['trança', 'tranca'],
    ),
    TurkishSeaFish(
      slug: 'karagoz',
      name: 'Karagöz',
      scientificName: 'Diplodus vulgaris',
      aliases: ['karagöz', 'karagoz'],
    ),
    TurkishSeaFish(
      slug: 'sargoz',
      name: 'Sargoz',
      scientificName: 'Diplodus sargus',
      aliases: ['sargoz', 'sargos', 'sargöz'],
    ),
    TurkishSeaFish(
      slug: 'mirmir',
      name: 'Mırmır',
      scientificName: 'Lithognathus mormyrus',
      aliases: ['mırmır', 'mirmir'],
    ),
    TurkishSeaFish(
      slug: 'minakop',
      name: 'Minakop',
      scientificName: 'Umbrina cirrosa',
      aliases: ['minakop'],
    ),
    TurkishSeaFish(
      slug: 'eskina',
      name: 'Eşkina',
      scientificName: 'Argyrosomus regius',
      aliases: ['eşkina', 'eskina'],
    ),
    TurkishSeaFish(
      slug: 'lahos',
      name: 'Lahos',
      scientificName: 'Epinephelus aeneus',
      aliases: ['lahos', 'lagos'],
    ),
    TurkishSeaFish(
      slug: 'orfoz',
      name: 'Orfoz',
      scientificName: 'Epinephelus marginatus',
      aliases: ['orfoz', 'grouper'],
    ),
    TurkishSeaFish(
      slug: 'granyoz',
      name: 'Granyöz',
      scientificName: 'Epinephelus costae',
      aliases: ['granyöz', 'granyoz', 'grida'],
    ),
    TurkishSeaFish(
      slug: 'barbun',
      name: 'Barbun',
      scientificName: 'Mullus barbatus',
      aliases: ['barbun', 'barbunya'],
    ),
    TurkishSeaFish(
      slug: 'tekir',
      name: 'Tekir',
      scientificName: 'Mullus surmuletus',
      aliases: ['tekir'],
    ),
    TurkishSeaFish(
      slug: 'kefal',
      name: 'Kefal',
      scientificName: 'Mugil cephalus',
      aliases: ['kefal', 'mullet'],
    ),
    TurkishSeaFish(
      slug: 'istavrit',
      name: 'İstavrit',
      scientificName: 'Trachurus mediterraneus',
      aliases: ['istavrit', 'ıstavrit'],
    ),
    TurkishSeaFish(
      slug: 'hamsi',
      name: 'Hamsi',
      scientificName: 'Engraulis encrasicolus',
      aliases: ['hamsi', 'anchovy'],
    ),
    TurkishSeaFish(
      slug: 'sardalya',
      name: 'Sardalya',
      scientificName: 'Sardina pilchardus',
      aliases: ['sardalya', 'sardine'],
    ),
    TurkishSeaFish(
      slug: 'uskumru',
      name: 'Uskumru',
      scientificName: 'Scomber scombrus',
      aliases: ['uskumru', 'mackerel'],
    ),
    TurkishSeaFish(
      slug: 'kolyoz',
      name: 'Kolyoz',
      scientificName: 'Scomber japonicus',
      aliases: ['kolyoz'],
    ),
    TurkishSeaFish(
      slug: 'palamut',
      name: 'Palamut',
      scientificName: 'Sarda sarda',
      aliases: ['palamut', 'bonito'],
    ),
    TurkishSeaFish(
      slug: 'torik',
      name: 'Torik',
      scientificName: 'Euthynnus alletteratus',
      aliases: ['torik'],
    ),
    TurkishSeaFish(
      slug: 'lufer',
      name: 'Lüfer',
      scientificName: 'Pomatomus saltatrix',
      aliases: ['lüfer', 'lufer', 'bluefish'],
    ),
    TurkishSeaFish(
      slug: 'cinekop',
      name: 'Çinekop',
      scientificName: 'Pomatomus saltatrix',
      aliases: ['çinekop', 'cinekop'],
    ),
    TurkishSeaFish(
      slug: 'kofana',
      name: 'Kofana',
      scientificName: 'Pomatomus saltatrix',
      aliases: ['kofana'],
    ),
    TurkishSeaFish(
      slug: 'sarikanat',
      name: 'Sarıkanat',
      aliases: ['sarıkanat', 'sarikanat'],
    ),
    TurkishSeaFish(
      slug: 'mezgit',
      name: 'Mezgit',
      scientificName: 'Merlangius merlangus',
      aliases: ['mezgit', 'whiting'],
    ),
    TurkishSeaFish(
      slug: 'bakalyaro',
      name: 'Bakalyaro',
      scientificName: 'Gadus morhua',
      aliases: ['bakalyaro'],
    ),
    TurkishSeaFish(
      slug: 'berlam',
      name: 'Berlam',
      scientificName: 'Merluccius merluccius',
      aliases: ['berlam'],
    ),
    TurkishSeaFish(
      slug: 'kirlangic',
      name: 'Kırlangıç',
      scientificName: 'Chelidonichthys lucerna',
      aliases: ['kırlangıç', 'kirlangic'],
    ),
    TurkishSeaFish(
      slug: 'iskorpit',
      name: 'İskorpit',
      scientificName: 'Scorpaena scrofa',
      aliases: ['iskorpit', 'scorpionfish'],
    ),
    TurkishSeaFish(
      slug: 'kalkan',
      name: 'Kalkan',
      scientificName: 'Psetta maxima',
      aliases: ['kalkan', 'turbot'],
    ),
    TurkishSeaFish(
      slug: 'dil',
      name: 'Dil',
      scientificName: 'Solea solea',
      aliases: ['dil balığı', 'dil', 'sole'],
    ),
    TurkishSeaFish(
      slug: 'trakonya',
      name: 'Trakonya',
      scientificName: 'Trachinus draco',
      aliases: ['trakonya', 'trahonya', 'pisi', 'pisi balığı'],
    ),
    TurkishSeaFish(
      slug: 'dulger',
      name: 'Dülger',
      scientificName: 'Zeus faber',
      aliases: ['dülger', 'dulger'],
    ),
    TurkishSeaFish(
      slug: 'zargana',
      name: 'Zargana',
      scientificName: 'Belone belone',
      aliases: ['zargana', 'needlefish'],
    ),
    TurkishSeaFish(
      slug: 'gumus',
      name: 'Gümüş',
      scientificName: 'Atherina boyeri',
      aliases: ['gümüş', 'gumus', 'gümüş balığı'],
    ),
    TurkishSeaFish(
      slug: 'izmarit',
      name: 'İzmarit',
      scientificName: 'Spicara smaris',
      aliases: ['izmarit', 'ızmarit'],
    ),
    TurkishSeaFish(
      slug: 'kupes',
      name: 'Kupes',
      scientificName: 'Boops boops',
      aliases: ['kupes', 'küpez'],
    ),
    TurkishSeaFish(
      slug: 'melanur',
      name: 'Melanur',
      scientificName: 'Oblada melanura',
      aliases: ['melanur', 'melanurya'],
    ),
    TurkishSeaFish(
      slug: 'lahoz',
      name: 'Lahoz',
      scientificName: 'Lichia amia',
      aliases: ['lahoz'],
    ),
    TurkishSeaFish(
      slug: 'akya',
      name: 'Akya',
      scientificName: 'Seriola dumerili',
      aliases: ['akya'],
    ),
    TurkishSeaFish(
      slug: 'kilic',
      name: 'Kılıç',
      scientificName: 'Xiphias gladius',
      aliases: ['kılıç', 'kilic', 'kılıç balığı'],
    ),
    TurkishSeaFish(
      slug: 'orkinos',
      name: 'Orkinos',
      scientificName: 'Thunnus thynnus',
      aliases: ['orkinos', 'tuna'],
    ),
    TurkishSeaFish(
      slug: 'tirsi',
      name: 'Tirsi',
      scientificName: 'Alosa fallax',
      aliases: ['tirsi'],
    ),
    TurkishSeaFish(
      slug: 'caca',
      name: 'Çaça',
      scientificName: 'Sprattus sprattus',
      aliases: ['çaça', 'caca', 'sprat'],
    ),
    TurkishSeaFish(
      slug: 'horozbina',
      name: 'Horozbina',
      scientificName: 'Chelidonichthys lastoviza',
      aliases: ['horozbina'],
    ),
    TurkishSeaFish(
      slug: 'gelincik',
      name: 'Gelincik',
      scientificName: 'Trigla lyra',
      aliases: ['gelincik'],
    ),
    TurkishSeaFish(
      slug: 'kayabaligi',
      name: 'Kayabalığı',
      aliases: ['kayabalığı', 'kayabaligi'],
    ),
    TurkishSeaFish(
      slug: 'vatoz',
      name: 'Vatoz',
      scientificName: 'Dasyatis spp.',
      aliases: ['vatoz', 'ray'],
    ),
    TurkishSeaFish(
      slug: 'ringa',
      name: 'Ringa',
      scientificName: 'Clupea harengus',
      aliases: ['ringa'],
    ),
    TurkishSeaFish(
      slug: 'mersin',
      name: 'Mersin',
      scientificName: 'Acipenser sturio',
      aliases: ['mersin', 'mersin balığı'],
    ),
    TurkishSeaFish(
      slug: 'laos',
      name: 'Laos',
      scientificName: 'Chelon labrosus',
      aliases: ['laos'],
    ),
    TurkishSeaFish(
      slug: 'sokar',
      name: 'Sokar',
      scientificName: 'Solea senegalensis',
      aliases: ['sokar'],
    ),
    TurkishSeaFish(
      slug: 'izmir_kaya',
      name: 'İzmir Kayabalığı',
      scientificName: 'Scorpaena porcus',
      aliases: ['izmir kayabalığı', 'izmir kaya'],
    ),
    TurkishSeaFish(
      slug: 'mene',
      name: 'Mene',
      scientificName: 'Spicara maena',
      aliases: ['mene'],
    ),
    TurkishSeaFish(
      slug: 'sivri',
      name: 'Sivri',
      scientificName: 'Sphyraena sphyraena',
      aliases: ['sivri'],
    ),
    TurkishSeaFish(
      slug: 'turna',
      name: 'Turna',
      scientificName: 'Sphyraena viridensis',
      aliases: ['turna'],
    ),
    TurkishSeaFish(
      slug: 'arapsaci',
      name: 'Arapsaçı',
      scientificName: 'Nemipterus randalli',
      aliases: ['arapsaçı', 'arapsaci'],
    ),
    TurkishSeaFish(
      slug: 'mercan_siyah',
      name: 'Siyahbenek Mercan',
      scientificName: 'Pagellus bogaraveo',
      aliases: ['siyahbenek mercan', 'mercan küçük'],
    ),
    TurkishSeaFish(
      slug: 'fangri',
      name: 'Fangri',
      aliases: ['fangri'],
    ),
    TurkishSeaFish(
      slug: 'kalamar',
      name: 'Kalamar',
      aliases: ['kalamar', 'squid'],
    ),
    TurkishSeaFish(
      slug: 'ahtapot',
      name: 'Ahtapot',
      aliases: ['ahtapot', 'octopus'],
    ),
    TurkishSeaFish(
      slug: 'karides',
      name: 'Karides',
      aliases: ['karides', 'shrimp'],
    ),
    TurkishSeaFish(
      slug: 'istakoz',
      name: 'Istakoz',
      aliases: ['istakoz', 'lobster'],
    ),
    TurkishSeaFish(
      slug: 'lipsoz',
      name: 'Lipsoz',
      aliases: ['lipsoz'],
    ),
    TurkishSeaFish(
      slug: 'ispendek',
      name: 'İspendek',
      aliases: ['ispendek', 'işpendek'],
    ),
    TurkishSeaFish(
      slug: 'lafina',
      name: 'Lafina',
      aliases: ['lafina', 'lafena'],
    ),
    TurkishSeaFish(
      slug: 'pacoz',
      name: 'Paçoz',
      aliases: ['paçoz', 'pacoz'],
    ),
  ];

  /// Slugs that have catalog WebP illustrations (not SVG fallback).
  static const Set<String> photoSlugs = {
    'cipura',
    'levrek',
    'mercan',
    'sinagrit',
    'tranca',
    'karagoz',
    'sargoz',
    'mirmir',
    'minakop',
    'eskina',
    'lahos',
    'orfoz',
    'granyoz',
    'barbun',
    'tekir',
    'kefal',
    'istavrit',
    'hamsi',
    'sardalya',
    'uskumru',
    'kolyoz',
    'palamut',
    'torik',
    'lufer',
    'cinekop',
    'kofana',
    'mezgit',
    'bakalyaro',
    'berlam',
    'kirlangic',
    'iskorpit',
    'kalkan',
    'dil',
    'trakonya',
    'dulger',
    'zargana',
    'gumus',
    'izmarit',
    'kupes',
    'melanur',
    'lahoz',
    'akya',
    'kilic',
    'orkinos',
    'tirsi',
    'caca',
    'horozbina',
    'gelincik',
    'kayabaligi',
    'vatoz',
    'ringa',
    'mersin',
    'laos',
    'sokar',
    'izmir_kaya',
    'mene',
    'sivri',
    'turna',
    'arapsaci',
    'mercan_siyah',
  };

  static const digerAsset = 'assets/fish/diger.svg';

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

  static String assetFor(String? speciesName) {
    final fish = match(speciesName);
    if (fish == null) return digerAsset;
    if (photoSlugs.contains(fish.slug)) return fish.photoAsset;
    return fish.asset;
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
