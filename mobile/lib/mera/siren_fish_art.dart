import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/mera/turkish_sea_fish_catalog.dart';

/// Species-specific fish artwork — never cross-map assets.
abstract final class SirenFishArt {
  static String assetFor(String? speciesName) =>
      TurkishSeaFishCatalog.assetFor(speciesName);

  static Widget image({
    required String? speciesName,
    double height = 72,
    BoxFit fit = BoxFit.contain,
  }) {
    return SvgPicture.asset(
      assetFor(speciesName),
      height: height,
      fit: fit,
    );
  }
}
