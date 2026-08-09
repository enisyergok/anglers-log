import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Mera Asistanı visual tokens — matches the product mockup.
abstract final class MeraColors {
  static const bg = Color(0xFF0B1220);
  static const bgElevated = Color(0xFF121A2A);
  static const card = Color(0xFF162033);
  static const cardBorder = Color(0xFF243049);
  static const surface = Color(0xFF1A2438);

  static const textPrimary = Color(0xFFF2F6FC);
  static const textSecondary = Color(0xFF9AA8BC);
  static const textMuted = Color(0xFF6B7A90);

  static const green = Color(0xFF22C55E);
  static const greenDark = Color(0xFF16A34A);
  static const blue = Color(0xFF3B82F6);
  static const blueDark = Color(0xFF2563EB);
  static const danger = Color(0xFFEF4444);
  static const warning = Color(0xFFF59E0B);

  static const searchFill = Color(0xCC121A2A);
  static const hudGlass = Color(0xE6121A2A);
}

ThemeData meraTheme() {
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

  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: scheme,
    scaffoldBackgroundColor: MeraColors.bg,
    canvasColor: MeraColors.bg,
    cardColor: MeraColors.card,
    dividerColor: MeraColors.cardBorder,
    splashFactory: InkRipple.splashFactory,
    fontFamily: 'Roboto', // overridden below via textTheme letter-spacing
    appBarTheme: const AppBarTheme(
      backgroundColor: MeraColors.bg,
      foregroundColor: MeraColors.textPrimary,
      elevation: 0,
      centerTitle: false,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: TextStyle(
        color: MeraColors.textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: MeraColors.bgElevated,
      selectedItemColor: MeraColors.green,
      unselectedItemColor: MeraColors.textMuted,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: MeraColors.surface,
      hintStyle: const TextStyle(color: MeraColors.textMuted),
      labelStyle: const TextStyle(color: MeraColors.textSecondary),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: MeraColors.cardBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: MeraColors.cardBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: MeraColors.green, width: 1.5),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: MeraColors.card,
      contentTextStyle: const TextStyle(color: MeraColors.textPrimary),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );

  return base.copyWith(
    textTheme: base.textTheme.apply(
      bodyColor: MeraColors.textPrimary,
      displayColor: MeraColors.textPrimary,
    ),
  );
}
