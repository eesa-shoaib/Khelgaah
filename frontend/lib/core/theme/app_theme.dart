import 'package:flutter/material.dart';

class AppTheme {
  static const Color background = Color(0xFF121212);
  static const Color surface = Color(0xFF1D1D1D);

  static const Color textPrimary = Color(0xFFB4B4B4);
  static const Color textSecondary = Color(0xFF949494);

  static const Color redPrimary = Color(0xFFB14242); // red_ember
  static const Color redGlow = Color(0xFFDF6464); // red_glowing

  static const Color orangePrimary = Color(0xFFC4693D); // orange_blaze
  static const Color orangeAccent = Color(0xFFE5A72A); // orange_golden
  static const Color orangeSoft = Color(0xFFE49A44); // orange_smolder

  static const Color error = Color(0xFFC53030); // red_flame

  static const Color divider = orangePrimary;

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,

    fontFamily: 'DMMono',

    scaffoldBackgroundColor: background,

    colorScheme: const ColorScheme.dark(
      primary: orangePrimary,
      secondary: orangeAccent,
      surface: surface,
      error: error,
    ),
    splashFactory: NoSplash.splashFactory,
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    hoverColor: Colors.transparent,

    appBarTheme: const AppBarTheme(
      backgroundColor: background,
      foregroundColor: textPrimary,
      elevation: 0,
    ),

    textTheme: const TextTheme(
      titleLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w500),
      bodyLarge: TextStyle(color: textPrimary),
      bodyMedium: TextStyle(color: textSecondary),
    ),

    dividerColor: divider,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: orangePrimary,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: surface,
      selectedItemColor: orangePrimary,
      unselectedItemColor: textSecondary,
      selectedIconTheme: IconThemeData(size: 24),
      unselectedIconTheme: IconThemeData(size: 24),
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500),
      elevation: 8,
      type: BottomNavigationBarType.fixed,
      showUnselectedLabels: true,
      enableFeedback: false,
    ),
    listTileTheme: const ListTileThemeData(
      iconColor: orangePrimary,
      textColor: textPrimary,
      tileColor: Colors.transparent,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      titleTextStyle: const TextStyle(
        color: textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      contentTextStyle: const TextStyle(color: textSecondary, fontSize: 14),
    ),

    cardColor: surface,
  );
}

// Core Design Principles

// Think of your UI in 3 layers:

// 1. Background (base)

// Always: background (#121212)
// Clean, minimal, no noise

// 2. Surfaces (cards, sections)

// Use: surface (#1d1d1d)
// Slight contrast from background

// 3. Accents (actions)

// Primary action → orange_blaze (#C4693D)
// Secondary → orange_golden (#E5A72A)
// Important → red_ember (#B14242)

// Rule (very important)

// Color = meaning
// Orange → user can act
// Red → important / destructive / highlight
// Grey → passive / info
