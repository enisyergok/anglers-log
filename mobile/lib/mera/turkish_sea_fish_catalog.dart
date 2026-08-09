/// Built-in Turkish sea species (Akdeniz, Ege, Marmara, Karadeniz).
/// Each entry has its own silhouette asset — never cross-mapped.
class TurkishSeaFish {
  const TurkishSeaFish({
    required this.slug,
    required this.name,
    required this.aliases,
  });

  final String slug;
  final String name;
  final List<String> aliases;

  String get asset => 'assets/fish/$slug.svg';
}

abstract final class TurkishSeaFishCatalog {
  static const List<TurkishSeaFish> all = [
    TurkishSeaFish(slug: 'cipura', name: 'Çipura', aliases: ['cipura', 'çupra', 'cupra']),
    TurkishSeaFish(slug: 'levrek', name: 'Levrek', aliases: ['levrek', 'bass', 'seabass']),
    TurkishSeaFish(slug: 'mercan', name: 'Mercan', aliases: ['mercan']),
    TurkishSeaFish(slug: 'lufer', name: 'Lüfer', aliases: ['lüfer', 'lufer', 'bluefish']),
    TurkishSeaFish(slug: 'cinekop', name: 'Çinekop', aliases: ['çinekop', 'cinekop']),
    TurkishSeaFish(slug: 'sarikanat', name: 'Sarıkanat', aliases: ['sarıkanat', 'sarikanat']),
    TurkishSeaFish(slug: 'palamut', name: 'Palamut', aliases: ['palamut', 'bonito']),
    TurkishSeaFish(slug: 'torik', name: 'Torik', aliases: ['torik']),
    TurkishSeaFish(slug: 'orkinos', name: 'Orkinos', aliases: ['orkinos', 'tuna']),
    TurkishSeaFish(slug: 'uskumru', name: 'Uskumru', aliases: ['uskumru', 'mackerel']),
    TurkishSeaFish(slug: 'kolyoz', name: 'Kolyoz', aliases: ['kolyoz']),
    TurkishSeaFish(slug: 'hamsi', name: 'Hamsi', aliases: ['hamsi', 'anchovy']),
    TurkishSeaFish(slug: 'sardalya', name: 'Sardalya', aliases: ['sardalya', 'sardine']),
    TurkishSeaFish(slug: 'caca', name: 'Çaça', aliases: ['çaça', 'caca', 'sprat']),
    TurkishSeaFish(slug: 'istavrit', name: 'İstavrit', aliases: ['istavrit', 'ıstavrit']),
    TurkishSeaFish(slug: 'barbun', name: 'Barbun', aliases: ['barbun', 'barbunya']),
    TurkishSeaFish(slug: 'tekir', name: 'Tekir', aliases: ['tekir']),
    TurkishSeaFish(slug: 'mezgit', name: 'Mezgit', aliases: ['mezgit', 'whiting']),
    TurkishSeaFish(slug: 'kalkan', name: 'Kalkan', aliases: ['kalkan', 'turbot']),
    TurkishSeaFish(slug: 'dil', name: 'Dil', aliases: ['dil balığı', 'dil', 'sole']),
    TurkishSeaFish(slug: 'karagoz', name: 'Karagöz', aliases: ['karagöz', 'karagoz']),
    TurkishSeaFish(slug: 'sargoz', name: 'Sargoz', aliases: ['sargoz', 'sargos']),
    TurkishSeaFish(slug: 'mirmir', name: 'Mırmır', aliases: ['mırmır', 'mirmir']),
    TurkishSeaFish(slug: 'kupes', name: 'Kupes', aliases: ['kupes', 'küpez']),
    TurkishSeaFish(slug: 'izmarit', name: 'İzmarit', aliases: ['izmarit', 'ızmarit']),
    TurkishSeaFish(slug: 'orfoz', name: 'Orfoz', aliases: ['orfoz', 'grouper']),
    TurkishSeaFish(slug: 'lahos', name: 'Lahos', aliases: ['lahos']),
    TurkishSeaFish(slug: 'sinagrit', name: 'Sinagrit', aliases: ['sinagrit', 'sinarit']),
    TurkishSeaFish(slug: 'fangri', name: 'Fangri', aliases: ['fangri']),
    TurkishSeaFish(slug: 'akya', name: 'Akya', aliases: ['akya']),
    TurkishSeaFish(slug: 'kefal', name: 'Kefal', aliases: ['kefal', 'mullet']),
    TurkishSeaFish(slug: 'zargana', name: 'Zargana', aliases: ['zargana', 'needlefish']),
    TurkishSeaFish(slug: 'iskorpit', name: 'İskorpit', aliases: ['iskorpit', 'scorpionfish']),
    TurkishSeaFish(slug: 'kirlangic', name: 'Kırlangıç', aliases: ['kırlangıç', 'kirlangic']),
    TurkishSeaFish(slug: 'minakop', name: 'Minakop', aliases: ['minakop']),
    TurkishSeaFish(slug: 'eskina', name: 'Eşkina', aliases: ['eşkina', 'eskina']),
    TurkishSeaFish(slug: 'granyoz', name: 'Granyöz', aliases: ['granyöz', 'granyoz']),
    TurkishSeaFish(slug: 'vatoz', name: 'Vatoz', aliases: ['vatoz', 'ray']),
    TurkishSeaFish(slug: 'kalamar', name: 'Kalamar', aliases: ['kalamar', 'squid']),
    TurkishSeaFish(slug: 'ahtapot', name: 'Ahtapot', aliases: ['ahtapot', 'octopus']),
    TurkishSeaFish(slug: 'karides', name: 'Karides', aliases: ['karides', 'shrimp']),
    TurkishSeaFish(slug: 'istakoz', name: 'Istakoz', aliases: ['istakoz', 'lobster']),
    TurkishSeaFish(slug: 'lipsoz', name: 'Lipsoz', aliases: ['lipsoz']),
    TurkishSeaFish(slug: 'gelincik', name: 'Gelincik', aliases: ['gelincik']),
    TurkishSeaFish(slug: 'horozbina', name: 'Horozbina', aliases: ['horozbina']),
    TurkishSeaFish(slug: 'kayabaligi', name: 'Kayabalığı', aliases: ['kayabalığı', 'kayabaligi']),
    TurkishSeaFish(slug: 'ispendek', name: 'İspendek', aliases: ['ispendek', 'işpendek']),
    TurkishSeaFish(slug: 'melanur', name: 'Melanur', aliases: ['melanur', 'melanurya']),
    TurkishSeaFish(slug: 'lafina', name: 'Lafina', aliases: ['lafina', 'lafena']),
    TurkishSeaFish(slug: 'pacoz', name: 'Paçoz', aliases: ['paçoz', 'pacoz']),
    TurkishSeaFish(slug: 'gumus', name: 'Gümüş', aliases: ['gümüş', 'gumus']),
    TurkishSeaFish(slug: 'trakonya', name: 'Trakonya', aliases: ['trakonya', 'trahonya']),
  ];

  static const digerAsset = 'assets/fish/diger.svg';

  static TurkishSeaFish? match(String? speciesName) {
    final n = _normalize(speciesName);
    if (n.isEmpty) return null;
    for (final fish in all) {
      if (_normalize(fish.name) == n) return fish;
      for (final alias in fish.aliases) {
        if (_normalize(alias) == n) return fish;
      }
    }
    // Contains match for compound names like "Dil balığı".
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

  static String assetFor(String? speciesName) =>
      match(speciesName)?.asset ?? digerAsset;

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
