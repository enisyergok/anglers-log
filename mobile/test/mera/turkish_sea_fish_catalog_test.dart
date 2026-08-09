import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/mera/siren_fish_art.dart';
import 'package:mobile/mera/turkish_sea_fish_catalog.dart';

void main() {
  final fishDir = Directory('assets/fish');

  test('ids and slugs are unique', () {
    expect(TurkishSeaFishCatalog.validateUniqueIds(), isEmpty);
    expect(TurkishSeaFishCatalog.validateUniqueSlugs(), isEmpty);
  });

  test('every catalog species maps to an EXISTING asset file', () {
    expect(fishDir.existsSync(), isTrue);
    for (final fish in TurkishSeaFishCatalog.all) {
      final relative = fish.imageAsset.replaceFirst('assets/fish/', '');
      final file = File('${fishDir.path}/$relative');
      expect(
        file.existsSync(),
        isTrue,
        reason: '${fish.id} → ${fish.imageAsset} missing on disk',
      );
      // SVG silhouette must always exist for the slug.
      expect(
        File('${fishDir.path}/${fish.slug}.svg').existsSync(),
        isTrue,
        reason: '${fish.slug}.svg missing',
      );
    }
  });

  test('photo species keep original Siren webp paths only', () {
    expect(
      TurkishSeaFishCatalog.byId('sparus-aurata')?.imageAsset,
      'assets/fish/cipura.webp',
    );
    expect(
      TurkishSeaFishCatalog.byId('dicentrarchus-labrax')?.imageAsset,
      'assets/fish/levrek.webp',
    );
    expect(
      TurkishSeaFishCatalog.byId('pagellus-erythrinus')?.imageAsset,
      'assets/fish/mercan.webp',
    );
    expect(TurkishSeaFishCatalog.existingPhotoSlugs, {
      'cipura',
      'levrek',
      'mercan',
    });
  });

  test('non-photo species use their own svg — never cipura/generic', () {
    expect(SirenFishArt.assetFor('Lüfer'), 'assets/fish/lufer.svg');
    expect(SirenFishArt.assetFor('Palamut'), 'assets/fish/palamut.svg');
    expect(SirenFishArt.assetFor('Hamsi'), 'assets/fish/hamsi.svg');
    expect(SirenFishArt.assetFor('Kalamar'), 'assets/fish/kalamar.svg');
    expect(SirenFishArt.assetFor('bass'), 'assets/fish/levrek.webp');
  });

  test('unknown species does not steal another species art', () {
    expect(SirenFishArt.assetFor('Bilinmeyen'), 'assets/fish/diger.svg');
    expect(SirenFishArt.assetFor(null), 'assets/fish/diger.svg');
  });

  test('no catalog entry points at another species slug', () {
    for (final fish in TurkishSeaFishCatalog.all) {
      expect(fish.imageAsset.contains('/${fish.slug}.'), isTrue);
    }
  });
}
