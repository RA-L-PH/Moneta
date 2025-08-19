import 'package:flutter/material.dart';

class AppTheme {
  // Light Theme Colors - "Professional & Fresh"
  static const Color _lightPrimary = Color(
    0xFF4A90E2,
  ); // Vibrant professional blue
  static const Color _lightSecondary = Color(0xFF50C878); // Earthy green
  static const Color _lightBackground = Color(
    0xFFF5F7FA,
  ); // Light gray/off-white
  static const Color _lightSurface = Color(0xFFFFFFFF); // Pure white
  static const Color _lightText = Color(0xFF2C3E50); // Dark readable charcoal

  // Dark Theme Colors - "Modern & Sleek"
  static const Color _darkPrimary = Color(0xFF00ADB5); // Striking deep teal
  static const Color _darkSecondary = Color(0xFFFFD700); // Warm golden yellow
  static const Color _darkBackground = Color(
    0xFF1D2635,
  ); // Dark muted blue/gray
  static const Color _darkSurface = Color(
    0xFF2A3A4C,
  ); // Slightly lighter surface
  static const Color _darkText = Color(0xFFEAEAEA); // Light soft gray

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: _lightPrimary,
      secondary: _lightSecondary,
      surface: _lightSurface,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: _lightText,
      error: Color(0xFFE53E3E),
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: _lightBackground,
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 0,
      backgroundColor: _lightBackground,
      foregroundColor: _lightText,
      titleTextStyle: TextStyle(
        color: _lightText,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    cardTheme: CardTheme(
      color: _lightSurface,
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _lightPrimary,
      foregroundColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _lightPrimary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _lightPrimary,
        side: const BorderSide(color: _lightPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: _lightPrimary),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _lightPrimary, width: 2),
      ),
      filled: true,
      fillColor: _lightSurface,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: _lightSurface,
      selectedItemColor: _lightPrimary,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    dividerTheme: DividerThemeData(color: Colors.grey.shade200, thickness: 1),
  );

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: _darkPrimary,
      secondary: _darkSecondary,
      surface: _darkSurface,
      onPrimary: Colors.black,
      onSecondary: Colors.black,
      onSurface: _darkText,
      error: Color(0xFFFF6B6B),
      onError: Colors.black,
    ),
    scaffoldBackgroundColor: _darkBackground,
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 0,
      backgroundColor: _darkBackground,
      foregroundColor: _darkText,
      titleTextStyle: TextStyle(
        color: _darkText,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    cardTheme: CardTheme(
      color: _darkSurface,
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _darkPrimary,
      foregroundColor: Colors.black,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _darkPrimary,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _darkPrimary,
        side: const BorderSide(color: _darkPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: _darkPrimary),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade600),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade600),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _darkPrimary, width: 2),
      ),
      filled: true,
      fillColor: _darkSurface,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: _darkSurface,
      selectedItemColor: _darkPrimary,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    dividerTheme: DividerThemeData(color: Colors.grey.shade700, thickness: 1),
  );

  // Helper methods for accessing theme colors in widgets
  static Color getIncomeColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? _lightSecondary
        : _darkPrimary;
  }

  static Color getExpenseColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? const Color(0xFFE53E3E)
        : _darkSecondary;
  }

  static Color getSuccessColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? _lightSecondary
        : _darkPrimary;
  }

  static Color getWarningColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? const Color(0xFFED8936)
        : _darkSecondary;
  }
}
