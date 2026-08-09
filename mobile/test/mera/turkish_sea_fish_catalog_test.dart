import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/mera/siren_fish_art.dart';
import 'package:mobile/mera/turkish_sea_fish_catalog.dart';

void main() {
  test('each catalog fish has unique slug', () {
    final slugs = TurkishSeaFishCatalog.all.map((f) => f.slug).toSet();
    expect(slugs.length, TurkishSeaFishCatalog.all.length);
  });

  test('aliases resolve to correct fish, never cross-map', () {
    expect(TurkishSeaFishCatalog.assetFor('Lüfer'), 'assets/fish/lufer.webp');
    expect(
      TurkishSeaFishCatalog.assetFor('çinekop'),
      'assets/fish/cinekop.webp',
    );
    expect(TurkishSeaFishCatalog.assetFor('bass'), 'assets/fish/levrek.webp');
    expect(TurkishSeaFishCatalog.assetFor('Hamsi'), 'assets/fish/hamsi.webp');
    expect(
      TurkishSeaFishCatalog.assetFor('Siyahbenek Mercan'),
      'assets/fish/mercan_siyah.webp',
    );
    expect(
      TurkishSeaFishCatalog.assetFor('Mercan'),
      'assets/fish/mercan.webp',
    );
    expect(TurkishSeaFishCatalog.assetFor('Bilinmeyen'), 'assets/fish/diger.svg');
  });

  test('photo species resolve via SirenFishArt to webp', () {
    expect(SirenFishArt.assetFor('Çipura'), 'assets/fish/cipura.webp');
    expect(SirenFishArt.assetFor('Levrek'), 'assets/fish/levrek.webp');
    expect(SirenFishArt.assetFor('Mercan'), 'assets/fish/mercan.webp');
    expect(SirenFishArt.assetFor('Palamut'), 'assets/fish/palamut.webp');
    expect(SirenFishArt.assetFor('Lüfer'), 'assets/fish/lufer.webp');
  });

  test('species without catalog photo keep svg', () {
    expect(SirenFishArt.assetFor('Kalamar'), 'assets/fish/kalamar.svg');
    expect(SirenFishArt.assetFor('Ahtapot'), 'assets/fish/ahtapot.svg');
  });

  test('scientific names present for primary activity species', () {
    final cipura = TurkishSeaFishCatalog.match('Çipura');
    expect(cipura?.scientificName, 'Sparus aurata');
    final levrek = TurkishSeaFishCatalog.match('Levrek');
    expect(levrek?.scientificName, 'Dicentrarchus labrax');
  });
}
