import 'package:flutter/material.dart';

/// Single source of truth for colours, typography and component styles.
class AppTheme {
  static const Color primary = Color(0xFF1D3665); // SafeHaven navy
  static const Color accent =
      Color(0xFFC93A30); // SafeHaven brand red (logo, selected tab)
  static const Color info =
      Color(0xFF2F6FED); // light blue for neutral highlights
  static const Color ok = Color(0xFF2E7D32);
  static const Color warn = Color(0xFFEF6C00);
  static const Color danger = Color(0xFFC62828);
  static const Color surface = Color(0xFFF3F6FB);
  static const Color ink = Color(0xFF14233F);
  static const Color muted = Color(0xFF4F5F75);

  static final ThemeData light = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      secondary: accent,
    ),
    scaffoldBackgroundColor: surface,
    textTheme: const TextTheme(
      headlineMedium: TextStyle(
          fontSize: 26, fontWeight: FontWeight.w800, color: ink, height: 1.2),
      titleLarge:
          TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: ink),
      titleMedium:
          TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: ink),
      bodyMedium: TextStyle(fontSize: 14, color: ink, height: 1.4),
      bodySmall: TextStyle(fontSize: 12.5, color: muted),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
          fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primary,
        minimumSize: const Size.fromHeight(50),
        side: const BorderSide(color: primary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: accent,
      unselectedItemColor: muted,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
    ),
  );

  /// Reusable card decoration (Container + BoxDecoration: radius, border, shadow).
  static BoxDecoration card({Color color = Colors.white}) => BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      );
}
