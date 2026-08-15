import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  // ─── Moneta v2.0 Color Palette ──────────────────────────────────────────
  static const Color brandPrimary = Color(0xFF188C4A);
  static const Color brandSecondary = Color(0xFF297349);
  static const Color brandMuted = Color(0xFF648C75);
  static const Color brandAccent = Color(0xFF0DF205);
  static const Color brandDark = Color(0xFF0D0D0D);

  // Light palette
  static const Color _lightPrimary = Color(0xFF188C4A);
  static const Color _lightPrimarySoft = Color(0xFFE8F5EC);
  static const Color _lightSecondary = Color(0xFF297349);
  static const Color _lightBackground = Color(0xFFF2F2F7);
  static const Color _lightSurface = Color(0xFFFFFFFF);
  static const Color _lightTextPrimary = Color(0xFF1C1C1E);
  static const Color _lightTextSecondary = Color(0xFF6E6E73);
  static const Color _lightTextTertiary = Color(0xFFAEAEB2);
  static const Color _lightDivider = Color(0xFFE5E5EA);
  static const Color _lightInputFill = Color(0xFFF2F2F7);
  static const Color _lightCardBorder = Color(0xFFE8E8ED);

  // Dark palette
  static const Color _darkPrimary = brandAccent;
  static const Color _darkSecondary = brandPrimary;
  static const Color _darkBackground = brandDark;
  static const Color _darkSurface = Color(0xFF1C1C1E);
  static const Color _darkText = Color(0xFFFFFFFF);

  // ═══════════════════════════════════════════════════════════════════════════
  // LIGHT THEME
  // ═══════════════════════════════════════════════════════════════════════════

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: _lightBackground,
    colorScheme: const ColorScheme.light(
      primary: _lightPrimary,
      onPrimary: Colors.white,
      secondary: _lightSecondary,
      onSecondary: Colors.white,
      surface: _lightSurface,
      onSurface: _lightTextPrimary,
      error: Color(0xFFFF3B30),
      onError: Colors.white,
      surfaceContainerHighest: Color(0xFFE5E5EA),
      onSurfaceVariant: _lightTextSecondary,
      outlineVariant: _lightDivider,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: _lightTextPrimary,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: _lightBackground,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      titleTextStyle: TextStyle(
        color: _lightTextPrimary,
        fontSize: 17,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
      ),
    ),
    cardTheme: CardThemeData(
      color: _lightSurface,
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: _lightCardBorder, width: 0.5),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: _lightPrimary,
      foregroundColor: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _lightPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _lightPrimary,
        side: const BorderSide(color: Color(0xFFD1E6D9)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _lightPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _lightDivider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _lightDivider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _lightPrimary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFFF3B30)),
      ),
      filled: true,
      fillColor: _lightInputFill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: const TextStyle(color: _lightTextTertiary),
    ),
    dividerTheme: const DividerThemeData(
      color: _lightDivider,
      thickness: 0.5,
      space: 0.5,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: _lightTextPrimary,
      contentTextStyle: const TextStyle(color: Colors.white),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return Colors.white;
        return const Color(0xFFE0E0E0);
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return _lightPrimary;
        return const Color(0xFFE0E0E0);
      }),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: _lightInputFill,
      selectedColor: _lightPrimarySoft,
      side: const BorderSide(color: _lightDivider),
      labelStyle: const TextStyle(color: _lightTextPrimary, fontSize: 13),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    ),
    tabBarTheme: const TabBarThemeData(
      labelColor: _lightPrimary,
      unselectedLabelColor: _lightTextSecondary,
      indicatorColor: _lightPrimary,
      dividerColor: _lightDivider,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: _lightSurface,
      selectedItemColor: _lightPrimary,
      unselectedItemColor: _lightTextTertiary,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: _lightSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: _lightSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // DARK THEME
  // ═══════════════════════════════════════════════════════════════════════════

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: _darkBackground,
    colorScheme: const ColorScheme.dark(
      primary: _darkPrimary,
      onPrimary: brandDark,
      secondary: _darkSecondary,
      onSecondary: Colors.white,
      surface: _darkSurface,
      onSurface: _darkText,
      error: Color(0xFFFF453A),
      onError: Colors.white,
      surfaceContainerHighest: Color(0xFF2C2C2E),
      onSurfaceVariant: brandMuted,
      outlineVariant: Color(0xFF38383A),
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: _darkText,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light,
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: _darkBackground,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      titleTextStyle: TextStyle(
        color: _darkText,
        fontSize: 17,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
      ),
    ),
    cardTheme: CardThemeData(
      color: _darkSurface,
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.06), width: 0.5),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: _darkPrimary,
      foregroundColor: brandDark,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _darkPrimary,
        foregroundColor: brandDark,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _darkPrimary,
        side: BorderSide(color: _darkPrimary.withValues(alpha: 0.3)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _darkPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _darkPrimary, width: 1.5),
      ),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.06),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    dividerTheme: DividerThemeData(
      color: Colors.white.withValues(alpha: 0.08),
      thickness: 0.5,
      space: 0.5,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: _darkSurface,
      contentTextStyle: const TextStyle(color: Colors.white),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return brandDark;
        return const Color(0xFF636366);
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return _darkPrimary;
        return const Color(0xFF38383A);
      }),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.white.withValues(alpha: 0.06),
      selectedColor: brandPrimary.withValues(alpha: 0.2),
      side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
      labelStyle: const TextStyle(color: _darkText, fontSize: 13),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    ),
    tabBarTheme: const TabBarThemeData(
      labelColor: _darkPrimary,
      unselectedLabelColor: brandMuted,
      indicatorColor: _darkPrimary,
      dividerColor: Color(0xFF38383A),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: _darkSurface,
      selectedItemColor: _darkPrimary,
      unselectedItemColor: brandMuted,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: _darkSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: _darkSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // HELPER COLORS
  // ═══════════════════════════════════════════════════════════════════════════

  static Color getIncomeColor(BuildContext context) {
    return isDark(context) ? brandAccent : const Color(0xFF188C4A);
  }

  static Color getExpenseColor(BuildContext context) {
    return isDark(context) ? const Color(0xFFFF453A) : const Color(0xFFFF3B30);
  }

  static Color getSuccessColor(BuildContext context) {
    return isDark(context) ? brandAccent : const Color(0xFF188C4A);
  }

  static Color getWarningColor(BuildContext context) {
    return isDark(context) ? const Color(0xFFFF9F0A) : const Color(0xFFFF9500);
  }

  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color glassBackground(BuildContext context) =>
      isDark(context)
          ? Colors.white.withValues(alpha: 0.06)
          : Colors.white.withValues(alpha: 0.75);

  static Color glassBorder(BuildContext context) =>
      isDark(context)
          ? Colors.white.withValues(alpha: 0.08)
          : const Color(0xFFE8E8ED);
}
