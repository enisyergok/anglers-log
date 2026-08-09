import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Species-specific fish artwork — never cross-map assets.
abstract final class SirenFishArt {
  static const cipura = 'assets/fish/cipura.svg';
  static const levrek = 'assets/fish/levrek.svg';
  static const mercan = 'assets/fish/mercan.svg';

  static String assetFor(String? speciesName) {
    final n = (speciesName ?? '').toLowerCase();
    if (n.contains('levrek') || n.contains('bass')) return levrek;
    if (n.contains('mercan') || n.contains('red')) return mercan;
    return cipura;
  }

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
