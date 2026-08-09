import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/mera/turkish_sea_fish_catalog.dart';

/// Species-specific fish artwork — never cross-map assets.
///
/// Çipura / Levrek / Mercan use photographic WebP from the Siren reference.
/// Other catalog species keep distinct SVG silhouettes.
abstract final class SirenFishArt {
  static const _photoAssets = <String, String>{
    'cipura': 'assets/fish/cipura.webp',
    'levrek': 'assets/fish/levrek.webp',
    'mercan': 'assets/fish/mercan.webp',
  };

  static String assetFor(String? speciesName) {
    final matched = TurkishSeaFishCatalog.match(speciesName);
    if (matched != null) {
      final photo = _photoAssets[matched.slug];
      if (photo != null) return photo;
      return matched.asset;
    }
    return TurkishSeaFishCatalog.digerAsset;
  }

  static bool isRaster(String assetPath) =>
      assetPath.endsWith('.webp') ||
      assetPath.endsWith('.png') ||
      assetPath.endsWith('.jpg');

  static Widget image({
    required String? speciesName,
    double height = 72,
    double? width,
    BoxFit fit = BoxFit.contain,
  }) {
    final asset = assetFor(speciesName);
    if (isRaster(asset)) {
      return Image.asset(
        asset,
        height: height,
        width: width,
        fit: fit,
        filterQuality: FilterQuality.high,
      );
    }
    return SvgPicture.asset(
      asset,
      height: height,
      width: width,
      fit: fit,
    );
  }
}
