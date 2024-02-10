import 'package:flutter/material.dart';
import 'package:lang_compare/app_theme/app_fonts.dart';

class AppTheme {
  static ThemeData lightMode(ColorScheme? colorScheme) {
    ColorScheme scheme = colorScheme ??
        ColorScheme.fromSeed(
          seedColor: const Color(0xFF52DEE5),
        );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      textTheme: appFont,
    );
  }

  static ThemeData darkMode(ColorScheme? colorScheme) {
    ColorScheme scheme = colorScheme ??
        ColorScheme.fromSeed(
          seedColor: const Color(0xFF52DEE5),
          brightness: Brightness.dark,
        );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      textTheme: appFont,
    );
  }
}
