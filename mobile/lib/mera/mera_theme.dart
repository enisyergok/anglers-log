import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Exact visual tokens from the Mera Asistanı mockup.
abstract final class MeraColors {
  static const bg = Color(0xFF0A0F1A);
  static const bgElevated = Color(0xFF0F1624);
  static const card = Color(0xFF141C2C);
  static const cardElevated = Color(0xFF1A2336);
  static const cardBorder = Color(0xFF2A3548);
  static const surface = Color(0xFF1C2638);

  static const textPrimary = Color(0xFFF5F7FB);
  static const textSecondary = Color(0xFFA0ADC2);
  static const textMuted = Color(0xFF6E7C93);

  /// Primary CTA green from mockup.
  static const green = Color(0xFF1FCB6A);
  static const greenGlow = Color(0x661FCB6A);
  static const greenDark = Color(0xFF149A4E);

  /// Secondary CTA blue from mockup.
  static const blue = Color(0xFF2F7BFF);
  static const blueGlow = Color(0x662F7BFF);
  static const blueDark = Color(0xFF1E5FD1);

  static const danger = Color(0xFFFF4D5E);
  static const warning = Color(0xFFFFB020);

  static const searchFill = Color(0xD9121A2A);
  static const hudGlass = Color(0xE60F1624);
  static const modalScrim = Color(0x99000000);
}

abstract final class MeraRadii {
  static const sm = 10.0;
  static const md = 14.0;
  static const lg = 18.0;
  static const xl = 24.0;
  static const pill = 999.0;
}

abstract final class MeraSpace {
  static const xs = 6.0;
  static const sm = 10.0;
  static const md = 16.0;
  static const lg = 20.0;
  static const xl = 28.0;
}

ThemeData meraTheme() {
  final baseText = GoogleFonts.plusJakartaSansTextTheme(
    ThemeData(brightness: Brightness.dark).textTheme,
  );

  final textTheme = baseText.apply(
    bodyColor: MeraColors.textPrimary,
    displayColor: MeraColors.textPrimary,
  );

  const scheme = ColorScheme.dark(
    primary: MeraColors.green,
    onPrimary: Colors.white,
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
      titleTextStyle: GoogleFonts.plusJakartaSans(
        color: MeraColors.textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: MeraColors.bgElevated,
      selectedItemColor: MeraColors.green,
      unselectedItemColor: MeraColors.textMuted,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedLabelStyle: GoogleFonts.plusJakartaSans(
        fontSize: 10,
        fontWeight: FontWeight.w700,
      ),
      unselectedLabelStyle: GoogleFonts.plusJakartaSans(
        fontSize: 10,
        fontWeight: FontWeight.w500,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: MeraColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      hintStyle: GoogleFonts.plusJakartaSans(
        color: MeraColors.textMuted,
        fontSize: 14,
      ),
      labelStyle: GoogleFonts.plusJakartaSans(
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
        borderSide: const BorderSide(color: MeraColors.green, width: 1.5),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: MeraColors.cardElevated,
      contentTextStyle: GoogleFonts.plusJakartaSans(
        color: MeraColors.textPrimary,
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(MeraRadii.md),
      ),
    ),
  );
}
