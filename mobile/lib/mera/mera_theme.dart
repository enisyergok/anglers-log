import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Siren dark marine design tokens (reference fidelity).
abstract final class MeraColors {
  static const bg = Color(0xFF02111B);
  static const bgElevated = Color(0xFF041722);
  static const card = Color(0xFF071A27);
  static const cardElevated = Color(0xFF0A2231);
  static const cardBorder = Color(0xFF193947);
  static const borderSecondary = Color(0xFF23404E);
  static const surface = Color(0xFF0A2231);

  static const textPrimary = Color(0xFFF1F7F9);
  static const textSecondary = Color(0xFF8098A5);
  static const textMuted = Color(0xFF6F8793);

  static const green = Color(0xFF27D46C);
  static const greenGlow = Color(0x6627D46C);
  static const greenDark = Color(0xFF1AA853);

  static const blue = Color(0xFF1198EE);
  static const blueGlow = Color(0x661198EE);
  static const blueDark = Color(0xFF0D7BC4);

  static const danger = Color(0xFFFF514B);
  static const warning = Color(0xFFFFD22F);

  static const searchFill = Color(0xD9061B28);
  static const hudGlass = Color(0xE6071D2A);
  static const modalScrim = Color(0x99000000);
}

/// Reference base radii 8â€“12px.
abstract final class MeraRadii {
  static const sm = 8.0;
  static const md = 10.0;
  static const lg = 12.0;
  static const xl = 16.0;
  static const pill = 999.0;
}

abstract final class MeraSpace {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const xxl = 24.0;
}

/// Reference phone ~462Ã—859 â†’ proportional helpers.
abstract final class SirenScale {
  static const refW = 462.0;
  static const refH = 859.0;

  static double of(BuildContext context, double refPx) {
    final w = MediaQuery.sizeOf(context).width;
    return refPx * (w / refW);
  }

  static double clampOf(
    BuildContext context,
    double refPx, {
    double min = 0,
    double? max,
  }) {
    final v = of(context, refPx);
    if (max != null) return v.clamp(min, max);
    return v < min ? min : v;
  }
}

ThemeData meraTheme() {
  final baseText = GoogleFonts.interTextTheme(
    ThemeData(brightness: Brightness.dark).textTheme,
  );

  final textTheme = baseText.apply(
    bodyColor: MeraColors.textPrimary,
    displayColor: MeraColors.textPrimary,
  );

  const scheme = ColorScheme.dark(
    primary: MeraColors.green,
    onPrimary: Color(0xFF002511),
    secondary: MeraColors.blue,
    onSecondary: Colors.white,
    surface: MeraColors.bg,
    onSurface: MeraColors.textPrimary,
    error: MeraColors.danger,
    onError: Colors.white,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: scheme,
    scaffoldBackgroundColor: MeraColors.bg,
    canvasColor: MeraColors.bg,
    cardColor: MeraColors.card,
    dividerColor: MeraColors.cardBorder,
    splashFactory: InkRipple.splashFactory,
    textTheme: textTheme,
    primaryTextTheme: textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: MeraColors.bg,
      foregroundColor: MeraColors.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: GoogleFonts.inter(
        color: MeraColors.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: MeraColors.bgElevated,
      selectedItemColor: MeraColors.blue,
      unselectedItemColor: MeraColors.textMuted,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedLabelStyle: GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w500,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: MeraColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      hintStyle: GoogleFonts.inter(
        color: MeraColors.textMuted,
        fontSize: 14,
      ),
      labelStyle: GoogleFonts.inter(
        color: MeraColors.textSecondary,
        fontSize: 13,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(MeraRadii.md),
        borderSide: const BorderSide(color: MeraColors.cardBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(MeraRadii.md),
        borderSide: const BorderSide(color: MeraColors.cardBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(MeraRadii.md),
        borderSide: const BorderSide(color: MeraColors.blue, width: 1.5),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: MeraColors.cardElevated,
      contentTextStyle: GoogleFonts.inter(color: MeraColors.textPrimary),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(MeraRadii.md),
      ),
    ),
  );
}
