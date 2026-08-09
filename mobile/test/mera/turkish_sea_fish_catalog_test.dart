import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/mera/siren_fish_art.dart';
import 'package:mobile/mera/turkish_sea_fish_catalog.dart';

void main() {
  test('each catalog fish has its own asset', () {
    final assets = TurkishSeaFishCatalog.all.map((f) => f.asset).toSet();
    expect(assets.length, TurkishSeaFishCatalog.all.length);
    for (final fish in TurkishSeaFishCatalog.all) {
      expect(fish.asset, 'assets/fish/${fish.slug}.svg');
      expect(TurkishSeaFishCatalog.assetFor(fish.name), fish.asset);
    }
  });

  test('aliases resolve to correct fish, never cross-map', () {
    expect(TurkishSeaFishCatalog.assetFor('Lüfer'), 'assets/fish/lufer.svg');
    expect(TurkishSeaFishCatalog.assetFor('çinekop'), 'assets/fish/cinekop.svg');
    expect(TurkishSeaFishCatalog.assetFor('bass'), 'assets/fish/levrek.svg');
    expect(TurkishSeaFishCatalog.assetFor('Hamsi'), 'assets/fish/hamsi.svg');
    expect(TurkishSeaFishCatalog.assetFor('Bilinmeyen'), 'assets/fish/diger.svg');
  });

  test('photo species resolve via SirenFishArt to webp', () {
    expect(SirenFishArt.assetFor('Çipura'), 'assets/fish/cipura.webp');
    expect(SirenFishArt.assetFor('Levrek'), 'assets/fish/levrek.webp');
    expect(SirenFishArt.assetFor('Mercan'), 'assets/fish/mercan.webp');
    expect(SirenFishArt.assetFor('Lüfer'), 'assets/fish/lufer.svg');
  });
}
