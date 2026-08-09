import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/mera/turkish_sea_fish_catalog.dart';

/// Species-specific fish artwork — never cross-map assets.
///
/// Catalog grid WebP illustrations are preferred when available; otherwise
/// distinct SVG silhouettes are used.
abstract final class SirenFishArt {
  static String assetFor(String? speciesName) =>
      TurkishSeaFishCatalog.assetFor(speciesName);

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
