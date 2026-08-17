import 'dart:math';

import 'package:adair_flutter_lib/utils/color.dart';
import 'package:flutter/material.dart';

Color randomAccentColor() {
  var colors = accentColors();
  return colors[Random().nextInt(colors.length)];
}

extension ColorShades on Color {
  /// Returns a darker shade of this color by [amount] (0.0 - 1.0), used to
  /// build subtle gradients for elevated card-style widgets.
  Color darken([double amount = 0.18]) {
    var hsl = HSLColor.fromColor(this);
    return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
  }

  /// Returns a lighter shade of this color by [amount] (0.0 - 1.0).
  Color lighten([double amount = 0.18]) {
    var hsl = HSLColor.fromColor(this);
    return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
  }
}
